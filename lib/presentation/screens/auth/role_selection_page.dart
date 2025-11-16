import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:balaji_points/config/theme.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001F3F), // Navy blue background
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Text(
                "Select Your Role",
                style: AppTextStyles.nunitoBold.copyWith(
                  fontSize: 28,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // Role Cards
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Carpenter Role Card
                    GestureDetector(
                      onTap: () => context.go('/carpenter-login'),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Colors.pink, width: 2),
                        ),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.construction,
                                size: 40,
                                color: Colors.pink,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Carpenter",
                                      style: AppTextStyles.nunitoBold.copyWith(
                                        fontSize: 20,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Earn and redeem Balaji Points easily.",
                                      style: AppTextStyles.nunitoRegular
                                          .copyWith(
                                            fontSize: 16,
                                            color: Colors.black54,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Admin Role Card
                    GestureDetector(
                      onTap: () => context.go('/admin-login'),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Colors.pink, width: 2),
                        ),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.admin_panel_settings,
                                size: 40,
                                color: Colors.pink,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Admin",
                                      style: AppTextStyles.nunitoBold.copyWith(
                                        fontSize: 20,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Manage users, rewards, and transactions.",
                                      style: AppTextStyles.nunitoRegular
                                          .copyWith(
                                            fontSize: 16,
                                            color: Colors.black54,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Footer
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                "© Balaji Points 2025",
                style: AppTextStyles.nunitoRegular.copyWith(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
