import 'package:dartz/dartz.dart';
import 'package:balaji_points/core/error/failures.dart';
import 'package:balaji_points/features/dashboard/domain/entities/dashboard.dart';
import 'package:balaji_points/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:balaji_points/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:balaji_points/features/dashboard/data/models/dashboard_model.dart';

/// Repository implementation for dashboard
/// 
/// Implements the repository interface from domain layer.
/// Handles data source calls and error conversion.
class UdashboardRepositoryImpl implements UdashboardRepository {
  final UdashboardRemoteDataSource remoteDataSource;
  
  UdashboardRepositoryImpl({required this.remoteDataSource});
  
  @override
  Future<Either<Failure, UdashboardEntity>> getUdashboard(String id) async {
    try {
      final model = await remoteDataSource.getUdashboard(id);
      return Right(model.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, List<UdashboardEntity>>> getAll() async {
    try {
      final models = await remoteDataSource.getAll();
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, void>> create(UdashboardEntity entity) async {
    try {
      final model = UdashboardModel.fromEntity(entity);
      await remoteDataSource.create(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, void>> update(UdashboardEntity entity) async {
    try {
      final model = UdashboardModel.fromEntity(entity);
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
