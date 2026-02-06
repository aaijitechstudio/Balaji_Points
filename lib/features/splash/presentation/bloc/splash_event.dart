import 'package:equatable/equatable.dart';

/// Events for Splash BLoC
abstract class SplashEvent extends Equatable {
  const SplashEvent();

  @override
  List<Object?> get props => [];
}

/// Event to check the current session
class CheckSessionEvent extends SplashEvent {
  const CheckSessionEvent();

  @override
  List<Object?> get props => [];
}
