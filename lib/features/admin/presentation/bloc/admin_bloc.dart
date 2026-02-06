import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:balaji_points/features/admin/domain/usecases/get_admin_usecase.dart';
import 'package:balaji_points/features/admin/presentation/bloc/admin_event.dart';
import 'package:balaji_points/features/admin/presentation/bloc/admin_state.dart';

/// BLoC for admin
/// 
/// Handles state management for admin feature.
/// Uses use cases to execute business logic.
class UadminBloc extends Bloc<UadminEvent, UadminState> {
  final GetUadminUseCase getUadminUseCase;
  // Add other use cases as needed
  
  UadminBloc({
    required this.getUadminUseCase,
  }) : super(const UadminInitial()) {
    on<LoadUadmin>(_onLoadUadmin);
    on<LoadAllUadmins>(_onLoadAllUadmins);
    on<CreateUadmin>(_onCreateUadmin);
    on<UpdateUadmin>(_onUpdateUadmin);
    on<DeleteUadmin>(_onDeleteUadmin);
  }
  
  Future<void> _onLoadUadmin(
    LoadUadmin event,
    Emitter<UadminState> emit,
  ) async {
    emit(const UadminLoading());
    
    final result = await getUadminUseCase(event.id);
    
    result.fold(
      (failure) => emit(UadminError(failure.message)),
      (entity) => emit(UadminLoaded(entity)),
    );
  }
  
  Future<void> _onLoadAllUadmins(
    LoadAllUadmins event,
    Emitter<UadminState> emit,
  ) async {
    emit(const UadminLoading());
    
    // Implement using GetAllUadminsUseCase
    // final result = await getAllUadminsUseCase();
    
    // result.fold(
    //   (failure) => emit(UadminError(failure.message)),
    //   (entities) => emit(UadminsLoaded(entities)),
    // );
  }
  
  Future<void> _onCreateUadmin(
    CreateUadmin event,
    Emitter<UadminState> emit,
  ) async {
    emit(const UadminLoading());
    
    // Implement using CreateUadminUseCase
  }
  
  Future<void> _onUpdateUadmin(
    UpdateUadmin event,
    Emitter<UadminState> emit,
  ) async {
    emit(const UadminLoading());
    
    // Implement using UpdateUadminUseCase
  }
  
  Future<void> _onDeleteUadmin(
    DeleteUadmin event,
    Emitter<UadminState> emit,
  ) async {
    emit(const UadminLoading());
    
    // Implement using DeleteUadminUseCase
  }
}
