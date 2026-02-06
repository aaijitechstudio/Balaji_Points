import 'package:dartz/dartz.dart';
import 'package:balaji_points/core/error/failures.dart';
import 'package:balaji_points/features/notifications/domain/entities/notifications.dart';
import 'package:balaji_points/features/notifications/domain/repositories/notifications_repository.dart';

/// Use case for getting notifications
/// 
/// Each use case handles a single business operation.
/// Contains the business logic for that specific operation.
class GetUnotificationsUseCase {
  final UnotificationsRepository repository;
  
  GetUnotificationsUseCase(this.repository);
  
  Future<Either<Failure, UnotificationsEntity>> call(String id) {
    return repository.getUnotifications(id);
  }
}
