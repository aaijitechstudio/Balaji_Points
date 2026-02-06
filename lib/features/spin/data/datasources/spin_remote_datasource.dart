import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:balaji_points/features/spin/data/models/spin_model.dart';

/// Remote data source for spin
/// 
/// Handles all network/database operations for this feature.
/// Throws exceptions on errors (handled by repository).
abstract class UspinRemoteDataSource {
  Future<UspinModel> getUspin(String id);
  Future<List<UspinModel>> getAll();
  Future<void> create(UspinModel model);
  Future<void> update(UspinModel model);
  Future<void> delete(String id);
}

class UspinRemoteDataSourceImpl implements UspinRemoteDataSource {
  final FirebaseFirestore firestore;
  
  UspinRemoteDataSourceImpl({required this.firestore});
  
  @override
  Future<UspinModel> getUspin(String id) async {
    try {
      final doc = await firestore.collection('COLLECTION_NAME').doc(id).get();
      
      if (!doc.exists) {
        throw Exception('spin not found');
      }
      
      return UspinModel.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Failed to get spin: $e');
    }
  }
  
  @override
  Future<List<UspinModel>> getAll() async {
    try {
      final snapshot = await firestore.collection('COLLECTION_NAME').get();
      return snapshot.docs
          .map((doc) => UspinModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get all spin: $e');
    }
  }
  
  @override
  Future<void> create(UspinModel model) async {
    try {
      await firestore
          .collection('COLLECTION_NAME')
          .doc(model.id)
          .set(model.toJson());
    } catch (e) {
      throw Exception('Failed to create spin: $e');
    }
  }
  
  @override
  Future<void> update(UspinModel model) async {
    try {
      await firestore
          .collection('COLLECTION_NAME')
          .doc(model.id)
          .update(model.toJson());
    } catch (e) {
      throw Exception('Failed to update spin: $e');
    }
  }
  
  @override
  Future<void> delete(String id) async {
    try {
      await firestore.collection('COLLECTION_NAME').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete spin: $e');
    }
  }
}
