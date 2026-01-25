import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../config/routes.dart';
import '../core/logger.dart';
import 'local_notification_service.dart';
import 'session_service.dart';

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

  /// Initialize FCM and permissions
  Future<void> initialize() async {
    try {
      await _localNotificationService.initialize();

      // 🔔 Permissions
      if (Platform.isAndroid) {
        final status = await Permission.notification.request();
        AppLogger.info('Android notification permission: $status');
      } else {
        await _messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // 🔑 Token
      await _getToken();

      _messaging.onTokenRefresh.listen((newToken) async {
        _token = newToken;
        AppLogger.info('🔄 FCM token refreshed');
        await _saveTokenToFirestore(newToken);
      });

      _setupMessageHandlers();
    } catch (e) {
      AppLogger.error('Error initializing FCM', e);
    }
  }

  Future<void> _getToken() async {
    try {
      _token = await _messaging.getToken();
      if (_token != null) {
        AppLogger.info('📲 FCM token: ${_token!.substring(0, 20)}...');
        await _saveTokenToFirestore(_token!);
      }
    } catch (e) {
      AppLogger.error('Error getting FCM token', e);
    }
  }

  /// 🔥 MAIN FIX IS HERE
  Future<void> _saveTokenToFirestore(String token) async {
    try {
      final Set<String> targetDocIds = {};

      // 1️⃣ Firebase Auth user (Admin via Auth)
      final authUser = _auth.currentUser;
      if (authUser != null) {
        targetDocIds.add(authUser.uid);
      }

      // 2️⃣ PIN login phone number
      final phone = await _sessionService.getPhoneNumber();
      if (phone != null && phone.isNotEmpty) {
        targetDocIds.add(phone);
      }

      // 3️⃣ Session userId
      final sessionUserId = await _sessionService.getUserId();
      if (sessionUserId != null && sessionUserId.isNotEmpty) {
        targetDocIds.add(sessionUserId);
      }

      // Save token to collected IDs
      for (final docId in targetDocIds) {
        await _firestore.collection('users').doc(docId).set({
          'fcmToken': token,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
          'platform': defaultTargetPlatform.name,
        }, SetOptions(merge: true));

        AppLogger.info('✅ FCM token saved to users/$docId');
      }

      // 🔥 4️⃣ FORCE SYNC TOKEN TO ADMIN ROLE DOCUMENT(S)
      final adminDocs = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'admin')
          .get();

      for (final doc in adminDocs.docs) {
        await doc.reference.set({
          'fcmToken': token,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
          'platform': defaultTargetPlatform.name,
        }, SetOptions(merge: true));

        AppLogger.info('👑 Admin token synced: ${doc.id}');
      }
    } catch (e) {
      AppLogger.error('Error saving FCM token', e);
    }
  }

  // ===============================
  // MESSAGE HANDLERS
  // ===============================

  void _setupMessageHandlers() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      AppLogger.info(
        '📩 Foreground notification: ${message.notification?.title}',
      );

      if (message.notification != null) {
        String channelId = 'balaji_points_default';
        final type = message.data['type'];

        if (type == 'billApproved' ||
            type == 'tierUpgraded' ||
            type == 'pointsWithdrawn') {
          channelId = 'balaji_points_important';
        }

        await _localNotificationService.showNotification(
          title: message.notification!.title ?? 'Notification',
          body: message.notification!.body ?? '',
          payload: message.data.toString(),
          channelId: channelId,
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageNavigation);

    _messaging.getInitialMessage().then((message) {
      if (message != null) {
        _handleMessageNavigation(message);
      }
    });
  }

  void _handleMessageNavigation(RemoteMessage message) {
    try {
      final context = navigatorKey.currentContext;
      if (context != null) {
        context.pushNamed('notifications');
      } else {
        _pendingNavigation = true;
      }
    } catch (e) {
      AppLogger.error('Navigation error', e);
    }
  }

  bool _pendingNavigation = false;

  void processPendingNavigation() {
    if (_pendingNavigation) {
      _pendingNavigation = false;
      final context = navigatorKey.currentContext;
      if (context != null) {
        context.pushNamed('notifications');
      }
    }
  }

  /// Logout cleanup
  Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
      _token = null;
      AppLogger.info('🧹 FCM token deleted');
    } catch (e) {
      AppLogger.error('Error deleting token', e);
    }
  }
}
