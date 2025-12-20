// filepath: lib/config/routes.dart
import 'package:balaji_points/presentation/screens/dashboard/dashboard_page.dart';
import 'package:balaji_points/presentation/screens/profile/edit_profile_page.dart';
import 'package:balaji_points/presentation/screens/profile/profile_page.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:balaji_points/presentation/screens/splash/splash_page.dart';
import 'package:balaji_points/presentation/screens/auth/login_page.dart';

// PIN authentication screens
import 'package:balaji_points/presentation/screens/auth/pin_setup_page.dart';
import 'package:balaji_points/presentation/screens/auth/pin_login_page.dart';
import 'package:balaji_points/presentation/screens/auth/reset_pin_page.dart';

import 'package:balaji_points/presentation/screens/spin/daily_spin_page.dart';
import 'package:balaji_points/presentation/screens/admin/admin_home_page.dart';
import 'package:balaji_points/presentation/screens/bills/add_bill_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',

    // NOTE: PIN-based authentication - no route guards for now
    // TODO: Implement proper session management with shared preferences or secure storage
    redirect: (context, state) async {
      // Allow all navigation for PIN-based auth
      return null;
    },

    routes: [
      GoRoute(path: '/splash', builder: (context, _) => const SplashPage()),

      GoRoute(path: '/login', builder: (context, _) => const LoginPage()),

      // ------------------ PIN SETUP ------------------
      GoRoute(
        path: '/pin-setup',
        builder: (context, state) {
          final phone = state.uri.queryParameters['phone'] ?? '';
          return PINSetupPage(phoneNumber: phone);
        },
      ),

      // ------------------ PIN LOGIN ------------------
      GoRoute(
        path: '/pin-login',
        builder: (context, state) {
          final phone = state.uri.queryParameters['phone'] ?? '';
          return PINLoginPage(phoneNumber: phone);
        },
      ),

      // ------------------ PIN RESET ------------------
      GoRoute(
        path: '/pin-reset',
        builder: (context, state) {
          final phone = state.uri.queryParameters['phone'] ?? '';
          return ResetPINPage(phoneNumber: phone);
        },
      ),

      // ------------------ MAIN APP ------------------
      GoRoute(path: '/', builder: (context, _) => const DashboardPage()),

      GoRoute(path: '/profile', builder: (context, _) => const ProfilePage()),

      GoRoute(
        path: '/edit-profile',
        builder: (context, state) {
          final isFirstTime = state.uri.queryParameters['firstTime'] == 'true';
          return EditProfilePage(isFirstTime: isFirstTime);
        },
      ),

      GoRoute(
        path: '/daily-spin',
        builder: (context, _) => const DailySpinPage(),
      ),

      GoRoute(path: '/admin', builder: (context, _) => const AdminHomePage()),

      GoRoute(path: '/add-bill', builder: (context, _) => const AddBillPage()),
    ],
  );
});
