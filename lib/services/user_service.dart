import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/logger.dart';
import 'session_service.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SessionService _sessionService = SessionService();

  /// Check if phone number exists in pending_users
  Future<bool> checkPendingUser(String phoneNumber) async {
    try {
      final doc = await _firestore
          .collection('pending_users')
          .doc(phoneNumber)
          .get();
      return doc.exists;
    } catch (e) {
      AppLogger.error('Error checking pending user', e);
      return false;
    }
  }

  /// Check if user is verified in users collection
  Future<Map<String, dynamic>?> checkVerifiedUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      AppLogger.error('Error checking verified user', e);
      return null;
    }
  }

  /// Get user by phone number
  Future<Map<String, dynamic>?> getUserByPhone(String phoneNumber) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('phone', isEqualTo: phoneNumber)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;

      final data = query.docs.first.data();
      final status = (data['status'] as String?)?.toLowerCase();
      if (status == 'verified' || status == 'approved') {
        return data;
      }
      return null;
    } catch (e) {
      AppLogger.error('Error getting user by phone', e);
      return null;
    }
  }

  /// Create pending user
  Future<bool> createPendingUser({
    required String firstName,
    required String lastName,
    required String phone,
    String? city,
    String? skill,
    String? referral,
  }) async {
    try {
      final exists = await checkPendingUser(phone);
      if (exists) return false;

      await _firestore.collection('pending_users').doc(phone).set({
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'role': 'carpenter',
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        if (city != null && city.isNotEmpty) 'city': city,
        if (skill != null && skill.isNotEmpty) 'skill': skill,
        if (referral != null && referral.isNotEmpty) 'referral': referral,
      });

      return true;
    } catch (e) {
      AppLogger.error('Error creating pending user', e);
      return false;
    }
  }

  /// Create verified user in Firestore
  Future<bool> createVerifiedUser({
    required String uid,
    required String firstName,
    required String lastName,
    required String phone,
    String? city,
    String? skill,
    String? referral,
    String verifiedBy = 'system',
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'role': 'carpenter',
        'status': 'verified',
        'totalPoints': 0,
        'tier': 'Bronze',
        'verifiedAt': FieldValue.serverTimestamp(),
        'verifiedBy': verifiedBy,
        'createdAt': FieldValue.serverTimestamp(),
        if (city != null) 'city': city,
        if (skill != null) 'skill': skill,
        if (referral != null) 'referral': referral,
      });

      // Points initialization
      await _firestore.collection('user_points').doc(uid).set({
        'userId': uid,
        'totalPoints': 0,
        'tier': 'Bronze',
        'lastUpdated': FieldValue.serverTimestamp(),
        'pointsHistory': [],
      });

      return true;
    } catch (e) {
      AppLogger.error('Error creating verified user', e);
      return false;
    }
  }

  /// Update user after verification
  Future<bool> updateUserAfterVerification({
    required String uid,
    required String phone,
  }) async {
    try {
      // Check pending data (most common)
      final pendingDoc = await _firestore
          .collection('pending_users')
          .doc(phone)
          .get();

      if (pendingDoc.exists) {
        final p = pendingDoc.data()!;
        await createVerifiedUser(
          uid: uid,
          firstName: p['firstName'] ?? '',
          lastName: p['lastName'] ?? '',
          phone: phone,
          city: p['city'],
          skill: p['skill'],
          referral: p['referral'],
          verifiedBy: 'phone-verification',
        );

        await _firestore.collection('pending_users').doc(phone).update({
          'status': 'approved',
          'approvedAt': FieldValue.serverTimestamp(),
        });

        return true;
      }

      // Auto-create
      await createVerifiedUser(
        uid: uid,
        firstName: 'User',
        lastName: '',
        phone: phone,
        verifiedBy: 'phone-verification',
      );

      return true;
    } catch (e) {
      AppLogger.error('Error updating user after verification', e);
      return false;
    }
  }

  /// Strict fresh user data (no cache)
  /// Uses phone number from session (PIN-based auth)
  Future<Map<String, dynamic>?> getCurrentUserData({
    bool forceRefresh = false,
  }) async {
    try {
      // Get phone number from session (PIN-based auth)
      final phoneNumber = await _sessionService.getPhoneNumber();
      if (phoneNumber == null) {
        AppLogger.warning('No phone number in session');
        return null;
      }

      // Query user by phone number as document ID
      final doc = await _firestore
          .collection('users')
          .doc(phoneNumber)
          .get(GetOptions(source: Source.server)); // Always fresh

      if (doc.exists) {
        AppLogger.info('User data loaded for phone: $phoneNumber');
        return doc.data();
      }

      AppLogger.warning('No user document found for phone: $phoneNumber');
      return null;
    } catch (e) {
      AppLogger.error('Error getting current user data', e);
      return null;
    }
  }

  /// Admin check
  Future<bool> isAdmin() async {
    try {
      final data = await getCurrentUserData(forceRefresh: true);
      return data?['role'] == 'admin';
    } catch (e) {
      AppLogger.error('Error checking admin status', e);
      return false;
    }
  }

  /// Delete carpenter from the system
  /// This will delete the user and all related data
  /// Note: Firestore batch operations are limited to 500 operations
  Future<bool> deleteCarpenter(String userId) async {
    try {
      AppLogger.info('Deleting carpenter: $userId');

      // First, get user data to retrieve phone number
      final userRef = _firestore.collection('users').doc(userId);
      final userDoc = await userRef.get();

      if (!userDoc.exists) {
        AppLogger.warning('User document does not exist: $userId');
        return false;
      }

      final userData = userDoc.data();
      final phone = userData?['phone'] as String?;

      // Get all related data first
      final billsQuery = await _firestore
          .collection('bills')
          .where('userId', isEqualTo: userId)
          .get();

      final redemptionsQuery = await _firestore
          .collection('offer_redemptions')
          .where('carpenterId', isEqualTo: userId)
          .get();

      // Check if batch size exceeds Firestore limit (500 operations)
      final totalOperations =
          2 +
          billsQuery.docs.length +
          redemptionsQuery.docs.length +
          (phone != null ? 1 : 0);

      if (totalOperations > 500) {
        AppLogger.error(
          'Too many operations for batch delete',
          'Total: $totalOperations',
        );
        // Delete in multiple batches if needed
        return await _deleteCarpenterInBatches(
          userId,
          phone,
          billsQuery.docs,
          redemptionsQuery.docs,
        );
      }

      // Use batch write for atomic operations
      final batch = _firestore.batch();

      // 1. Delete user document
      batch.delete(userRef);

      // 2. Delete user_points document
      final userPointsRef = _firestore.collection('user_points').doc(userId);
      batch.delete(userPointsRef);

      // 3. Delete all bills associated with this user
      for (var billDoc in billsQuery.docs) {
        batch.delete(billDoc.reference);
      }

      // 4. Delete all offer redemptions associated with this user
      for (var redemptionDoc in redemptionsQuery.docs) {
        batch.delete(redemptionDoc.reference);
      }

      // 5. Delete from pending_users if exists (using phone number)
      if (phone != null && phone.isNotEmpty) {
        final pendingRef = _firestore.collection('pending_users').doc(phone);
        final pendingDoc = await pendingRef.get();
        if (pendingDoc.exists) {
          batch.delete(pendingRef);
        }
      }

      // Execute batch delete
      await batch.commit();

      AppLogger.info('Carpenter deleted successfully: $userId');
      return true;
    } catch (e) {
      AppLogger.error('Error deleting carpenter', e);
      rethrow; // Re-throw to get better error messages
    }
  }

  /// Delete carpenter in multiple batches if operation count exceeds Firestore limit
  Future<bool> _deleteCarpenterInBatches(
    String userId,
    String? phone,
    List<QueryDocumentSnapshot> bills,
    List<QueryDocumentSnapshot> redemptions,
  ) async {
    try {
      // Batch 1: Delete user and user_points
      final batch1 = _firestore.batch();
      batch1.delete(_firestore.collection('users').doc(userId));
      batch1.delete(_firestore.collection('user_points').doc(userId));
      await batch1.commit();

      // Batch 2: Delete bills (in chunks of 498 to stay under 500 limit)
      const chunkSize = 498;
      for (var i = 0; i < bills.length; i += chunkSize) {
        final batch = _firestore.batch();
        final chunk = bills.skip(i).take(chunkSize);
        for (var billDoc in chunk) {
          batch.delete(billDoc.reference);
        }
        await batch.commit();
      }

      // Batch 3: Delete redemptions (in chunks of 498)
      for (var i = 0; i < redemptions.length; i += chunkSize) {
        final batch = _firestore.batch();
        final chunk = redemptions.skip(i).take(chunkSize);
        for (var redemptionDoc in chunk) {
          batch.delete(redemptionDoc.reference);
        }
        await batch.commit();
      }

      // Batch 4: Delete pending_users if exists
      if (phone != null && phone.isNotEmpty) {
        final pendingRef = _firestore.collection('pending_users').doc(phone);
        final pendingDoc = await pendingRef.get();
        if (pendingDoc.exists) {
          final batch = _firestore.batch();
          batch.delete(pendingRef);
          await batch.commit();
        }
      }

      AppLogger.info('Carpenter deleted successfully in batches: $userId');
      return true;
    } catch (e) {
      AppLogger.error('Error deleting carpenter in batches', e);
      return false;
    }
  }
}
