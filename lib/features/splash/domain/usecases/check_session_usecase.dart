import 'package:dartz/dartz.dart';
import 'package:balaji_points/core/error/failures.dart';
import 'package:balaji_points/features/splash/domain/entities/session.dart';
import 'package:balaji_points/features/splash/domain/repositories/splash_repository.dart';

/// Use case for checking the current user session
/// 
/// This use case wraps the repository call to check if a user is logged in.
class CheckSessionUseCase {
  final SplashRepository repository;

  CheckSessionUseCase(this.repository);

  /// Execute the check session use case
  /// 
  /// Returns [Either<Failure, Session?>] where Right contains the Session if
  /// user is logged in, or null if not. Left contains the failure information.
  Future<Either<Failure, Session?>> call() async {
    return await repository.checkSession();
  }
}
