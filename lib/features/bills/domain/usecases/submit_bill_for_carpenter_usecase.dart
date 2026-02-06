import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:balaji_points/core/error/failures.dart';
import 'package:balaji_points/features/bills/domain/repositories/bill_repository.dart';

/// Use case for submitting bill for carpenter by admin
class SubmitBillForCarpenterUseCase {
  final BillRepository repository;

  SubmitBillForCarpenterUseCase(this.repository);

  Future<Either<Failure, bool>> call({
    required String carpenterId,
    required String carpenterPhone,
    required double amount,
    required String adminId,
    required String adminPhone,
    String? adminName,
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
    if (adminId.isEmpty) {
      return const Left(ValidationFailure(message: 'Admin ID is required'));
    }

    return await repository.submitBillForCarpenter(
      carpenterId: carpenterId,
      carpenterPhone: carpenterPhone,
      amount: amount,
      adminId: adminId,
      adminPhone: adminPhone,
      adminName: adminName,
      imageFile: imageFile,
      billDate: billDate,
      storeName: storeName,
      billNumber: billNumber,
      notes: notes,
    );
  }
}
