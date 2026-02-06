import 'package:dartz/dartz.dart';
import 'package:balaji_points/core/error/failures.dart';
import 'package:balaji_points/features/redeem/domain/entities/redeem.dart';
import 'package:balaji_points/features/redeem/domain/repositories/redeem_repository.dart';
import 'package:balaji_points/features/redeem/data/datasources/redeem_remote_datasource.dart';
import 'package:balaji_points/features/redeem/data/models/redeem_model.dart';

/// Repository implementation for redeem
/// 
/// Implements the repository interface from domain layer.
/// Handles data source calls and error conversion.
class UredeemRepositoryImpl implements UredeemRepository {
  final UredeemRemoteDataSource remoteDataSource;
  
  UredeemRepositoryImpl({required this.remoteDataSource});
  
  @override
  Future<Either<Failure, UredeemEntity>> getUredeem(String id) async {
    try {
      final model = await remoteDataSource.getUredeem(id);
      return Right(model.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, List<UredeemEntity>>> getAll() async {
    try {
      final models = await remoteDataSource.getAll();
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, void>> create(UredeemEntity entity) async {
    try {
      final model = UredeemModel.fromEntity(entity);
      await remoteDataSource.create(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, void>> update(UredeemEntity entity) async {
    try {
      final model = UredeemModel.fromEntity(entity);
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
