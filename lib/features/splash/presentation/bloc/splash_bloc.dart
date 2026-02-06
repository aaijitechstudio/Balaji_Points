import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:balaji_points/features/splash/domain/usecases/check_session_usecase.dart';
import 'package:balaji_points/features/splash/presentation/bloc/splash_event.dart';
import 'package:balaji_points/features/splash/presentation/bloc/splash_state.dart';

/// BLoC for Splash
/// 
/// Handles state management for splash feature.
/// Uses use cases to execute business logic.
class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final CheckSessionUseCase checkSessionUseCase;

  SplashBloc({
    required this.checkSessionUseCase,
  }) : super(const SplashInitial()) {
    on<CheckSessionEvent>(_onCheckSession);
  }

  /// Handle CheckSessionEvent
  /// 
  /// Checks if user has an active session and emits appropriate state.
  Future<void> _onCheckSession(
    CheckSessionEvent event,
    Emitter<SplashState> emit,
  ) async {
    emit(const SplashChecking());

    final result = await checkSessionUseCase.call();

    result.fold(
      (failure) => emit(SplashError(failure.message)),
      (session) {
        if (session != null) {
          emit(SplashAuthenticated(session));
        } else {
          emit(const SplashUnauthenticated());
        }
      },
    );
  }
}
