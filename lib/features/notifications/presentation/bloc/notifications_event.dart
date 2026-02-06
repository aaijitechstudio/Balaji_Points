import 'package:equatable/equatable.dart';
import 'package:balaji_points/features/notifications/domain/entities/notifications.dart';

/// Events for notifications BLoC
abstract class UnotificationsEvent extends Equatable {
  const UnotificationsEvent();
  
  @override
  List<Object?> get props => [];
}

class LoadUnotifications extends UnotificationsEvent {
  final String id;
  
  const LoadUnotifications(this.id);
  
  @override
  List<Object?> get props => [id];
}

class LoadAllUnotificationss extends UnotificationsEvent {
  const LoadAllUnotificationss();
}

class CreateUnotifications extends UnotificationsEvent {
  final UnotificationsEntity entity;
  
  const CreateUnotifications(this.entity);
  
  @override
  List<Object?> get props => [entity];
}

class UpdateUnotifications extends UnotificationsEvent {
  final UnotificationsEntity entity;
  
  const UpdateUnotifications(this.entity);
  
  @override
  List<Object?> get props => [entity];
}

class DeleteUnotifications extends UnotificationsEvent {
  final String id;
  
  const DeleteUnotifications(this.id);
  
  @override
  List<Object?> get props => [id];
}
