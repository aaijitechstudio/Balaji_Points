import 'package:dartz/dartz.dart';
import 'package:balaji_points/core/error/failures.dart';
import 'package:balaji_points/features/spin/domain/entities/spin.dart';
import 'package:balaji_points/features/spin/domain/repositories/spin_repository.dart';

/// Use case for getting spin
/// 
/// Each use case handles a single business operation.
/// Contains the business logic for that specific operation.
class GetUspinUseCase {
  final UspinRepository repository;
  
  GetUspinUseCase(this.repository);
  
  Future<Either<Failure, UspinEntity>> call(String id) {
    return repository.getUspin(id);
  }
}
