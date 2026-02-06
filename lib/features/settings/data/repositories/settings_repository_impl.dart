import 'package:dartz/dartz.dart';
import 'package:balaji_points/core/error/failures.dart';
import 'package:balaji_points/features/settings/domain/entities/settings.dart';
import 'package:balaji_points/features/settings/domain/repositories/settings_repository.dart';
import 'package:balaji_points/features/settings/data/datasources/settings_remote_datasource.dart';
import 'package:balaji_points/features/settings/data/models/settings_model.dart';

/// Repository implementation for settings
/// 
/// Implements the repository interface from domain layer.
/// Handles data source calls and error conversion.
class UsettingsRepositoryImpl implements UsettingsRepository {
  final UsettingsRemoteDataSource remoteDataSource;
  
  UsettingsRepositoryImpl({required this.remoteDataSource});
  
  @override
  Future<Either<Failure, UsettingsEntity>> getUsettings(String id) async {
    try {
      final model = await remoteDataSource.getUsettings(id);
      return Right(model.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, List<UsettingsEntity>>> getAll() async {
    try {
      final models = await remoteDataSource.getAll();
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, void>> create(UsettingsEntity entity) async {
    try {
      final model = UsettingsModel.fromEntity(entity);
      await remoteDataSource.create(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, void>> update(UsettingsEntity entity) async {
    try {
      final model = UsettingsModel.fromEntity(entity);
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
