import 'package:balaji_points/features/admin/domain/entities/admin.dart';

/// Data model for admin
/// 
/// Extends the domain entity and adds JSON serialization.
/// Handles conversion between JSON and domain entities.
class UadminModel extends UadminEntity {
  UadminModel({
    required super.id,
  });
  
  /// Convert from JSON
  factory UadminModel.fromJson(Map<String, dynamic> json) {
    return UadminModel(
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
  factory UadminModel.fromEntity(UadminEntity entity) {
    return UadminModel(
      id: entity.id,
    );
  }
  
  /// Convert to domain entity
  UadminEntity toEntity() {
    return UadminEntity(
      id: id,
    );
  }
}
