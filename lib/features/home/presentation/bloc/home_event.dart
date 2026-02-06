import 'package:equatable/equatable.dart';
import 'package:balaji_points/features/home/domain/entities/home.dart';

/// Events for home BLoC
abstract class UhomeEvent extends Equatable {
  const UhomeEvent();
  
  @override
  List<Object?> get props => [];
}

class LoadUhome extends UhomeEvent {
  final String id;
  
  const LoadUhome(this.id);
  
  @override
  List<Object?> get props => [id];
}

class LoadAllUhomes extends UhomeEvent {
  const LoadAllUhomes();
}

class CreateUhome extends UhomeEvent {
  final UhomeEntity entity;
  
  const CreateUhome(this.entity);
  
  @override
  List<Object?> get props => [entity];
}

class UpdateUhome extends UhomeEvent {
  final UhomeEntity entity;
  
  const UpdateUhome(this.entity);
  
  @override
  List<Object?> get props => [entity];
}

class DeleteUhome extends UhomeEvent {
  final String id;
  
  const DeleteUhome(this.id);
  
  @override
  List<Object?> get props => [id];
}
