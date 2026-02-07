import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:balaji_points/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:balaji_points/features/dashboard/presentation/bloc/dashboard_state.dart';

/// BLoC for dashboard tab navigation
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(const DashboardTab(0)) {
    on<TabChanged>(_onTabChanged);
  }
  
  void _onTabChanged(
    TabChanged event,
    Emitter<DashboardState> emit,
  ) {
    emit(DashboardTab(event.index));
  }
}
