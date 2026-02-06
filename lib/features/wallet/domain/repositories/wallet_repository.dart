import 'package:balaji_points/features/wallet/domain/entities/wallet_stats.dart';
import 'package:balaji_points/features/wallet/domain/entities/bill.dart';

/// Repository interface for wallet
/// 
/// Defines the contract that the data layer must implement.
/// Returns streams for real-time updates from Firestore.
abstract class WalletRepository {
  /// Get wallet stats stream (total points, tier, pending/approved counts)
  Stream<WalletStats> getWalletStatsStream(String userId);
  
  /// Get bills stream for a user
  Stream<List<Bill>> getBillsStream(String userId);
}
