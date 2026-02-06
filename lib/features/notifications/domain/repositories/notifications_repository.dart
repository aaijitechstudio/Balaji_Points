import 'package:dartz/dartz.dart';
import 'package:balaji_points/core/error/failures.dart';
import 'package:balaji_points/features/notifications/domain/entities/notifications.dart';

/// Repository interface for notifications
/// 
/// Defines the contract that the data layer must implement.
/// Returns Either<Failure, Data> for error handling.
abstract class UnotificationsRepository {
  Future<Either<Failure, UnotificationsEntity>> getUnotifications(String id);
  Future<Either<Failure, List<UnotificationsEntity>>> getAll();
  Future<Either<Failure, void>> create(UnotificationsEntity entity);
  Future<Either<Failure, void>> update(UnotificationsEntity entity);
  Future<Either<Failure, void>> delete(String id);
}
