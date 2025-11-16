// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'firebase_options.dart'; // generated after Firebase setup
import 'core/logger.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Reduce logging verbosity
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  AppLogger.info('App starting...');

  // Render first frame immediately, initialize Firebase in the widget tree.
  runApp(const ProviderScope(child: _Bootstrap()));
}

class _Bootstrap extends StatelessWidget {
  const _Bootstrap();

  Future<void> _init() async {
    try {
      AppLogger.info('Initializing Firebase...');
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      AppLogger.info('Firebase initialized successfully');
    } catch (e) {
      AppLogger.error('Firebase initialization failed', e);
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _init(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: _SplashScreen(),
          );
        }
        return const BalajiPointsApp();
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: SizedBox(
          width: 48,
          height: 48,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
