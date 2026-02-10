// lib/features/home/presentation/widgets/hero_section/quick_actions.dart
// Quick action buttons for common tasks

import 'package:flutter/material.dart';
import 'package:balaji_points/core/theme/design_token.dart';
import 'package:balaji_points/core/theme/design_token_extensions.dart';

class QuickActions extends StatelessWidget {
  final VoidCallback? onAddBill;
  final VoidCallback? onRedeem;
  final VoidCallback? onHistory;

  const QuickActions({
    super.key,
    this.onAddBill,
    this.onRedeem,
    this.onHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (onAddBill != null)
          Expanded(
            child: _QuickActionButton(
              icon: Icons.receipt_long,
              label: 'Add Bill',
              color: DesignToken.success,
              onTap: onAddBill!,
            ),
          ),
        if (onAddBill != null && onRedeem != null)
          SizedBox(width: context.spacing.md),
        if (onRedeem != null)
          Expanded(
            child: _QuickActionButton(
              icon: Icons.card_giftcard,
              label: 'Redeem',
              color: DesignToken.primary,
              onTap: onRedeem!,
            ),
          ),
        if ((onAddBill != null || onRedeem != null) && onHistory != null)
          SizedBox(width: context.spacing.md),
        if (onHistory != null)
          Expanded(
            child: _QuickActionButton(
              icon: Icons.history,
              label: 'History',
              color: DesignToken.info,
              onTap: onHistory!,
            ),
          ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: context.radius.borderMD,
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: context.spacing.md,
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: context.radius.borderMD,
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: color,
                size: 28,
              ),
              SizedBox(height: context.spacing.xs),
              Text(
                label,
                style: context.text.labelMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
