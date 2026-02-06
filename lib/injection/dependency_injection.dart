// filepath: lib/injection/dependency_injection.dart
import 'package:get_it/get_it.dart';
import 'package:balaji_points/services/pin_auth_service.dart';
import 'package:balaji_points/services/session_service.dart';
import 'package:balaji_points/services/fcm_service.dart';
import 'package:balaji_points/services/bill_service.dart';
import 'package:balaji_points/services/user_service.dart';
import 'package:balaji_points/services/storage_service.dart';
import 'package:balaji_points/services/offer_service.dart';
import 'package:balaji_points/services/notification_service.dart';
import 'package:balaji_points/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:balaji_points/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:balaji_points/features/auth/domain/repositories/auth_repository.dart';
import 'package:balaji_points/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:balaji_points/features/splash/data/datasources/splash_remote_datasource.dart';
import 'package:balaji_points/features/splash/data/repositories/splash_repository_impl.dart';
import 'package:balaji_points/features/splash/domain/repositories/splash_repository.dart';
import 'package:balaji_points/features/splash/domain/usecases/check_session_usecase.dart';
import 'package:balaji_points/features/splash/presentation/bloc/splash_bloc.dart';

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
  getIt.registerLazySingleton(() => BillService());
  getIt.registerLazySingleton(() => UserService());
  getIt.registerLazySingleton(() => StorageService());
  getIt.registerLazySingleton(() => OfferService());
  getIt.registerLazySingleton(() => NotificationService());

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
  
  // ============================================
  // SPLASH FEATURE
  // ============================================
  
  // Data sources
  getIt.registerLazySingleton<SplashRemoteDataSource>(
    () => SplashRemoteDataSourceImpl(
      getIt<SessionService>(),
    ),
  );

  // Repositories
  getIt.registerLazySingleton<SplashRepository>(
    () => SplashRepositoryImpl(
      remoteDataSource: getIt<SplashRemoteDataSource>(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton(
    () => CheckSessionUseCase(
      getIt<SplashRepository>(),
    ),
  );

  // BLoC (Factory - new instance each time)
  getIt.registerFactory(
    () => SplashBloc(
      checkSessionUseCase: getIt<CheckSessionUseCase>(),
    ),
  );
  
  // ============================================
  // NOTE: Other features (wallet, bills, home, profile, admin, etc.)
  // use existing services directly in their UI for now.
  // BLoC/domain layers exist but not yet wired up - will be done
  // after confirming all UIs work with current service calls.
  // ============================================
}
