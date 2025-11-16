// filepath: lib/config/routes.dart
import 'package:balaji_points/presentation/screens/dashboard/dashboard_page.dart';
import 'package:balaji_points/presentation/screens/profile/edit_profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:balaji_points/presentation/screens/splash/splash_page.dart';
import 'package:balaji_points/presentation/screens/auth/login_page.dart';
import 'package:balaji_points/presentation/screens/auth/signup_page.dart';
import 'package:balaji_points/presentation/screens/auth/phone_login_page.dart';
import 'package:balaji_points/presentation/screens/spin/daily_spin_page.dart';
import 'package:balaji_points/presentation/screens/admin/admin_home_page.dart';
import 'package:balaji_points/presentation/screens/bills/add_bill_page.dart';
import 'package:balaji_points/services/user_service.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) async {
      final user = FirebaseAuth.instance.currentUser;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup' ||
          state.matchedLocation == '/phone-login';

      // If on splash, let it handle navigation
      if (state.matchedLocation == '/splash') {
        return null;
      }

      // If not authenticated, redirect to login (unless already on auth route)
      if (user == null) {
        return isAuthRoute ? null : '/login';
      }

      // User is authenticated - check profile completion
      if (!isAuthRoute && state.matchedLocation != '/edit-profile') {
        final userService = UserService();
        final userData = await userService.getCurrentUserData();

        // Check if profile is incomplete (missing firstName)
        final firstName = userData?['firstName'] as String? ?? '';
        if (firstName.trim().isEmpty || firstName == 'User') {
          return '/edit-profile';
        }

        // Check if user is admin
        final role = (userData?['role'] as String?)?.toLowerCase();
        if (role == 'admin' && state.matchedLocation != '/admin') {
          return '/admin';
        }
      }

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, _) => const SplashPage()),
      GoRoute(
        path: '/login',
        builder: (context, _) => const LoginPage(),
      ), // Login Screen
      GoRoute(
        path: '/signup',
        builder: (context, _) => const SignupPage(),
      ), // Signup Screen
      GoRoute(
        path: '/phone-login',
        builder: (context, _) => const PhoneLoginPage(),
      ), // Phone Login Screen
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) {
          final isFirstTime = state.uri.queryParameters['firstTime'] == 'true';
          return EditProfilePage(isFirstTime: isFirstTime);
        },
      ), // Profile Completion Screen
      GoRoute(
        path: '/',
        builder: (context, _) => const DashboardPage(),
      ), // Home Screen
      GoRoute(
        path: '/daily-spin',
        builder: (context, _) => const DailySpinPage(),
      ), // Daily Spin Screen
      GoRoute(
        path: '/admin',
        builder: (context, _) => const AdminHomePage(),
      ), // Admin Home Screen
      GoRoute(
        path: '/add-bill',
        builder: (context, _) => const AddBillPage(),
      ), // Add Bill Screen
    ],
  );
});
