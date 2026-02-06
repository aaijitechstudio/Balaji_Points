import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:balaji_points/features/spin/domain/usecases/get_spin_usecase.dart';
import 'package:balaji_points/features/spin/presentation/bloc/spin_event.dart';
import 'package:balaji_points/features/spin/presentation/bloc/spin_state.dart';

/// BLoC for spin
/// 
/// Handles state management for spin feature.
/// Uses use cases to execute business logic.
class UspinBloc extends Bloc<UspinEvent, UspinState> {
  final GetUspinUseCase getUspinUseCase;
  // Add other use cases as needed
  
  UspinBloc({
    required this.getUspinUseCase,
  }) : super(const UspinInitial()) {
    on<LoadUspin>(_onLoadUspin);
    on<LoadAllUspins>(_onLoadAllUspins);
    on<CreateUspin>(_onCreateUspin);
    on<UpdateUspin>(_onUpdateUspin);
    on<DeleteUspin>(_onDeleteUspin);
  }
  
  Future<void> _onLoadUspin(
    LoadUspin event,
    Emitter<UspinState> emit,
  ) async {
    emit(const UspinLoading());
    
    final result = await getUspinUseCase(event.id);
    
    result.fold(
      (failure) => emit(UspinError(failure.message)),
      (entity) => emit(UspinLoaded(entity)),
    );
  }
  
  Future<void> _onLoadAllUspins(
    LoadAllUspins event,
    Emitter<UspinState> emit,
  ) async {
    emit(const UspinLoading());
    
    // Implement using GetAllUspinsUseCase
    // final result = await getAllUspinsUseCase();
    
    // result.fold(
    //   (failure) => emit(UspinError(failure.message)),
    //   (entities) => emit(UspinsLoaded(entities)),
    // );
  }
  
  Future<void> _onCreateUspin(
    CreateUspin event,
    Emitter<UspinState> emit,
  ) async {
    emit(const UspinLoading());
    
    // Implement using CreateUspinUseCase
  }
  
  Future<void> _onUpdateUspin(
    UpdateUspin event,
    Emitter<UspinState> emit,
  ) async {
    emit(const UspinLoading());
    
    // Implement using UpdateUspinUseCase
  }
  
  Future<void> _onDeleteUspin(
    DeleteUspin event,
    Emitter<UspinState> emit,
  ) async {
    emit(const UspinLoading());
    
    // Implement using DeleteUspinUseCase
  }
}
