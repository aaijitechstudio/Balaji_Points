import 'package:equatable/equatable.dart';
import 'package:balaji_points/features/dashboard/domain/entities/dashboard.dart';

/// Events for dashboard BLoC
abstract class UdashboardEvent extends Equatable {
  const UdashboardEvent();
  
  @override
  List<Object?> get props => [];
}

class LoadUdashboard extends UdashboardEvent {
  final String id;
  
  const LoadUdashboard(this.id);
  
  @override
  List<Object?> get props => [id];
}

class LoadAllUdashboards extends UdashboardEvent {
  const LoadAllUdashboards();
}

class CreateUdashboard extends UdashboardEvent {
  final UdashboardEntity entity;
  
  const CreateUdashboard(this.entity);
  
  @override
  List<Object?> get props => [entity];
}

class UpdateUdashboard extends UdashboardEvent {
  final UdashboardEntity entity;
  
  const UpdateUdashboard(this.entity);
  
  @override
  List<Object?> get props => [entity];
}

class DeleteUdashboard extends UdashboardEvent {
  final String id;
  
  const DeleteUdashboard(this.id);
  
  @override
  List<Object?> get props => [id];
}
