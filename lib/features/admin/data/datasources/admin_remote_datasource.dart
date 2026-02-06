import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:balaji_points/features/admin/data/models/admin_model.dart';

/// Remote data source for admin
/// 
/// Handles all network/database operations for this feature.
/// Throws exceptions on errors (handled by repository).
abstract class UadminRemoteDataSource {
  Future<UadminModel> getUadmin(String id);
  Future<List<UadminModel>> getAll();
  Future<void> create(UadminModel model);
  Future<void> update(UadminModel model);
  Future<void> delete(String id);
}

class UadminRemoteDataSourceImpl implements UadminRemoteDataSource {
  final FirebaseFirestore firestore;
  
  UadminRemoteDataSourceImpl({required this.firestore});
  
  @override
  Future<UadminModel> getUadmin(String id) async {
    try {
      final doc = await firestore.collection('COLLECTION_NAME').doc(id).get();
      
      if (!doc.exists) {
        throw Exception('admin not found');
      }
      
      return UadminModel.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Failed to get admin: $e');
    }
  }
  
  @override
  Future<List<UadminModel>> getAll() async {
    try {
      final snapshot = await firestore.collection('COLLECTION_NAME').get();
      return snapshot.docs
          .map((doc) => UadminModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get all admin: $e');
    }
  }
  
  @override
  Future<void> create(UadminModel model) async {
    try {
      await firestore
          .collection('COLLECTION_NAME')
          .doc(model.id)
          .set(model.toJson());
    } catch (e) {
      throw Exception('Failed to create admin: $e');
    }
  }
  
  @override
  Future<void> update(UadminModel model) async {
    try {
      await firestore
          .collection('COLLECTION_NAME')
          .doc(model.id)
          .update(model.toJson());
    } catch (e) {
      throw Exception('Failed to update admin: $e');
    }
  }
  
  @override
  Future<void> delete(String id) async {
    try {
      await firestore.collection('COLLECTION_NAME').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete admin: $e');
    }
  }
}
