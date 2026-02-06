import 'package:balaji_points/features/notifications/domain/entities/notifications.dart';

/// Data model for notifications
/// 
/// Extends the domain entity and adds JSON serialization.
/// Handles conversion between JSON and domain entities.
class UnotificationsModel extends UnotificationsEntity {
  UnotificationsModel({
    required super.id,
  });
  
  /// Convert from JSON
  factory UnotificationsModel.fromJson(Map<String, dynamic> json) {
    return UnotificationsModel(
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
  factory UnotificationsModel.fromEntity(UnotificationsEntity entity) {
    return UnotificationsModel(
      id: entity.id,
    );
  }
  
  /// Convert to domain entity
  UnotificationsEntity toEntity() {
    return UnotificationsEntity(
      id: id,
    );
  }
}
