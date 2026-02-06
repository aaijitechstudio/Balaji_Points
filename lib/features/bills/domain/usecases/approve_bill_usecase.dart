import 'package:dartz/dartz.dart';
import 'package:balaji_points/core/error/failures.dart';
import 'package:balaji_points/features/bills/domain/repositories/bill_repository.dart';

/// Use case for approving bill
class ApproveBillUseCase {
  final BillRepository repository;

  ApproveBillUseCase(this.repository);

  Future<Either<Failure, bool>> call({
    required String billId,
    required String carpenterId,
    required double amount,
  }) async {
    if (billId.isEmpty) {
      return const Left(ValidationFailure(message: 'Bill ID is required'));
    }
    if (carpenterId.isEmpty) {
      return const Left(ValidationFailure(message: 'Carpenter ID is required'));
    }
    if (amount <= 0) {
      return const Left(ValidationFailure(message: 'Amount must be greater than 0'));
    }

    return await repository.approveBill(
      billId: billId,
      carpenterId: carpenterId,
      amount: amount,
    );
  }
}
