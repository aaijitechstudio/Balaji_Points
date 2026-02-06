import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:balaji_points/features/bills/domain/entities/bill.dart';
import 'package:balaji_points/features/bills/domain/entities/carpenter.dart';

/// States for Bill BLoC
abstract class BillState extends Equatable {
  const BillState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class BillInitial extends BillState {
  const BillInitial();
}

/// Loading state
class BillLoading extends BillState {
  const BillLoading();
}

/// User data loaded
class UserDataLoaded extends BillState {
  final Map<String, dynamic> userData;

  const UserDataLoaded(this.userData);

  @override
  List<Object?> get props => [userData];
}

/// Profile incomplete state
class ProfileIncomplete extends BillState {
  final Map<String, dynamic> userData;

  const ProfileIncomplete(this.userData);

  @override
  List<Object?> get props => [userData];
}

/// Image selected
class ImageSelected extends BillState {
  final File imageFile;

  const ImageSelected(this.imageFile);

  @override
  List<Object?> get props => [imageFile];
}

/// Image removed
class ImageRemoved extends BillState {
  const ImageRemoved();
}

/// Date selected
class DateSelected extends BillState {
  final DateTime date;

  const DateSelected(this.date);

  @override
  List<Object?> get props => [date];
}

/// Submitting bill
class BillSubmitting extends BillState {
  const BillSubmitting();
}

/// Bill submitted successfully
class BillSubmitted extends BillState {
  const BillSubmitted();
}

/// Bill submission failed
class BillSubmissionFailed extends BillState {
  final String message;

  const BillSubmissionFailed(this.message);

  @override
  List<Object?> get props => [message];
}

/// Carpenters loading
class CarpentersLoading extends BillState {
  const CarpentersLoading();
}

/// Carpenters loaded
class CarpentersLoaded extends BillState {
  final List<Carpenter> carpenters;

  const CarpentersLoaded(this.carpenters);

  @override
  List<Object?> get props => [carpenters];
}

/// Carpenters load failed
class CarpentersLoadFailed extends BillState {
  final String message;

  const CarpentersLoadFailed(this.message);

  @override
  List<Object?> get props => [message];
}

/// Carpenter selected
class CarpenterSelected extends BillState {
  final Carpenter carpenter;

  const CarpenterSelected(this.carpenter);

  @override
  List<Object?> get props => [carpenter];
}

/// Bill details loading
class BillDetailsLoading extends BillState {
  const BillDetailsLoading();
}

/// Bill details loaded
class BillDetailsLoaded extends BillState {
  final Bill bill;
  final Carpenter? carpenter;

  const BillDetailsLoaded({
    required this.bill,
    this.carpenter,
  });

  @override
  List<Object?> get props => [bill, carpenter];
}

/// Bill details load failed
class BillDetailsLoadFailed extends BillState {
  final String message;

  const BillDetailsLoadFailed(this.message);

  @override
  List<Object?> get props => [message];
}

/// Bill action processing (approve/reject/withdraw)
class BillActionProcessing extends BillState {
  const BillActionProcessing();
}

/// Bill approved
class BillApproved extends BillState {
  const BillApproved();
}

/// Bill rejected
class BillRejected extends BillState {
  const BillRejected();
}

/// Bill withdrawn
class BillWithdrawn extends BillState {
  const BillWithdrawn();
}

/// Bill action failed
class BillActionFailed extends BillState {
  final String message;

  const BillActionFailed(this.message);

  @override
  List<Object?> get props => [message];
}

/// Error state
class BillError extends BillState {
  final String message;

  const BillError(this.message);

  @override
  List<Object?> get props => [message];
}
