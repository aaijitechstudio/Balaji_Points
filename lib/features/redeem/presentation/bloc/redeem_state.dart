import 'package:equatable/equatable.dart';
import 'package:balaji_points/features/redeem/domain/entities/redeem.dart';

/// States for redeem BLoC
abstract class UredeemState extends Equatable {
  const UredeemState();
  
  @override
  List<Object?> get props => [];
}

class UredeemInitial extends UredeemState {
  const UredeemInitial();
}

class UredeemLoading extends UredeemState {
  const UredeemLoading();
}

class UredeemLoaded extends UredeemState {
  final UredeemEntity entity;
  
  const UredeemLoaded(this.entity);
  
  @override
  List<Object?> get props => [entity];
}

class UredeemsLoaded extends UredeemState {
  final List<UredeemEntity> entities;
  
  const UredeemsLoaded(this.entities);
  
  @override
  List<Object?> get props => [entities];
}

class UredeemError extends UredeemState {
  final String message;
  
  const UredeemError(this.message);
  
  @override
  List<Object?> get props => [message];
}

class UredeemOperationSuccess extends UredeemState {
  final String message;
  
  const UredeemOperationSuccess(this.message);
  
  @override
  List<Object?> get props => [message];
}
