import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// States for home BLoC
abstract class HomeState extends Equatable {
  const HomeState();
  
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoaded extends HomeState {
  final Stream<QuerySnapshot> offersStream;
  final Stream<QuerySnapshot> carpentersStream;
  
  const HomeLoaded({
    required this.offersStream,
    required this.carpentersStream,
  });
  
  @override
  List<Object?> get props => [offersStream, carpentersStream];
}
