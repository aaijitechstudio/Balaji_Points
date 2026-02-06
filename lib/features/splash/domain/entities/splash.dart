/// Domain entity for splash
/// 
/// This is a plain Dart class with no dependencies on external packages.
/// It represents the business logic model.
class UsplashEntity {
  final String id;
  // Add your entity properties here
  
  UsplashEntity({
    required this.id,
  });
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UsplashEntity && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}
