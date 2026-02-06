import 'package:dartz/dartz.dart';
import 'package:balaji_points/core/error/failures.dart';
import 'package:balaji_points/features/home/domain/entities/home.dart';

/// Repository interface for home
/// 
/// Defines the contract that the data layer must implement.
/// Returns Either<Failure, Data> for error handling.
abstract class UhomeRepository {
  Future<Either<Failure, UhomeEntity>> getUhome(String id);
  Future<Either<Failure, List<UhomeEntity>>> getAll();
  Future<Either<Failure, void>> create(UhomeEntity entity);
  Future<Either<Failure, void>> update(UhomeEntity entity);
  Future<Either<Failure, void>> delete(String id);
}
