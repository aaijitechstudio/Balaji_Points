import 'package:dartz/dartz.dart';
import 'package:balaji_points/core/error/failures.dart';
import 'package:balaji_points/features/redeem/domain/entities/redeem.dart';
import 'package:balaji_points/features/redeem/domain/repositories/redeem_repository.dart';

/// Use case for getting redeem
/// 
/// Each use case handles a single business operation.
/// Contains the business logic for that specific operation.
class GetUredeemUseCase {
  final UredeemRepository repository;
  
  GetUredeemUseCase(this.repository);
  
  Future<Either<Failure, UredeemEntity>> call(String id) {
    return repository.getUredeem(id);
  }
}
