import 'package:dartz/dartz.dart';
import 'package:balaji_points/core/error/failures.dart';
import 'package:balaji_points/features/dashboard/domain/entities/dashboard.dart';
import 'package:balaji_points/features/dashboard/domain/repositories/dashboard_repository.dart';

/// Use case for getting dashboard
/// 
/// Each use case handles a single business operation.
/// Contains the business logic for that specific operation.
class GetUdashboardUseCase {
  final UdashboardRepository repository;
  
  GetUdashboardUseCase(this.repository);
  
  Future<Either<Failure, UdashboardEntity>> call(String id) {
    return repository.getUdashboard(id);
  }
}
