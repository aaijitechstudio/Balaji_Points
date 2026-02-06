import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:balaji_points/features/transactions/data/models/transactions_model.dart';

/// Remote data source for transactions
/// 
/// Handles all network/database operations for this feature.
/// Throws exceptions on errors (handled by repository).
abstract class UtransactionsRemoteDataSource {
  Future<UtransactionsModel> getUtransactions(String id);
  Future<List<UtransactionsModel>> getAll();
  Future<void> create(UtransactionsModel model);
  Future<void> update(UtransactionsModel model);
  Future<void> delete(String id);
}

class UtransactionsRemoteDataSourceImpl implements UtransactionsRemoteDataSource {
  final FirebaseFirestore firestore;
  
  UtransactionsRemoteDataSourceImpl({required this.firestore});
  
  @override
  Future<UtransactionsModel> getUtransactions(String id) async {
    try {
      final doc = await firestore.collection('COLLECTION_NAME').doc(id).get();
      
      if (!doc.exists) {
        throw Exception('transactions not found');
      }
      
      return UtransactionsModel.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Failed to get transactions: $e');
    }
  }
  
  @override
  Future<List<UtransactionsModel>> getAll() async {
    try {
      final snapshot = await firestore.collection('COLLECTION_NAME').get();
      return snapshot.docs
          .map((doc) => UtransactionsModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get all transactions: $e');
    }
  }
  
  @override
  Future<void> create(UtransactionsModel model) async {
    try {
      await firestore
          .collection('COLLECTION_NAME')
          .doc(model.id)
          .set(model.toJson());
    } catch (e) {
      throw Exception('Failed to create transactions: $e');
    }
  }
  
  @override
  Future<void> update(UtransactionsModel model) async {
    try {
      await firestore
          .collection('COLLECTION_NAME')
          .doc(model.id)
          .update(model.toJson());
    } catch (e) {
      throw Exception('Failed to update transactions: $e');
    }
  }
  
  @override
  Future<void> delete(String id) async {
    try {
      await firestore.collection('COLLECTION_NAME').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete transactions: $e');
    }
  }
}
