/// Domain entity for redeem
/// 
/// This is a plain Dart class with no dependencies on external packages.
/// It represents the business logic model.
class UredeemEntity {
  final String id;
  // Add your entity properties here
  
  UredeemEntity({
    required this.id,
  });
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UredeemEntity && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}
