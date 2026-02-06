import 'package:equatable/equatable.dart';
import 'package:balaji_points/features/profile/domain/entities/profile.dart';

/// Events for profile BLoC
abstract class UprofileEvent extends Equatable {
  const UprofileEvent();
  
  @override
  List<Object?> get props => [];
}

class LoadUprofile extends UprofileEvent {
  final String id;
  
  const LoadUprofile(this.id);
  
  @override
  List<Object?> get props => [id];
}

class LoadAllUprofiles extends UprofileEvent {
  const LoadAllUprofiles();
}

class CreateUprofile extends UprofileEvent {
  final UprofileEntity entity;
  
  const CreateUprofile(this.entity);
  
  @override
  List<Object?> get props => [entity];
}

class UpdateUprofile extends UprofileEvent {
  final UprofileEntity entity;
  
  const UpdateUprofile(this.entity);
  
  @override
  List<Object?> get props => [entity];
}

class DeleteUprofile extends UprofileEvent {
  final String id;
  
  const DeleteUprofile(this.id);
  
  @override
  List<Object?> get props => [id];
}
