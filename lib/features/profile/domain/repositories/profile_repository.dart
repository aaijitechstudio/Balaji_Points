import 'package:dartz/dartz.dart';
import 'package:balaji_points/core/error/failures.dart';
import 'package:balaji_points/features/profile/domain/entities/profile.dart';

/// Repository interface for profile
/// 
/// Defines the contract that the data layer must implement.
/// Returns Either<Failure, Data> for error handling.
abstract class UprofileRepository {
  Future<Either<Failure, UprofileEntity>> getUprofile(String id);
  Future<Either<Failure, List<UprofileEntity>>> getAll();
  Future<Either<Failure, void>> create(UprofileEntity entity);
  Future<Either<Failure, void>> update(UprofileEntity entity);
  Future<Either<Failure, void>> delete(String id);
}
