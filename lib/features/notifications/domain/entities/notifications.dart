/// Domain entity for notifications
/// 
/// This is a plain Dart class with no dependencies on external packages.
/// It represents the business logic model.
class UnotificationsEntity {
  final String id;
  // Add your entity properties here
  
  UnotificationsEntity({
    required this.id,
  });
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UnotificationsEntity && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}
