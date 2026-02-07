import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/utils/logger.dart';
import 'session_service.dart';
import 'notification_service.dart';

class BillService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final SessionService _sessionService = SessionService();

  /// Upload bill image to Firebase Storage
  Future<String?> uploadBillImage(File imageFile, String billId) async {
    try {
      final ref = _storage.ref().child('bill_images/$billId.jpg');

      Logger.d('Uploading bill image: bill_images/$billId.jpg');

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
      Logger.d('Bill image uploaded: $imageUrl');
      return imageUrl;
    } on FirebaseException catch (e) {
      Logger.e('Firebase Storage error: ${e.code} - ${e.message}');
      throw Exception('Storage error: ${e.message}');
    } catch (e) {
      Logger.e('Error uploading bill image', error: e);
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
      Logger.d('BillService: === SUBMITTING BILL ===');
      Logger.d('  carpenterId: $carpenterId');
      Logger.d('  carpenterPhone: $carpenterPhone');
      Logger.d('  amount: $amount');
      Logger.d('  storeName: $storeName');
      Logger.d('  billNumber: $billNumber');

      final billRef = _firestore.collection('bills').doc();
      final billId = billRef.id;
      Logger.d('  Generated billId: $billId');

      String? imageUrl;
      if (imageFile != null) {
        Logger.d('  Uploading bill image...');
        imageUrl = await uploadBillImage(imageFile, billId);
        Logger.d('  Image uploaded: $imageUrl');
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

      Logger.d('  Saving to Firestore: bills/$billId');
      await billRef.set(billData);

      // Verify the save by reading back
      final verifyDoc = await billRef.get();
      if (verifyDoc.exists) {
        Logger.d('BillService: ✅ Bill saved and verified successfully!');
        Logger.d(
          '  Verified data: carpenterId=${verifyDoc.data()?['carpenterId']}, status=${verifyDoc.data()?['status']}',
        );

        // Send notification to all admins about new pending bill
        try {
          // Get carpenter name from users collection
          final userDoc =
              await _firestore.collection('users').doc(carpenterId).get();
          final userData = userDoc.data();
          final firstName = userData?['firstName'] as String? ?? '';
          final lastName = userData?['lastName'] as String? ?? '';
          final carpenterName = '$firstName $lastName'.trim();

          final notificationService = NotificationService();
          await notificationService.notifyAdminsNewPendingBill(
            carpenterName:
                carpenterName.isNotEmpty ? carpenterName : carpenterPhone,
            carpenterPhone: carpenterPhone,
            amount: amount,
            billId: billId,
          );
          Logger.d('✅ Admin notification sent for new pending bill');
        } catch (e) {
          // Don't fail the bill submission if notification fails
          Logger.w('Failed to send admin notification: $e');
        }
      } else {
        Logger.e('BillService: Bill document not found after save!');
      }

      return true;
    } catch (e) {
      Logger.e('BillService: ❌ Error submitting bill', error: e);
      return false;
    }
  }

  /// Submit bill for carpenter by admin
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
    try {
      Logger.d(
        'BillService: === ADMIN SUBMITTING BILL FOR CARPENTER ===',
      );
      Logger.d('  carpenterId: $carpenterId');
      Logger.d('  carpenterPhone: $carpenterPhone');
      Logger.d('  adminId: $adminId');
      Logger.d('  adminPhone: $adminPhone');
      Logger.d('  amount: $amount');
      Logger.d('  storeName: $storeName');
      Logger.d('  billNumber: $billNumber');

      final billRef = _firestore.collection('bills').doc();
      final billId = billRef.id;
      Logger.d('  Generated billId: $billId');

      String? imageUrl;
      if (imageFile != null) {
        Logger.d('  Uploading bill image...');
        imageUrl = await uploadBillImage(imageFile, billId);
        Logger.d('  Image uploaded: $imageUrl');
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
        'submittedBy': 'admin',
        'adminId': adminId,
        'adminPhone': adminPhone,
        if (adminName != null) 'adminName': adminName,
        'createdAt': FieldValue.serverTimestamp(),
      };

      Logger.d('  Saving to Firestore: bills/$billId');
      await billRef.set(billData);

      // Verify the save by reading back
      final verifyDoc = await billRef.get();
      if (verifyDoc.exists) {
        Logger.d(
          'BillService: ✅ Admin bill saved and verified successfully!',
        );
        Logger.d(
          '  Verified data: carpenterId=${verifyDoc.data()?['carpenterId']}, status=${verifyDoc.data()?['status']}, submittedBy=${verifyDoc.data()?['submittedBy']}',
        );
      } else {
        Logger.e('BillService: Bill document not found after save!');
      }

      return true;
    } catch (e) {
      Logger.e('BillService: ❌ Error submitting bill for carpenter', error: e);
      return false;
    }
  }

  /// Approve bill (Admin)
  Future<bool> approveBill(
    String billId,
    String carpenterId,
    double amount,
  ) async {

    Logger.d('=== APPROVE BILL START ===');
    Logger.d(
      'Input params: billId=$billId, carpenterId=$carpenterId, amount=$amount',
    );

    try {
      // Validate inputs
      Logger.d('Step 0: Validating inputs...');
      if (billId.isEmpty) {
        Logger.e('approveBill: Bill ID is empty');
        return false;
      }
      Logger.d('  ✓ billId is valid: $billId');

      if (amount <= 0) {
        Logger.e('approveBill: Invalid amount: $amount');
        return false;
      }
      Logger.d('  ✓ amount is valid: $amount');

      final pointsEarned = (amount / 1000).floor();
      Logger.d('  ✓ pointsEarned calculated: $pointsEarned');

      // Verify bill exists
      Logger.d('Step 1: Fetching bill document...');
      final billRef = _firestore.collection('bills').doc(billId);
      Logger.d('  Bill ref path: bills/$billId');

      final billDoc = await billRef.get();
      Logger.d('  Bill doc exists: ${billDoc.exists}');

      if (!billDoc.exists) {
        Logger.e('approveBill: Bill not found - billId: $billId');
        return false;
      }

      // Check if bill is already approved or rejected
      Logger.d('Step 2: Checking bill status...');
      final billData = billDoc.data();
      Logger.d('  Bill data: $billData');

      if (billData != null) {
        final currentStatus = billData['status'] as String? ?? 'pending';
        Logger.d('  Current status: $currentStatus');

        if (currentStatus == 'approved') {
          Logger.e('approveBill: Bill already approved - billId: $billId');
          return false;
        }
        if (currentStatus == 'rejected') {
          Logger.e('approveBill: Bill already rejected - billId: $billId');
          return false;
        }
        Logger.d('  ✓ Bill status is pending, can proceed');
      } else {
        Logger.d('  ⚠️ Bill data is null, assuming pending status');
      }

      // If carpenterId passed is empty, try to read from bill doc
      Logger.d('Step 3: Resolving carpenterId...');
      String finalCarpenterId = carpenterId;
      Logger.d(
        '  Initial carpenterId: "$carpenterId" (isEmpty: ${carpenterId.isEmpty})',
      );

      if (finalCarpenterId.isEmpty && billData != null) {
        finalCarpenterId = billData['carpenterId'] ?? '';
        Logger.d('  Read carpenterId from bill: "$finalCarpenterId"');
      }

      // Validate carpenterId is not empty
      if (finalCarpenterId.isEmpty) {
        Logger.e('approveBill: Carpenter ID is empty after resolution - billId: $billId');
        Logger.e('  billData keys: ${billData?.keys.toList()}');
        return false;
      }
      Logger.d('  ✓ Final carpenterId: $finalCarpenterId');

      // Get admin info from session (phone+pin auth) or fallback to FirebaseAuth
      Logger.d('Step 4: Getting admin info...');
      final fbUser = FirebaseAuth.instance.currentUser;
      Logger.d('  FirebaseAuth currentUser: ${fbUser?.uid ?? "null"}');

      final sessionPhone = await _sessionService.getPhoneNumber();
      final sessionUserId = await _sessionService.getUserId();
      Logger.d('  Session phone: $sessionPhone');
      Logger.d('  Session userId: $sessionUserId');

      final adminPhone = sessionPhone ?? fbUser?.phoneNumber ?? 'admin';
      final adminUserId = sessionUserId ?? fbUser?.uid ?? 'admin';

      Logger.d('  ✓ Final adminPhone: $adminPhone');
      Logger.d('  ✓ Final adminUserId: $adminUserId');

      Logger.d('Step 5: Fetching user document...');
      final userRef = _firestore.collection('users').doc(finalCarpenterId);
      Logger.d('  User ref path: users/$finalCarpenterId');

      final userDoc = await userRef.get();
      Logger.d('  User doc exists: ${userDoc.exists}');
      if (userDoc.exists) {
        Logger.d('  User data: ${userDoc.data()}');
      }

      // Determine current points (0 if user not found)
      Logger.d('Step 6: Calculating points...');
      final dynamic currentPointsRaw;
      if (userDoc.exists) {
        currentPointsRaw = userDoc.data()?['totalPoints'] ?? 0;
        Logger.d(
          '  Found totalPoints in user doc: $currentPointsRaw (type: ${currentPointsRaw.runtimeType})',
        );
      } else {
        currentPointsRaw = 0;
        Logger.d('  User not found, using 0 as current points');
      }

      final int currentPoints = currentPointsRaw is num
          ? currentPointsRaw.toInt()
          : int.tryParse(currentPointsRaw.toString()) ?? 0;
      Logger.d('  ✓ Current points (int): $currentPoints');
      Logger.d('  ✓ Points to add: $pointsEarned');

      // Get old tier before calculating new tier (for tier upgrade notification)
      final oldTier = userDoc.exists
          ? (userDoc.data()?['tier'] as String? ?? 'Bronze')
          : 'Bronze';

      final newTotalPoints = currentPoints + pointsEarned;
      final newTier = _calculateTier(newTotalPoints);
      Logger.d('  ✓ Old tier: $oldTier');
      Logger.d('  ✓ New total points: $newTotalPoints');
      Logger.d('  ✓ New tier: $newTier');

      // Points history entry
      Logger.d('Step 7: Creating points history entry...');
      // Use Timestamp.now() instead of FieldValue.serverTimestamp() because
      // FieldValue.serverTimestamp() cannot be used inside arrays when using batch.set()
      final newHistoryEntry = {
        'points': pointsEarned,
        'reason': 'Bill approval',
        'date': Timestamp.now(), // Changed from FieldValue.serverTimestamp()
        'billId': billId,
        'amount': amount,
      };
      Logger.d('  History entry: $newHistoryEntry');

      Logger.d('Step 8: Fetching user_points document...');
      final userPointsRef = _firestore
          .collection('user_points')
          .doc(finalCarpenterId);
      Logger.d('  User points ref path: user_points/$finalCarpenterId');

      final userPointsDoc = await userPointsRef.get();
      Logger.d('  User points doc exists: ${userPointsDoc.exists}');
      if (userPointsDoc.exists) {
        Logger.d('  User points data: ${userPointsDoc.data()}');
      }

      Logger.d('Step 9: Creating batch operations...');
      final batch = _firestore.batch();
      Logger.d('  Batch created');

      // 1. Update bill (always update)
      Logger.d('  Batch Operation 1: Update bill doc');
      final billUpdateData = {
        'status': 'approved',
        'pointsEarned': pointsEarned,
        'approvedBy': adminUserId,
        'approvedByPhone': adminPhone,
        'approvedAt': FieldValue.serverTimestamp(),
        'approvedDate': _getTodayDateString(),
      };
      Logger.d('    Bill update data: $billUpdateData');
      batch.update(billRef, billUpdateData);
      Logger.d('    ✓ Bill update added to batch');

      // 2. Update or create user account with merged fields
      Logger.d('  Batch Operation 2: Update/create users doc');
      final userUpdateData = {
        'totalPoints': newTotalPoints,
        'tier': newTier,
        'lastUpdated': FieldValue.serverTimestamp(),
      };
      Logger.d('    User update data: $userUpdateData');
      batch.set(userRef, userUpdateData, SetOptions(merge: true));
      Logger.d('    ✓ User update added to batch (merge: true)');

      // 3. Update user_points
      Logger.d('  Batch Operation 3: Update/create user_points doc');
      if (userPointsDoc.exists) {
        // Get existing history to merge with new entry
        final existingData = userPointsDoc.data() ?? {};
        Logger.d('    Existing user_points data: $existingData');

        final existingHistory =
            existingData['pointsHistory'] as List<dynamic>? ?? [];
        Logger.d(
          '    Existing history length: ${existingHistory.length}',
        );

        // Check if userId exists in existing document (required by Firestore rules)
        final existingUserId = existingData['userId'] as String?;
        Logger.d('    Existing userId: "$existingUserId"');
        Logger.d('    Expected userId: "$finalCarpenterId"');
        Logger.d(
          '    userId matches: ${existingUserId == finalCarpenterId}',
        );

        if (existingUserId == null || existingUserId != finalCarpenterId) {
          // If userId is missing or doesn't match, use set to fix it
          // Merge existing history with new entry
          Logger.d('    Using batch.set() (userId missing or mismatch)');
          final userPointsSetData = {
            'userId': finalCarpenterId, // Ensure userId matches document ID
            'totalPoints': newTotalPoints,
            'tier': newTier,
            'lastUpdated': FieldValue.serverTimestamp(),
            'pointsHistory': [...existingHistory, newHistoryEntry],
          };
          Logger.d('    User points set data: $userPointsSetData');
          final historyList = userPointsSetData['pointsHistory'] as List;
          Logger.d('    New history length: ${historyList.length}');
          batch.set(userPointsRef, userPointsSetData, SetOptions(merge: false));
          Logger.d('    ✓ User points set added to batch');
        } else {
          // userId exists and matches, can use update with arrayUnion
          Logger.d(
            '    Using batch.update() with arrayUnion (userId matches)',
          );
          final userPointsUpdateData = {
            'totalPoints': newTotalPoints,
            'tier': newTier,
            'lastUpdated': FieldValue.serverTimestamp(),
            'pointsHistory': FieldValue.arrayUnion([newHistoryEntry]),
          };
          Logger.d('    User points update data: $userPointsUpdateData');
          batch.update(userPointsRef, userPointsUpdateData);
          Logger.d('    ✓ User points update added to batch');
        }
      } else {
        Logger.d('    User points doc does not exist, creating new');
        final userPointsCreateData = {
          'userId': finalCarpenterId,
          'totalPoints': newTotalPoints,
          'tier': newTier,
          'lastUpdated': FieldValue.serverTimestamp(),
          'pointsHistory': [newHistoryEntry],
        };
        Logger.d('    User points create data: $userPointsCreateData');
        batch.set(userPointsRef, userPointsCreateData);
        Logger.d('    ✓ User points create added to batch');
      }

      Logger.d('Step 10: Committing batch...');
      Logger.d('  Total batch operations: 3');
      try {
        await batch.commit();
        Logger.d('✅ Batch committed successfully!');
        Logger.d(
          '✅ Bill approved: $billId (Points: $pointsEarned) for user $finalCarpenterId',
        );
        Logger.d('=== APPROVE BILL SUCCESS ===');

        // Send notification after successful approval
        try {
          Logger.d('📤 Attempting to send bill approved notification...');
          Logger.d('   userId: $finalCarpenterId');
          Logger.d('   amount: $amount');
          Logger.d('   points: $pointsEarned');
          Logger.d('   billId: $billId');

          final notificationService = NotificationService();
          final notificationSent = await notificationService
              .sendBillApprovedNotification(
                userId: finalCarpenterId,
                amount: amount,
                points: pointsEarned,
                billId: billId,
              );

          if (notificationSent) {
            Logger.d('✅ Bill approved notification sent successfully');
          } else {
            Logger.w(
              '⚠️ Bill approved notification failed to send (check logs above)',
            );
          }

          // Check for tier upgrade and send notification if tier changed
          if (oldTier != newTier) {
            Logger.d('Tier upgraded from $oldTier to $newTier');
            await notificationService.sendTierUpgradedNotification(
              userId: finalCarpenterId,
              newTier: newTier,
              points: newTotalPoints,
            );
          }

          // Check for points milestone
          await _checkAndNotifyMilestone(
            notificationService,
            finalCarpenterId,
            newTotalPoints,
          );
        } catch (e, stackTrace) {
          // Don't fail the approval if notification fails
          Logger.w(
            'Failed to send notification after bill approval: $e',
          );
          Logger.e('Notification error stacktrace', error: stackTrace);
        }

        return true;
      } on FirebaseException catch (fe) {
        Logger.e('FirebaseException during batch.commit() - Code: ${fe.code}, Message: ${fe.message}');
        Logger.e('  Bill ID: $billId');
        Logger.e('  Carpenter ID: $finalCarpenterId');
        Logger.e('  Amount: $amount');
        Logger.e('  Points: $pointsEarned');
        Logger.e('=== APPROVE BILL FAILED (FirebaseException) ===');
        throw Exception('Firebase error: ${fe.code} - ${fe.message}');
      }
    } catch (e, st) {
      Logger.e('Exception in approveBill - Error: $e');
      Logger.e('  Type: ${e.runtimeType}');
      Logger.e('  StackTrace:\n$st');
      Logger.e('  Bill ID: $billId');
      Logger.e('  Carpenter ID: $carpenterId');
      Logger.e('  Amount: $amount');
      Logger.e('=== APPROVE BILL FAILED (Exception) ===');
      return false;
    }
  }

  /// Reject bill
  Future<bool> rejectBill(String billId) async {
    try {
      // Get admin info from session (phone+pin auth)
      final adminPhone = await _sessionService.getPhoneNumber() ?? 'admin';
      final adminUserId = await _sessionService.getUserId() ?? 'admin';

      // Get bill data to extract amount and carpenterId
      final billDoc = await _firestore.collection('bills').doc(billId).get();
      final billData = billDoc.data();
      final carpenterId = billData?['carpenterId'] as String? ?? '';
      final amount = (billData?['amount'] as num?)?.toDouble() ?? 0.0;

      await _firestore.collection('bills').doc(billId).update({
        'status': 'rejected',
        'rejectedAt': FieldValue.serverTimestamp(),
        'rejectedBy': adminUserId,
        'rejectedByPhone': adminPhone,
      });

      Logger.d('Bill rejected: $billId');

      // Send notification after successful rejection
      if (carpenterId.isNotEmpty) {
        try {
          final notificationService = NotificationService();
          await notificationService.sendBillRejectedNotification(
            userId: carpenterId,
            amount: amount,
            billId: billId,
          );
        } catch (e) {
          // Don't fail the rejection if notification fails
          Logger.w(
            'Failed to send notification after bill rejection: $e',
          );
        }
      }

      return true;
    } catch (e) {
      Logger.e('Error rejecting bill', error: e);
      return false;
    }
  }

  /// Withdraw/Cancel approved bill (Admin)
  /// Reverses the points that were added when the bill was approved
  Future<bool> withdrawBill(String billId) async {
    Logger.d('=== WITHDRAW BILL START ===');
    Logger.d('Input params: billId=$billId');

    try {
      // Step 1: Get bill document
      final billRef = _firestore.collection('bills').doc(billId);
      final billDoc = await billRef.get();

      if (!billDoc.exists) {
        Logger.e('withdrawBill: Bill not found - billId: $billId');
        return false;
      }

      final billData = billDoc.data()!;
      final status = billData['status'] as String? ?? '';
      final amount = (billData['amount'] as num?)?.toDouble() ?? 0.0;

      if (status != 'approved') {
        Logger.e('withdrawBill: Bill is not approved (status: $status) - billId: $billId');
        return false;
      }

      final carpenterId = billData['carpenterId'] as String? ?? '';
      if (carpenterId.isEmpty) {
        Logger.e('withdrawBill: Carpenter ID is empty - billId: $billId');
        return false;
      }

      final pointsEarned = (billData['pointsEarned'] as num?)?.toInt() ?? 0;

      if (pointsEarned <= 0) {
        Logger.e(
          'withdrawBill: ❌ Invalid points earned: $pointsEarned',
          error: billId,
        );
        return false;
      }

      Logger.d(
        '  Bill found: carpenterId=$carpenterId, points=$pointsEarned',
      );

      // Step 2: Get user document
      final userRef = _firestore.collection('users').doc(carpenterId);
      final userDoc = await userRef.get();

      final currentPointsRaw = userDoc.exists
          ? (userDoc.data()?['totalPoints'] ?? 0)
          : 0;
      final int currentPoints = currentPointsRaw is num
          ? currentPointsRaw.toInt()
          : int.tryParse(currentPointsRaw.toString()) ?? 0;

      if (currentPoints < pointsEarned) {
        Logger.e(
          'withdrawBill: ❌ Insufficient points to withdraw (current: $currentPoints, required: $pointsEarned)',
          error: billId,
        );
        return false;
      }

      final newTotalPoints = currentPoints - pointsEarned;
      final newTier = _calculateTier(newTotalPoints);

      Logger.d('  Current points: $currentPoints');
      Logger.d('  Points to withdraw: $pointsEarned');
      Logger.d('  New total points: $newTotalPoints');
      Logger.d('  New tier: $newTier');

      // Step 3: Get user_points document
      final userPointsRef = _firestore
          .collection('user_points')
          .doc(carpenterId);
      final userPointsDoc = await userPointsRef.get();

      // Step 4: Find and remove the history entry for this bill
      List<dynamic> updatedHistory = [];
      if (userPointsDoc.exists) {
        final existingData = userPointsDoc.data() ?? {};
        final existingHistory =
            existingData['pointsHistory'] as List<dynamic>? ?? [];

        // Remove the entry that matches this billId
        updatedHistory = existingHistory.where((entry) {
          final entryMap = entry as Map<String, dynamic>;
          final entryBillId = entryMap['billId'] as String?;
          return entryBillId != billId;
        }).toList();

        Logger.d(
          '  History entries: ${existingHistory.length} -> ${updatedHistory.length}',
        );
      }

      // Step 5: Get admin info
      final fbUser = FirebaseAuth.instance.currentUser;
      final sessionPhone = await _sessionService.getPhoneNumber();
      final sessionUserId = await _sessionService.getUserId();
      final adminPhone = sessionPhone ?? fbUser?.phoneNumber ?? 'admin';
      final adminUserId = sessionUserId ?? fbUser?.uid ?? 'admin';

      // Step 6: Create batch operations
      final batch = _firestore.batch();

      // 1. Update bill status to 'withdrawn'
      batch.update(billRef, {
        'status': 'withdrawn',
        'withdrawnAt': FieldValue.serverTimestamp(),
        'withdrawnBy': adminUserId,
        'withdrawnByPhone': adminPhone,
      });

      // 2. Update user document
      batch.set(userRef, {
        'totalPoints': newTotalPoints,
        'tier': newTier,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 3. Update user_points document
      if (userPointsDoc.exists) {
        batch.set(userPointsRef, {
          'userId': carpenterId,
          'totalPoints': newTotalPoints,
          'tier': newTier,
          'lastUpdated': FieldValue.serverTimestamp(),
          'pointsHistory': updatedHistory,
        }, SetOptions(merge: false));
      } else {
        // Create new document if it doesn't exist
        batch.set(userPointsRef, {
          'userId': carpenterId,
          'totalPoints': newTotalPoints,
          'tier': newTier,
          'lastUpdated': FieldValue.serverTimestamp(),
          'pointsHistory': updatedHistory,
        });
      }

      // Step 7: Commit batch
      await batch.commit();

      Logger.d('✅ Bill withdrawn successfully: $billId');
      Logger.d(
        '✅ Points withdrawn: $pointsEarned from user $carpenterId',
      );
      Logger.d('=== WITHDRAW BILL SUCCESS ===');

      // Send notification after successful withdrawal
      try {
        final notificationService = NotificationService();
        await notificationService.sendPointsWithdrawnNotification(
          userId: carpenterId,
          points: pointsEarned,
          amount: amount,
          billId: billId,
        );
      } catch (e) {
        // Don't fail the withdrawal if notification fails
        Logger.w(
          'Failed to send notification after points withdrawal: $e',
        );
      }

      return true;
    } catch (e, st) {
      Logger.e('Exception in withdrawBill - Error: $e');
      Logger.e('  StackTrace:\n$st');
      Logger.e('  Bill ID: $billId');
      Logger.e('=== WITHDRAW BILL FAILED ===');
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
      Logger.e('Error getting bills', error: e);
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

  /// Check for points milestone and send notification if reached
  Future<void> _checkAndNotifyMilestone(
    NotificationService notificationService,
    String userId,
    int newPoints,
  ) async {
    try {
      // Define milestone thresholds
      const milestones = [
        1000,
        2500,
        5000,
        7500,
        10000,
        15000,
        20000,
        25000,
        50000,
      ];

      // Check if new points crossed any milestone
      for (final milestone in milestones) {
        // Get user's last milestone from Firestore
        final userDoc = await _firestore.collection('users').doc(userId).get();
        final lastMilestone = userDoc.exists
            ? (userDoc.data()?['lastMilestone'] as int? ?? 0)
            : 0;

        // If we crossed this milestone and haven't notified for it yet
        if (newPoints >= milestone && lastMilestone < milestone) {
          // Send milestone notification
          await notificationService.sendPointsMilestoneNotification(
            userId: userId,
            points: newPoints,
            milestone: milestone,
          );

          // Update last milestone in Firestore
          await _firestore.collection('users').doc(userId).set({
            'lastMilestone': milestone,
          }, SetOptions(merge: true));

          Logger.d('Milestone notification sent: $milestone points');
          break; // Only notify for the highest milestone reached
        }
      }
    } catch (e) {
      Logger.w('Error checking milestone: $e');
      // Don't throw - milestone checking is not critical
    }
  }
}
