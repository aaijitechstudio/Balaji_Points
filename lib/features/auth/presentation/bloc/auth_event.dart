// filepath: lib/features/auth/presentation/bloc/auth_event.dart
import 'package:equatable/equatable.dart';

/// Events for Auth BLoC
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Check if user exists by phone number
class CheckUserExistsEvent extends AuthEvent {
  final String phoneNumber;

  const CheckUserExistsEvent(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

/// Login with PIN
class LoginWithPinEvent extends AuthEvent {
  final String phoneNumber;
  final String pin;
  final bool rememberMe;

  const LoginWithPinEvent({
    required this.phoneNumber,
    required this.pin,
    this.rememberMe = true,
  });

  @override
  List<Object?> get props => [phoneNumber, pin, rememberMe];
}

/// Setup PIN for new user
class SetupPinEvent extends AuthEvent {
  final String phoneNumber;
  final String pin;
  final String firstName;
  final String? lastName;
  final String? profileImageUrl;

  const SetupPinEvent({
    required this.phoneNumber,
    required this.pin,
    required this.firstName,
    this.lastName,
    this.profileImageUrl,
  });

  @override
  List<Object?> get props => [
        phoneNumber,
        pin,
        firstName,
        lastName,
        profileImageUrl,
      ];
}

/// Reset PIN (requires old PIN verification)
class ResetPinEvent extends AuthEvent {
  final String phoneNumber;
  final String oldPin;
  final String newPin;

  const ResetPinEvent({
    required this.phoneNumber,
    required this.oldPin,
    required this.newPin,
  });

  @override
  List<Object?> get props => [phoneNumber, oldPin, newPin];
}

/// Logout
class LogoutRequestedEvent extends AuthEvent {
  const LogoutRequestedEvent();
}

/// Check current session (on app startup)
class CheckSessionEvent extends AuthEvent {
  const CheckSessionEvent();
}
