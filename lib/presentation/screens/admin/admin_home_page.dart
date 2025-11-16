import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:balaji_points/config/theme.dart';
import '../../widgets/admin/pending_bills_list.dart';
import '../../widgets/admin/offers_management.dart';
import '../../widgets/admin/users_list.dart';

class AdminHomePage extends ConsumerStatefulWidget {
  const AdminHomePage({super.key});

  @override
  ConsumerState<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends ConsumerState<AdminHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Logout',
          style: AppTextStyles.nunitoBold.copyWith(fontSize: 22),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: AppTextStyles.nunitoRegular.copyWith(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: AppTextStyles.nunitoMedium.copyWith(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Logout',
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logout failed: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Column(
        children: [
          // Top Safe Area with Primary Color
          SafeArea(
            bottom: false,
            child: Container(
              color: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // App Logo
                  Image.asset(
                    'assets/images/balaji_point_logo.png',
                    width: 32,
                    height: 32,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.star,
                          color: Colors.white,
                          size: 20,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  // Admin Title
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Admin Panel',
                          style: AppTextStyles.nunitoBold.copyWith(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Manage Bills, Offers & Users',
                          style: AppTextStyles.nunitoRegular.copyWith(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Logout Button
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    onPressed: _handleLogout,
                  ),
                ],
              ),
            ),
          ),

          // Tabs
          Container(
            color: AppColors.primary,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withOpacity(0.7),
              labelStyle: AppTextStyles.nunitoSemiBold.copyWith(fontSize: 14),
              unselectedLabelStyle: AppTextStyles.nunitoRegular.copyWith(
                fontSize: 14,
              ),
              tabs: const [
                Tab(
                  icon: Icon(Icons.receipt_long),
                  text: 'Pending Bills',
                ),
                Tab(
                  icon: Icon(Icons.local_offer),
                  text: 'Offers',
                ),
                Tab(
                  icon: Icon(Icons.people),
                  text: 'Users',
                ),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: Container(
              color: AppColors.woodenBackground,
              child: TabBarView(
                controller: _tabController,
                children: const [
                  PendingBillsList(),
                  OffersManagement(),
                  UsersList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
