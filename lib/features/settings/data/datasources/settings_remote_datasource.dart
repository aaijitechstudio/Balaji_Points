import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:balaji_points/features/settings/data/models/settings_model.dart';

/// Remote data source for settings
/// 
/// Handles all network/database operations for this feature.
/// Throws exceptions on errors (handled by repository).
abstract class UsettingsRemoteDataSource {
  Future<UsettingsModel> getUsettings(String id);
  Future<List<UsettingsModel>> getAll();
  Future<void> create(UsettingsModel model);
  Future<void> update(UsettingsModel model);
  Future<void> delete(String id);
}

class UsettingsRemoteDataSourceImpl implements UsettingsRemoteDataSource {
  final FirebaseFirestore firestore;
  
  UsettingsRemoteDataSourceImpl({required this.firestore});
  
  @override
  Future<UsettingsModel> getUsettings(String id) async {
    try {
      final doc = await firestore.collection('COLLECTION_NAME').doc(id).get();
      
      if (!doc.exists) {
        throw Exception('settings not found');
      }
      
      return UsettingsModel.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Failed to get settings: $e');
    }
  }
  
  @override
  Future<List<UsettingsModel>> getAll() async {
    try {
      final snapshot = await firestore.collection('COLLECTION_NAME').get();
      return snapshot.docs
          .map((doc) => UsettingsModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get all settings: $e');
    }
  }
  
  @override
  Future<void> create(UsettingsModel model) async {
    try {
      await firestore
          .collection('COLLECTION_NAME')
          .doc(model.id)
          .set(model.toJson());
    } catch (e) {
      throw Exception('Failed to create settings: $e');
    }
  }
  
  @override
  Future<void> update(UsettingsModel model) async {
    try {
      await firestore
          .collection('COLLECTION_NAME')
          .doc(model.id)
          .update(model.toJson());
    } catch (e) {
      throw Exception('Failed to update settings: $e');
    }
  }
  
  @override
  Future<void> delete(String id) async {
    try {
      await firestore.collection('COLLECTION_NAME').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete settings: $e');
    }
  }
}
