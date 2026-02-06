/// Domain entity for profile
/// 
/// This is a plain Dart class with no dependencies on external packages.
/// It represents the business logic model.
class UprofileEntity {
  final String id;
  // Add your entity properties here
  
  UprofileEntity({
    required this.id,
  });
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UprofileEntity && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}
