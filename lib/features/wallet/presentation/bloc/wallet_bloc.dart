import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:balaji_points/services/session_service.dart';
import 'package:balaji_points/features/wallet/domain/usecases/get_wallet_stats_stream_usecase.dart';
import 'package:balaji_points/features/wallet/domain/usecases/get_bills_stream_usecase.dart';
import 'package:balaji_points/features/wallet/presentation/bloc/wallet_event.dart';
import 'package:balaji_points/features/wallet/presentation/bloc/wallet_state.dart';
import 'package:balaji_points/features/wallet/domain/entities/wallet_stats.dart';
import 'package:balaji_points/features/wallet/domain/entities/bill.dart';

/// BLoC for wallet
/// 
/// Handles state management for wallet feature.
/// Uses use cases to execute business logic.
class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final GetWalletStatsStreamUseCase getWalletStatsStreamUseCase;
  final GetBillsStreamUseCase getBillsStreamUseCase;
  final SessionService sessionService;
  
  StreamSubscription<WalletStats>? _statsSubscription;
  StreamSubscription<List<Bill>>? _billsSubscription;
  
  WalletBloc({
    required this.getWalletStatsStreamUseCase,
    required this.getBillsStreamUseCase,
    required this.sessionService,
  }) : super(const WalletInitial()) {
    on<LoadWalletData>(_onLoadWalletData);
    on<RefreshWalletData>(_onRefreshWalletData);
  }
  
  Future<void> _onLoadWalletData(
    LoadWalletData event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletLoading());
    
    try {
      // Cancel existing subscriptions
      await _statsSubscription?.cancel();
      await _billsSubscription?.cancel();
      
      final userId = event.userId;
      
      // Initialize with empty data
      WalletStats currentStats = const WalletStats(
        totalPoints: 0,
        tier: 'Bronze',
        pendingCount: 0,
        approvedCount: 0,
      );
      List<Bill> currentBills = [];
      
      // Listen to stats stream
      _statsSubscription = getWalletStatsStreamUseCase(userId).listen(
        (stats) {
          currentStats = stats;
          if (state is WalletLoaded) {
            emit((state as WalletLoaded).copyWith(stats: stats));
          } else {
            emit(WalletLoaded(
              userId: userId,
              stats: currentStats,
              bills: currentBills,
            ));
          }
        },
        onError: (error) {
          emit(WalletError(error.toString()));
        },
      );
      
      // Listen to bills stream
      _billsSubscription = getBillsStreamUseCase(userId).listen(
        (bills) {
          currentBills = bills;
          if (state is WalletLoaded) {
            emit((state as WalletLoaded).copyWith(bills: bills));
          } else {
            emit(WalletLoaded(
              userId: userId,
              stats: currentStats,
              bills: currentBills,
            ));
          }
        },
        onError: (error) {
          emit(WalletError(error.toString()));
        },
      );
      
      // Emit initial loaded state
      emit(WalletLoaded(
        userId: userId,
        stats: currentStats,
        bills: currentBills,
      ));
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }
  
  Future<void> _onRefreshWalletData(
    RefreshWalletData event,
    Emitter<WalletState> emit,
  ) async {
    // For refresh, just set the refreshing flag
    // The streams will automatically update
    if (state is WalletLoaded) {
      final currentState = state as WalletLoaded;
      emit(currentState.copyWith(isRefreshing: true));
      
      // Small delay to show refresh indicator
      await Future.delayed(const Duration(milliseconds: 500));
      
      emit(currentState.copyWith(isRefreshing: false));
    }
  }
  
  @override
  Future<void> close() {
    _statsSubscription?.cancel();
    _billsSubscription?.cancel();
    return super.close();
  }
}
