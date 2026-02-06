import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:balaji_points/features/dashboard/data/models/dashboard_model.dart';

/// Remote data source for dashboard
/// 
/// Handles all network/database operations for this feature.
/// Throws exceptions on errors (handled by repository).
abstract class UdashboardRemoteDataSource {
  Future<UdashboardModel> getUdashboard(String id);
  Future<List<UdashboardModel>> getAll();
  Future<void> create(UdashboardModel model);
  Future<void> update(UdashboardModel model);
  Future<void> delete(String id);
}

class UdashboardRemoteDataSourceImpl implements UdashboardRemoteDataSource {
  final FirebaseFirestore firestore;
  
  UdashboardRemoteDataSourceImpl({required this.firestore});
  
  @override
  Future<UdashboardModel> getUdashboard(String id) async {
    try {
      final doc = await firestore.collection('COLLECTION_NAME').doc(id).get();
      
      if (!doc.exists) {
        throw Exception('dashboard not found');
      }
      
      return UdashboardModel.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Failed to get dashboard: $e');
    }
  }
  
  @override
  Future<List<UdashboardModel>> getAll() async {
    try {
      final snapshot = await firestore.collection('COLLECTION_NAME').get();
      return snapshot.docs
          .map((doc) => UdashboardModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get all dashboard: $e');
    }
  }
  
  @override
  Future<void> create(UdashboardModel model) async {
    try {
      await firestore
          .collection('COLLECTION_NAME')
          .doc(model.id)
          .set(model.toJson());
    } catch (e) {
      throw Exception('Failed to create dashboard: $e');
    }
  }
  
  @override
  Future<void> update(UdashboardModel model) async {
    try {
      await firestore
          .collection('COLLECTION_NAME')
          .doc(model.id)
          .update(model.toJson());
    } catch (e) {
      throw Exception('Failed to update dashboard: $e');
    }
  }
  
  @override
  Future<void> delete(String id) async {
    try {
      await firestore.collection('COLLECTION_NAME').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete dashboard: $e');
    }
  }
}
