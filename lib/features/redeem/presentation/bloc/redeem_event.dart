import 'package:equatable/equatable.dart';
import 'package:balaji_points/features/redeem/domain/entities/redeem.dart';

/// Events for redeem BLoC
abstract class UredeemEvent extends Equatable {
  const UredeemEvent();
  
  @override
  List<Object?> get props => [];
}

class LoadUredeem extends UredeemEvent {
  final String id;
  
  const LoadUredeem(this.id);
  
  @override
  List<Object?> get props => [id];
}

class LoadAllUredeems extends UredeemEvent {
  const LoadAllUredeems();
}

class CreateUredeem extends UredeemEvent {
  final UredeemEntity entity;
  
  const CreateUredeem(this.entity);
  
  @override
  List<Object?> get props => [entity];
}

class UpdateUredeem extends UredeemEvent {
  final UredeemEntity entity;
  
  const UpdateUredeem(this.entity);
  
  @override
  List<Object?> get props => [entity];
}

class DeleteUredeem extends UredeemEvent {
  final String id;
  
  const DeleteUredeem(this.id);
  
  @override
  List<Object?> get props => [id];
}
