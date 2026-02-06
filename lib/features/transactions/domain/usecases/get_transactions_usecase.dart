import 'package:dartz/dartz.dart';
import 'package:balaji_points/core/error/failures.dart';
import 'package:balaji_points/features/transactions/domain/entities/transactions.dart';
import 'package:balaji_points/features/transactions/domain/repositories/transactions_repository.dart';

/// Use case for getting transactions
/// 
/// Each use case handles a single business operation.
/// Contains the business logic for that specific operation.
class GetUtransactionsUseCase {
  final UtransactionsRepository repository;
  
  GetUtransactionsUseCase(this.repository);
  
  Future<Either<Failure, UtransactionsEntity>> call(String id) {
    return repository.getUtransactions(id);
  }
}
