import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:balaji_points/features/bills/domain/usecases/submit_bill_usecase.dart';
import 'package:balaji_points/features/bills/domain/usecases/submit_bill_for_carpenter_usecase.dart';
import 'package:balaji_points/features/bills/domain/usecases/approve_bill_usecase.dart';
import 'package:balaji_points/features/bills/domain/usecases/reject_bill_usecase.dart';
import 'package:balaji_points/features/bills/domain/usecases/withdraw_bill_usecase.dart';
import 'package:balaji_points/features/bills/domain/usecases/get_bill_by_id_usecase.dart';
import 'package:balaji_points/features/bills/domain/usecases/get_carpenters_usecase.dart';
import 'package:balaji_points/features/bills/domain/usecases/get_carpenter_by_id_usecase.dart';
import 'package:balaji_points/features/bills/domain/usecases/get_current_user_data_usecase.dart';
import 'package:balaji_points/features/bills/presentation/bloc/bill_event.dart';
import 'package:balaji_points/features/bills/presentation/bloc/bill_state.dart';

class BillBloc extends Bloc<BillEvent, BillState> {
  final SubmitBillUseCase submitBillUseCase;
  final SubmitBillForCarpenterUseCase submitBillForCarpenterUseCase;
  final ApproveBillUseCase approveBillUseCase;
  final RejectBillUseCase rejectBillUseCase;
  final WithdrawBillUseCase withdrawBillUseCase;
  final GetBillByIdUseCase getBillByIdUseCase;
  final GetCarpentersUseCase getCarpentersUseCase;
  final GetCarpenterByIdUseCase getCarpenterByIdUseCase;
  final GetCurrentUserDataUseCase getCurrentUserDataUseCase;

  BillBloc({
    required this.submitBillUseCase,
    required this.submitBillForCarpenterUseCase,
    required this.approveBillUseCase,
    required this.rejectBillUseCase,
    required this.withdrawBillUseCase,
    required this.getBillByIdUseCase,
    required this.getCarpentersUseCase,
    required this.getCarpenterByIdUseCase,
    required this.getCurrentUserDataUseCase,
  }) : super(const BillInitial()) {
    on<LoadCurrentUserDataEvent>(_onLoadCurrentUserData);
    on<SelectImageEvent>(_onSelectImage);
    on<RemoveImageEvent>(_onRemoveImage);
    on<SelectDateEvent>(_onSelectDate);
    on<SubmitBillEvent>(_onSubmitBill);
    on<LoadCarpentersEvent>(_onLoadCarpenters);
    on<SelectCarpenterEvent>(_onSelectCarpenter);
    on<SubmitBillForCarpenterEvent>(_onSubmitBillForCarpenter);
    on<LoadBillDetailsEvent>(_onLoadBillDetails);
    on<ApproveBillEvent>(_onApproveBill);
    on<RejectBillEvent>(_onRejectBill);
    on<WithdrawBillEvent>(_onWithdrawBill);
    on<ResetBillStateEvent>(_onResetState);
  }

  Future<void> _onLoadCurrentUserData(
    LoadCurrentUserDataEvent event,
    Emitter<BillState> emit,
  ) async {
    emit(const BillLoading());
    final result = await getCurrentUserDataUseCase();
    result.fold(
      (failure) => emit(BillError(failure.message)),
      (userData) {
        final firstName = (userData['firstName'] as String? ?? '').trim();
        final lastName = (userData['lastName'] as String? ?? '').trim();
        final profileImage = (userData['profileImage'] as String? ?? '').trim();

        if (firstName.isEmpty || lastName.isEmpty || profileImage.isEmpty) {
          emit(ProfileIncomplete(userData));
        } else {
          emit(UserDataLoaded(userData));
        }
      },
    );
  }

  Future<void> _onSelectImage(
    SelectImageEvent event,
    Emitter<BillState> emit,
  ) async {
    emit(ImageSelected(event.imageFile));
  }

  Future<void> _onRemoveImage(
    RemoveImageEvent event,
    Emitter<BillState> emit,
  ) async {
    emit(const ImageRemoved());
  }

  Future<void> _onSelectDate(
    SelectDateEvent event,
    Emitter<BillState> emit,
  ) async {
    emit(DateSelected(event.date));
  }

  Future<void> _onSubmitBill(
    SubmitBillEvent event,
    Emitter<BillState> emit,
  ) async {
    emit(const BillSubmitting());
    final result = await submitBillUseCase(
      carpenterId: event.carpenterId,
      carpenterPhone: event.carpenterPhone,
      amount: event.amount,
      imageFile: event.imageFile,
      billDate: event.billDate,
      storeName: event.storeName,
      billNumber: event.billNumber,
      notes: event.notes,
    );
    result.fold(
      (failure) => emit(BillSubmissionFailed(failure.message)),
      (_) => emit(const BillSubmitted()),
    );
  }

  Future<void> _onLoadCarpenters(
    LoadCarpentersEvent event,
    Emitter<BillState> emit,
  ) async {
    emit(const CarpentersLoading());
    final result = await getCarpentersUseCase();
    result.fold(
      (failure) => emit(CarpentersLoadFailed(failure.message)),
      (carpenters) => emit(CarpentersLoaded(carpenters)),
    );
  }

  Future<void> _onSelectCarpenter(
    SelectCarpenterEvent event,
    Emitter<BillState> emit,
  ) async {
    emit(CarpenterSelected(event.carpenter));
  }

  Future<void> _onSubmitBillForCarpenter(
    SubmitBillForCarpenterEvent event,
    Emitter<BillState> emit,
  ) async {
    emit(const BillSubmitting());
    final result = await submitBillForCarpenterUseCase(
      carpenterId: event.carpenterId,
      carpenterPhone: event.carpenterPhone,
      amount: event.amount,
      adminId: event.adminId,
      adminPhone: event.adminPhone,
      adminName: event.adminName,
      imageFile: event.imageFile,
      billDate: event.billDate,
      storeName: event.storeName,
      billNumber: event.billNumber,
      notes: event.notes,
    );
    result.fold(
      (failure) => emit(BillSubmissionFailed(failure.message)),
      (_) => emit(const BillSubmitted()),
    );
  }

  Future<void> _onLoadBillDetails(
    LoadBillDetailsEvent event,
    Emitter<BillState> emit,
  ) async {
    emit(const BillDetailsLoading());
    final billResult = await getBillByIdUseCase(event.billId);
    
    await billResult.fold(
      (failure) async => emit(BillDetailsLoadFailed(failure.message)),
      (bill) async {
        final carpenterResult = await getCarpenterByIdUseCase(bill.carpenterId);
        carpenterResult.fold(
          (_) => emit(BillDetailsLoaded(bill: bill)),
          (carpenter) => emit(BillDetailsLoaded(bill: bill, carpenter: carpenter)),
        );
      },
    );
  }

  Future<void> _onApproveBill(
    ApproveBillEvent event,
    Emitter<BillState> emit,
  ) async {
    emit(const BillActionProcessing());
    final result = await approveBillUseCase(
      billId: event.billId,
      carpenterId: event.carpenterId,
      amount: event.amount,
    );
    result.fold(
      (failure) => emit(BillActionFailed(failure.message)),
      (_) => emit(const BillApproved()),
    );
  }

  Future<void> _onRejectBill(
    RejectBillEvent event,
    Emitter<BillState> emit,
  ) async {
    emit(const BillActionProcessing());
    final result = await rejectBillUseCase(
      billId: event.billId,
      reason: event.reason,
    );
    result.fold(
      (failure) => emit(BillActionFailed(failure.message)),
      (_) => emit(const BillRejected()),
    );
  }

  Future<void> _onWithdrawBill(
    WithdrawBillEvent event,
    Emitter<BillState> emit,
  ) async {
    emit(const BillActionProcessing());
    final result = await withdrawBillUseCase(event.billId);
    result.fold(
      (failure) => emit(BillActionFailed(failure.message)),
      (_) => emit(const BillWithdrawn()),
    );
  }

  Future<void> _onResetState(
    ResetBillStateEvent event,
    Emitter<BillState> emit,
  ) async {
    emit(const BillInitial());
  }
}
