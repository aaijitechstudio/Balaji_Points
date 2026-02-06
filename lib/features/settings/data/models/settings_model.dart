import 'package:balaji_points/features/settings/domain/entities/settings.dart';

/// Data model for settings
/// 
/// Extends the domain entity and adds JSON serialization.
/// Handles conversion between JSON and domain entities.
class UsettingsModel extends UsettingsEntity {
  UsettingsModel({
    required super.id,
  });
  
  /// Convert from JSON
  factory UsettingsModel.fromJson(Map<String, dynamic> json) {
    return UsettingsModel(
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
  factory UsettingsModel.fromEntity(UsettingsEntity entity) {
    return UsettingsModel(
      id: entity.id,
    );
  }
  
  /// Convert to domain entity
  UsettingsEntity toEntity() {
    return UsettingsEntity(
      id: id,
    );
  }
}
