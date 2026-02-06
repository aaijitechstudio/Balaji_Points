import 'package:dartz/dartz.dart';
import 'package:balaji_points/core/error/failures.dart';
import 'package:balaji_points/features/settings/domain/entities/settings.dart';

/// Repository interface for settings
/// 
/// Defines the contract that the data layer must implement.
/// Returns Either<Failure, Data> for error handling.
abstract class UsettingsRepository {
  Future<Either<Failure, UsettingsEntity>> getUsettings(String id);
  Future<Either<Failure, List<UsettingsEntity>>> getAll();
  Future<Either<Failure, void>> create(UsettingsEntity entity);
  Future<Either<Failure, void>> update(UsettingsEntity entity);
  Future<Either<Failure, void>> delete(String id);
}
