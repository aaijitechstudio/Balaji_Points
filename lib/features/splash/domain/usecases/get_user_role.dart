import 'package:dartz/dartz.dart';
import 'package:balaji_points/core/error/failures.dart';
import '../repositories/splash_repository.dart';

class GetUserRole {
  final SplashRepository repository;
  
  GetUserRole(this.repository);
  
  Future<Either<Failure, String?>> call() async {
    final result = await repository.checkSession();
    return result.fold(
      (failure) => Left(failure),
      (session) => Right(session?.role),
    );
  }
}
