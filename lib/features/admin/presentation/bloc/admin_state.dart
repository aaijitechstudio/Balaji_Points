import 'package:equatable/equatable.dart';
import 'package:balaji_points/features/admin/domain/entities/admin.dart';

/// States for admin BLoC
abstract class UadminState extends Equatable {
  const UadminState();
  
  @override
  List<Object?> get props => [];
}

class UadminInitial extends UadminState {
  const UadminInitial();
}

class UadminLoading extends UadminState {
  const UadminLoading();
}

class UadminLoaded extends UadminState {
  final UadminEntity entity;
  
  const UadminLoaded(this.entity);
  
  @override
  List<Object?> get props => [entity];
}

class UadminsLoaded extends UadminState {
  final List<UadminEntity> entities;
  
  const UadminsLoaded(this.entities);
  
  @override
  List<Object?> get props => [entities];
}

class UadminError extends UadminState {
  final String message;
  
  const UadminError(this.message);
  
  @override
  List<Object?> get props => [message];
}

class UadminOperationSuccess extends UadminState {
  final String message;
  
  const UadminOperationSuccess(this.message);
  
  @override
  List<Object?> get props => [message];
}
