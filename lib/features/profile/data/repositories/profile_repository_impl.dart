import 'package:dartz/dartz.dart';
import 'package:balaji_points/core/error/failures.dart';
import 'package:balaji_points/features/profile/domain/entities/profile.dart';
import 'package:balaji_points/features/profile/domain/repositories/profile_repository.dart';
import 'package:balaji_points/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:balaji_points/features/profile/data/models/profile_model.dart';

/// Repository implementation for profile
/// 
/// Implements the repository interface from domain layer.
/// Handles data source calls and error conversion.
class UprofileRepositoryImpl implements UprofileRepository {
  final UprofileRemoteDataSource remoteDataSource;
  
  UprofileRepositoryImpl({required this.remoteDataSource});
  
  @override
  Future<Either<Failure, UprofileEntity>> getUprofile(String id) async {
    try {
      final model = await remoteDataSource.getUprofile(id);
      return Right(model.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, List<UprofileEntity>>> getAll() async {
    try {
      final models = await remoteDataSource.getAll();
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, void>> create(UprofileEntity entity) async {
    try {
      final model = UprofileModel.fromEntity(entity);
      await remoteDataSource.create(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, void>> update(UprofileEntity entity) async {
    try {
      final model = UprofileModel.fromEntity(entity);
      await remoteDataSource.update(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, void>> delete(String id) async {
    try {
      await remoteDataSource.delete(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
