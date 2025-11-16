import 'package:flutter/material.dart';
import 'package:balaji_points/config/theme.dart';

class HomeNavBar extends StatelessWidget {
  final VoidCallback? onDrawerTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;

  const HomeNavBar({
    super.key,
    this.onDrawerTap,
    this.onNotificationTap,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.primary,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Drawer Icon Button
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.white, size: 24),
                onPressed:
                    onDrawerTap ??
                    () {
                      Scaffold.of(context).openDrawer();
                    },
              ),

              // App Logo and Title
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
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
                    const SizedBox(width: 8),
                    // App Title
                    Text(
                      'Balaji Points',
                      style: AppTextStyles.nunitoBold.copyWith(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Notification or Profile Button
              IconButton(
                icon: Stack(
                  children: [
                    const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
                onPressed: onNotificationTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
