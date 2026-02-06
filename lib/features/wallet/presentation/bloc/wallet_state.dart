import 'package:equatable/equatable.dart';
import 'package:balaji_points/features/wallet/domain/entities/wallet_stats.dart';
import 'package:balaji_points/features/wallet/domain/entities/bill.dart';

/// States for wallet BLoC
abstract class WalletState extends Equatable {
  const WalletState();
  
  @override
  List<Object?> get props => [];
}

/// Initial state - no user loaded yet
class WalletInitial extends WalletState {
  const WalletInitial();
}

/// Loading state - fetching user ID from session
class WalletLoading extends WalletState {
  const WalletLoading();
}

/// Loaded state - streaming wallet data
class WalletLoaded extends WalletState {
  final String userId;
  final WalletStats stats;
  final List<Bill> bills;
  final bool isRefreshing;
  
  const WalletLoaded({
    required this.userId,
    required this.stats,
    required this.bills,
    this.isRefreshing = false,
  });
  
  @override
  List<Object?> get props => [userId, stats, bills, isRefreshing];
  
  WalletLoaded copyWith({
    String? userId,
    WalletStats? stats,
    List<Bill>? bills,
    bool? isRefreshing,
  }) {
    return WalletLoaded(
      userId: userId ?? this.userId,
      stats: stats ?? this.stats,
      bills: bills ?? this.bills,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

/// Error state
class WalletError extends WalletState {
  final String message;
  
  const WalletError(this.message);
  
  @override
  List<Object?> get props => [message];
}
