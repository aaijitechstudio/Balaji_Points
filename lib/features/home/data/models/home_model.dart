import 'package:balaji_points/features/home/domain/entities/home.dart';

/// Data model for home
/// 
/// Extends the domain entity and adds JSON serialization.
/// Handles conversion between JSON and domain entities.
class UhomeModel extends UhomeEntity {
  UhomeModel({
    required super.id,
  });
  
  /// Convert from JSON
  factory UhomeModel.fromJson(Map<String, dynamic> json) {
    return UhomeModel(
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
  factory UhomeModel.fromEntity(UhomeEntity entity) {
    return UhomeModel(
      id: entity.id,
    );
  }
  
  /// Convert to domain entity
  UhomeEntity toEntity() {
    return UhomeEntity(
      id: id,
    );
  }
}
