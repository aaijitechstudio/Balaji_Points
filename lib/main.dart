// filepath: lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'package:balaji_points/core/utils/app_logger.dart';
import 'core/utils/app_logger.dart';
import 'services/fcm_service.dart';
import 'services/local_notification_service.dart';
import 'injection/dependency_injection.dart';

/// -------------------------------
/// BACKGROUND FCM HANDLER (TOP LEVEL)
/// -------------------------------
/// This handler is called when app is in background or terminated
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // For Android, explicitly show local notification when app is in background
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
    } catch (e) {
      AppLogger.error('Background notification error', error: e);
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

  // App begins with Bootstrap (Firebase initialization inside)
  runApp(const ProviderScope(child: _Bootstrap()));
}

/// ------------------------------------------------------
/// BOOTSTRAP WIDGET — Handles ALL initialization cleanly
/// ------------------------------------------------------
class _Bootstrap extends StatelessWidget {
  const _Bootstrap();

  Future<void> _init() async {
    final startTime = DateTime.now();
    AppLogger.appInit('Starting', detail: 'Initializing Firebase & Dependencies');
    
    try {
      // Initialize Firebase
      final firebaseStart = DateTime.now();
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      final firebaseDuration = DateTime.now().difference(firebaseStart).inMilliseconds;
      AppLogger.performance('Firebase initialization', firebaseDuration);

      // Setup dependency injection
      final diStart = DateTime.now();
      await setupDependencyInjection();
      final diDuration = DateTime.now().difference(diStart).inMilliseconds;
      AppLogger.performance('Dependency injection', diDuration);

      // FCM (Safe Initialization)
      try {
        final fcmStart = DateTime.now();
        FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler,
        );
        await FCMService().initialize();
        final fcmDuration = DateTime.now().difference(fcmStart).inMilliseconds;
        AppLogger.performance('FCM initialization', fcmDuration);
      } catch (fcmError) {
        AppLogger.warning('⚠️ FCM initialization failed', data: fcmError);
      }
      
      final totalDuration = DateTime.now().difference(startTime).inMilliseconds;
      AppLogger.appInit('Complete', detail: 'Total: ${totalDuration}ms');
      AppLogger.info('✅ App initialized successfully');
    } catch (e) {
      AppLogger.error('❌ App initialization failed', error: e);
      rethrow;
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
