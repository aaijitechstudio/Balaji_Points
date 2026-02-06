import 'package:equatable/equatable.dart';
import 'package:balaji_points/features/dashboard/domain/entities/dashboard.dart';

/// States for dashboard BLoC
abstract class UdashboardState extends Equatable {
  const UdashboardState();
  
  @override
  List<Object?> get props => [];
}

class UdashboardInitial extends UdashboardState {
  const UdashboardInitial();
}

class UdashboardLoading extends UdashboardState {
  const UdashboardLoading();
}

class UdashboardLoaded extends UdashboardState {
  final UdashboardEntity entity;
  
  const UdashboardLoaded(this.entity);
  
  @override
  List<Object?> get props => [entity];
}

class UdashboardsLoaded extends UdashboardState {
  final List<UdashboardEntity> entities;
  
  const UdashboardsLoaded(this.entities);
  
  @override
  List<Object?> get props => [entities];
}

class UdashboardError extends UdashboardState {
  final String message;
  
  const UdashboardError(this.message);
  
  @override
  List<Object?> get props => [message];
}

class UdashboardOperationSuccess extends UdashboardState {
  final String message;
  
  const UdashboardOperationSuccess(this.message);
  
  @override
  List<Object?> get props => [message];
}
