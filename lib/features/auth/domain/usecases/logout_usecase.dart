import 'package:dartz/dartz.dart';
import 'package:balaji_points/core/error/failures.dart';
import 'package:balaji_points/features/auth/domain/repositories/auth_repository.dart';

/// Use case for logout
class LogoutUseCase {
  final AuthRepository repository;
  
  LogoutUseCase(this.repository);
  
  Future<Either<Failure, void>> call() {
    return repository.logout();
  }
}
