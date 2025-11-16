import 'package:flutter/material.dart';
import 'package:balaji_points/config/theme.dart';
import 'top_carpenters_display.dart';

class TopCarpentersList extends StatelessWidget {
  final List<CarpenterRank> carpenters;
  final bool showViewAll;

  const TopCarpentersList({
    super.key,
    required this.carpenters,
    this.showViewAll = true,
  });

  @override
  Widget build(BuildContext context) {
    if (carpenters.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '🏆 Top Carpenters',
              style: TextStyle(
                color: AppColors.secondary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (showViewAll)
              TextButton(onPressed: () {}, child: const Text('View All')),
          ],
        ),
        const SizedBox(height: 16),
        ...carpenters.map((carpenter) => _buildLeaderboardRow(carpenter)),
      ],
    );
  }

  Widget _buildLeaderboardRow(CarpenterRank carpenter) {
    Widget rankWidget;

    if (carpenter.rank == 1) {
      rankWidget = Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.amber.shade100,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.emoji_events, color: Colors.amber, size: 24),
      );
    } else if (carpenter.rank == 2) {
      rankWidget = Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.emoji_events, color: Colors.grey, size: 24),
      );
    } else if (carpenter.rank == 3) {
      rankWidget = Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.brown.shade100,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.emoji_events, color: Colors.brown.shade400, size: 24),
      );
    } else {
      rankWidget = CircleAvatar(
        backgroundColor: Colors.pink.shade100,
        radius: 18,
        child: Text(
          '${carpenter.rank}',
          style: TextStyle(
            color: AppColors.secondary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          rankWidget,
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.blue.shade100,
            backgroundImage: carpenter.imageUrl != null
                ? NetworkImage(carpenter.imageUrl!)
                : null,
            child: carpenter.imageUrl == null
                ? const Icon(Icons.person, size: 20, color: Colors.blue)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              carpenter.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
                _formatPoints(carpenter.points),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
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
