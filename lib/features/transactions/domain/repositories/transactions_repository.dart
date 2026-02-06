import 'package:dartz/dartz.dart';
import 'package:balaji_points/core/error/failures.dart';
import 'package:balaji_points/features/transactions/domain/entities/transactions.dart';

/// Repository interface for transactions
/// 
/// Defines the contract that the data layer must implement.
/// Returns Either<Failure, Data> for error handling.
abstract class UtransactionsRepository {
  Future<Either<Failure, UtransactionsEntity>> getUtransactions(String id);
  Future<Either<Failure, List<UtransactionsEntity>>> getAll();
  Future<Either<Failure, void>> create(UtransactionsEntity entity);
  Future<Either<Failure, void>> update(UtransactionsEntity entity);
  Future<Either<Failure, void>> delete(String id);
}
