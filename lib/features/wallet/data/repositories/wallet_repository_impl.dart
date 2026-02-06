import 'package:balaji_points/features/wallet/domain/entities/wallet_stats.dart';
import 'package:balaji_points/features/wallet/domain/entities/bill.dart';
import 'package:balaji_points/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:balaji_points/features/wallet/data/datasources/wallet_remote_datasource.dart';

/// Repository implementation for wallet
/// 
/// Implements the repository interface from domain layer.
/// Handles data source calls and converts models to entities.
class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource remoteDataSource;
  
  WalletRepositoryImpl({required this.remoteDataSource});
  
  @override
  Stream<WalletStats> getWalletStatsStream(String userId) {
    return remoteDataSource.getWalletStatsStream(userId).map((model) => model.toEntity());
  }
  
  @override
  Stream<List<Bill>> getBillsStream(String userId) {
    return remoteDataSource.getBillsStream(userId).map(
      (models) => models.map((model) => model.toEntity()).toList(),
    );
  }
}
