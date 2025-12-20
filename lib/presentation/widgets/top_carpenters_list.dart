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

  /// Get initials from name (e.g., "Ramesh Kumar" -> "RK")
  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
    }
    final firstInitial = parts[0].isNotEmpty ? parts[0][0] : '';
    final lastInitial = parts[parts.length - 1].isNotEmpty ? parts[parts.length - 1][0] : '';
    return (firstInitial + lastInitial).toUpperCase();
  }

  /// Check if URL is valid for NetworkImage (http or https)
  bool _isValidImageUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    final trimmed = url.trim();
    return trimmed.startsWith('http://') || trimmed.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    if (carpenters.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
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
        ),
        const SizedBox(height: 8),
        // Carpenters list with cards
        ...carpenters.map((carpenter) => _buildLeaderboardCard(carpenter)),
      ],
    );
  }

  Widget _buildLeaderboardCard(CarpenterRank carpenter) {
    // Determine rank badge color based on position
    Color rankBgColor;
    Color rankTextColor;

    if (carpenter.rank == 1) {
      rankBgColor = Colors.amber.shade100;
      rankTextColor = Colors.amber.shade700;
    } else if (carpenter.rank == 2) {
      rankBgColor = Colors.grey.shade200;
      rankTextColor = Colors.grey.shade700;
    } else if (carpenter.rank == 3) {
      rankBgColor = Colors.brown.shade100;
      rankTextColor = Colors.brown.shade700;
    } else {
      rankBgColor = AppColors.secondary.withValues(alpha: 0.1);
      rankTextColor = AppColors.secondary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank badge - Simple number for all ranks
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: rankBgColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${carpenter.rank}',
                style: TextStyle(
                  color: rankTextColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Profile Image or Initials
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: carpenter.isCurrentUser && _isValidImageUrl(carpenter.imageUrl)
                  ? Colors.transparent
                  : rankBgColor,
              border: Border.all(
                color: AppColors.secondary.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: carpenter.isCurrentUser && _isValidImageUrl(carpenter.imageUrl)
                ? ClipOval(
                    child: Image.network(
                      carpenter.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Text(
                            _getInitials(carpenter.name),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: rankTextColor,
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : Center(
                    child: Text(
                      _getInitials(carpenter.name),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: rankTextColor,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 16),

          // Name
          Expanded(
            child: Text(
              carpenter.name,
              style: AppTextStyles.nunitoSemiBold.copyWith(
                fontSize: 16,
                color: AppColors.textDark,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),

          // Points
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.amber.shade200,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.monetization_on,
                  color: Colors.amber.shade700,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatPoints(carpenter.points),
                  style: AppTextStyles.nunitoBold.copyWith(
                    fontSize: 16,
                    color: Colors.amber.shade900,
                  ),
                ),
              ],
            ),
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
