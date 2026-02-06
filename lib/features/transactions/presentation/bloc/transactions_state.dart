import 'package:equatable/equatable.dart';
import 'package:balaji_points/features/transactions/domain/entities/transactions.dart';

/// States for transactions BLoC
abstract class UtransactionsState extends Equatable {
  const UtransactionsState();
  
  @override
  List<Object?> get props => [];
}

class UtransactionsInitial extends UtransactionsState {
  const UtransactionsInitial();
}

class UtransactionsLoading extends UtransactionsState {
  const UtransactionsLoading();
}

class UtransactionsLoaded extends UtransactionsState {
  final UtransactionsEntity entity;
  
  const UtransactionsLoaded(this.entity);
  
  @override
  List<Object?> get props => [entity];
}

class UtransactionssLoaded extends UtransactionsState {
  final List<UtransactionsEntity> entities;
  
  const UtransactionssLoaded(this.entities);
  
  @override
  List<Object?> get props => [entities];
}

class UtransactionsError extends UtransactionsState {
  final String message;
  
  const UtransactionsError(this.message);
  
  @override
  List<Object?> get props => [message];
}

class UtransactionsOperationSuccess extends UtransactionsState {
  final String message;
  
  const UtransactionsOperationSuccess(this.message);
  
  @override
  List<Object?> get props => [message];
}
