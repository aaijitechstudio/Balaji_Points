import 'package:dartz/dartz.dart';
import 'package:balaji_points/core/error/failures.dart';
import 'package:balaji_points/features/settings/domain/entities/settings.dart';
import 'package:balaji_points/features/settings/domain/repositories/settings_repository.dart';

/// Use case for getting settings
/// 
/// Each use case handles a single business operation.
/// Contains the business logic for that specific operation.
class GetUsettingsUseCase {
  final UsettingsRepository repository;
  
  GetUsettingsUseCase(this.repository);
  
  Future<Either<Failure, UsettingsEntity>> call(String id) {
    return repository.getUsettings(id);
  }
}
