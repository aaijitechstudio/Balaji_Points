import 'package:dartz/dartz.dart';
import 'package:balaji_points/core/error/failures.dart';
import 'package:balaji_points/features/dashboard/domain/entities/dashboard.dart';

/// Repository interface for dashboard
/// 
/// Defines the contract that the data layer must implement.
/// Returns Either<Failure, Data> for error handling.
abstract class UdashboardRepository {
  Future<Either<Failure, UdashboardEntity>> getUdashboard(String id);
  Future<Either<Failure, List<UdashboardEntity>>> getAll();
  Future<Either<Failure, void>> create(UdashboardEntity entity);
  Future<Either<Failure, void>> update(UdashboardEntity entity);
  Future<Either<Failure, void>> delete(String id);
}
