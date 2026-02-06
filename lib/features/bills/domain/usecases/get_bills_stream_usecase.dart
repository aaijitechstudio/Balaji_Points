import 'package:dartz/dartz.dart';
import 'package:balaji_points/core/error/failures.dart';
import 'package:balaji_points/features/bills/domain/entities/bill.dart';
import 'package:balaji_points/features/bills/domain/repositories/bill_repository.dart';

/// Use case for getting bills stream
class GetBillsStreamUseCase {
  final BillRepository repository;

  GetBillsStreamUseCase(this.repository);

  Stream<Either<Failure, List<Bill>>> call(String carpenterId) {
    if (carpenterId.isEmpty) {
      return Stream.value(
        const Left(ValidationFailure(message: 'Carpenter ID is required')),
      );
    }

    return repository.getBillsStream(carpenterId);
  }
}
