import 'package:equatable/equatable.dart';

/// Events for wallet BLoC
abstract class WalletEvent extends Equatable {
  const WalletEvent();
  
  @override
  List<Object?> get props => [];
}

/// Event to load wallet data for a specific user
class LoadWalletData extends WalletEvent {
  final String userId;
  
  const LoadWalletData(this.userId);
  
  @override
  List<Object?> get props => [userId];
}

/// Event to refresh wallet data (pull-to-refresh)
class RefreshWalletData extends WalletEvent {
  const RefreshWalletData();
}
