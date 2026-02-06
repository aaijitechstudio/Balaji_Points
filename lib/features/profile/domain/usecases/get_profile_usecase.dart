import 'package:dartz/dartz.dart';
import 'package:balaji_points/core/error/failures.dart';
import 'package:balaji_points/features/profile/domain/entities/profile.dart';
import 'package:balaji_points/features/profile/domain/repositories/profile_repository.dart';

/// Use case for getting profile
/// 
/// Each use case handles a single business operation.
/// Contains the business logic for that specific operation.
class GetUprofileUseCase {
  final UprofileRepository repository;
  
  GetUprofileUseCase(this.repository);
  
  Future<Either<Failure, UprofileEntity>> call(String id) {
    return repository.getUprofile(id);
  }
}
