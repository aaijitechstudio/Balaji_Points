import 'package:dartz/dartz.dart';
import 'package:balaji_points/core/error/failures.dart';
import 'package:balaji_points/features/bills/domain/repositories/bill_repository.dart';

/// Use case for rejecting bill
class RejectBillUseCase {
  final BillRepository repository;

  RejectBillUseCase(this.repository);

  Future<Either<Failure, bool>> call({
    required String billId,
    required String reason,
  }) async {
    if (billId.isEmpty) {
      return const Left(ValidationFailure(message: 'Bill ID is required'));
    }
    if (reason.isEmpty) {
      return const Left(ValidationFailure(message: 'Reason is required'));
    }

    return await repository.rejectBill(
      billId: billId,
      reason: reason,
    );
  }
}
