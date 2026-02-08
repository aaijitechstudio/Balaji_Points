import 'package:dartz/dartz.dart';
import 'package:balaji_points/core/error/failures.dart';
import '../repositories/splash_repository.dart';

class CheckAuthStatus {
  final SplashRepository repository;
  
  CheckAuthStatus(this.repository);
  
  Future<Either<Failure, bool>> call() async {
    final result = await repository.checkSession();
    return result.fold(
      (failure) => Left(failure),
      (session) => Right(session != null),
    );
  }
}
