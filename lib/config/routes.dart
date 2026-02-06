// filepath: lib/config/routes.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:balaji_points/presentation/screens/dashboard/dashboard_page.dart';
import 'package:balaji_points/presentation/screens/profile/edit_profile_page.dart';
import 'package:balaji_points/presentation/screens/profile/profile_page.dart';
import 'package:balaji_points/presentation/screens/splash/splash_page.dart';

// NEW ARCHITECTURE - Auth screens (Clean Architecture + BLoC)
import 'package:balaji_points/features/auth/presentation/pages/login_page.dart';
import 'package:balaji_points/features/auth/presentation/pages/pin_setup_page.dart';
import 'package:balaji_points/features/auth/presentation/pages/pin_login_page.dart';
import 'package:balaji_points/features/auth/presentation/pages/reset_pin_page.dart';
import 'package:balaji_points/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:balaji_points/injection/dependency_injection.dart';

import 'package:balaji_points/presentation/screens/spin/daily_spin_page.dart';
import 'package:balaji_points/presentation/screens/admin/admin_home_page.dart';
import 'package:balaji_points/presentation/screens/admin/admin_add_bill_page.dart';
import 'package:balaji_points/presentation/screens/admin/diagnostic_page.dart';
import 'package:balaji_points/presentation/screens/bills/add_bill_page.dart';
import 'package:balaji_points/presentation/screens/settings/notification_settings_page.dart';
import 'package:balaji_points/presentation/screens/notifications/notifications_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/splash',

    redirect: (context, state) async {
      return null;
    },

    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Page not found: ${state.uri}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),

    routes: [
      GoRoute(path: '/splash', builder: (context, _) => const SplashPage()),

      // NEW ARCHITECTURE - Auth routes with BLoC
      GoRoute(
        path: '/login',
        builder: (context, _) => BlocProvider(
          create: (_) => getIt<AuthBloc>(),
          child: const LoginPage(),
        ),
      ),

      GoRoute(
        path: '/pin-setup',
        builder: (context, state) {
          final phone = state.uri.queryParameters['phone'] ?? '';
          return BlocProvider(
            create: (_) => getIt<AuthBloc>(),
            child: PINSetupPage(phoneNumber: phone),
          );
        },
      ),

      GoRoute(
        path: '/pin-login',
        builder: (context, state) {
          final phone = state.uri.queryParameters['phone'] ?? '';
          return BlocProvider(
            create: (_) => getIt<AuthBloc>(),
            child: PINLoginPage(phoneNumber: phone),
          );
        },
      ),

      GoRoute(
        path: '/pin-reset',
        builder: (context, state) {
          final phone = state.uri.queryParameters['phone'] ?? '';
          return BlocProvider(
            create: (_) => getIt<AuthBloc>(),
            child: ResetPINPage(phoneNumber: phone),
          );
        },
      ),

      GoRoute(path: '/', builder: (context, _) => const DashboardPage()),
      GoRoute(path: '/profile', builder: (context, _) => const ProfilePage()),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) {
          final isFirstTime = state.uri.queryParameters['firstTime'] == 'true';
          return EditProfilePage(isFirstTime: isFirstTime);
        },
      ),
      GoRoute(path: '/daily-spin', builder: (context, _) => const DailySpinPage()),
      GoRoute(path: '/admin', builder: (context, _) => const AdminHomePage()),
      GoRoute(path: '/admin/add-bill', builder: (context, _) => const AdminAddBillPage()),
      GoRoute(path: '/admin/diagnostic', builder: (context, _) => const DiagnosticPage()),
      GoRoute(path: '/add-bill', builder: (context, _) => const AddBillPage()),
      GoRoute(path: '/notification-settings', builder: (context, _) => const NotificationSettingsPage()),
      GoRoute(path: '/notifications', builder: (context, _) => const NotificationsPage()),
    ],
  );
});
