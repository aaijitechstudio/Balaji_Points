import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:balaji_points/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:balaji_points/features/profile/presentation/bloc/profile_event.dart';
import 'package:balaji_points/features/profile/presentation/bloc/profile_state.dart';

/// BLoC for profile
/// 
/// Handles state management for profile feature.
/// Uses use cases to execute business logic.
class UprofileBloc extends Bloc<UprofileEvent, UprofileState> {
  final GetUprofileUseCase getUprofileUseCase;
  // Add other use cases as needed
  
  UprofileBloc({
    required this.getUprofileUseCase,
  }) : super(const UprofileInitial()) {
    on<LoadUprofile>(_onLoadUprofile);
    on<LoadAllUprofiles>(_onLoadAllUprofiles);
    on<CreateUprofile>(_onCreateUprofile);
    on<UpdateUprofile>(_onUpdateUprofile);
    on<DeleteUprofile>(_onDeleteUprofile);
  }
  
  Future<void> _onLoadUprofile(
    LoadUprofile event,
    Emitter<UprofileState> emit,
  ) async {
    emit(const UprofileLoading());
    
    final result = await getUprofileUseCase(event.id);
    
    result.fold(
      (failure) => emit(UprofileError(failure.message)),
      (entity) => emit(UprofileLoaded(entity)),
    );
  }
  
  Future<void> _onLoadAllUprofiles(
    LoadAllUprofiles event,
    Emitter<UprofileState> emit,
  ) async {
    emit(const UprofileLoading());
    
    // Implement using GetAllUprofilesUseCase
    // final result = await getAllUprofilesUseCase();
    
    // result.fold(
    //   (failure) => emit(UprofileError(failure.message)),
    //   (entities) => emit(UprofilesLoaded(entities)),
    // );
  }
  
  Future<void> _onCreateUprofile(
    CreateUprofile event,
    Emitter<UprofileState> emit,
  ) async {
    emit(const UprofileLoading());
    
    // Implement using CreateUprofileUseCase
  }
  
  Future<void> _onUpdateUprofile(
    UpdateUprofile event,
    Emitter<UprofileState> emit,
  ) async {
    emit(const UprofileLoading());
    
    // Implement using UpdateUprofileUseCase
  }
  
  Future<void> _onDeleteUprofile(
    DeleteUprofile event,
    Emitter<UprofileState> emit,
  ) async {
    emit(const UprofileLoading());
    
    // Implement using DeleteUprofileUseCase
  }
}
