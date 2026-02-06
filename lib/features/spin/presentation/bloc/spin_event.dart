import 'package:equatable/equatable.dart';
import 'package:balaji_points/features/spin/domain/entities/spin.dart';

/// Events for spin BLoC
abstract class UspinEvent extends Equatable {
  const UspinEvent();
  
  @override
  List<Object?> get props => [];
}

class LoadUspin extends UspinEvent {
  final String id;
  
  const LoadUspin(this.id);
  
  @override
  List<Object?> get props => [id];
}

class LoadAllUspins extends UspinEvent {
  const LoadAllUspins();
}

class CreateUspin extends UspinEvent {
  final UspinEntity entity;
  
  const CreateUspin(this.entity);
  
  @override
  List<Object?> get props => [entity];
}

class UpdateUspin extends UspinEvent {
  final UspinEntity entity;
  
  const UpdateUspin(this.entity);
  
  @override
  List<Object?> get props => [entity];
}

class DeleteUspin extends UspinEvent {
  final String id;
  
  const DeleteUspin(this.id);
  
  @override
  List<Object?> get props => [id];
}
