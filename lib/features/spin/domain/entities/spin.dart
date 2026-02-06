/// Domain entity for spin
/// 
/// This is a plain Dart class with no dependencies on external packages.
/// It represents the business logic model.
class UspinEntity {
  final String id;
  // Add your entity properties here
  
  UspinEntity({
    required this.id,
  });
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UspinEntity && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}
