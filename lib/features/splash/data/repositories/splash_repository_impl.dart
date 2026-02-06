import 'package:dartz/dartz.dart';
import 'package:balaji_points/core/error/failures.dart';
import 'package:balaji_points/features/splash/domain/entities/session.dart';
import 'package:balaji_points/features/splash/domain/repositories/splash_repository.dart';
import 'package:balaji_points/features/splash/data/datasources/splash_remote_datasource.dart';

/// Repository implementation for splash
/// 
/// Implements the repository interface from domain layer.
/// Handles data source calls and error conversion.
class SplashRepositoryImpl implements SplashRepository {
  final SplashRemoteDataSource remoteDataSource;

  SplashRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Session?>> checkSession() async {
    try {
      final sessionModel = await remoteDataSource.checkSession();
      // Convert model to entity (or null)
      final session = sessionModel?.toEntity();
      return Right(session);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
