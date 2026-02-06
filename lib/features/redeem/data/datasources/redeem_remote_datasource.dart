import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:balaji_points/features/redeem/data/models/redeem_model.dart';

/// Remote data source for redeem
/// 
/// Handles all network/database operations for this feature.
/// Throws exceptions on errors (handled by repository).
abstract class UredeemRemoteDataSource {
  Future<UredeemModel> getUredeem(String id);
  Future<List<UredeemModel>> getAll();
  Future<void> create(UredeemModel model);
  Future<void> update(UredeemModel model);
  Future<void> delete(String id);
}

class UredeemRemoteDataSourceImpl implements UredeemRemoteDataSource {
  final FirebaseFirestore firestore;
  
  UredeemRemoteDataSourceImpl({required this.firestore});
  
  @override
  Future<UredeemModel> getUredeem(String id) async {
    try {
      final doc = await firestore.collection('COLLECTION_NAME').doc(id).get();
      
      if (!doc.exists) {
        throw Exception('redeem not found');
      }
      
      return UredeemModel.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Failed to get redeem: $e');
    }
  }
  
  @override
  Future<List<UredeemModel>> getAll() async {
    try {
      final snapshot = await firestore.collection('COLLECTION_NAME').get();
      return snapshot.docs
          .map((doc) => UredeemModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get all redeem: $e');
    }
  }
  
  @override
  Future<void> create(UredeemModel model) async {
    try {
      await firestore
          .collection('COLLECTION_NAME')
          .doc(model.id)
          .set(model.toJson());
    } catch (e) {
      throw Exception('Failed to create redeem: $e');
    }
  }
  
  @override
  Future<void> update(UredeemModel model) async {
    try {
      await firestore
          .collection('COLLECTION_NAME')
          .doc(model.id)
          .update(model.toJson());
    } catch (e) {
      throw Exception('Failed to update redeem: $e');
    }
  }
  
  @override
  Future<void> delete(String id) async {
    try {
      await firestore.collection('COLLECTION_NAME').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete redeem: $e');
    }
  }
}
