import 'package:dartz/dartz.dart';
import 'package:balaji_points/core/error/failures.dart';
import 'package:balaji_points/features/admin/domain/entities/admin.dart';
import 'package:balaji_points/features/admin/domain/repositories/admin_repository.dart';
import 'package:balaji_points/features/admin/data/datasources/admin_remote_datasource.dart';
import 'package:balaji_points/features/admin/data/models/admin_model.dart';

/// Repository implementation for admin
/// 
/// Implements the repository interface from domain layer.
/// Handles data source calls and error conversion.
class UadminRepositoryImpl implements UadminRepository {
  final UadminRemoteDataSource remoteDataSource;
  
  UadminRepositoryImpl({required this.remoteDataSource});
  
  @override
  Future<Either<Failure, UadminEntity>> getUadmin(String id) async {
    try {
      final model = await remoteDataSource.getUadmin(id);
      return Right(model.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, List<UadminEntity>>> getAll() async {
    try {
      final models = await remoteDataSource.getAll();
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, void>> create(UadminEntity entity) async {
    try {
      final model = UadminModel.fromEntity(entity);
      await remoteDataSource.create(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, void>> update(UadminEntity entity) async {
    try {
      final model = UadminModel.fromEntity(entity);
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
