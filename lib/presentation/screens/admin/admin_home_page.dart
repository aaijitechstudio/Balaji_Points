import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:balaji_points/core/theme/design_token.dart';
import 'package:balaji_points/config/theme.dart' hide AppColors;
import 'package:balaji_points/l10n/app_localizations.dart';
import 'package:balaji_points/core/mixins/double_tap_exit_mixin.dart';
import 'package:balaji_points/services/fcm_service.dart';
import '../../widgets/admin/pending_bills_list.dart';
import '../../widgets/admin/offers_management.dart';
import '../../widgets/admin/users_list.dart';
import '../../widgets/admin/daily_spin_management.dart';
import '../../widgets/admin/bill_history_list.dart';

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
    _tabController = TabController(length: 5, vsync: this);
  }

  /// Get filtered notifications stream based on user role
  Stream<QuerySnapshot> _getFilteredNotificationsStream() {
    // For admins, show only admin-related notifications (new bills, new users)
    return FirebaseFirestore.instance
        .collection('notification_logs')
        .where('type', whereIn: ['newPendingBill', 'newUserRegistered'])
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
        // Delete FCM token before signing out
        await FCMService().deleteToken();

        // Sign out from Firebase
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
            // Compact iOS-style Header
            SafeArea(
              bottom: false,
              child: Container(
                color: DesignToken.primary,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Column(
                  children: [
                    // Top row with title and actions
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.adminPanel,
                                style: AppTextStyles.nunitoBold.copyWith(
                                  fontSize: 24,
                                  color: Colors.white,
                                  height: 1.2,
                                ),
                              ),
                              Text(
                                l10n.adminSubtitle,
                                style: AppTextStyles.nunitoRegular.copyWith(
                                  fontSize: 13,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Compact action buttons
                        StreamBuilder<QuerySnapshot>(
                          stream: _getFilteredNotificationsStream(),
                          builder: (context, snapshot) {
                            int notificationCount = 0;
                            if (snapshot.hasData) {
                              notificationCount = snapshot.data!.docs.length;
                            }

                            return Stack(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.notifications_outlined,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  onPressed: () => context.push('/notifications'),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 40,
                                    minHeight: 40,
                                  ),
                                ),
                                if (notificationCount > 0)
                                  Positioned(
                                    right: 6,
                                    top: 6,
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
                                          notificationCount > 99 ? '99+' : '$notificationCount',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
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
                          icon: const Icon(Icons.logout, color: Colors.white, size: 24),
                          onPressed: _handleLogout,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // iOS-style Segmented Control Tabs
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        labelColor: DesignToken.primary,
                        unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
                        labelStyle: AppTextStyles.nunitoBold.copyWith(
                          fontSize: 13,
                          letterSpacing: 0.3,
                        ),
                        unselectedLabelStyle: AppTextStyles.nunitoMedium.copyWith(
                          fontSize: 12,
                          letterSpacing: 0.2,
                        ),
                        labelPadding: EdgeInsets.zero,
                        isScrollable: false,
                        tabs: const [
                          Tab(text: 'Pending', height: 36),
                          Tab(text: 'History', height: 36),
                          Tab(text: 'Offers', height: 36),
                          Tab(text: 'Users', height: 36),
                          Tab(text: 'Spin', height: 36),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Tab Content with maximum space
            Expanded(
              child: Container(
                color: DesignToken.woodenBackground,
                child: SafeArea(
                  top: false,
                  child: TabBarView(
                    controller: _tabController,
                    children: const [
                      PendingBillsList(),
                      BillHistoryList(),
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
