import 'package:dartz/dartz.dart';
import 'package:balaji_points/core/error/failures.dart';
import 'package:balaji_points/features/redeem/domain/entities/redeem.dart';

/// Repository interface for redeem
/// 
/// Defines the contract that the data layer must implement.
/// Returns Either<Failure, Data> for error handling.
abstract class UredeemRepository {
  Future<Either<Failure, UredeemEntity>> getUredeem(String id);
  Future<Either<Failure, List<UredeemEntity>>> getAll();
  Future<Either<Failure, void>> create(UredeemEntity entity);
  Future<Either<Failure, void>> update(UredeemEntity entity);
  Future<Either<Failure, void>> delete(String id);
}
