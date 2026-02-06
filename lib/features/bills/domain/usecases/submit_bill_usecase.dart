import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:balaji_points/core/error/failures.dart';
import 'package:balaji_points/features/bills/domain/repositories/bill_repository.dart';

/// Use case for submitting bill by carpenter
class SubmitBillUseCase {
  final BillRepository repository;

  SubmitBillUseCase(this.repository);

  Future<Either<Failure, bool>> call({
    required String carpenterId,
    required String carpenterPhone,
    required double amount,
    File? imageFile,
    DateTime? billDate,
    String? storeName,
    String? billNumber,
    String? notes,
  }) async {
    if (carpenterId.isEmpty) {
      return const Left(ValidationFailure(message: 'Carpenter ID is required'));
    }
    if (carpenterPhone.isEmpty) {
      return const Left(ValidationFailure(message: 'Carpenter phone is required'));
    }
    if (amount <= 0) {
      return const Left(ValidationFailure(message: 'Amount must be greater than 0'));
    }

    return await repository.submitBill(
      carpenterId: carpenterId,
      carpenterPhone: carpenterPhone,
      amount: amount,
      imageFile: imageFile,
      billDate: billDate,
      storeName: storeName,
      billNumber: billNumber,
      notes: notes,
    );
  }
}
