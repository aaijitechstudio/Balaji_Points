import 'package:balaji_points/features/wallet/domain/entities/wallet_stats.dart';

/// Data model for wallet stats
/// 
/// Extends the domain entity and adds JSON serialization.
/// Handles conversion between Firestore and domain entities.
class WalletStatsModel extends WalletStats {
  const WalletStatsModel({
    required super.totalPoints,
    required super.tier,
    required super.pendingCount,
    required super.approvedCount,
  });
  
  /// Convert from Firestore JSON
  factory WalletStatsModel.fromJson(Map<String, dynamic> json) {
    return WalletStatsModel(
      totalPoints: json['totalPoints'] as int? ?? 0,
      tier: json['tier'] as String? ?? 'Bronze',
      pendingCount: json['pendingCount'] as int? ?? 0,
      approvedCount: json['approvedCount'] as int? ?? 0,
    );
  }
  
  /// Convert to Firestore JSON
  Map<String, dynamic> toJson() {
    return {
      'totalPoints': totalPoints,
      'tier': tier,
      'pendingCount': pendingCount,
      'approvedCount': approvedCount,
    };
  }
  
  /// Convert from domain entity
  factory WalletStatsModel.fromEntity(WalletStats entity) {
    return WalletStatsModel(
      totalPoints: entity.totalPoints,
      tier: entity.tier,
      pendingCount: entity.pendingCount,
      approvedCount: entity.approvedCount,
    );
  }
  
  /// Convert to domain entity
  WalletStats toEntity() {
    return WalletStats(
      totalPoints: totalPoints,
      tier: tier,
      pendingCount: pendingCount,
      approvedCount: approvedCount,
    );
  }
}
