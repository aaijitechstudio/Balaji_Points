import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:balaji_points/services/bill_service.dart';
import 'package:balaji_points/services/user_service.dart';
import 'package:balaji_points/features/bills/data/models/bill_model.dart';
import 'package:balaji_points/features/bills/data/models/carpenter_model.dart';

abstract class BillRemoteDataSource {
  Future<bool> submitBill({
    required String carpenterId,
    required String carpenterPhone,
    required double amount,
    File? imageFile,
    DateTime? billDate,
    String? storeName,
    String? billNumber,
    String? notes,
  });

  Future<bool> submitBillForCarpenter({
    required String carpenterId,
    required String carpenterPhone,
    required double amount,
    required String adminId,
    required String adminPhone,
    String? adminName,
    File? imageFile,
    DateTime? billDate,
    String? storeName,
    String? billNumber,
    String? notes,
  });

  Future<bool> approveBill({
    required String billId,
    required String carpenterId,
    required double amount,
  });

  Future<bool> rejectBill({
    required String billId,
    required String reason,
  });

  Future<bool> withdrawBill(String billId);

  Stream<List<BillModel>> getBillsStream(String carpenterId);

  Future<BillModel> getBillById(String billId);

  Future<List<CarpenterModel>> getCarpenters();

  Future<CarpenterModel> getCarpenterById(String carpenterId);

  Future<Map<String, dynamic>> getCurrentUserData();
}

class BillRemoteDataSourceImpl implements BillRemoteDataSource {
  final BillService _billService;
  final UserService _userService;
  final FirebaseFirestore _firestore;

  BillRemoteDataSourceImpl({
    required BillService billService,
    required UserService userService,
    required FirebaseFirestore firestore,
  })  : _billService = billService,
        _userService = userService,
        _firestore = firestore;

  @override
  Future<bool> submitBill({
    required String carpenterId,
    required String carpenterPhone,
    required double amount,
    File? imageFile,
    DateTime? billDate,
    String? storeName,
    String? billNumber,
    String? notes,
  }) async {
    return await _billService.submitBill(
      carpenterId: carpenterId,
      carpenterPhone: carpenterPhone,
      amount: amount,
      imageFile: imageFile,
      billDate: billDate,
      storeName: storeName,
      billNumber: billNumber,
      notes: notes,
    );
  }

  @override
  Future<bool> submitBillForCarpenter({
    required String carpenterId,
    required String carpenterPhone,
    required double amount,
    required String adminId,
    required String adminPhone,
    String? adminName,
    File? imageFile,
    DateTime? billDate,
    String? storeName,
    String? billNumber,
    String? notes,
  }) async {
    return await _billService.submitBillForCarpenter(
      carpenterId: carpenterId,
      carpenterPhone: carpenterPhone,
      amount: amount,
      adminId: adminId,
      adminPhone: adminPhone,
      adminName: adminName,
      imageFile: imageFile,
      billDate: billDate,
      storeName: storeName,
      billNumber: billNumber,
      notes: notes,
    );
  }

  @override
  Future<bool> approveBill({
    required String billId,
    required String carpenterId,
    required double amount,
  }) async {
    return await _billService.approveBill(billId, carpenterId, amount);
  }

  @override
  Future<bool> rejectBill({
    required String billId,
    required String reason,
  }) async {
    // Note: BillService.rejectBill doesn't use reason parameter currently
    return await _billService.rejectBill(billId);
  }

  @override
  Future<bool> withdrawBill(String billId) async {
    return await _billService.withdrawBill(billId);
  }

  @override
  Stream<List<BillModel>> getBillsStream(String carpenterId) {
    return _firestore
        .collection('bills')
        .where('carpenterId', isEqualTo: carpenterId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => BillModel.fromFirestore(doc)).toList();
    });
  }

  @override
  Future<BillModel> getBillById(String billId) async {
    final doc = await _firestore.collection('bills').doc(billId).get();
    if (!doc.exists) {
      throw Exception('Bill not found');
    }
    return BillModel.fromFirestore(doc);
  }

  @override
  Future<List<CarpenterModel>> getCarpenters() async {
    final snapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'carpenter')
        .orderBy('firstName')
        .get();

    return snapshot.docs
        .map((doc) => CarpenterModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<CarpenterModel> getCarpenterById(String carpenterId) async {
    final doc = await _firestore.collection('users').doc(carpenterId).get();
    if (!doc.exists) {
      throw Exception('Carpenter not found');
    }
    return CarpenterModel.fromFirestore(doc);
  }

  @override
  Future<Map<String, dynamic>> getCurrentUserData() async {
    final userData = await _userService.getCurrentUserData();
    if (userData == null) {
      throw Exception('User not found');
    }
    return userData;
  }
}
