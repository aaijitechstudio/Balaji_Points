import 'package:balaji_points/features/spin/domain/entities/spin.dart';

/// Data model for spin
/// 
/// Extends the domain entity and adds JSON serialization.
/// Handles conversion between JSON and domain entities.
class UspinModel extends UspinEntity {
  UspinModel({
    required super.id,
  });
  
  /// Convert from JSON
  factory UspinModel.fromJson(Map<String, dynamic> json) {
    return UspinModel(
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
  factory UspinModel.fromEntity(UspinEntity entity) {
    return UspinModel(
      id: entity.id,
    );
  }
  
  /// Convert to domain entity
  UspinEntity toEntity() {
    return UspinEntity(
      id: id,
    );
  }
}
