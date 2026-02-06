import 'package:equatable/equatable.dart';
import 'package:balaji_points/features/transactions/domain/entities/transactions.dart';

/// Events for transactions BLoC
abstract class UtransactionsEvent extends Equatable {
  const UtransactionsEvent();
  
  @override
  List<Object?> get props => [];
}

class LoadUtransactions extends UtransactionsEvent {
  final String id;
  
  const LoadUtransactions(this.id);
  
  @override
  List<Object?> get props => [id];
}

class LoadAllUtransactionss extends UtransactionsEvent {
  const LoadAllUtransactionss();
}

class CreateUtransactions extends UtransactionsEvent {
  final UtransactionsEntity entity;
  
  const CreateUtransactions(this.entity);
  
  @override
  List<Object?> get props => [entity];
}

class UpdateUtransactions extends UtransactionsEvent {
  final UtransactionsEntity entity;
  
  const UpdateUtransactions(this.entity);
  
  @override
  List<Object?> get props => [entity];
}

class DeleteUtransactions extends UtransactionsEvent {
  final String id;
  
  const DeleteUtransactions(this.id);
  
  @override
  List<Object?> get props => [id];
}
