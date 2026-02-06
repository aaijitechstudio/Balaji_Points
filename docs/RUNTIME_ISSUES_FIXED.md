# Runtime Issues Fixed

## Issue #1: SplashBloc Provider Not Found (2026-02-06)

### Error
```
Error: Could not find the correct Provider<SplashBloc> above this SplashPage Widget
```

### Root Causes
1. SplashBloc was not registered in dependency injection
2. SplashPage route was not wrapped with BlocProvider
3. SplashBloc was not imported in routes.dart

### Fixes Applied

#### 1. Added SplashBloc to DI (`lib/injection/dependency_injection.dart`)
```dart
// Splash Feature DI
getIt.registerLazySingleton<SplashRemoteDataSource>(
  () => SplashRemoteDataSourceImpl(getIt<SessionService>()),
);

getIt.registerLazySingleton<SplashRepository>(
  () => SplashRepositoryImpl(remoteDataSource: getIt<SplashRemoteDataSource>()),
);

getIt.registerLazySingleton(
  () => CheckSessionUseCase(getIt<SplashRepository>()),
);

getIt.registerFactory(
  () => SplashBloc(checkSessionUseCase: getIt<CheckSessionUseCase>()),
);
```

#### 2. Updated Routes (`lib/config/routes.dart`)
```dart
// Added import
import 'package:balaji_points/features/splash/presentation/bloc/splash_bloc.dart';

// Wrapped route with BlocProvider
GoRoute(
  path: '/splash',
  builder: (context, _) => BlocProvider(
    create: (_) => getIt<SplashBloc>(),
    child: const SplashPage(),
  ),
),
```

### Lessons Learned
- When migrating screens to BLoC, ensure:
  1. BLoC is registered in DI
  2. BLoC is imported in routes
  3. Page is wrapped with BlocProvider
  4. Constructor parameters match (positional vs named)

### Status
✅ FIXED - Build compiles, app runs successfully

---

## Checklist for Future BLoC Migrations

When adding a new BLoC screen:

- [ ] Create BLoC files (bloc, event, state)
- [ ] Create domain layer (entities, repositories, use cases)
- [ ] Create data layer (models, data sources, repository impl)
- [ ] Register data source in DI
- [ ] Register repository in DI
- [ ] Register use cases in DI
- [ ] Register BLoC in DI (as factory)
- [ ] Import BLoC in routes.dart
- [ ] Wrap route with BlocProvider
- [ ] Test hot restart (not hot reload)

---

**Last Updated:** 2026-02-06
