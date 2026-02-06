import 'package:dartz/dartz.dart';
import 'package:balaji_points/core/error/failures.dart';
import 'package:balaji_points/features/auth/domain/entities/user.dart';
import 'package:balaji_points/features/auth/domain/repositories/auth_repository.dart';

/// Use case for getting current user
class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<Either<Failure, User?>> call() {
    return repository.getCurrentUser();
  }
}
