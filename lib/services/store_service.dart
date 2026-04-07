import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/app_constants.dart';
import '../core/logger.dart';
import 'session_service.dart';

class StoreService {
  StoreService({FirebaseFirestore? firestore, SessionService? sessionService})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _sessionService = sessionService ?? SessionService();

  final FirebaseFirestore _firestore;
  final SessionService _sessionService;

  static const String defaultStoreId = 'sri-balaji-plywood-hardware-e-road';
  static const String defaultStoreName =
      'Sri Balaji Plywood & Hardware - E Road';
  static const String defaultStoreCode = 'SRI_BALAJI_EROAD';

  CollectionReference<Map<String, dynamic>> get _storesRef =>
      _firestore.collection('stores');

  Stream<QuerySnapshot<Map<String, dynamic>>> watchStores() {
    return _storesRef.orderBy('updatedAt', descending: true).snapshots();
  }

  Future<void> ensureDefaultStoreExists() async {
    try {
      final snapshot = await _storesRef.limit(1).get();
      if (snapshot.docs.isNotEmpty) return;

      await _storesRef
          .doc(defaultStoreId)
          .set(await _buildDefaultStorePayload());
      AppLogger.info('Default store created: $defaultStoreId');
    } catch (e, st) {
      AppLogger.error('Failed to ensure default store exists', e, st);
      rethrow;
    }
  }

  Future<void> createStore({
    required String name,
    required String code,
    required String address,
    required String city,
    required String phone,
    required String email,
    required String gstNo,
    bool isActive = true,
  }) async {
    final docRef = _storesRef.doc(_buildStoreId(name, code));
    final actorId = await _sessionService.getUserId() ?? 'system';

    await docRef.set({
      'storeId': docRef.id,
      'name': name.trim(),
      'code': code.trim().toUpperCase(),
      'address': address.trim(),
      'city': city.trim(),
      'phone': phone.trim(),
      'email': email.trim(),
      'gstNo': gstNo.trim(),
      'isActive': isActive,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'createdBy': actorId,
      'updatedBy': actorId,
    });
  }

  Future<void> updateStore({
    required String storeId,
    required String name,
    required String code,
    required String address,
    required String city,
    required String phone,
    required String email,
    required String gstNo,
    required bool isActive,
  }) async {
    final actorId = await _sessionService.getUserId() ?? 'system';

    await _storesRef.doc(storeId).update({
      'name': name.trim(),
      'code': code.trim().toUpperCase(),
      'address': address.trim(),
      'city': city.trim(),
      'phone': phone.trim(),
      'email': email.trim(),
      'gstNo': gstNo.trim(),
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
      'updatedBy': actorId,
    });
  }

  String _buildStoreId(String name, String code) {
    final preferred = code.trim().isNotEmpty ? code : name;
    final normalized = preferred
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
    return normalized.isEmpty
        ? 'store-${DateTime.now().millisecondsSinceEpoch}'
        : normalized;
  }

  Future<Map<String, dynamic>> _buildDefaultStorePayload() async {
    final actorId = await _sessionService.getUserId() ?? 'system';
    return {
      'storeId': defaultStoreId,
      'name': defaultStoreName,
      'code': defaultStoreCode,
      'address': AppConstants.shopAddressShort,
      'city': 'Erode',
      'phone': '9600609121',
      'email': 'sribalajihardwares1008@gmail.com',
      'gstNo': '33DFXPS5949H2ZH',
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'createdBy': actorId,
      'updatedBy': actorId,
    };
  }
}
