import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Events for home BLoC
abstract class HomeEvent extends Equatable {
  const HomeEvent();
  
  @override
  List<Object?> get props => [];
}

class LoadHomeData extends HomeEvent {
  const LoadHomeData();
}
