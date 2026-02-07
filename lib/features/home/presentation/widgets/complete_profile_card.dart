import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:balaji_points/l10n/app_localizations.dart';
import 'package:balaji_points/config/theme.dart';

class CompleteProfileCard extends StatelessWidget {
  const CompleteProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.shade400,
            Colors.deepOrange.shade500,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/edit-profile'),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_add_alt_1,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),

                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.completeProfile,
                        style: AppTextStyles.nunitoBold.copyWith(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.completeProfileDetails,
                        style: AppTextStyles.nunitoRegular.copyWith(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.95),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow icon
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
