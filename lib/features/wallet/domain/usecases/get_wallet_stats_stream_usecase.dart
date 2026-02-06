import 'package:balaji_points/features/wallet/domain/entities/wallet_stats.dart';
import 'package:balaji_points/features/wallet/domain/repositories/wallet_repository.dart';

/// Use case to get wallet stats stream
/// 
/// Follows Clean Architecture principles - each use case has a single responsibility
class GetWalletStatsStreamUseCase {
  final WalletRepository repository;
  
  GetWalletStatsStreamUseCase(this.repository);
  
  Stream<WalletStats> call(String userId) {
    return repository.getWalletStatsStream(userId);
  }
}
