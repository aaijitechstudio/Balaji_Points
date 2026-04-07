// filepath: lib/features/auth/presentation/bloc/auth_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:balaji_points/services/pin_auth_service.dart';
import 'package:balaji_points/services/session_service.dart';
import 'package:balaji_points/services/fcm_service.dart';
import 'package:balaji_points/features/auth/domain/entities/user.dart';
import 'package:balaji_points/features/auth/presentation/bloc/auth_event.dart';
import 'package:balaji_points/features/auth/presentation/bloc/auth_state.dart';
import 'package:balaji_points/core/logger.dart';

/// BLoC for authentication
///
/// Handles all authentication-related business logic including:
/// - Checking if user exists
/// - PIN-based login
/// - PIN setup for new users
/// - PIN reset
/// - Session management
/// - FCM token management
///
/// Uses existing services (PinAuthService, SessionService, FCMService)
/// to maintain compatibility during migration.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final PinAuthService _pinAuthService;
  final SessionService _sessionService;

  AuthBloc({
    required PinAuthService pinAuthService,
    required SessionService sessionService,
    required FCMService fcmService,
  }) : _pinAuthService = pinAuthService,
       _sessionService = sessionService,
       super(const AuthInitial()) {
    on<CheckUserExistsEvent>(_onCheckUserExists);
    on<LoginWithPinEvent>(_onLoginWithPin);
    on<SetupPinEvent>(_onSetupPin);
    on<ResetPinEvent>(_onResetPin);
    on<LogoutRequestedEvent>(_onLogoutRequested);
    on<CheckSessionEvent>(_onCheckSession);
  }

  /// Check if user exists by phone number
  Future<void> _onCheckUserExists(
    CheckUserExistsEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const CheckingUserState());

    try {
      final exists = await _pinAuthService.userExists(event.phoneNumber);

      if (exists) {
        emit(UserExistsState(event.phoneNumber));
      } else {
        emit(UserDoesNotExistState(event.phoneNumber));
      }
    } catch (e) {
      AppLogger.error('Error checking user existence', e);
      emit(AuthErrorState('Error checking user: $e'));
    }
  }

  /// Login with PIN
  Future<void> _onLoginWithPin(
    LoginWithPinEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState());

    try {
      final userData = await _pinAuthService.verifyPin(
        phone: event.phoneNumber,
        pin: event.pin,
      );

      if (userData == null) {
        emit(const AuthErrorState('Invalid PIN'));
        return;
      }

      // Save session if remember me is checked
      if (event.rememberMe) {
        final normalizedRole = (userData['role'] as String? ?? 'carpenter')
            .trim()
            .toLowerCase();
        await _sessionService.saveSession(
          phoneNumber: event.phoneNumber,
          userId: userData['id'] as String? ?? event.phoneNumber,
          role: normalizedRole,
          firstName: userData['firstName'] as String?,
          lastName: userData['lastName'] as String?,
        );
      }

      // Refresh FCM token after successful login
      try {
        // FCM token refresh handled in datasource
        // await _fcmService.initialize(event.phoneNumber);
      } catch (e) {
        // Don't fail login if FCM fails
      }

      // Create User entity from Firebase data
      final user = User(
        id:
            userData['id'] as String? ??
            userData['userId'] as String? ??
            event.phoneNumber,
        email: userData['email'] as String? ?? '',
        phoneNumber: event.phoneNumber,
        displayName: _buildDisplayName(
          userData['firstName'] as String?,
          userData['lastName'] as String?,
        ),
        photoUrl: userData['profileImage'] as String?,
        role: (userData['role'] as String? ?? 'carpenter').trim().toLowerCase(),
        isEmailVerified: true, // Phone-verified user
        createdAt: DateTime.now(), // Will be replaced with Firestore timestamp
      );

      emit(AuthAuthenticatedState(user, role: user.role));
    } catch (e) {
      AppLogger.error('Login failed', e);
      emit(AuthErrorState('Login failed: $e'));
    }
  }

  /// Setup PIN for new user
  Future<void> _onSetupPin(SetupPinEvent event, Emitter<AuthState> emit) async {
    emit(const PinSetupLoadingState());

    try {
      final success = await _pinAuthService.setPinForPhone(
        phone: event.phoneNumber,
        pin: event.pin,
        firstName: event.firstName,
        lastName: event.lastName,
        profileImageUrl: event.profileImageUrl,
      );

      if (!success) {
        emit(const PinSetupErrorState('Failed to setup PIN'));
        return;
      }

      // Auto-login after successful setup
      final userData = await _pinAuthService.verifyPin(
        phone: event.phoneNumber,
        pin: event.pin,
      );

      if (userData == null) {
        emit(const PinSetupErrorState('Auto-login failed after setup'));
        return;
      }

      // Save session
      await _sessionService.saveSession(
        phoneNumber: event.phoneNumber,
        userId: userData['id'] as String? ?? event.phoneNumber,
        role: (userData['role'] as String? ?? 'carpenter').trim().toLowerCase(),
        firstName: userData['firstName'] as String?,
        lastName: userData['lastName'] as String?,
      );

      // Refresh FCM token
      try {
        // FCM token refresh handled in datasource
        // await _fcmService.initialize(event.phoneNumber);
      } catch (e) {
        // Don't fail setup if FCM fails
      }

      // Create User entity
      final user = User(
        id:
            userData['id'] as String? ??
            userData['userId'] as String? ??
            event.phoneNumber,
        email: userData['email'] as String? ?? '',
        phoneNumber: event.phoneNumber,
        displayName: _buildDisplayName(event.firstName, event.lastName),
        photoUrl: event.profileImageUrl,
        role: userData['role'] as String? ?? 'carpenter',
        isEmailVerified: true,
        createdAt: DateTime.now(),
      );

      emit(PinSetupSuccessState(user));
    } catch (e) {
      AppLogger.error('PIN setup failed', e);
      emit(PinSetupErrorState('PIN setup failed: $e'));
    }
  }

  /// Reset PIN (requires old PIN verification)
  Future<void> _onResetPin(ResetPinEvent event, Emitter<AuthState> emit) async {
    emit(const ResetPinLoadingState());

    try {
      // Verify old PIN first
      final userData = await _pinAuthService.verifyPin(
        phone: event.phoneNumber,
        pin: event.oldPin,
      );

      if (userData == null) {
        emit(const ResetPinErrorState('Invalid current PIN'));
        return;
      }

      // Set new PIN
      final success = await _pinAuthService.setPinForPhone(
        phone: event.phoneNumber,
        pin: event.newPin,
      );

      if (success) {
        emit(const ResetPinSuccessState());
      } else {
        emit(const ResetPinErrorState('Failed to reset PIN'));
      }
    } catch (e) {
      AppLogger.error('PIN reset failed', e);
      emit(ResetPinErrorState('PIN reset failed: $e'));
    }
  }

  /// Logout
  Future<void> _onLogoutRequested(
    LogoutRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _sessionService.clearSession();
      emit(const AuthUnauthenticatedState());
    } catch (e) {
      AppLogger.error('Logout failed', e);
      emit(AuthErrorState('Logout failed: $e'));
    }
  }

  /// Check current session (on app startup)
  Future<void> _onCheckSession(
    CheckSessionEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final session = await _sessionService.getSessionData();

      if (session.isNotEmpty) {
        // Session exists, create User entity
        final user = User(
          id: session['userId'] ?? '',
          email: '',
          phoneNumber: session['phoneNumber'] ?? '',
          displayName: _buildDisplayName(
            session['firstName'],
            session['lastName'],
          ),
          role: (session['role'] ?? 'carpenter').trim().toLowerCase(),
          isEmailVerified: true,
          createdAt: DateTime.now(),
        );

        emit(AuthAuthenticatedState(user, role: user.role));
      } else {
        emit(const AuthUnauthenticatedState());
      }
    } catch (e) {
      AppLogger.error('Session check failed', e);
      emit(const AuthUnauthenticatedState());
    }
  }

  /// Helper: Build display name from first and last name
  String _buildDisplayName(String? firstName, String? lastName) {
    final name = '${firstName ?? ''} ${lastName ?? ''}'.trim();
    return name.isEmpty ? 'User' : name;
  }
}
