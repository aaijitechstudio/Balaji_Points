import 'package:equatable/equatable.dart';
import 'package:balaji_points/features/settings/domain/entities/settings.dart';

/// States for settings BLoC
abstract class UsettingsState extends Equatable {
  const UsettingsState();
  
  @override
  List<Object?> get props => [];
}

class UsettingsInitial extends UsettingsState {
  const UsettingsInitial();
}

class UsettingsLoading extends UsettingsState {
  const UsettingsLoading();
}

class UsettingsLoaded extends UsettingsState {
  final UsettingsEntity entity;
  
  const UsettingsLoaded(this.entity);
  
  @override
  List<Object?> get props => [entity];
}

class UsettingssLoaded extends UsettingsState {
  final List<UsettingsEntity> entities;
  
  const UsettingssLoaded(this.entities);
  
  @override
  List<Object?> get props => [entities];
}

class UsettingsError extends UsettingsState {
  final String message;
  
  const UsettingsError(this.message);
  
  @override
  List<Object?> get props => [message];
}

class UsettingsOperationSuccess extends UsettingsState {
  final String message;
  
  const UsettingsOperationSuccess(this.message);
  
  @override
  List<Object?> get props => [message];
}
