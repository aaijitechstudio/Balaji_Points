import 'package:equatable/equatable.dart';
import 'package:balaji_points/features/home/domain/entities/home.dart';

/// States for home BLoC
abstract class UhomeState extends Equatable {
  const UhomeState();
  
  @override
  List<Object?> get props => [];
}

class UhomeInitial extends UhomeState {
  const UhomeInitial();
}

class UhomeLoading extends UhomeState {
  const UhomeLoading();
}

class UhomeLoaded extends UhomeState {
  final UhomeEntity entity;
  
  const UhomeLoaded(this.entity);
  
  @override
  List<Object?> get props => [entity];
}

class UhomesLoaded extends UhomeState {
  final List<UhomeEntity> entities;
  
  const UhomesLoaded(this.entities);
  
  @override
  List<Object?> get props => [entities];
}

class UhomeError extends UhomeState {
  final String message;
  
  const UhomeError(this.message);
  
  @override
  List<Object?> get props => [message];
}

class UhomeOperationSuccess extends UhomeState {
  final String message;
  
  const UhomeOperationSuccess(this.message);
  
  @override
  List<Object?> get props => [message];
}
