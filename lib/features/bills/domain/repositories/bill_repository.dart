import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:balaji_points/core/error/failures.dart';
import 'package:balaji_points/features/bills/domain/entities/bill.dart';
import 'package:balaji_points/features/bills/domain/entities/carpenter.dart';

/// Bill repository interface
abstract class BillRepository {
  /// Submit bill by carpenter
  Future<Either<Failure, bool>> submitBill({
    required String carpenterId,
    required String carpenterPhone,
    required double amount,
    File? imageFile,
    DateTime? billDate,
    String? storeName,
    String? billNumber,
    String? notes,
  });

  /// Submit bill for carpenter by admin
  Future<Either<Failure, bool>> submitBillForCarpenter({
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
  });

  /// Approve bill
  Future<Either<Failure, bool>> approveBill({
    required String billId,
    required String carpenterId,
    required double amount,
  });

  /// Reject bill
  Future<Either<Failure, bool>> rejectBill({
    required String billId,
    required String reason,
  });

  /// Withdraw bill
  Future<Either<Failure, bool>> withdrawBill(String billId);

  /// Get bills stream for carpenter
  Stream<Either<Failure, List<Bill>>> getBillsStream(String carpenterId);

  /// Get bill by ID
  Future<Either<Failure, Bill>> getBillById(String billId);

  /// Get carpenters list (for admin)
  Future<Either<Failure, List<Carpenter>>> getCarpenters();

  /// Get carpenter by ID
  Future<Either<Failure, Carpenter>> getCarpenterById(String carpenterId);

  /// Get current user data
  Future<Either<Failure, Map<String, dynamic>>> getCurrentUserData();
}
