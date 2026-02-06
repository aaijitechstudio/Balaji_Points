import 'package:balaji_points/features/splash/domain/entities/session.dart';

/// Model for session data
/// 
/// This class represents session data as returned from the data source.
/// It extends Session entity and provides serialization methods.
class SessionModel extends Session {
  const SessionModel({
    super.id,
    super.phoneNumber,
    super.firstName,
    super.lastName,
    super.role,
  });

  /// Factory constructor to create SessionModel from JSON
  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['userId'] ?? json['id'],
      phoneNumber: json['phoneNumber'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      role: json['role'],
    );
  }

  /// Convert SessionModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'firstName': firstName,
      'lastName': lastName,
      'role': role,
    };
  }

  /// Convert to Session entity
  Session toEntity() {
    return Session(
      id: id,
      phoneNumber: phoneNumber,
      firstName: firstName,
      lastName: lastName,
      role: role,
    );
  }
}
