import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:balaji_points/core/theme/design_token.dart';
import 'package:balaji_points/config/theme.dart' hide AppColors;
import 'package:balaji_points/l10n/app_localizations.dart';
import 'package:balaji_points/core/mixins/double_tap_exit_mixin.dart';
import '../../widgets/admin/pending_bills_list.dart';
import '../../widgets/admin/offers_management.dart';
import '../../widgets/admin/users_list.dart';
import '../../widgets/admin/daily_spin_management.dart';
import '../../widgets/home_nav_bar.dart';

class AdminHomePage extends ConsumerStatefulWidget {
  const AdminHomePage({super.key});

  @override
  ConsumerState<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends ConsumerState<AdminHomePage>
    with SingleTickerProviderStateMixin, DoubleTapExitMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  /// Get filtered notifications stream based on user role
  Stream<QuerySnapshot> _getFilteredNotificationsStream() {
    // For admins, show all notifications
    return FirebaseFirestore.instance
        .collection('notification_logs')
        .orderBy('sentAt', descending: true)
        .snapshots();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    final l10n = AppLocalizations.of(context)!;
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.logout,
          style: AppTextStyles.nunitoBold.copyWith(fontSize: 22),
        ),
        content: Text(
          l10n.logoutConfirmation,
          style: AppTextStyles.nunitoRegular.copyWith(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              l10n.cancel,
              style: AppTextStyles.nunitoMedium.copyWith(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignToken.error,
              foregroundColor: DesignToken.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              l10n.logout,
              style: AppTextStyles.nunitoSemiBold.copyWith(fontSize: 16),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true && mounted) {
      try {
        await FirebaseAuth.instance.signOut();
        if (mounted) {
          context.go('/login');
        }
      } catch (e) {
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10n.logoutFailed}: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          // Check for dialogs first
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
            return;
          }

          // Handle double-tap exit
          await handleDoubleTapExit();
        }
      },
      child: Scaffold(
        backgroundColor: DesignToken.primary,
        body: Column(
          children: [
            // Unified Navigation Bar - Consistent 64px height
            HomeNavBar(
              title: l10n.adminPanel,
              subtitle: l10n.adminSubtitle,
              showLogo: true,
              showProfileButton: false,
              actions: [
                // Notifications button with badge
                StreamBuilder<QuerySnapshot>(
                  stream: _getFilteredNotificationsStream(),
                  builder: (context, snapshot) {
                    int notificationCount = 0;

                    if (snapshot.hasData) {
                      // For admins, show all notifications (no filtering needed)
                      notificationCount = snapshot.data!.docs.length;
                    }

                    return Stack(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.notifications_outlined,
                            color: DesignToken.white,
                            size: 22,
                          ),
                          onPressed: () {
                            context.push('/notifications');
                          },
                          tooltip: 'Notifications',
                        ),
                        if (notificationCount > 0)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Center(
                                child: Text(
                                  notificationCount > 99
                                      ? '99+'
                                      : '$notificationCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.logout,
                    color: DesignToken.white,
                    size: 22,
                  ),
                  onPressed: _handleLogout,
                  tooltip: l10n.logout,
                ),
              ],
            ),

            // Tabs
            Container(
              color: DesignToken.primary,
              child: TabBar(
                controller: _tabController,
                indicatorColor: DesignToken.white,
                indicatorWeight: 3,
                labelColor: DesignToken.white,
                unselectedLabelColor: DesignToken.white.withValues(alpha: 0.7),
                labelStyle: AppTextStyles.nunitoSemiBold.copyWith(fontSize: 14),
                unselectedLabelStyle: AppTextStyles.nunitoRegular.copyWith(
                  fontSize: 14,
                ),
                tabs: [
                  Tab(
                    icon: const Icon(Icons.receipt_long),
                    text: l10n.pendingBills,
                  ),
                  Tab(icon: const Icon(Icons.local_offer), text: l10n.offers),
                  Tab(icon: const Icon(Icons.people), text: l10n.users),
                  Tab(icon: const Icon(Icons.casino), text: l10n.dailySpin),
                ],
              ),
            ),

            // Tab Content with bottom safe area
            Expanded(
              child: Container(
                color: DesignToken.woodenBackground,
                child: SafeArea(
                  top: false,
                  child: TabBarView(
                    controller: _tabController,
                    children: const [
                      PendingBillsList(),
                      OffersManagement(),
                      UsersList(),
                      DailySpinManagement(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
