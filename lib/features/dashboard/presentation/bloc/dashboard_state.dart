import 'package:equatable/equatable.dart';

/// States for dashboard BLoC - tab navigation
abstract class DashboardState extends Equatable {
  const DashboardState();
  
  @override
  List<Object?> get props => [];
}

class DashboardTab extends DashboardState {
  final int selectedIndex;
  
  const DashboardTab(this.selectedIndex);
  
  @override
  List<Object?> get props => [selectedIndex];
}
