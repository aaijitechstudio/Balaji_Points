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
    print('═══════════════════════════════════════════════════════════');
    print('🚀 APPROVE BILL START');
    print('═══════════════════════════════════════════════════════════');
    print('📋 Input params:');
    print('   billId: "$billId"');
    print('   carpenterId: "$carpenterId"');
    print('   amount: $amount');
    print('═══════════════════════════════════════════════════════════');

    AppLogger.info('=== APPROVE BILL START ===');
    AppLogger.info(
      'Input params: billId=$billId, carpenterId=$carpenterId, amount=$amount',
    );

    try {
      // Validate inputs
      print('📝 Step 0: Validating inputs...');
      AppLogger.info('Step 0: Validating inputs...');
      if (billId.isEmpty) {
        print('❌ ERROR: Bill ID is empty!');
        AppLogger.error('approveBill: ❌ Bill ID is empty', '');
        return false;
      }
      print('   ✓ billId is valid: "$billId"');
      AppLogger.info('  ✓ billId is valid: $billId');

      if (amount <= 0) {
        print('❌ ERROR: Invalid amount: $amount');
        AppLogger.error('approveBill: ❌ Invalid amount', amount);
        return false;
      }
      print('   ✓ amount is valid: $amount');
      AppLogger.info('  ✓ amount is valid: $amount');

      final pointsEarned = (amount / 1000).floor();
      print('   ✓ pointsEarned calculated: $pointsEarned');
      AppLogger.info('  ✓ pointsEarned calculated: $pointsEarned');

      // Verify bill exists
      print('📄 Step 1: Fetching bill document...');
      AppLogger.info('Step 1: Fetching bill document...');
      final billRef = _firestore.collection('bills').doc(billId);
      print('   Bill ref path: bills/$billId');
      AppLogger.info('  Bill ref path: bills/$billId');

      final billDoc = await billRef.get();
      print('   Bill doc exists: ${billDoc.exists}');
      AppLogger.info('  Bill doc exists: ${billDoc.exists}');

      if (!billDoc.exists) {
        print('❌ ERROR: Bill not found! billId: "$billId"');
        AppLogger.error('approveBill: ❌ Bill not found', billId);
        return false;
      }

      // Check if bill is already approved or rejected
      print('📊 Step 2: Checking bill status...');
      AppLogger.info('Step 2: Checking bill status...');
      final billData = billDoc.data();
      print('   Bill data keys: ${billData?.keys.toList()}');
      AppLogger.info('  Bill data: $billData');

      if (billData != null) {
        final currentStatus = billData['status'] as String? ?? 'pending';
        print('   Current status: "$currentStatus"');
        AppLogger.info('  Current status: $currentStatus');

        if (currentStatus == 'approved') {
          print('❌ ERROR: Bill already approved!');
          AppLogger.error('approveBill: ❌ Bill already approved', billId);
          return false;
        }
        if (currentStatus == 'rejected') {
          print('❌ ERROR: Bill already rejected!');
          AppLogger.error('approveBill: ❌ Bill already rejected', billId);
          return false;
        }
        print('   ✓ Bill status is pending, can proceed');
        AppLogger.info('  ✓ Bill status is pending, can proceed');
      } else {
        print('   ⚠️ Bill data is null, assuming pending status');
        AppLogger.info('  ⚠️ Bill data is null, assuming pending status');
      }

      // If carpenterId passed is empty, try to read from bill doc
      AppLogger.info('Step 3: Resolving carpenterId...');
      String finalCarpenterId = carpenterId;
      AppLogger.info(
        '  Initial carpenterId: "$carpenterId" (isEmpty: ${carpenterId.isEmpty})',
      );

      if (finalCarpenterId.isEmpty && billData != null) {
        finalCarpenterId = billData['carpenterId'] ?? '';
        AppLogger.info('  Read carpenterId from bill: "$finalCarpenterId"');
      }

      // Validate carpenterId is not empty
      if (finalCarpenterId.isEmpty) {
        AppLogger.error(
          'approveBill: ❌ Carpenter ID is empty after resolution',
          billId,
        );
        AppLogger.error('  billData keys: ${billData?.keys.toList()}');
        return false;
      }
      AppLogger.info('  ✓ Final carpenterId: $finalCarpenterId');

      // Get admin info from session (phone+pin auth) or fallback to FirebaseAuth
      AppLogger.info('Step 4: Getting admin info...');
      final fbUser = FirebaseAuth.instance.currentUser;
      AppLogger.info('  FirebaseAuth currentUser: ${fbUser?.uid ?? "null"}');

      final sessionPhone = await _sessionService.getPhoneNumber();
      final sessionUserId = await _sessionService.getUserId();
      AppLogger.info('  Session phone: $sessionPhone');
      AppLogger.info('  Session userId: $sessionUserId');

      final adminPhone = sessionPhone ?? fbUser?.phoneNumber ?? 'admin';
      final adminUserId = sessionUserId ?? fbUser?.uid ?? 'admin';

      AppLogger.info('  ✓ Final adminPhone: $adminPhone');
      AppLogger.info('  ✓ Final adminUserId: $adminUserId');

      AppLogger.info('Step 5: Fetching user document...');
      final userRef = _firestore.collection('users').doc(finalCarpenterId);
      AppLogger.info('  User ref path: users/$finalCarpenterId');

      final userDoc = await userRef.get();
      AppLogger.info('  User doc exists: ${userDoc.exists}');
      if (userDoc.exists) {
        AppLogger.info('  User data: ${userDoc.data()}');
      }

      // Determine current points (0 if user not found)
      AppLogger.info('Step 6: Calculating points...');
      final dynamic currentPointsRaw;
      if (userDoc.exists) {
        currentPointsRaw = userDoc.data()?['totalPoints'] ?? 0;
        AppLogger.info(
          '  Found totalPoints in user doc: $currentPointsRaw (type: ${currentPointsRaw.runtimeType})',
        );
      } else {
        currentPointsRaw = 0;
        AppLogger.info('  User not found, using 0 as current points');
      }

      final int currentPoints = currentPointsRaw is num
          ? currentPointsRaw.toInt()
          : int.tryParse(currentPointsRaw.toString()) ?? 0;
      AppLogger.info('  ✓ Current points (int): $currentPoints');
      AppLogger.info('  ✓ Points to add: $pointsEarned');

      final newTotalPoints = currentPoints + pointsEarned;
      final newTier = _calculateTier(newTotalPoints);
      AppLogger.info('  ✓ New total points: $newTotalPoints');
      AppLogger.info('  ✓ New tier: $newTier');

      // Points history entry
      print('📝 Step 7: Creating points history entry...');
      AppLogger.info('Step 7: Creating points history entry...');
      // Use Timestamp.now() instead of FieldValue.serverTimestamp() because
      // FieldValue.serverTimestamp() cannot be used inside arrays when using batch.set()
      final newHistoryEntry = {
        'points': pointsEarned,
        'reason': 'Bill approval',
        'date': Timestamp.now(), // Changed from FieldValue.serverTimestamp()
        'billId': billId,
        'amount': amount,
      };
      print('   History entry: $newHistoryEntry');
      AppLogger.info('  History entry: $newHistoryEntry');

      AppLogger.info('Step 8: Fetching user_points document...');
      final userPointsRef = _firestore
          .collection('user_points')
          .doc(finalCarpenterId);
      AppLogger.info('  User points ref path: user_points/$finalCarpenterId');

      final userPointsDoc = await userPointsRef.get();
      AppLogger.info('  User points doc exists: ${userPointsDoc.exists}');
      if (userPointsDoc.exists) {
        AppLogger.info('  User points data: ${userPointsDoc.data()}');
      }

      AppLogger.info('Step 9: Creating batch operations...');
      final batch = _firestore.batch();
      AppLogger.info('  Batch created');

      // 1. Update bill (always update)
      AppLogger.info('  Batch Operation 1: Update bill doc');
      final billUpdateData = {
        'status': 'approved',
        'pointsEarned': pointsEarned,
        'approvedBy': adminUserId,
        'approvedByPhone': adminPhone,
        'approvedAt': FieldValue.serverTimestamp(),
        'approvedDate': _getTodayDateString(),
      };
      AppLogger.info('    Bill update data: $billUpdateData');
      batch.update(billRef, billUpdateData);
      AppLogger.info('    ✓ Bill update added to batch');

      // 2. Update or create user account with merged fields
      AppLogger.info('  Batch Operation 2: Update/create users doc');
      final userUpdateData = {
        'totalPoints': newTotalPoints,
        'tier': newTier,
        'lastUpdated': FieldValue.serverTimestamp(),
      };
      AppLogger.info('    User update data: $userUpdateData');
      batch.set(userRef, userUpdateData, SetOptions(merge: true));
      AppLogger.info('    ✓ User update added to batch (merge: true)');

      // 3. Update user_points
      AppLogger.info('  Batch Operation 3: Update/create user_points doc');
      if (userPointsDoc.exists) {
        // Get existing history to merge with new entry
        final existingData = userPointsDoc.data() ?? {};
        AppLogger.info('    Existing user_points data: $existingData');

        final existingHistory =
            existingData['pointsHistory'] as List<dynamic>? ?? [];
        AppLogger.info(
          '    Existing history length: ${existingHistory.length}',
        );

        // Check if userId exists in existing document (required by Firestore rules)
        final existingUserId = existingData['userId'] as String?;
        AppLogger.info('    Existing userId: "$existingUserId"');
        AppLogger.info('    Expected userId: "$finalCarpenterId"');
        AppLogger.info(
          '    userId matches: ${existingUserId == finalCarpenterId}',
        );

        if (existingUserId == null || existingUserId != finalCarpenterId) {
          // If userId is missing or doesn't match, use set to fix it
          // Merge existing history with new entry
          AppLogger.info('    Using batch.set() (userId missing or mismatch)');
          final userPointsSetData = {
            'userId': finalCarpenterId, // Ensure userId matches document ID
            'totalPoints': newTotalPoints,
            'tier': newTier,
            'lastUpdated': FieldValue.serverTimestamp(),
            'pointsHistory': [...existingHistory, newHistoryEntry],
          };
          AppLogger.info('    User points set data: $userPointsSetData');
          final historyList = userPointsSetData['pointsHistory'] as List;
          AppLogger.info('    New history length: ${historyList.length}');
          batch.set(userPointsRef, userPointsSetData, SetOptions(merge: false));
          AppLogger.info('    ✓ User points set added to batch');
        } else {
          // userId exists and matches, can use update with arrayUnion
          AppLogger.info(
            '    Using batch.update() with arrayUnion (userId matches)',
          );
          final userPointsUpdateData = {
            'totalPoints': newTotalPoints,
            'tier': newTier,
            'lastUpdated': FieldValue.serverTimestamp(),
            'pointsHistory': FieldValue.arrayUnion([newHistoryEntry]),
          };
          AppLogger.info('    User points update data: $userPointsUpdateData');
          batch.update(userPointsRef, userPointsUpdateData);
          AppLogger.info('    ✓ User points update added to batch');
        }
      } else {
        AppLogger.info('    User points doc does not exist, creating new');
        final userPointsCreateData = {
          'userId': finalCarpenterId,
          'totalPoints': newTotalPoints,
          'tier': newTier,
          'lastUpdated': FieldValue.serverTimestamp(),
          'pointsHistory': [newHistoryEntry],
        };
        AppLogger.info('    User points create data: $userPointsCreateData');
        batch.set(userPointsRef, userPointsCreateData);
        AppLogger.info('    ✓ User points create added to batch');
      }

      print('💾 Step 10: Committing batch...');
      print('   Total batch operations: 3');
      AppLogger.info('Step 10: Committing batch...');
      AppLogger.info('  Total batch operations: 3');
      try {
        print('   Attempting batch.commit()...');
        await batch.commit();
        print('✅✅✅ BATCH COMMITTED SUCCESSFULLY! ✅✅✅');
        print(
          '✅ Bill approved: $billId (Points: $pointsEarned) for user $finalCarpenterId',
        );
        AppLogger.info('✅ Batch committed successfully!');
        AppLogger.info(
          '✅ Bill approved: $billId (Points: $pointsEarned) for user $finalCarpenterId',
        );
        AppLogger.info('=== APPROVE BILL SUCCESS ===');
        print('═══════════════════════════════════════════════════════════');
        print('✅ APPROVE BILL SUCCESS');
        print('═══════════════════════════════════════════════════════════');
        return true;
      } on FirebaseException catch (fe) {
        print('🔥🔥🔥 FIREBASE EXCEPTION DURING BATCH.COMMIT() 🔥🔥🔥');
        print('   Code: ${fe.code}');
        print('   Message: ${fe.message}');
        print('   StackTrace: ${fe.stackTrace}');
        print('   Bill ID: $billId');
        print('   Carpenter ID: $finalCarpenterId');
        print('   Amount: $amount');
        print('   Points: $pointsEarned');
        AppLogger.error(
          '🔥 FirebaseException during batch.commit()',
          'Code: ${fe.code}, Message: ${fe.message}, StackTrace: ${fe.stackTrace}',
        );
        AppLogger.error('  Bill ID: $billId');
        AppLogger.error('  Carpenter ID: $finalCarpenterId');
        AppLogger.error('  Amount: $amount');
        AppLogger.error('  Points: $pointsEarned');
        AppLogger.error('=== APPROVE BILL FAILED (FirebaseException) ===');
        print('═══════════════════════════════════════════════════════════');
        print('❌ APPROVE BILL FAILED (FirebaseException)');
        print('═══════════════════════════════════════════════════════════');
        throw Exception('Firebase error: ${fe.code} - ${fe.message}');
      }
    } catch (e, st) {
      print('❌❌❌ EXCEPTION IN APPROVE BILL ❌❌❌');
      print('   Error: $e');
      print('   Type: ${e.runtimeType}');
      print('   StackTrace:');
      print('$st');
      print('   Bill ID: $billId');
      print('   Carpenter ID: $carpenterId');
      print('   Amount: $amount');
      AppLogger.error('❌ Exception in approveBill', 'Error: $e');
      AppLogger.error('  Type: ${e.runtimeType}');
      AppLogger.error('  StackTrace:\n$st');
      AppLogger.error('  Bill ID: $billId');
      AppLogger.error('  Carpenter ID: $carpenterId');
      AppLogger.error('  Amount: $amount');
      AppLogger.error('=== APPROVE BILL FAILED (Exception) ===');
      print('═══════════════════════════════════════════════════════════');
      print('❌ APPROVE BILL FAILED (Exception)');
      print('═══════════════════════════════════════════════════════════');
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
