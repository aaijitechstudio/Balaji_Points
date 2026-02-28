import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:balaji_points/core/constants/app_constants.dart';
import 'package:balaji_points/core/theme/design_token.dart';
import 'package:balaji_points/config/theme.dart' hide AppColors;
import 'package:balaji_points/l10n/app_localizations.dart';
import 'package:balaji_points/core/mixins/double_tap_exit_mixin.dart';
import 'package:balaji_points/services/fcm_service.dart';
import '../../widgets/admin/admin_dashboard.dart';
import '../../widgets/admin/pending_bills_list.dart';
import '../../widgets/admin/offers_management.dart';
import '../../widgets/admin/products_management.dart';
import '../../widgets/admin/users_list.dart';
import '../../widgets/admin/daily_spin_management.dart';
import '../../widgets/admin/bill_history_list.dart';
import '../../widgets/admin/orders_management.dart';

class AdminHomePage extends ConsumerStatefulWidget {
  const AdminHomePage({super.key});

  @override
  ConsumerState<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends ConsumerState<AdminHomePage>
    with DoubleTapExitMixin {
  bool _showDashboard = true;
  String? _selectedSection;

  void _openSection(String section) {
    setState(() {
      _showDashboard = false;
      _selectedSection = section;
    });
  }

  void _backToDashboard() {
    setState(() {
      _showDashboard = true;
      _selectedSection = null;
    });
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
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: DesignToken.textDark,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleSpacing: _showDashboard ? 0 : null,
          leading: _showDashboard
              ? null
              : IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 22),
                  onPressed: _backToDashboard,
                ),
          title: _showDashboard
              ? Padding(
                  padding: const EdgeInsets.only(left: 14),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          AppConstants.logoPath,
                          width: 36,
                          height: 36,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: DesignToken.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.forest,
                              color: DesignToken.primary,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Balaji Points - Admin Panel',
                            style: AppTextStyles.nunitoBold.copyWith(
                              fontSize: 17,
                              color: DesignToken.textDark,
                              letterSpacing: 0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AppConstants.shopAddressShort,
                            style: AppTextStyles.nunitoRegular.copyWith(
                              fontSize: 11,
                              color: DesignToken.textDark.withValues(alpha: 0.65),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              : Text(
                  _sectionTitle(_selectedSection!),
                  style: AppTextStyles.nunitoBold.copyWith(
                    fontSize: 18,
                    color: DesignToken.textDark,
                  ),
                ),
          centerTitle: !_showDashboard,
          actions: [
            StreamBuilder<QuerySnapshot>(
              stream: _getFilteredNotificationsStream(),
              builder: (context, snapshot) {
                int notificationCount = snapshot.data?.docs.length ?? 0;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined, size: 24),
                      onPressed: () => context.push('/notifications'),
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
              icon: const Icon(Icons.logout, size: 24),
              onPressed: _handleLogout,
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              height: 1,
              color: Colors.black.withValues(alpha: 0.08),
            ),
          ),
        ),
        body: Container(
          color: DesignToken.woodenBackground,
          child: _showDashboard
              ? AdminDashboard(onOpenSection: _openSection)
              : _buildSectionContent(_selectedSection!),
        ),
      ),
    );
  }

  String _sectionTitle(String section) {
    switch (section) {
      case 'pending':
        return 'Pending Bills';
      case 'history':
        return 'Bill History';
      case 'offers':
        return 'Offers';
      case 'users':
        return 'Users';
      case 'products':
        return 'Products';
      case 'orders':
        return 'Orders';
      case 'spin':
        return 'Spin';
      default:
        return 'Admin';
    }
  }

  Widget _buildSectionContent(String section) {
    switch (section) {
      case 'pending':
        return const PendingBillsList();
      case 'history':
        return const BillHistoryList();
      case 'offers':
        return const OffersManagement();
      case 'users':
        return const UsersList();
      case 'products':
        return const ProductsManagement();
      case 'orders':
        return const OrdersManagement();
      case 'spin':
        return const DailySpinManagement();
      default:
        return const SizedBox.shrink();
    }
  }
}

