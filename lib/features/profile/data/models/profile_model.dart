import 'package:balaji_points/features/profile/domain/entities/profile.dart';

/// Data model for profile
/// 
/// Extends the domain entity and adds JSON serialization.
/// Handles conversion between JSON and domain entities.
class UprofileModel extends UprofileEntity {
  UprofileModel({
    required super.id,
  });
  
  /// Convert from JSON
  factory UprofileModel.fromJson(Map<String, dynamic> json) {
    return UprofileModel(
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
  factory UprofileModel.fromEntity(UprofileEntity entity) {
    return UprofileModel(
      id: entity.id,
    );
  }
  
  /// Convert to domain entity
  UprofileEntity toEntity() {
    return UprofileEntity(
      id: id,
    );
  }
}
