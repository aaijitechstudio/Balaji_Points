// filepath: lib/injection/dependency_injection.dart
import 'package:get_it/get_it.dart';
import 'package:balaji_points/services/pin_auth_service.dart';
import 'package:balaji_points/services/session_service.dart';
import 'package:balaji_points/services/fcm_service.dart';
import 'package:balaji_points/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:balaji_points/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:balaji_points/features/auth/domain/repositories/auth_repository.dart';
import 'package:balaji_points/features/auth/presentation/bloc/auth_bloc.dart';

final getIt = GetIt.instance;

/// Setup dependency injection
/// Call this in main() before runApp()
Future<void> setupDependencyInjection() async {
  // ============================================
  // SERVICES (Existing - Singletons)
  // ============================================
  getIt.registerLazySingleton(() => PinAuthService());
  getIt.registerLazySingleton(() => SessionService());
  getIt.registerLazySingleton(() => FCMService());

  // ============================================
  // AUTH FEATURE
  // ============================================
  
  // Data sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      pinAuthService: getIt<PinAuthService>(),
      sessionService: getIt<SessionService>(),
      fcmService: getIt<FCMService>(),
    ),
  );

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
    ),
  );

  // BLoC (Factory - new instance each time)
  getIt.registerFactory(
    () => AuthBloc(
      pinAuthService: getIt<PinAuthService>(),
      sessionService: getIt<SessionService>(),
      fcmService: getIt<FCMService>(),
    ),
  );
}
