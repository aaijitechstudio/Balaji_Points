import 'package:equatable/equatable.dart';
import 'package:balaji_points/features/spin/domain/entities/spin.dart';

/// States for spin BLoC
abstract class UspinState extends Equatable {
  const UspinState();
  
  @override
  List<Object?> get props => [];
}

class UspinInitial extends UspinState {
  const UspinInitial();
}

class UspinLoading extends UspinState {
  const UspinLoading();
}

class UspinLoaded extends UspinState {
  final UspinEntity entity;
  
  const UspinLoaded(this.entity);
  
  @override
  List<Object?> get props => [entity];
}

class UspinsLoaded extends UspinState {
  final List<UspinEntity> entities;
  
  const UspinsLoaded(this.entities);
  
  @override
  List<Object?> get props => [entities];
}

class UspinError extends UspinState {
  final String message;
  
  const UspinError(this.message);
  
  @override
  List<Object?> get props => [message];
}

class UspinOperationSuccess extends UspinState {
  final String message;
  
  const UspinOperationSuccess(this.message);
  
  @override
  List<Object?> get props => [message];
}
