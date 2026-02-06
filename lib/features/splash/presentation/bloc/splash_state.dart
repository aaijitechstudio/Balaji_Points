import 'package:equatable/equatable.dart';
import 'package:balaji_points/features/splash/domain/entities/session.dart';

/// States for Splash BLoC
abstract class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class SplashInitial extends SplashState {
  const SplashInitial();
}

/// Loading state - checking session
class SplashChecking extends SplashState {
  const SplashChecking();
}

/// User is authenticated with session data
class SplashAuthenticated extends SplashState {
  final Session session;

  const SplashAuthenticated(this.session);

  @override
  List<Object?> get props => [session];
}

/// User is not authenticated
class SplashUnauthenticated extends SplashState {
  const SplashUnauthenticated();
}

/// Error state
class SplashError extends SplashState {
  final String message;

  const SplashError(this.message);

  @override
  List<Object?> get props => [message];
}
