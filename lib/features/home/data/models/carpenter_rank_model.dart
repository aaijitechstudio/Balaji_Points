// lib/features/home/data/models/carpenter_rank_model.dart
// Carpenter ranking data model for leaderboard

/// Represents a carpenter's ranking in the leaderboard
class CarpenterRankModel {
  final String id;
  final int rank;
  final String name;
  final int points;
  final String? imageUrl;
  final bool isCurrentUser;
  final String? tier;

  CarpenterRankModel({
    required this.id,
    required this.rank,
    required this.name,
    required this.points,
    this.imageUrl,
    this.isCurrentUser = false,
    this.tier,
  });

  /// Create from map (for easy Firestore integration)
  factory CarpenterRankModel.fromMap(
    Map<String, dynamic> data,
    String userId, {
    required int rank,
    String? currentUserId,
  }) {
    return CarpenterRankModel(
      id: userId,
      rank: rank,
      name: data['name'] ?? 'Unknown',
      points: data['points'] ?? 0,
      imageUrl: data['imageUrl'] as String?,
      isCurrentUser: userId == currentUserId,
      tier: data['tier'] as String?,
    );
  }

  /// Get display name (fallback to "Carpenter #rank")
  String get displayName => name.isNotEmpty ? name : 'Carpenter #$rank';

  /// Get medal emoji for top 3
  String? get medalEmoji {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return null;
    }
  }

  /// Check if this is a top performer (top 3)
  bool get isTopPerformer => rank <= 3;

  /// Copy with method for immutability
  CarpenterRankModel copyWith({
    String? id,
    int? rank,
    String? name,
    int? points,
    String? imageUrl,
    bool? isCurrentUser,
    String? tier,
  }) {
    return CarpenterRankModel(
      id: id ?? this.id,
      rank: rank ?? this.rank,
      name: name ?? this.name,
      points: points ?? this.points,
      imageUrl: imageUrl ?? this.imageUrl,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
      tier: tier ?? this.tier,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CarpenterRankModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          rank == other.rank;

  @override
  int get hashCode => id.hashCode ^ rank.hashCode;

  @override
  String toString() =>
      'CarpenterRankModel(id: $id, rank: $rank, name: $name, points: $points)';
}
