import 'package:balaji_points/features/redeem/domain/entities/redeem.dart';

/// Data model for redeem
/// 
/// Extends the domain entity and adds JSON serialization.
/// Handles conversion between JSON and domain entities.
class UredeemModel extends UredeemEntity {
  UredeemModel({
    required super.id,
  });
  
  /// Convert from JSON
  factory UredeemModel.fromJson(Map<String, dynamic> json) {
    return UredeemModel(
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
  factory UredeemModel.fromEntity(UredeemEntity entity) {
    return UredeemModel(
      id: entity.id,
    );
  }
  
  /// Convert to domain entity
  UredeemEntity toEntity() {
    return UredeemEntity(
      id: id,
    );
  }
}
