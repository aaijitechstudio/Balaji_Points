// filepath: lib/features/auth/presentation/bloc/auth_state.dart
import 'package:equatable/equatable.dart';
import 'package:balaji_points/features/auth/domain/entities/user.dart';

/// States for Auth BLoC
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Checking if user exists
class CheckingUserState extends AuthState {
  const CheckingUserState();
}

/// User exists (navigate to PIN login)
class UserExistsState extends AuthState {
  final String phoneNumber;

  const UserExistsState(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

/// User does not exist (navigate to PIN setup)
class UserDoesNotExistState extends AuthState {
  final String phoneNumber;

  const UserDoesNotExistState(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

/// Logging in (PIN verification in progress)
class AuthLoadingState extends AuthState {
  const AuthLoadingState();
}

/// User authenticated successfully
class AuthAuthenticatedState extends AuthState {
  final User user;
  final String? role;

  const AuthAuthenticatedState(this.user, {this.role});

  @override
  List<Object?> get props => [user, role];
}

/// User is not authenticated
class AuthUnauthenticatedState extends AuthState {
  const AuthUnauthenticatedState();
}

/// Authentication error
class AuthErrorState extends AuthState {
  final String message;

  const AuthErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

/// PIN setup in progress
class PinSetupLoadingState extends AuthState {
  const PinSetupLoadingState();
}

/// PIN setup successful (user created and auto-logged in)
class PinSetupSuccessState extends AuthState {
  final User user;

  const PinSetupSuccessState(this.user);

  @override
  List<Object?> get props => [user];
}

/// PIN setup error
class PinSetupErrorState extends AuthState {
  final String message;

  const PinSetupErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

/// PIN reset in progress
class ResetPinLoadingState extends AuthState {
  const ResetPinLoadingState();
}

/// PIN reset successful
class ResetPinSuccessState extends AuthState {
  const ResetPinSuccessState();
}

/// PIN reset error
class ResetPinErrorState extends AuthState {
  final String message;

  const ResetPinErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
