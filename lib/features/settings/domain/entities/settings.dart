/// Domain entity for settings
/// 
/// This is a plain Dart class with no dependencies on external packages.
/// It represents the business logic model.
class UsettingsEntity {
  final String id;
  // Add your entity properties here
  
  UsettingsEntity({
    required this.id,
  });
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UsettingsEntity && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}
