// filepath: lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'core/logger.dart';
import 'services/fcm_service.dart';
import 'services/local_notification_service.dart';

/// -------------------------------
/// BACKGROUND FCM HANDLER (TOP LEVEL)
/// -------------------------------
/// This handler is called when app is in background or terminated
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  AppLogger.info('💬 Background FCM Message: ${message.notification?.title}');
  AppLogger.info('   Body: ${message.notification?.body}');
  AppLogger.info('   Data: ${message.data}');

  // For Android, explicitly show local notification when app is in background
  // This ensures notifications appear even if FCM payload format varies
  if (message.notification != null) {
    try {
      final localNotificationService = LocalNotificationService();
      await localNotificationService.initialize();

      // Determine channel based on priority or type
      String channelId = 'balaji_points_default';
      if (message.data['type'] == 'billApproved' ||
          message.data['type'] == 'tierUpgraded' ||
          message.data['type'] == 'pointsWithdrawn') {
        channelId = 'balaji_points_important';
      }

      await localNotificationService.showNotification(
        title: message.notification!.title ?? 'Notification',
        body: message.notification!.body ?? '',
        payload: message.data.toString(),
        channelId: channelId,
      );

      AppLogger.info(
        '✅ Background notification shown via LocalNotificationService',
      );
    } catch (e) {
      AppLogger.error('Error showing background notification', e);
      // Continue - FCM might still show it automatically
    }
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // System UI Styling (Status bar)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  AppLogger.info('🚀 App starting...');

  // App begins with Bootstrap (Firebase initialization inside)
  runApp(const ProviderScope(child: _Bootstrap()));
}

/// ------------------------------------------------------
/// BOOTSTRAP WIDGET — Handles ALL initialization cleanly
/// ------------------------------------------------------
class _Bootstrap extends StatelessWidget {
  const _Bootstrap();

  Future<void> _init() async {
    try {
      AppLogger.info('⚙️ Initializing Firebase...');

      // Initialize Firebase ONLY once
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      AppLogger.info('✅ Firebase initialized');

      // ----------------------------
      // FCM (Safe Initialization)
      // ----------------------------
      try {
        FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler,
        );

        await FCMService().initialize();

        AppLogger.info('📩 FCM initialized');
      } catch (fcmError) {
        AppLogger.warning(
          '⚠️ FCM initialization failed — continuing app: $fcmError',
        );
      }
    } catch (e) {
      AppLogger.error('❌ Firebase initialization FAILED', e);
      rethrow; // allow splash to show forever if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _init(),
      builder: (context, snapshot) {
        // Show splash until Firebase is ready
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: _SplashScreen(),
          );
        }

        // Firebase ready → Load full app
        return const BalajiPointsApp();
      },
    );
  }
}

/// ------------------------
/// Minimal Splash UI
/// ------------------------
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SizedBox(
          width: 48,
          height: 48,
          child: CircularProgressIndicator(strokeWidth: 2.6),
        ),
      ),
    );
  }
}
