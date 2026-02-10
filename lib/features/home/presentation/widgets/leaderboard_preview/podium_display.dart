// lib/features/home/presentation/widgets/leaderboard_preview/podium_display.dart
// Podium display for top 3 performers

import 'package:flutter/material.dart';
import 'package:balaji_points/core/theme/design_token.dart';
import 'package:balaji_points/core/theme/design_token_extensions.dart';
import 'package:balaji_points/features/home/data/models/carpenter_rank_model.dart';

class PodiumDisplay extends StatelessWidget {
  final List<CarpenterRankModel> topCarpenters;

  const PodiumDisplay({
    super.key,
    required this.topCarpenters,
  });

  @override
  Widget build(BuildContext context) {
    // Ensure we have at least 1 carpenter
    if (topCarpenters.isEmpty) {
      return Padding(
        padding: context.spacing.paddingXL,
        child: Text(
          'No carpenters yet',
          style: context.text.bodyMedium.copyWith(
            color: DesignToken.grey600,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    // Get top 3 (or less) - ALREADY SORTED BY POINTS
    final first = topCarpenters.isNotEmpty ? topCarpenters[0] : null;
    final second = topCarpenters.length > 1 ? topCarpenters[1] : null;
    final third = topCarpenters.length > 2 ? topCarpenters[2] : null;

    // Debug logging
    debugPrint('=== PODIUM DISPLAY ===');
    if (first != null) debugPrint('1st: ${first.name} - ${first.points} pts (Rank: ${first.rank})');
    if (second != null) debugPrint('2nd: ${second.name} - ${second.points} pts (Rank: ${second.rank})');
    if (third != null) debugPrint('3rd: ${third.name} - ${third.points} pts (Rank: ${third.rank})');
    debugPrint('=====================');

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.spacing.md,
        vertical: context.spacing.lg,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd place (LEFT position)
          if (second != null)
            Flexible(
              flex: 1,
              child: _PodiumItem(
                carpenter: second,
                rank: 2,
                height: 85,
                color: Colors.grey.shade400,
                emoji: '🥈',
              ),
            ),

          SizedBox(width: context.spacing.xs),

          // 1st place (CENTER position - TALLEST)
          if (first != null)
            Flexible(
              flex: 1,
              child: _PodiumItem(
                carpenter: first,
                rank: 1,
                height: 110,
                color: Colors.amber.shade400,
                emoji: '🥇',
              ),
            ),

          SizedBox(width: context.spacing.xs),

          // 3rd place (RIGHT position)
          if (third != null)
            Flexible(
              flex: 1,
              child: _PodiumItem(
                carpenter: third,
                rank: 3,
                height: 70,
                color: Colors.brown.shade400,
                emoji: '🥉',
              ),
            ),
        ],
      ),
    );
  }
}

class _PodiumItem extends StatelessWidget {
  final CarpenterRankModel carpenter;
  final int rank;
  final double height;
  final Color color;
  final String emoji;

  const _PodiumItem({
    required this.carpenter,
    required this.rank,
    required this.height,
    required this.color,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar
        Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: rank == 1 ? 30 : 24,
              backgroundColor: color.withOpacity(0.2),
              backgroundImage: carpenter.imageUrl != null && 
                             carpenter.imageUrl!.isNotEmpty
                  ? NetworkImage(carpenter.imageUrl!)
                  : null,
              child: carpenter.imageUrl == null || carpenter.imageUrl!.isEmpty
                  ? Text(
                      carpenter.name.isNotEmpty 
                          ? carpenter.name[0].toUpperCase() 
                          : 'C',
                      style: TextStyle(
                        color: color,
                        fontSize: rank == 1 ? 22 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            // Medal badge
            Positioned(
              bottom: -2,
              right: -2,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Text(
                  emoji,
                  style: TextStyle(fontSize: rank == 1 ? 16 : 14),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: context.spacing.xs),

        // Name - with proper constraints
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 90),
          child: Text(
            carpenter.displayName,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: DesignToken.textDark,
              fontSize: DesignToken.fontSizeXS, // 10px
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        const SizedBox(height: 2),

        // Points - smaller font
        Text(
          '${carpenter.points}',
          style: const TextStyle(
            color: DesignToken.grey600,
            fontWeight: FontWeight.w500,
            fontSize: DesignToken.fontSizeXS, // 10px
          ),
        ),

        SizedBox(height: context.spacing.xs),

        // Podium base
        Container(
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color,
                color.withOpacity(0.7),
              ],
            ),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(8),
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '$rank',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: rank == 1 ? 36 : 28,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
