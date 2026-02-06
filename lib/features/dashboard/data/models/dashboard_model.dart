import 'package:balaji_points/features/dashboard/domain/entities/dashboard.dart';

/// Data model for dashboard
/// 
/// Extends the domain entity and adds JSON serialization.
/// Handles conversion between JSON and domain entities.
class UdashboardModel extends UdashboardEntity {
  UdashboardModel({
    required super.id,
  });
  
  /// Convert from JSON
  factory UdashboardModel.fromJson(Map<String, dynamic> json) {
    return UdashboardModel(
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
  factory UdashboardModel.fromEntity(UdashboardEntity entity) {
    return UdashboardModel(
      id: entity.id,
    );
  }
  
  /// Convert to domain entity
  UdashboardEntity toEntity() {
    return UdashboardEntity(
      id: id,
    );
  }
}
