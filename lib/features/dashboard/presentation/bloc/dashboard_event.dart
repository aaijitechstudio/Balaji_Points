import 'package:equatable/equatable.dart';

/// Events for dashboard BLoC - tab navigation
abstract class DashboardEvent extends Equatable {
  const DashboardEvent();
  
  @override
  List<Object?> get props => [];
}

class TabChanged extends DashboardEvent {
  final int index;
  
  const TabChanged(this.index);
  
  @override
  List<Object?> get props => [index];
}
