import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/logger.dart';
import 'session_service.dart';

class BillService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final SessionService _sessionService = SessionService();

  /// Upload bill image to Firebase Storage
  Future<String?> uploadBillImage(File imageFile, String billId) async {
    try {
      final ref = _storage.ref().child('bill_images/$billId.jpg');

      AppLogger.info('Uploading bill image: bill_images/$billId.jpg');

      final uploadTask = await ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'billId': billId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      final imageUrl = await uploadTask.ref.getDownloadURL();
      AppLogger.info('Bill image uploaded: $imageUrl');
      return imageUrl;
    } on FirebaseException catch (e) {
      AppLogger.error('Firebase Storage error', '${e.code} - ${e.message}');
      throw Exception('Storage error: ${e.message}');
    } catch (e) {
      AppLogger.error('Error uploading bill image', e);
      throw Exception('Failed to upload bill image: $e');
    }
  }

  /// Submit bill
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
    try {
      AppLogger.info('BillService: === SUBMITTING BILL ===');
      AppLogger.info('  carpenterId: $carpenterId');
      AppLogger.info('  carpenterPhone: $carpenterPhone');
      AppLogger.info('  amount: $amount');
      AppLogger.info('  storeName: $storeName');
      AppLogger.info('  billNumber: $billNumber');

      final billRef = _firestore.collection('bills').doc();
      final billId = billRef.id;
      AppLogger.info('  Generated billId: $billId');

      String? imageUrl;
      if (imageFile != null) {
        AppLogger.info('  Uploading bill image...');
        imageUrl = await uploadBillImage(imageFile, billId);
        AppLogger.info('  Image uploaded: $imageUrl');
      }

      final billData = {
        'billId': billId,
        'carpenterId': carpenterId,
        'carpenterPhone': carpenterPhone,
        'amount': amount,
        'imageUrl': imageUrl ?? '',
        'status': 'pending',
        'pointsEarned': 0,
        'billDate': Timestamp.fromDate(billDate ?? DateTime.now()),
        'storeName': storeName ?? '',
        'billNumber': billNumber ?? '',
        'notes': notes ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      };

      AppLogger.info('  Saving to Firestore: bills/$billId');
      await billRef.set(billData);

      // Verify the save by reading back
      final verifyDoc = await billRef.get();
      if (verifyDoc.exists) {
        AppLogger.info('BillService: ✅ Bill saved and verified successfully!');
        AppLogger.info(
          '  Verified data: carpenterId=${verifyDoc.data()?['carpenterId']}, status=${verifyDoc.data()?['status']}',
        );
      } else {
        AppLogger.error(
          'BillService: ❌ Bill document not found after save!',
          null,
        );
      }

      return true;
    } catch (e) {
      AppLogger.error('BillService: ❌ Error submitting bill', e);
      return false;
    }
  }

  /// Approve bill (Admin)
  Future<bool> approveBill(
    String billId,
    String carpenterId,
    double amount,
  ) async {
    try {
      final pointsEarned = (amount / 1000).floor();

      // Verify bill exists
      final billRef = _firestore.collection('bills').doc(billId);
      final billDoc = await billRef.get();
      if (!billDoc.exists) {
        AppLogger.error('approveBill: Bill not found', billId);
        return false;
      }

      // If carpenterId passed is empty, try to read from bill doc
      String finalCarpenterId = carpenterId;
      final billData = billDoc.data();
      if (finalCarpenterId.isEmpty && billData != null) {
        finalCarpenterId = billData['carpenterId'] ?? '';
      }

      // Get admin info from session (phone+pin auth) or fallback to FirebaseAuth
      final fbUser = FirebaseAuth.instance.currentUser;
      final adminPhone =
          (await _sessionService.getPhoneNumber()) ??
          fbUser?.phoneNumber ??
          'admin';
      final adminUserId =
          (await _sessionService.getUserId()) ?? fbUser?.uid ?? 'admin';

      final userRef = _firestore.collection('users').doc(finalCarpenterId);
      final userDoc = await userRef.get();

      // Determine current points (0 if user not found)
      final dynamic currentPointsRaw;
      if (userDoc.exists) {
        currentPointsRaw = userDoc.data()?['totalPoints'] ?? 0;
      } else {
        currentPointsRaw = 0;
      }
      final int currentPoints = currentPointsRaw is num
          ? currentPointsRaw.toInt()
          : int.tryParse(currentPointsRaw.toString()) ?? 0;

      final newTotalPoints = currentPoints + pointsEarned;
      final newTier = _calculateTier(newTotalPoints);

      // Points history entry
      final newHistoryEntry = {
        'points': pointsEarned,
        'reason': 'Bill approval',
        'date': FieldValue.serverTimestamp(),
        'billId': billId,
        'amount': amount,
      };

      final userPointsRef = _firestore
          .collection('user_points')
          .doc(finalCarpenterId);
      final userPointsDoc = await userPointsRef.get();

      final batch = _firestore.batch();

      AppLogger.info('approveBill: Starting batch write...');
      AppLogger.info(
        '  billId=$billId, carpenterId=$finalCarpenterId, pointsEarned=$pointsEarned',
      );

      // 1. Update bill (always update)
      AppLogger.info('  Step 1: Update bill doc');
      batch.update(billRef, {
        'status': 'approved',
        'pointsEarned': pointsEarned,
        'approvedBy': adminUserId,
        'approvedByPhone': adminPhone,
        'approvedAt': FieldValue.serverTimestamp(),
        'approvedDate': _getTodayDateString(),
      });

      // 2. Update or create user account with merged fields
      AppLogger.info('  Step 2: Update/create users doc');
      batch.set(userRef, {
        'totalPoints': newTotalPoints,
        'tier': newTier,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 3. Update user_points
      AppLogger.info(
        '  Step 3: Update/create user_points doc (exists=${userPointsDoc.exists})',
      );
      if (userPointsDoc.exists) {
        batch.update(userPointsRef, {
          'totalPoints': newTotalPoints,
          'tier': newTier,
          'lastUpdated': FieldValue.serverTimestamp(),
          'pointsHistory': FieldValue.arrayUnion([newHistoryEntry]),
        });
      } else {
        batch.set(userPointsRef, {
          'userId': finalCarpenterId,
          'totalPoints': newTotalPoints,
          'tier': newTier,
          'lastUpdated': FieldValue.serverTimestamp(),
          'pointsHistory': [newHistoryEntry],
        });
      }

      AppLogger.info('approveBill: Committing batch...');
      try {
        await batch.commit();
        AppLogger.info('approveBill: ✅ Batch committed successfully!');
      } on FirebaseException catch (fe) {
        AppLogger.error(
          'approveBill: 🔥 FirebaseException during batch.commit()',
          'Code: ${fe.code}, Message: ${fe.message}',
        );
        throw Exception('Firebase error: ${fe.code} - ${fe.message}');
      }

      AppLogger.info(
        'Bill approved: $billId (Points: $pointsEarned) for user $finalCarpenterId',
      );
      return true;
    } catch (e, st) {
      AppLogger.error('Error approving bill', '$e\nStackTrace:\n$st');
      return false;
    }
  }

  /// Reject bill
  Future<bool> rejectBill(String billId) async {
    try {
      // Get admin info from session (phone+pin auth)
      final adminPhone = await _sessionService.getPhoneNumber() ?? 'admin';
      final adminUserId = await _sessionService.getUserId() ?? 'admin';

      await _firestore.collection('bills').doc(billId).update({
        'status': 'rejected',
        'rejectedAt': FieldValue.serverTimestamp(),
        'rejectedBy': adminUserId,
        'rejectedByPhone': adminPhone,
      });

      AppLogger.info('Bill rejected: $billId');
      return true;
    } catch (e) {
      AppLogger.error('Error rejecting bill', e);
      return false;
    }
  }

  /// Get today's date string in YYYY-MM-DD format
  String _getTodayDateString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// User bills
  Future<List<Map<String, dynamic>>> getUserBills(String carpenterId) async {
    try {
      final query = await _firestore
          .collection('bills')
          .where('carpenterId', isEqualTo: carpenterId)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      AppLogger.error('Error getting bills', e);
      return [];
    }
  }

  /// Determine tier
  String _calculateTier(int points) {
    if (points >= 10000) return 'Platinum';
    if (points >= 5000) return 'Gold';
    if (points >= 2000) return 'Silver';
    return 'Bronze';
  }
}
