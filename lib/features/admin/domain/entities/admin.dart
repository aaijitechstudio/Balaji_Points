/// Domain entity for admin
/// 
/// This is a plain Dart class with no dependencies on external packages.
/// It represents the business logic model.
class UadminEntity {
  final String id;
  // Add your entity properties here
  
  UadminEntity({
    required this.id,
  });
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UadminEntity && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}
