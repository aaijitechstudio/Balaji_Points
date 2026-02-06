import 'package:balaji_points/features/splash/domain/entities/splash.dart';

/// Data model for splash
/// 
/// Extends the domain entity and adds JSON serialization.
/// Handles conversion between JSON and domain entities.
class UsplashModel extends UsplashEntity {
  UsplashModel({
    required super.id,
  });
  
  /// Convert from JSON
  factory UsplashModel.fromJson(Map<String, dynamic> json) {
    return UsplashModel(
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
  factory UsplashModel.fromEntity(UsplashEntity entity) {
    return UsplashModel(
      id: entity.id,
    );
  }
  
  /// Convert to domain entity
  UsplashEntity toEntity() {
    return UsplashEntity(
      id: id,
    );
  }
}
