import 'package:dartz/dartz.dart';
import 'package:balaji_points/core/error/failures.dart';
import 'package:balaji_points/features/bills/domain/repositories/bill_repository.dart';

/// Use case for getting current user data
class GetCurrentUserDataUseCase {
  final BillRepository repository;

  GetCurrentUserDataUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call() async {
    return await repository.getCurrentUserData();
  }
}
