import 'package:dartz/dartz.dart';
import 'package:balaji_points/core/error/failures.dart';
import 'package:balaji_points/features/bills/domain/entities/bill.dart';
import 'package:balaji_points/features/bills/domain/repositories/bill_repository.dart';

/// Use case for getting bill by ID
class GetBillByIdUseCase {
  final BillRepository repository;

  GetBillByIdUseCase(this.repository);

  Future<Either<Failure, Bill>> call(String billId) async {
    if (billId.isEmpty) {
      return const Left(ValidationFailure(message: 'Bill ID is required'));
    }

    return await repository.getBillById(billId);
  }
}
