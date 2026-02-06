import 'package:dartz/dartz.dart';
import 'package:balaji_points/core/error/failures.dart';
import 'package:balaji_points/features/notifications/domain/entities/notifications.dart';
import 'package:balaji_points/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:balaji_points/features/notifications/data/datasources/notifications_remote_datasource.dart';
import 'package:balaji_points/features/notifications/data/models/notifications_model.dart';

/// Repository implementation for notifications
/// 
/// Implements the repository interface from domain layer.
/// Handles data source calls and error conversion.
class UnotificationsRepositoryImpl implements UnotificationsRepository {
  final UnotificationsRemoteDataSource remoteDataSource;
  
  UnotificationsRepositoryImpl({required this.remoteDataSource});
  
  @override
  Future<Either<Failure, UnotificationsEntity>> getUnotifications(String id) async {
    try {
      final model = await remoteDataSource.getUnotifications(id);
      return Right(model.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, List<UnotificationsEntity>>> getAll() async {
    try {
      final models = await remoteDataSource.getAll();
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, void>> create(UnotificationsEntity entity) async {
    try {
      final model = UnotificationsModel.fromEntity(entity);
      await remoteDataSource.create(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, void>> update(UnotificationsEntity entity) async {
    try {
      final model = UnotificationsModel.fromEntity(entity);
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
