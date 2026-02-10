// lib/features/home/presentation/widgets/leaderboard_preview/leaderboard_preview.dart
// Compact leaderboard preview with podium (top 3) and user position

import 'package:flutter/material.dart';
import 'package:balaji_points/core/theme/design_token.dart';
import 'package:balaji_points/core/theme/design_token_extensions.dart';
import 'package:balaji_points/features/home/data/models/carpenter_rank_model.dart';
import 'package:balaji_points/features/home/presentation/widgets/leaderboard_preview/podium_display.dart';

class LeaderboardPreview extends StatelessWidget {
  final List<CarpenterRankModel> topCarpenters;
  final CarpenterRankModel? currentUserRank;
  final VoidCallback? onViewFull;
  final bool isLoading;

  const LeaderboardPreview({
    super.key,
    required this.topCarpenters,
    this.currentUserRank,
    this.onViewFull,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildShimmer(context);
    }

    if (topCarpenters.isEmpty) {
      return const SizedBox.shrink();
    }

    final top3 = topCarpenters.take(3).toList();
    final showUserPosition = currentUserRank != null && 
                            currentUserRank!.rank > 3;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: context.spacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: context.radius.borderLG,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: context.spacing.paddingXL,
            child: Row(
              children: [
                const Text('🏆', style: TextStyle(fontSize: 24)),
                SizedBox(width: context.spacing.sm),
                Text(
                  'Top Performers',
                  style: context.text.heading3.copyWith(
                    color: DesignToken.textDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Podium display
          PodiumDisplay(topCarpenters: top3),

          // User position (if not in top 3)
          if (showUserPosition) ...[
            Divider(height: 1, color: Colors.grey.shade200),
            _buildUserPosition(context, currentUserRank!),
          ],

          // View full button
          if (onViewFull != null) ...[
            Divider(height: 1, color: Colors.grey.shade200),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: onViewFull,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('View Full Leaderboard'),
                style: TextButton.styleFrom(
                  foregroundColor: DesignToken.primary,
                  padding: EdgeInsets.symmetric(
                    vertical: context.spacing.md,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUserPosition(BuildContext context, CarpenterRankModel userRank) {
    return Container(
      padding: context.spacing.paddingLG,
      decoration: BoxDecoration(
        color: DesignToken.primary.withOpacity(0.05),
      ),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: DesignToken.primary,
              borderRadius: context.radius.borderSM,
            ),
            child: Center(
              child: Text(
                '${userRank.rank}',
                style: context.text.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: context.spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You',
                  style: context.text.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: DesignToken.textDark,
                  ),
                ),
                Text(
                  '${userRank.points} points',
                  style: context.text.bodySmall.copyWith(
                    color: DesignToken.grey600,
                  ),
                ),
              ],
            ),
          ),
          // Up/down indicator (placeholder - could calculate movement)
          const Icon(
            Icons.trending_up,
            color: DesignToken.success,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: context.spacing.lg),
      height: 280,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: context.radius.borderLG,
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: DesignToken.primary,
        ),
      ),
    );
  }
}
