/// Domain entity for dashboard
/// 
/// This is a plain Dart class with no dependencies on external packages.
/// It represents the business logic model.
class UdashboardEntity {
  final String id;
  // Add your entity properties here
  
  UdashboardEntity({
    required this.id,
  });
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UdashboardEntity && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}
