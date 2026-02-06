import 'package:dartz/dartz.dart';
import 'package:balaji_points/core/error/failures.dart';
import 'package:balaji_points/features/admin/domain/entities/admin.dart';

/// Repository interface for admin
/// 
/// Defines the contract that the data layer must implement.
/// Returns Either<Failure, Data> for error handling.
abstract class UadminRepository {
  Future<Either<Failure, UadminEntity>> getUadmin(String id);
  Future<Either<Failure, List<UadminEntity>>> getAll();
  Future<Either<Failure, void>> create(UadminEntity entity);
  Future<Either<Failure, void>> update(UadminEntity entity);
  Future<Either<Failure, void>> delete(String id);
}
