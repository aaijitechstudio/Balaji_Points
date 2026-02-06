import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:balaji_points/features/notifications/data/models/notifications_model.dart';

/// Remote data source for notifications
/// 
/// Handles all network/database operations for this feature.
/// Throws exceptions on errors (handled by repository).
abstract class UnotificationsRemoteDataSource {
  Future<UnotificationsModel> getUnotifications(String id);
  Future<List<UnotificationsModel>> getAll();
  Future<void> create(UnotificationsModel model);
  Future<void> update(UnotificationsModel model);
  Future<void> delete(String id);
}

class UnotificationsRemoteDataSourceImpl implements UnotificationsRemoteDataSource {
  final FirebaseFirestore firestore;
  
  UnotificationsRemoteDataSourceImpl({required this.firestore});
  
  @override
  Future<UnotificationsModel> getUnotifications(String id) async {
    try {
      final doc = await firestore.collection('COLLECTION_NAME').doc(id).get();
      
      if (!doc.exists) {
        throw Exception('notifications not found');
      }
      
      return UnotificationsModel.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Failed to get notifications: $e');
    }
  }
  
  @override
  Future<List<UnotificationsModel>> getAll() async {
    try {
      final snapshot = await firestore.collection('COLLECTION_NAME').get();
      return snapshot.docs
          .map((doc) => UnotificationsModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get all notifications: $e');
    }
  }
  
  @override
  Future<void> create(UnotificationsModel model) async {
    try {
      await firestore
          .collection('COLLECTION_NAME')
          .doc(model.id)
          .set(model.toJson());
    } catch (e) {
      throw Exception('Failed to create notifications: $e');
    }
  }
  
  @override
  Future<void> update(UnotificationsModel model) async {
    try {
      await firestore
          .collection('COLLECTION_NAME')
          .doc(model.id)
          .update(model.toJson());
    } catch (e) {
      throw Exception('Failed to update notifications: $e');
    }
  }
  
  @override
  Future<void> delete(String id) async {
    try {
      await firestore.collection('COLLECTION_NAME').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete notifications: $e');
    }
  }
}
