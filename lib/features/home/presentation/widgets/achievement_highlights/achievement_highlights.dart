// lib/features/home/presentation/widgets/achievement_highlights/achievement_highlights.dart
// Combined widget for today's winner and current user ranking

import 'package:flutter/material.dart';
import 'package:balaji_points/core/theme/design_token.dart';
import 'package:balaji_points/core/theme/design_token_extensions.dart';
import 'package:balaji_points/features/home/data/models/carpenter_rank_model.dart';

class AchievementHighlights extends StatelessWidget {
  final CarpenterRankModel? todaysWinner;
  final CarpenterRankModel? currentUserRank;
  final int? totalCarpenters;
  final VoidCallback? onViewLeaderboard;

  const AchievementHighlights({
    super.key,
    this.todaysWinner,
    this.currentUserRank,
    this.totalCarpenters,
    this.onViewLeaderboard,
  });

  @override
  Widget build(BuildContext context) {
    if (todaysWinner == null && currentUserRank == null) {
      return const SizedBox.shrink();
    }

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
        children: [
          // Today's Winner
          if (todaysWinner != null) ...[
            _TodaysWinnerSection(
              winner: todaysWinner!,
            ),
            if (currentUserRank != null) Divider(height: 1, color: Colors.grey.shade200),
          ],

          // Your Ranking
          if (currentUserRank != null) ...[
            _YourRankingSection(
              userRank: currentUserRank!,
              totalCarpenters: totalCarpenters,
              onViewLeaderboard: onViewLeaderboard,
            ),
          ],
        ],
      ),
    );
  }
}

class _TodaysWinnerSection extends StatelessWidget {
  final CarpenterRankModel winner;

  const _TodaysWinnerSection({required this.winner});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.spacing.paddingXL,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🎉', style: TextStyle(fontSize: 24)),
              SizedBox(width: context.spacing.sm),
              Text(
                'Today\'s Top Performer',
                style: context.text.heading3.copyWith(
                  color: DesignToken.textDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: context.spacing.md),
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 28,
                backgroundColor: DesignToken.primary.withOpacity(0.1),
                backgroundImage: winner.imageUrl != null && winner.imageUrl!.isNotEmpty
                    ? NetworkImage(winner.imageUrl!)
                    : null,
                child: winner.imageUrl == null || winner.imageUrl!.isEmpty
                    ? Text(
                        winner.name.isNotEmpty ? winner.name[0].toUpperCase() : 'C',
                        style: context.text.heading2.copyWith(
                          color: DesignToken.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              SizedBox(width: context.spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      winner.displayName,
                      style: context.text.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: DesignToken.textDark,
                      ),
                    ),
                    SizedBox(height: context.spacing.xs),
                    Row(
                      children: [
                        const Icon(
                          Icons.trending_up,
                          size: 16,
                          color: DesignToken.success,
                        ),
                        SizedBox(width: context.spacing.xs),
                        Text(
                          '${winner.points} points',
                          style: context.text.bodyMedium.copyWith(
                            color: DesignToken.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Trophy
              const Text('🏆', style: TextStyle(fontSize: 32)),
            ],
          ),
        ],
      ),
    );
  }
}

class _YourRankingSection extends StatelessWidget {
  final CarpenterRankModel userRank;
  final int? totalCarpenters;
  final VoidCallback? onViewLeaderboard;

  const _YourRankingSection({
    required this.userRank,
    this.totalCarpenters,
    this.onViewLeaderboard,
  });

  String _getMotivationalMessage() {
    if (userRank.rank == 1) {
      return '🎉 You\'re the top performer!';
    } else if (userRank.rank <= 3) {
      return '🥳 You\'re in the top 3!';
    } else if (userRank.rank <= 10) {
      return '💪 You\'re in the top 10!';
    } else {
      return '⭐ Keep climbing!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.spacing.paddingXL,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📊', style: TextStyle(fontSize: 24)),
              SizedBox(width: context.spacing.sm),
              Text(
                'Your Ranking',
                style: context.text.heading3.copyWith(
                  color: DesignToken.textDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: context.spacing.md),

          // Rank display
          Container(
            padding: context.spacing.paddingLG,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  DesignToken.primary.withOpacity(0.1),
                  DesignToken.primary.withOpacity(0.05),
                ],
              ),
              borderRadius: context.radius.borderMD,
              border: Border.all(
                color: DesignToken.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Rank number
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: DesignToken.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '#${userRank.rank}',
                      style: context.text.bodyLarge.copyWith(
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
                      if (totalCarpenters != null)
                        Text(
                          'out of $totalCarpenters carpenters',
                          style: context.text.bodyMedium.copyWith(
                            color: DesignToken.grey600,
                          ),
                        ),
                      SizedBox(height: context.spacing.xs),
                      Text(
                        _getMotivationalMessage(),
                        style: context.text.bodyMedium.copyWith(
                          color: DesignToken.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (onViewLeaderboard != null) ...[
            SizedBox(height: context.spacing.md),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: onViewLeaderboard,
                icon: const Icon(Icons.leaderboard),
                label: const Text('View Full Leaderboard'),
                style: TextButton.styleFrom(
                  foregroundColor: DesignToken.primary,
                  padding: EdgeInsets.symmetric(vertical: context.spacing.md),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
