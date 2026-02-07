import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:balaji_points/features/home/presentation/bloc/home_event.dart';
import 'package:balaji_points/features/home/presentation/bloc/home_state.dart';

/// BLoC for home - wraps Firebase streams
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeInitial()) {
    on<LoadHomeData>(_onLoadHomeData);
  }
  
  void _onLoadHomeData(
    LoadHomeData event,
    Emitter<HomeState> emit,
  ) {
    // Wrap existing Firebase streams in BLoC state
    final offersStream = FirebaseFirestore.instance
      .collection('offers')
      .where('isActive', isEqualTo: true)
      .orderBy('createdAt', descending: true)
      .snapshots();
    
    final carpentersStream = FirebaseFirestore.instance
      .collection('users')
      .where('role', isEqualTo: 'carpenter')
      .orderBy('totalPoints', descending: true)
      .limit(10)
      .snapshots();
    
    emit(HomeLoaded(
      offersStream: offersStream,
      carpentersStream: carpentersStream,
    ));
  }
}
