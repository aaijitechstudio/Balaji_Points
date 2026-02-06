import 'package:equatable/equatable.dart';
import 'package:balaji_points/features/admin/domain/entities/admin.dart';

/// Events for admin BLoC
abstract class UadminEvent extends Equatable {
  const UadminEvent();
  
  @override
  List<Object?> get props => [];
}

class LoadUadmin extends UadminEvent {
  final String id;
  
  const LoadUadmin(this.id);
  
  @override
  List<Object?> get props => [id];
}

class LoadAllUadmins extends UadminEvent {
  const LoadAllUadmins();
}

class CreateUadmin extends UadminEvent {
  final UadminEntity entity;
  
  const CreateUadmin(this.entity);
  
  @override
  List<Object?> get props => [entity];
}

class UpdateUadmin extends UadminEvent {
  final UadminEntity entity;
  
  const UpdateUadmin(this.entity);
  
  @override
  List<Object?> get props => [entity];
}

class DeleteUadmin extends UadminEvent {
  final String id;
  
  const DeleteUadmin(this.id);
  
  @override
  List<Object?> get props => [id];
}
