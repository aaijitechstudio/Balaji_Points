import 'package:dartz/dartz.dart';
import 'package:balaji_points/core/error/failures.dart';
import 'package:balaji_points/features/spin/domain/entities/spin.dart';

/// Repository interface for spin
/// 
/// Defines the contract that the data layer must implement.
/// Returns Either<Failure, Data> for error handling.
abstract class UspinRepository {
  Future<Either<Failure, UspinEntity>> getUspin(String id);
  Future<Either<Failure, List<UspinEntity>>> getAll();
  Future<Either<Failure, void>> create(UspinEntity entity);
  Future<Either<Failure, void>> update(UspinEntity entity);
  Future<Either<Failure, void>> delete(String id);
}
