import 'package:balaji_points/features/transactions/domain/entities/transactions.dart';

/// Data model for transactions
/// 
/// Extends the domain entity and adds JSON serialization.
/// Handles conversion between JSON and domain entities.
class UtransactionsModel extends UtransactionsEntity {
  UtransactionsModel({
    required super.id,
  });
  
  /// Convert from JSON
  factory UtransactionsModel.fromJson(Map<String, dynamic> json) {
    return UtransactionsModel(
      id: json['id'] as String,
    );
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
  
  /// Convert from domain entity
  factory UtransactionsModel.fromEntity(UtransactionsEntity entity) {
    return UtransactionsModel(
      id: entity.id,
    );
  }
  
  /// Convert to domain entity
  UtransactionsEntity toEntity() {
    return UtransactionsEntity(
      id: id,
    );
  }
}
