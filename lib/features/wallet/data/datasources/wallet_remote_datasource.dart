import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:balaji_points/features/wallet/data/models/wallet_stats_model.dart';
import 'package:balaji_points/features/wallet/data/models/bill_model.dart';

/// Remote data source for wallet
/// 
/// Handles all Firestore operations for wallet feature.
/// Wraps SessionService and Firestore streams.
class WalletRemoteDataSource {
  final FirebaseFirestore firestore;
  
  WalletRemoteDataSource({required this.firestore});
  
  /// Get wallet stats stream from Firestore
  /// Combines user document stream and bills collection streams
  Stream<WalletStatsModel> getWalletStatsStream(String userId) async* {
    // Create a stream that combines user data and bill counts
    await for (final userSnapshot in firestore.collection('users').doc(userId).snapshots()) {
      final userData = userSnapshot.data();
      
      // Get pending count
      final pendingSnapshot = await firestore
          .collection('bills')
          .where('carpenterId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .get();
      
      // Get approved count
      final approvedSnapshot = await firestore
          .collection('bills')
          .where('carpenterId', isEqualTo: userId)
          .where('status', isEqualTo: 'approved')
          .get();
      
      yield WalletStatsModel(
        totalPoints: userData?['totalPoints'] as int? ?? 0,
        tier: userData?['tier'] as String? ?? 'Bronze',
        pendingCount: pendingSnapshot.docs.length,
        approvedCount: approvedSnapshot.docs.length,
      );
    }
  }
  
  /// Get bills stream from Firestore
  Stream<List<BillModel>> getBillsStream(String userId) {
    return firestore
        .collection('bills')
        .where('carpenterId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => BillModel.fromFirestore(doc)).toList());
  }
}
