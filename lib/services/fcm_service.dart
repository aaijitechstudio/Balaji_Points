import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../core/logger.dart';
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

      // Request notification permissions (iOS)
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        AppLogger.info('Notification permissions granted');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        AppLogger.info('Notification permissions provisionally granted');
      } else {
        AppLogger.warning('Notification permissions denied');
        return;
      }

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

      await _firestore.collection('users').doc(userId).set({
        'fcmToken': token,
        'lastTokenUpdate': FieldValue.serverTimestamp(),
        'platform': defaultTargetPlatform.name,
      }, SetOptions(merge: true));

      AppLogger.info('FCM token saved to Firestore for user: $userId');
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

        // Show local notification when app is in foreground
        await _localNotificationService.showNotification(
          title: message.notification!.title ?? 'Notification',
          body: message.notification!.body ?? '',
          payload: message.data.toString(),
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

      // Get the screen route from notification data
      final screen = data['screen'] as String?;
      if (screen == null || screen.isEmpty) {
        AppLogger.info(
          'No screen route in notification data, skipping navigation',
        );
        return;
      }

      // Use a global navigator key or context to navigate
      // For now, we'll use a callback approach
      // The app should register a navigation callback during initialization
      _navigateToScreen(screen, data);
    } catch (e) {
      AppLogger.error('Error handling notification navigation', e);
    }
  }

  /// Navigate to a specific screen based on route
  /// This will be called from the app's navigation context
  void _navigateToScreen(String route, Map<String, dynamic> data) {
    // Navigation will be handled by the app using GoRouter
    // We'll store the navigation intent and let the app handle it
    AppLogger.info('Navigation intent: $route with data: $data');

    // Store navigation intent for the app to process
    // The app should check this on startup or when resuming
    _pendingNavigation = {'route': route, 'data': data};
  }

  /// Pending navigation data (to be processed by the app)
  Map<String, dynamic>? _pendingNavigation;

  /// Get and clear pending navigation
  Map<String, dynamic>? getPendingNavigation() {
    final nav = _pendingNavigation;
    _pendingNavigation = null;
    return nav;
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
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  AppLogger.info('Background message: ${message.notification?.title}');
}
