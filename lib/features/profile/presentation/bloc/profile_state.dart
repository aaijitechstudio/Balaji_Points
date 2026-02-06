import 'package:equatable/equatable.dart';
import 'package:balaji_points/features/profile/domain/entities/profile.dart';

/// States for profile BLoC
abstract class UprofileState extends Equatable {
  const UprofileState();
  
  @override
  List<Object?> get props => [];
}

class UprofileInitial extends UprofileState {
  const UprofileInitial();
}

class UprofileLoading extends UprofileState {
  const UprofileLoading();
}

class UprofileLoaded extends UprofileState {
  final UprofileEntity entity;
  
  const UprofileLoaded(this.entity);
  
  @override
  List<Object?> get props => [entity];
}

class UprofilesLoaded extends UprofileState {
  final List<UprofileEntity> entities;
  
  const UprofilesLoaded(this.entities);
  
  @override
  List<Object?> get props => [entities];
}

class UprofileError extends UprofileState {
  final String message;
  
  const UprofileError(this.message);
  
  @override
  List<Object?> get props => [message];
}

class UprofileOperationSuccess extends UprofileState {
  final String message;
  
  const UprofileOperationSuccess(this.message);
  
  @override
  List<Object?> get props => [message];
}
