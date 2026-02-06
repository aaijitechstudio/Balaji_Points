import 'package:dartz/dartz.dart';
import 'package:balaji_points/core/error/failures.dart';
import 'package:balaji_points/features/spin/domain/entities/spin.dart';
import 'package:balaji_points/features/spin/domain/repositories/spin_repository.dart';
import 'package:balaji_points/features/spin/data/datasources/spin_remote_datasource.dart';
import 'package:balaji_points/features/spin/data/models/spin_model.dart';

/// Repository implementation for spin
/// 
/// Implements the repository interface from domain layer.
/// Handles data source calls and error conversion.
class UspinRepositoryImpl implements UspinRepository {
  final UspinRemoteDataSource remoteDataSource;
  
  UspinRepositoryImpl({required this.remoteDataSource});
  
  @override
  Future<Either<Failure, UspinEntity>> getUspin(String id) async {
    try {
      final model = await remoteDataSource.getUspin(id);
      return Right(model.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, List<UspinEntity>>> getAll() async {
    try {
      final models = await remoteDataSource.getAll();
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, void>> create(UspinEntity entity) async {
    try {
      final model = UspinModel.fromEntity(entity);
      await remoteDataSource.create(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, void>> update(UspinEntity entity) async {
    try {
      final model = UspinModel.fromEntity(entity);
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
