/// Domain entity for transactions
/// 
/// This is a plain Dart class with no dependencies on external packages.
/// It represents the business logic model.
class UtransactionsEntity {
  final String id;
  // Add your entity properties here
  
  UtransactionsEntity({
    required this.id,
  });
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UtransactionsEntity && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}
