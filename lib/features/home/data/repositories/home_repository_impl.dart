import 'package:dartz/dartz.dart';
import 'package:balaji_points/core/error/failures.dart';
import 'package:balaji_points/features/home/domain/entities/home.dart';
import 'package:balaji_points/features/home/domain/repositories/home_repository.dart';
import 'package:balaji_points/features/home/data/datasources/home_remote_datasource.dart';
import 'package:balaji_points/features/home/data/models/home_model.dart';

/// Repository implementation for home
/// 
/// Implements the repository interface from domain layer.
/// Handles data source calls and error conversion.
class UhomeRepositoryImpl implements UhomeRepository {
  final UhomeRemoteDataSource remoteDataSource;
  
  UhomeRepositoryImpl({required this.remoteDataSource});
  
  @override
  Future<Either<Failure, UhomeEntity>> getUhome(String id) async {
    try {
      final model = await remoteDataSource.getUhome(id);
      return Right(model.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, List<UhomeEntity>>> getAll() async {
    try {
      final models = await remoteDataSource.getAll();
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, void>> create(UhomeEntity entity) async {
    try {
      final model = UhomeModel.fromEntity(entity);
      await remoteDataSource.create(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, void>> update(UhomeEntity entity) async {
    try {
      final model = UhomeModel.fromEntity(entity);
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
