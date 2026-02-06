import 'package:dartz/dartz.dart';
import 'package:balaji_points/core/error/failures.dart';
import 'package:balaji_points/features/admin/domain/entities/admin.dart';
import 'package:balaji_points/features/admin/domain/repositories/admin_repository.dart';

/// Use case for getting admin
/// 
/// Each use case handles a single business operation.
/// Contains the business logic for that specific operation.
class GetUadminUseCase {
  final UadminRepository repository;
  
  GetUadminUseCase(this.repository);
  
  Future<Either<Failure, UadminEntity>> call(String id) {
    return repository.getUadmin(id);
  }
}
