import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../core/logger.dart';

/// Firebase Cloud Messaging Service for device token management
class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _token;
  String? get token => _token;

  /// Initialize FCM and request notification permissions
  Future<void> initialize() async {
    try {
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
  Future<void> _saveTokenToFirestore(String token) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        AppLogger.warning('No authenticated user to save FCM token');
        return;
      }

      await _firestore.collection('users').doc(user.uid).set({
        'fcmToken': token,
        'lastTokenUpdate': FieldValue.serverTimestamp(),
        'platform': defaultTargetPlatform.name,
      }, SetOptions(merge: true));

      AppLogger.info('FCM token saved to Firestore for user: ${user.uid}');
    } catch (e) {
      AppLogger.error('Error saving FCM token to Firestore', e);
    }
  }

  /// Setup message handlers for foreground/background notifications
  void _setupMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      AppLogger.info('Foreground message received: ${message.notification?.title}');

      if (message.notification != null) {
        debugPrint('Notification: ${message.notification!.title}');
        debugPrint('Body: ${message.notification!.body}');
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
    // Add navigation logic based on notification data
    final data = message.data;
    debugPrint('Notification data: $data');

    // Example: Navigate to specific screen based on notification type
    // if (data['type'] == 'points_earned') {
    //   // Navigate to points history
    // } else if (data['type'] == 'new_offer') {
    //   // Navigate to offers
    // }
  }

  /// Delete FCM token (on logout)
  Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
      _token = null;

      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'fcmToken': FieldValue.delete(),
        });
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
