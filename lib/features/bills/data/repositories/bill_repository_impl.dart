import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:balaji_points/core/error/failures.dart';
import 'package:balaji_points/features/bills/domain/entities/bill.dart';
import 'package:balaji_points/features/bills/domain/entities/carpenter.dart';
import 'package:balaji_points/features/bills/domain/repositories/bill_repository.dart';
import 'package:balaji_points/features/bills/data/datasources/bill_remote_datasource.dart';

class BillRepositoryImpl implements BillRepository {
  final BillRemoteDataSource remoteDataSource;

  BillRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, bool>> submitBill({
    required String carpenterId,
    required String carpenterPhone,
    required double amount,
    File? imageFile,
    DateTime? billDate,
    String? storeName,
    String? billNumber,
    String? notes,
  }) async {
    try {
      final result = await remoteDataSource.submitBill(
        carpenterId: carpenterId,
        carpenterPhone: carpenterPhone,
        amount: amount,
        imageFile: imageFile,
        billDate: billDate,
        storeName: storeName,
        billNumber: billNumber,
        notes: notes,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
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
  }) async {
    try {
      final result = await remoteDataSource.submitBillForCarpenter(
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
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> approveBill({
    required String billId,
    required String carpenterId,
    required double amount,
  }) async {
    try {
      final result = await remoteDataSource.approveBill(
        billId: billId,
        carpenterId: carpenterId,
        amount: amount,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> rejectBill({
    required String billId,
    required String reason,
  }) async {
    try {
      final result = await remoteDataSource.rejectBill(
        billId: billId,
        reason: reason,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> withdrawBill(String billId) async {
    try {
      final result = await remoteDataSource.withdrawBill(billId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<Bill>>> getBillsStream(String carpenterId) {
    try {
      return remoteDataSource.getBillsStream(carpenterId).map((billModels) {
        final bills = billModels.map((model) => model.toEntity()).toList();
        return Right<Failure, List<Bill>>(bills);
      }).handleError((error) {
        return Left<Failure, List<Bill>>(
          ServerFailure(message: error.toString()),
        );
      });
    } catch (e) {
      return Stream.value(Left(ServerFailure(message: e.toString())));
    }
  }

  @override
  Future<Either<Failure, Bill>> getBillById(String billId) async {
    try {
      final billModel = await remoteDataSource.getBillById(billId);
      return Right(billModel.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Carpenter>>> getCarpenters() async {
    try {
      final carpenterModels = await remoteDataSource.getCarpenters();
      final carpenters =
          carpenterModels.map((model) => model.toEntity()).toList();
      return Right(carpenters);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Carpenter>> getCarpenterById(
    String carpenterId,
  ) async {
    try {
      final carpenterModel =
          await remoteDataSource.getCarpenterById(carpenterId);
      return Right(carpenterModel.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getCurrentUserData() async {
    try {
      final userData = await remoteDataSource.getCurrentUserData();
      return Right(userData);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
