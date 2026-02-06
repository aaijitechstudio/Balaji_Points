import 'package:dartz/dartz.dart';
import 'package:balaji_points/core/error/failures.dart';
import 'package:balaji_points/features/bills/domain/repositories/bill_repository.dart';

/// Use case for withdrawing bill
class WithdrawBillUseCase {
  final BillRepository repository;

  WithdrawBillUseCase(this.repository);

  Future<Either<Failure, bool>> call(String billId) async {
    if (billId.isEmpty) {
      return const Left(ValidationFailure(message: 'Bill ID is required'));
    }

    return await repository.withdrawBill(billId);
  }
}
