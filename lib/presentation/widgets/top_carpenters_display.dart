import 'package:flutter/material.dart';
import 'package:balaji_points/config/theme.dart';

class TopCarpentersDisplay extends StatelessWidget {
  final List<CarpenterRank> topCarpenters;
  final CarpenterRank? currentUser;

  const TopCarpentersDisplay({
    super.key,
    required this.topCarpenters,
    this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    if (topCarpenters.length < 3) {
      return const SizedBox.shrink();
    }

    final top3 = topCarpenters.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🏆 Top Carpenters',
          style: TextStyle(
            color: AppColors.secondary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),

        // Top 3 Display
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Rank 2 (Left)
            if (top3.length > 1) _buildTrophyCard(top3[1], 2, false),

            // Rank 1 (Center)
            _buildTrophyCard(top3[0], 1, true),

            // Rank 3 (Right)
            if (top3.length > 2) _buildTrophyCard(top3[2], 3, false),
          ],
        ),

        // Current User Position (if not in top 3)
        if (currentUser != null && currentUser!.rank > 3) ...[
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade700,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${currentUser!.rank}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.person, color: Colors.blue, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    currentUser!.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.monetization_on,
                      color: Colors.amber.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatPoints(currentUser!.points),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTrophyCard(CarpenterRank carpenter, int rank, bool isFirst) {
    Color trophyColor;
    IconData trophyIcon;

    switch (rank) {
      case 1:
        trophyColor = Colors.amber;
        trophyIcon = Icons.emoji_events;
        break;
      case 2:
        trophyColor = Colors.grey.shade400;
        trophyIcon = Icons.emoji_events;
        break;
      default:
        trophyColor = Colors.brown.shade400;
        trophyIcon = Icons.emoji_events;
    }

    return Expanded(
      child: Column(
        children: [
          Container(
            width: isFirst ? 80 : 60,
            height: isFirst ? 80 : 60,
            decoration: BoxDecoration(
              color: isFirst ? Colors.amber.shade100 : Colors.grey.shade100,
              shape: BoxShape.circle,
              border: Border.all(color: trophyColor, width: 3),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(trophyIcon, size: isFirst ? 50 : 35, color: trophyColor),
                Positioned(
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade700,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$rank',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            carpenter.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isFirst ? 14 : 12,
              fontWeight: isFirst ? FontWeight.bold : FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.monetization_on,
                color: Colors.amber.shade700,
                size: 16,
              ),
              const SizedBox(width: 2),
              Text(
                _formatPoints(carpenter.points),
                style: TextStyle(
                  fontSize: isFirst ? 14 : 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatPoints(int points) {
    if (points >= 1000) {
      return '${(points / 1000).toStringAsFixed(1)}K';
    }
    return points.toString();
  }
}

class CarpenterRank {
  final int rank;
  final String name;
  final int points;
  final String? imageUrl;

  CarpenterRank({
    required this.rank,
    required this.name,
    required this.points,
    this.imageUrl, required uid,
  });
}
