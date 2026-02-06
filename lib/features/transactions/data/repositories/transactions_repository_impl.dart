import 'package:dartz/dartz.dart';
import 'package:balaji_points/core/error/failures.dart';
import 'package:balaji_points/features/transactions/domain/entities/transactions.dart';
import 'package:balaji_points/features/transactions/domain/repositories/transactions_repository.dart';
import 'package:balaji_points/features/transactions/data/datasources/transactions_remote_datasource.dart';
import 'package:balaji_points/features/transactions/data/models/transactions_model.dart';

/// Repository implementation for transactions
/// 
/// Implements the repository interface from domain layer.
/// Handles data source calls and error conversion.
class UtransactionsRepositoryImpl implements UtransactionsRepository {
  final UtransactionsRemoteDataSource remoteDataSource;
  
  UtransactionsRepositoryImpl({required this.remoteDataSource});
  
  @override
  Future<Either<Failure, UtransactionsEntity>> getUtransactions(String id) async {
    try {
      final model = await remoteDataSource.getUtransactions(id);
      return Right(model.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, List<UtransactionsEntity>>> getAll() async {
    try {
      final models = await remoteDataSource.getAll();
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, void>> create(UtransactionsEntity entity) async {
    try {
      final model = UtransactionsModel.fromEntity(entity);
      await remoteDataSource.create(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, void>> update(UtransactionsEntity entity) async {
    try {
      final model = UtransactionsModel.fromEntity(entity);
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
