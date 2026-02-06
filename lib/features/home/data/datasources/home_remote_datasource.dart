import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:balaji_points/features/home/data/models/home_model.dart';

/// Remote data source for home
/// 
/// Handles all network/database operations for this feature.
/// Throws exceptions on errors (handled by repository).
abstract class UhomeRemoteDataSource {
  Future<UhomeModel> getUhome(String id);
  Future<List<UhomeModel>> getAll();
  Future<void> create(UhomeModel model);
  Future<void> update(UhomeModel model);
  Future<void> delete(String id);
}

class UhomeRemoteDataSourceImpl implements UhomeRemoteDataSource {
  final FirebaseFirestore firestore;
  
  UhomeRemoteDataSourceImpl({required this.firestore});
  
  @override
  Future<UhomeModel> getUhome(String id) async {
    try {
      final doc = await firestore.collection('COLLECTION_NAME').doc(id).get();
      
      if (!doc.exists) {
        throw Exception('home not found');
      }
      
      return UhomeModel.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Failed to get home: $e');
    }
  }
  
  @override
  Future<List<UhomeModel>> getAll() async {
    try {
      final snapshot = await firestore.collection('COLLECTION_NAME').get();
      return snapshot.docs
          .map((doc) => UhomeModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get all home: $e');
    }
  }
  
  @override
  Future<void> create(UhomeModel model) async {
    try {
      await firestore
          .collection('COLLECTION_NAME')
          .doc(model.id)
          .set(model.toJson());
    } catch (e) {
      throw Exception('Failed to create home: $e');
    }
  }
  
  @override
  Future<void> update(UhomeModel model) async {
    try {
      await firestore
          .collection('COLLECTION_NAME')
          .doc(model.id)
          .update(model.toJson());
    } catch (e) {
      throw Exception('Failed to update home: $e');
    }
  }
  
  @override
  Future<void> delete(String id) async {
    try {
      await firestore.collection('COLLECTION_NAME').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete home: $e');
    }
  }
}
