/// Domain entity for home
/// 
/// This is a plain Dart class with no dependencies on external packages.
/// It represents the business logic model.
class UhomeEntity {
  final String id;
  // Add your entity properties here
  
  UhomeEntity({
    required this.id,
  });
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UhomeEntity && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}
