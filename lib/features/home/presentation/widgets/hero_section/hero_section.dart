// lib/features/home/presentation/widgets/hero_section/hero_section.dart
// Hero section with greeting, points display, tier badge, and quick actions

import 'package:flutter/material.dart';
import 'package:balaji_points/core/theme/design_token.dart';
import 'package:balaji_points/core/theme/design_token_extensions.dart';
import 'package:balaji_points/features/home/presentation/widgets/hero_section/points_display.dart';
import 'package:balaji_points/features/home/presentation/widgets/hero_section/quick_actions.dart';

class HeroSection extends StatelessWidget {
  final String userName;
  final int points;
  final String tier;
  final String? userImageUrl;
  final VoidCallback? onAddBill;
  final VoidCallback? onRedeem;
  final VoidCallback? onHistory;
  final bool showQuickActions;

  const HeroSection({
    super.key,
    required this.userName,
    required this.points,
    required this.tier,
    this.userImageUrl,
    this.onAddBill,
    this.onRedeem,
    this.onHistory,
    this.showQuickActions = true,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: context.spacing.lg,
        vertical: context.spacing.md,
      ),
      padding: context.spacing.paddingXL,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DesignToken.woodenBackground,
            Colors.white,
          ],
        ),
        borderRadius: context.radius.borderLG,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting with wave emoji
          Row(
            children: [
              Text(
                '${_getGreeting()}, ',
                style: context.text.bodyLarge.copyWith(
                  color: DesignToken.grey600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                userName,
                style: context.text.heading3.copyWith(
                  color: DesignToken.textDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '👋',
                style: TextStyle(fontSize: 24),
              ),
            ],
          ),

          SizedBox(height: context.spacing.lg),

          // Points Display
          PointsDisplay(
            points: points,
            tier: tier,
          ),

          if (showQuickActions) ...[
            SizedBox(height: context.spacing.xl),

            // Quick Actions
            QuickActions(
              onAddBill: onAddBill,
              onRedeem: onRedeem,
              onHistory: onHistory,
            ),
          ],
        ],
      ),
    );
  }
}
