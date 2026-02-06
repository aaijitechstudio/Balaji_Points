import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:balaji_points/features/bills/domain/entities/carpenter.dart';

/// Events for Bill BLoC
abstract class BillEvent extends Equatable {
  const BillEvent();

  @override
  List<Object?> get props => [];
}

/// Load current user data
class LoadCurrentUserDataEvent extends BillEvent {
  const LoadCurrentUserDataEvent();
}

/// Select image
class SelectImageEvent extends BillEvent {
  final File imageFile;

  const SelectImageEvent(this.imageFile);

  @override
  List<Object?> get props => [imageFile];
}

/// Remove image
class RemoveImageEvent extends BillEvent {
  const RemoveImageEvent();
}

/// Select date
class SelectDateEvent extends BillEvent {
  final DateTime date;

  const SelectDateEvent(this.date);

  @override
  List<Object?> get props => [date];
}

/// Submit bill by carpenter
class SubmitBillEvent extends BillEvent {
  final String carpenterId;
  final String carpenterPhone;
  final double amount;
  final File? imageFile;
  final DateTime? billDate;
  final String? storeName;
  final String? billNumber;
  final String? notes;

  const SubmitBillEvent({
    required this.carpenterId,
    required this.carpenterPhone,
    required this.amount,
    this.imageFile,
    this.billDate,
    this.storeName,
    this.billNumber,
    this.notes,
  });

  @override
  List<Object?> get props => [
        carpenterId,
        carpenterPhone,
        amount,
        imageFile,
        billDate,
        storeName,
        billNumber,
        notes,
      ];
}

/// Load carpenters (for admin)
class LoadCarpentersEvent extends BillEvent {
  const LoadCarpentersEvent();
}

/// Select carpenter (for admin)
class SelectCarpenterEvent extends BillEvent {
  final Carpenter carpenter;

  const SelectCarpenterEvent(this.carpenter);

  @override
  List<Object?> get props => [carpenter];
}

/// Submit bill for carpenter by admin
class SubmitBillForCarpenterEvent extends BillEvent {
  final String carpenterId;
  final String carpenterPhone;
  final double amount;
  final String adminId;
  final String adminPhone;
  final String? adminName;
  final File? imageFile;
  final DateTime? billDate;
  final String? storeName;
  final String? billNumber;
  final String? notes;

  const SubmitBillForCarpenterEvent({
    required this.carpenterId,
    required this.carpenterPhone,
    required this.amount,
    required this.adminId,
    required this.adminPhone,
    this.adminName,
    this.imageFile,
    this.billDate,
    this.storeName,
    this.billNumber,
    this.notes,
  });

  @override
  List<Object?> get props => [
        carpenterId,
        carpenterPhone,
        amount,
        adminId,
        adminPhone,
        adminName,
        imageFile,
        billDate,
        storeName,
        billNumber,
        notes,
      ];
}

/// Load bill details
class LoadBillDetailsEvent extends BillEvent {
  final String billId;

  const LoadBillDetailsEvent(this.billId);

  @override
  List<Object?> get props => [billId];
}

/// Approve bill
class ApproveBillEvent extends BillEvent {
  final String billId;
  final String carpenterId;
  final double amount;

  const ApproveBillEvent({
    required this.billId,
    required this.carpenterId,
    required this.amount,
  });

  @override
  List<Object?> get props => [billId, carpenterId, amount];
}

/// Reject bill
class RejectBillEvent extends BillEvent {
  final String billId;
  final String reason;

  const RejectBillEvent({
    required this.billId,
    required this.reason,
  });

  @override
  List<Object?> get props => [billId, reason];
}

/// Withdraw bill
class WithdrawBillEvent extends BillEvent {
  final String billId;

  const WithdrawBillEvent(this.billId);

  @override
  List<Object?> get props => [billId];
}

/// Reset state
class ResetBillStateEvent extends BillEvent {
  const ResetBillStateEvent();
}
