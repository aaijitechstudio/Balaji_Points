// filepath: lib/config/routes.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:balaji_points/presentation/screens/dashboard/dashboard_page.dart';
import 'package:balaji_points/presentation/screens/home/home_page.dart';
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
import 'package:balaji_points/presentation/screens/wallet/wallet_page.dart';
import 'package:balaji_points/presentation/screens/admin/admin_home_page.dart';
import 'package:balaji_points/presentation/screens/admin/admin_add_bill_page.dart';
import 'package:balaji_points/presentation/screens/admin/diagnostic_page.dart';
import 'package:balaji_points/presentation/screens/admin/admin_notifications_page.dart';
import 'package:balaji_points/presentation/screens/bills/add_bill_page.dart';
import 'package:balaji_points/presentation/screens/settings/notification_settings_page.dart';
import 'package:balaji_points/presentation/screens/notifications/notifications_page.dart';
import 'package:balaji_points/services/session_service.dart';
import 'package:balaji_points/presentation/screens/products/product_list_page.dart';
import 'package:balaji_points/presentation/screens/cart/cart_page.dart';
import 'package:balaji_points/presentation/screens/products/product_detail_page.dart';
import 'package:balaji_points/presentation/screens/orders/orders_page.dart';
import 'package:balaji_points/presentation/screens/orders/order_detail_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/splash',

    redirect: (context, state) async {
      // Prevent admin from entering carpenter notifications route.
      if (state.uri.path == '/notifications') {
        final role =
            (await SessionService().getUserRole())?.trim().toLowerCase();
        if (role == 'admin') return '/admin/notifications';
      }

      // Robust fallback: if anything weird is appended to the admin notifications
      // path (extra slash/segments), normalize it back.
      if (state.uri.path.startsWith('/admin/notifications') &&
          state.uri.path != '/admin/notifications') {
        return '/admin/notifications';
      }
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
            if (state.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12, left: 24, right: 24),
                child: Text(
                  'Error: ${state.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final role =
                    (await SessionService().getUserRole())?.trim().toLowerCase();
                if (!context.mounted) return;
                if (role == 'admin') {
                  context.go('/admin');
                } else {
                  context.go('/');
                }
              },
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

      // Carpenter shell with persistent bottom tab bar
      ShellRoute(
        builder: (context, state, child) => DashboardPage(child: child),
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: '/wallet',
            name: 'wallet',
            builder: (context, state) => const WalletPage(),
          ),
          GoRoute(
            path: '/notifications',
            name: 'notifications',
            builder: (context, state) => const NotificationsPage(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) =>
                const ProfilePage(showBottomNav: false),
          ),
          GoRoute(
            path: '/add-bill',
            name: 'add-bill',
            builder: (context, state) => const AddBillPage(),
          ),
          GoRoute(
            path: '/notification-settings',
            name: 'notification-settings',
            builder: (context, state) => const NotificationSettingsPage(),
          ),
          GoRoute(
            path: '/products',
            name: 'products',
            builder: (context, state) {
              final category = state.uri.queryParameters['category'];
              return ProductListPage(initialCategory: category);
            },
          ),
          GoRoute(
            path: '/cart',
            name: 'cart',
            builder: (context, state) => const CartPage(),
          ),
          GoRoute(
            path: '/product-detail/:id',
            name: 'product-detail',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return ProductDetailPage(productId: id);
            },
          ),
          GoRoute(
            path: '/orders',
            name: 'orders',
            builder: (context, state) => const OrdersPage(),
          ),
          GoRoute(
            path: '/order-detail/:id',
            name: 'order-detail',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return OrderDetailPage(orderId: id);
            },
          ),
          GoRoute(
            path: '/edit-profile',
            builder: (context, state) {
              final isFirstTime =
                  state.uri.queryParameters['firstTime'] == 'true';
              return EditProfilePage(isFirstTime: isFirstTime);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/daily-spin',
        builder: (context, _) => const DailySpinPage(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, _) => const AdminHomePage(),
      ),
      GoRoute(
        path: '/admin/add-bill',
        builder: (context, _) => const AdminAddBillPage(),
      ),
      GoRoute(
        path: '/admin/diagnostic',
        builder: (context, _) => const DiagnosticPage(),
      ),
      GoRoute(
        path: '/admin/notifications',
        builder: (context, _) => const AdminNotificationsPage(),
      ),
      // Note: trailing slash is normalized by the redirect.
    ],
  );
});
