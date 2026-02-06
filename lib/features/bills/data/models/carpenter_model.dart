import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:balaji_points/features/bills/domain/entities/carpenter.dart';

/// Data model for Carpenter
class CarpenterModel extends Carpenter {
  const CarpenterModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.phone,
    super.city,
    super.skill,
    super.profileImage,
  });

  /// Convert from Firestore document
  factory CarpenterModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CarpenterModel.fromJson(data, doc.id);
  }

  /// Convert from JSON
  factory CarpenterModel.fromJson(Map<String, dynamic> json, [String? id]) {
    return CarpenterModel(
      id: id ?? json['userId'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      city: json['city'] as String?,
      skill: json['skill'] as String?,
      profileImage: json['profileImage'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': id,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      if (city != null) 'city': city,
      if (skill != null) 'skill': skill,
      if (profileImage != null) 'profileImage': profileImage,
    };
  }

  /// Convert from domain entity
  factory CarpenterModel.fromEntity(Carpenter carpenter) {
    return CarpenterModel(
      id: carpenter.id,
      firstName: carpenter.firstName,
      lastName: carpenter.lastName,
      phone: carpenter.phone,
      city: carpenter.city,
      skill: carpenter.skill,
      profileImage: carpenter.profileImage,
    );
  }

  /// Convert to domain entity
  Carpenter toEntity() {
    return Carpenter(
      id: id,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      city: city,
      skill: skill,
      profileImage: profileImage,
    );
  }
}
