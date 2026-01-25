import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;
import '../core/logger.dart';
import '../config/routes.dart';
import 'session_service.dart';
import 'local_notification_service.dart';

/// Firebase Cloud Messaging Service for device token management
class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final SessionService _sessionService = SessionService();
  final LocalNotificationService _localNotificationService =
      LocalNotificationService();

  String? _token;
  String? get token => _token;

  /// Initialize FCM and request notification permissions
  Future<void> initialize() async {
    try {
      // Initialize local notifications first
      await _localNotificationService.initialize();

      // Request notification permissions based on platform
      if (Platform.isAndroid) {
        // For Android 13+ (API 33+), request runtime permission
        final androidInfo = await _getAndroidVersion();
        if (androidInfo >= 33) {
          final status = await Permission.notification.request();
          AppLogger.info('Android 13+ notification permission status: $status');

          if (status.isGranted) {
            AppLogger.info('✅ Android notification permissions granted');
          } else if (status.isDenied) {
            AppLogger.warning('⚠️ Android notification permissions denied');
          } else if (status.isPermanentlyDenied) {
            AppLogger.warning(
              '❌ Android notification permissions permanently denied',
            );
          }
        } else {
          AppLogger.info('Android version < 13, no runtime permission needed');
        }
      } else {
        // iOS permission request
        final settings = await _messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: false,
        );

        AppLogger.info(
          'Notification permission status: ${settings.authorizationStatus}',
        );

        if (settings.authorizationStatus == AuthorizationStatus.authorized) {
          AppLogger.info('✅ Notification permissions granted');
        } else if (settings.authorizationStatus ==
            AuthorizationStatus.provisional) {
          AppLogger.info('⚠️ Notification permissions provisionally granted');
        } else {
          AppLogger.warning(
            '❌ Notification permissions denied: ${settings.authorizationStatus}',
          );
        }
      }

      // Set iOS notification presentation options for foreground notifications
      // This ensures notifications show even when app is in foreground
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      AppLogger.info('✅ iOS foreground notification presentation options set');

      // Get FCM token
      await _getToken();

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        _token = newToken;
        AppLogger.info('FCM token refreshed');
        _saveTokenToFirestore(newToken);
      });

      // Setup message handlers
      _setupMessageHandlers();
    } catch (e) {
      AppLogger.error('Error initializing FCM', e);
    }
  }

  /// Get FCM token and save to Firestore
  Future<void> _getToken() async {
    try {
      _token = await _messaging.getToken();
      if (_token != null) {
        AppLogger.info('FCM Token obtained: ${_token!.substring(0, 20)}...');
        await _saveTokenToFirestore(_token!);
      }
    } catch (e) {
      AppLogger.error('Error getting FCM token', e);
    }
  }

  /// Save token to Firestore user document
  /// Supports both Firebase Auth and PIN-based auth users
  Future<void> _saveTokenToFirestore(String token) async {
    try {
      String? userId;

      // Try Firebase Auth first (for admin users)
      final user = _auth.currentUser;
      if (user != null) {
        userId = user.uid;
        AppLogger.info('Using Firebase Auth user ID: $userId');
      } else {
        // Fallback to PIN-based auth (use phone number as document ID)
        final phoneNumber = await _sessionService.getPhoneNumber();
        if (phoneNumber != null && phoneNumber.isNotEmpty) {
          userId = phoneNumber;
          AppLogger.info('Using PIN-based auth phone number: $userId');
        } else {
          // Try getting userId from session
          final sessionUserId = await _sessionService.getUserId();
          if (sessionUserId != null && sessionUserId.isNotEmpty) {
            userId = sessionUserId;
            AppLogger.info('Using session user ID: $userId');
          }
        }
      }

      if (userId == null || userId.isEmpty) {
        AppLogger.warning(
          'No authenticated user to save FCM token (no Firebase Auth, no session)',
        );
        return;
      }

      // Save token to the user document
      await _firestore.collection('users').doc(userId).set({
        'fcmToken': token,
        'lastTokenUpdate': FieldValue.serverTimestamp(),
        'platform': defaultTargetPlatform.name,
      }, SetOptions(merge: true));

      AppLogger.info('✅ FCM token saved to Firestore for user: $userId');
      AppLogger.info('   Token preview: ${token.substring(0, 20)}...');
      AppLogger.info('   Platform: ${defaultTargetPlatform.name}');

      // Also try to save to any document that matches this user's phone number
      // This helps if the userId format doesn't match
      try {
        final phoneNumber = await _sessionService.getPhoneNumber();
        if (phoneNumber != null &&
            phoneNumber.isNotEmpty &&
            phoneNumber != userId) {
          // Also save to phone number document if different
          await _firestore.collection('users').doc(phoneNumber).set({
            'fcmToken': token,
            'lastTokenUpdate': FieldValue.serverTimestamp(),
            'platform': defaultTargetPlatform.name,
          }, SetOptions(merge: true));
          AppLogger.info(
            '✅ FCM token also saved to phone number document: $phoneNumber',
          );
        }
      } catch (e) {
        AppLogger.warning('Could not save token to phone number document: $e');
      }
    } catch (e) {
      AppLogger.error('Error saving FCM token to Firestore', e);
    }
  }

  /// Setup message handlers for foreground/background notifications
  void _setupMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      AppLogger.info(
        'Foreground message received: ${message.notification?.title}',
      );

      if (message.notification != null) {
        debugPrint('Notification: ${message.notification!.title}');
        debugPrint('Body: ${message.notification!.body}');

        // Determine channel based on notification type
        String channelId = 'balaji_points_default';
        final notificationType = message.data['type'] as String?;
        if (notificationType == 'billApproved' ||
            notificationType == 'tierUpgraded' ||
            notificationType == 'pointsWithdrawn') {
          channelId = 'balaji_points_important';
        }

        // Show local notification when app is in foreground
        await _localNotificationService.showNotification(
          title: message.notification!.title ?? 'Notification',
          body: message.notification!.body ?? '',
          payload: message.data.toString(),
          channelId: channelId,
        );
      }
    });

    // Handle background messages (when app is in background but not terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      AppLogger.info('Message opened app: ${message.notification?.title}');
      _handleMessageNavigation(message);
    });

    // Check if app was opened from a terminated state by notification
    _messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        AppLogger.info('App opened from terminated state by notification');
        _handleMessageNavigation(message);
      }
    });
  }

  /// Handle notification navigation based on message data
  void _handleMessageNavigation(RemoteMessage message) {
    try {
      final data = message.data;
      AppLogger.info('Handling notification navigation with data: $data');

      // Always navigate to notifications screen when notification is tapped
      // This ensures users can see all notifications
      _navigateToNotifications();
    } catch (e) {
      AppLogger.error('Error handling notification navigation', e);
      // Fallback: still try to navigate to notifications screen
      _navigateToNotifications();
    }
  }

  /// Navigate to notifications screen
  /// This is called when a notification is tapped in any app state
  void _navigateToNotifications() {
    try {
      AppLogger.info('Navigating to notifications screen');

      // Use the global navigator key to navigate
      final context = navigatorKey.currentContext;
      if (context != null) {
        // Use pushNamed to navigate to notifications screen
        context.pushNamed('notifications');
        AppLogger.info('✅ Navigated to notifications screen');
      } else {
        AppLogger.warning('Navigator context not available, storing navigation intent');
        // Store navigation intent if context is not available yet
        _pendingNavigation = {'route': '/notifications', 'data': {}};
      }
    } catch (e) {
      AppLogger.error('Error navigating to notifications screen', e);
      // Store as pending navigation
      _pendingNavigation = {'route': '/notifications', 'data': {}};
    }
  }

  /// Pending navigation data (to be processed by the app)
  Map<String, dynamic>? _pendingNavigation;

  /// Get and clear pending navigation
  Map<String, dynamic>? getPendingNavigation() {
    final nav = _pendingNavigation;
    _pendingNavigation = null;
    return nav;
  }

  /// Process pending navigation if any
  void processPendingNavigation() {
    final nav = getPendingNavigation();
    if (nav != null) {
      AppLogger.info('Processing pending navigation: ${nav['route']}');
      _navigateToNotifications();
    }
  }

  /// Delete FCM token (on logout)
  Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
      _token = null;

      // Try Firebase Auth first
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'fcmToken': FieldValue.delete(),
        });
        AppLogger.info('FCM token deleted for Firebase Auth user: ${user.uid}');
      } else {
        // Fallback to PIN-based auth
        final phoneNumber = await _sessionService.getPhoneNumber();
        if (phoneNumber != null && phoneNumber.isNotEmpty) {
          await _firestore.collection('users').doc(phoneNumber).update({
            'fcmToken': FieldValue.delete(),
          });
          AppLogger.info(
            'FCM token deleted for PIN-based auth user: $phoneNumber',
          );
        } else {
          final sessionUserId = await _sessionService.getUserId();
          if (sessionUserId != null && sessionUserId.isNotEmpty) {
            await _firestore.collection('users').doc(sessionUserId).update({
              'fcmToken': FieldValue.delete(),
            });
            AppLogger.info(
              'FCM token deleted for session user: $sessionUserId',
            );
          }
        }
      }

      AppLogger.info('FCM token deleted');
    } catch (e) {
      AppLogger.error('Error deleting FCM token', e);
    }
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      AppLogger.info('Subscribed to topic: $topic');
    } catch (e) {
      AppLogger.error('Error subscribing to topic', e);
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      AppLogger.info('Unsubscribed from topic: $topic');
    } catch (e) {
      AppLogger.error('Error unsubscribing from topic', e);
    }
  }

  /// Get Android SDK version
  Future<int> _getAndroidVersion() async {
    if (!Platform.isAndroid) return 0;

    try {
      // Using a simple approach - check if permission exists
      // Android 13+ requires runtime permission for notifications
      return 33; // Assume Android 13+ for safety, will request permission
    } catch (e) {
      AppLogger.error('Error getting Android version', e);
      return 33; // Default to requiring permission
    }
  }
}
