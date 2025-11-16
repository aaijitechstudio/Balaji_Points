import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../core/logger.dart';

class BillService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload bill image to Firebase Storage
  Future<String?> uploadBillImage(File imageFile, String billId) async {
    try {
      final ref = _storage.ref().child('bill_images/$billId.jpg');

      AppLogger.info('Uploading bill image: bill_images/$billId.jpg');
      AppLogger.info('Storage bucket: ${_storage.bucket}');

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
      AppLogger.error('Firebase Storage error', 'Code: ${e.code}, Message: ${e.message}');
      if (e.code == 'storage/unauthorized') {
        throw Exception('Storage access denied. Please check Firebase Storage rules.');
      } else if (e.code == 'storage/canceled') {
        throw Exception('Upload was cancelled');
      } else if (e.code == 'storage/unknown') {
        throw Exception('Firebase Storage is not configured. Please enable Storage in Firebase Console.');
      }
      throw Exception('Failed to upload bill image: ${e.message}');
    } catch (e) {
      AppLogger.error('Error uploading bill image', e);
      throw Exception('Failed to upload bill image: $e');
    }
  }

  /// Submit a bill for approval (Carpenter action)
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
    // Use current date if billDate is not provided
    final effectiveBillDate = billDate ?? DateTime.now();
    try {
      // Create bill document first to get billId
      final billRef = _firestore.collection('bills').doc();
      final billId = billRef.id;

      // Upload image if provided
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await uploadBillImage(imageFile, billId);
      }

      // Calculate points: 1000 rs = 1 point (will be set on approval)
      final pointsEarned = 0; // Set to 0 initially, calculated on approval

      // Save bill to Firestore with new structure
      await billRef.set({
        'billId': billId,
        'carpenterId': carpenterId,
        'carpenterPhone': carpenterPhone,
        'amount': amount,
        'imageUrl': imageUrl ?? '',
        'status': 'pending',
        'pointsEarned': pointsEarned,
        'billDate': Timestamp.fromDate(effectiveBillDate),
        'storeName': storeName ?? '',
        'billNumber': billNumber ?? '',
        'notes': notes ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      AppLogger.info('Bill submitted: $billId, Amount: $amount');
      return true;
    } catch (e) {
      AppLogger.error('Error submitting bill', e);
      return false;
    }
  }

  /// Approve a bill (Admin action)
  Future<bool> approveBill(
    String billId,
    String carpenterId,
    double amount,
  ) async {
    try {
      AppLogger.info('Starting bill approval: $billId for carpenter: $carpenterId');

      // Calculate points: 1000 rs = 1 point
      final pointsEarned = (amount / 1000).floor();
      AppLogger.info('Points to be earned: $pointsEarned (Amount: $amount)');

      // Get current user data first
      final userRef = _firestore.collection('users').doc(carpenterId);
      final userDoc = await userRef.get();

      if (!userDoc.exists) {
        AppLogger.error('User not found', 'carpenterId: $carpenterId');
        throw Exception('Carpenter not found');
      }

      final userData = userDoc.data()!;
      final currentPoints = (userData['totalPoints'] ?? 0) as int;
      final newTotalPoints = currentPoints + pointsEarned;
      final newTier = _calculateTier(newTotalPoints);

      AppLogger.info('Current points: $currentPoints, New total: $newTotalPoints, New tier: $newTier');

      // Get user_points document reference
      final userPointsRef = _firestore.collection('user_points').doc(carpenterId);
      final userPointsDoc = await userPointsRef.get();

      final newHistoryEntry = {
        'points': pointsEarned,
        'reason': 'Bill approval',
        'date': FieldValue.serverTimestamp(),
        'billId': billId,
        'amount': amount,
      };

      // Use batch for atomic operations
      final batch = _firestore.batch();

      // 1. Update bill status
      final billRef = _firestore.collection('bills').doc(billId);
      batch.update(billRef, {
        'status': 'approved',
        'pointsEarned': pointsEarned,
        'approvedBy': _auth.currentUser?.uid ?? 'admin',
        'approvedAt': FieldValue.serverTimestamp(),
      });

      // 2. Update user points and tier (use set with merge to handle missing fields)
      batch.set(userRef, {
        'totalPoints': newTotalPoints,
        'tier': newTier,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 3. Update user_points collection
      if (userPointsDoc.exists) {
        batch.update(userPointsRef, {
          'totalPoints': newTotalPoints,
          'tier': newTier,
          'lastUpdated': FieldValue.serverTimestamp(),
          'pointsHistory': FieldValue.arrayUnion([newHistoryEntry]),
        });
      } else {
        batch.set(userPointsRef, {
          'userId': carpenterId,
          'totalPoints': newTotalPoints,
          'tier': newTier,
          'lastUpdated': FieldValue.serverTimestamp(),
          'pointsHistory': [newHistoryEntry],
        });
      }

      // Commit all changes
      await batch.commit();

      AppLogger.info('Bill approved successfully: $billId, Points added: $pointsEarned');
      return true;
    } on FirebaseException catch (e) {
      AppLogger.error('Firebase error approving bill', 'Code: ${e.code}, Message: ${e.message}');
      return false;
    } catch (e) {
      AppLogger.error('Error approving bill', e.toString());
      return false;
    }
  }

  /// Reject a bill (Admin action)
  Future<bool> rejectBill(String billId) async {
    try {
      await _firestore.collection('bills').doc(billId).update({
        'status': 'rejected',
        'rejectedAt': FieldValue.serverTimestamp(),
        'rejectedBy': _auth.currentUser?.uid ?? 'admin',
      });

      AppLogger.info('Bill rejected: $billId');
      return true;
    } catch (e) {
      AppLogger.error('Error rejecting bill', e);
      return false;
    }
  }

  /// Get user's bills
  Future<List<Map<String, dynamic>>> getUserBills(String carpenterId) async {
    try {
      final query = await _firestore
          .collection('bills')
          .where('carpenterId', isEqualTo: carpenterId)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      AppLogger.error('Error getting user bills', e);
      return [];
    }
  }

  /// Calculate tier based on points
  String _calculateTier(int points) {
    if (points >= 10000) {
      return 'Platinum';
    } else if (points >= 5000) {
      return 'Gold';
    } else if (points >= 2000) {
      return 'Silver';
    } else {
      return 'Bronze';
    }
  }
}
