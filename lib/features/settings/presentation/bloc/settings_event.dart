import 'package:equatable/equatable.dart';
import 'package:balaji_points/features/settings/domain/entities/settings.dart';

/// Events for settings BLoC
abstract class UsettingsEvent extends Equatable {
  const UsettingsEvent();
  
  @override
  List<Object?> get props => [];
}

class LoadUsettings extends UsettingsEvent {
  final String id;
  
  const LoadUsettings(this.id);
  
  @override
  List<Object?> get props => [id];
}

class LoadAllUsettingss extends UsettingsEvent {
  const LoadAllUsettingss();
}

class CreateUsettings extends UsettingsEvent {
  final UsettingsEntity entity;
  
  const CreateUsettings(this.entity);
  
  @override
  List<Object?> get props => [entity];
}

class UpdateUsettings extends UsettingsEvent {
  final UsettingsEntity entity;
  
  const UpdateUsettings(this.entity);
  
  @override
  List<Object?> get props => [entity];
}

class DeleteUsettings extends UsettingsEvent {
  final String id;
  
  const DeleteUsettings(this.id);
  
  @override
  List<Object?> get props => [id];
}
