/// Domain entity for wallet statistics
/// 
/// This is a plain Dart class with no dependencies on external packages.
/// It represents the business logic model for wallet stats.
class WalletStats {
  final int totalPoints;
  final String tier;
  final int pendingCount;
  final int approvedCount;
  
  const WalletStats({
    required this.totalPoints,
    required this.tier,
    required this.pendingCount,
    required this.approvedCount,
  });
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WalletStats &&
        other.totalPoints == totalPoints &&
        other.tier == tier &&
        other.pendingCount == pendingCount &&
        other.approvedCount == approvedCount;
  }
  
  @override
  int get hashCode => Object.hash(totalPoints, tier, pendingCount, approvedCount);
}
