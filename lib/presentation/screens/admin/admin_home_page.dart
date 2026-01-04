import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
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
                // TEMPORARY: Diagnostic button - Remove after verification
                IconButton(
                  icon: const Icon(
                    Icons.bug_report,
                    color: DesignToken.white,
                    size: 22,
                  ),
                  onPressed: () {
                    // Try named route first, fallback to path
                    try {
                      context.pushNamed(
                        'admin-diagnostic',
                        queryParameters: {'phone': '9894223355'},
                      );
                    } catch (e) {
                      // Fallback to path-based navigation
                      context.push('/admin/diagnostic?phone=9894223355');
                    }
                  },
                  tooltip: 'Diagnostic (Temp)',
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

            // Tab Content
            Expanded(
              child: Container(
                color: DesignToken.woodenBackground,
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
          ],
        ),
      ),
    );
  }
}
