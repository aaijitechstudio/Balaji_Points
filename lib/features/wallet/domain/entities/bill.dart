/// Domain entity for bill
/// 
/// This is a plain Dart class with no dependencies on external packages.
/// It represents the business logic model for a bill/transaction.
class Bill {
  final String id;
  final String storeName;
  final double amount;
  final String status;
  final int pointsEarned;
  final DateTime? createdAt;
  final String carpenterId;
  
  const Bill({
    required this.id,
    required this.storeName,
    required this.amount,
    required this.status,
    required this.pointsEarned,
    this.createdAt,
    required this.carpenterId,
  });
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Bill &&
        other.id == id &&
        other.storeName == storeName &&
        other.amount == amount &&
        other.status == status &&
        other.pointsEarned == pointsEarned &&
        other.createdAt == createdAt &&
        other.carpenterId == carpenterId;
  }
  
  @override
  int get hashCode => Object.hash(
        id,
        storeName,
        amount,
        status,
        pointsEarned,
        createdAt,
        carpenterId,
      );
}
