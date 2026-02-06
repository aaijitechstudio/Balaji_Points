import 'package:equatable/equatable.dart';
import 'package:balaji_points/features/notifications/domain/entities/notifications.dart';

/// States for notifications BLoC
abstract class UnotificationsState extends Equatable {
  const UnotificationsState();
  
  @override
  List<Object?> get props => [];
}

class UnotificationsInitial extends UnotificationsState {
  const UnotificationsInitial();
}

class UnotificationsLoading extends UnotificationsState {
  const UnotificationsLoading();
}

class UnotificationsLoaded extends UnotificationsState {
  final UnotificationsEntity entity;
  
  const UnotificationsLoaded(this.entity);
  
  @override
  List<Object?> get props => [entity];
}

class UnotificationssLoaded extends UnotificationsState {
  final List<UnotificationsEntity> entities;
  
  const UnotificationssLoaded(this.entities);
  
  @override
  List<Object?> get props => [entities];
}

class UnotificationsError extends UnotificationsState {
  final String message;
  
  const UnotificationsError(this.message);
  
  @override
  List<Object?> get props => [message];
}

class UnotificationsOperationSuccess extends UnotificationsState {
  final String message;
  
  const UnotificationsOperationSuccess(this.message);
  
  @override
  List<Object?> get props => [message];
}
