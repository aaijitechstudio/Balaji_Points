import 'package:dartz/dartz.dart';
import 'package:balaji_points/core/error/failures.dart';
import 'package:balaji_points/features/home/domain/entities/home.dart';
import 'package:balaji_points/features/home/domain/repositories/home_repository.dart';

/// Use case for getting home
/// 
/// Each use case handles a single business operation.
/// Contains the business logic for that specific operation.
class GetUhomeUseCase {
  final UhomeRepository repository;
  
  GetUhomeUseCase(this.repository);
  
  Future<Either<Failure, UhomeEntity>> call(String id) {
    return repository.getUhome(id);
  }
}
