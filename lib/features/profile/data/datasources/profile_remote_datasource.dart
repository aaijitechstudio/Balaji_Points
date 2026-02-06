import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:balaji_points/features/profile/data/models/profile_model.dart';

/// Remote data source for profile
/// 
/// Handles all network/database operations for this feature.
/// Throws exceptions on errors (handled by repository).
abstract class UprofileRemoteDataSource {
  Future<UprofileModel> getUprofile(String id);
  Future<List<UprofileModel>> getAll();
  Future<void> create(UprofileModel model);
  Future<void> update(UprofileModel model);
  Future<void> delete(String id);
}

class UprofileRemoteDataSourceImpl implements UprofileRemoteDataSource {
  final FirebaseFirestore firestore;
  
  UprofileRemoteDataSourceImpl({required this.firestore});
  
  @override
  Future<UprofileModel> getUprofile(String id) async {
    try {
      final doc = await firestore.collection('COLLECTION_NAME').doc(id).get();
      
      if (!doc.exists) {
        throw Exception('profile not found');
      }
      
      return UprofileModel.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Failed to get profile: $e');
    }
  }
  
  @override
  Future<List<UprofileModel>> getAll() async {
    try {
      final snapshot = await firestore.collection('COLLECTION_NAME').get();
      return snapshot.docs
          .map((doc) => UprofileModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get all profile: $e');
    }
  }
  
  @override
  Future<void> create(UprofileModel model) async {
    try {
      await firestore
          .collection('COLLECTION_NAME')
          .doc(model.id)
          .set(model.toJson());
    } catch (e) {
      throw Exception('Failed to create profile: $e');
    }
  }
  
  @override
  Future<void> update(UprofileModel model) async {
    try {
      await firestore
          .collection('COLLECTION_NAME')
          .doc(model.id)
          .update(model.toJson());
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }
  
  @override
  Future<void> delete(String id) async {
    try {
      await firestore.collection('COLLECTION_NAME').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete profile: $e');
    }
  }
}
