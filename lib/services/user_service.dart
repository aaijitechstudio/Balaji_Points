import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/logger.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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

  /// Get user by phone number from users collection
  /// Accept both 'verified' and 'approved' statuses
  Future<Map<String, dynamic>?> getUserByPhone(String phoneNumber) async {
    try {
      // Use a single equality filter to avoid composite index requirement
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

  /// Get any user by phone number regardless of status (admin bypass helper)
  Future<Map<String, dynamic>?> getAnyUserByPhone(String phoneNumber) async {
    try {
      final normalized = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');

      // First try string match (recommended schema)
      var query = await _firestore
          .collection('users')
          .where('phone', isEqualTo: normalized)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return query.docs.first.data();
      }

      // Fallback: try numeric match if some manual docs stored phone as number
      final asInt = int.tryParse(normalized);
      if (asInt != null) {
        query = await _firestore
            .collection('users')
            .where('phone', isEqualTo: asInt)
            .limit(1)
            .get();
        if (query.docs.isNotEmpty) {
          return query.docs.first.data();
        }
      }

      // Fallbacks for common formats
      final variants = <String>['+91$normalized', '0$normalized'];
      for (final v in variants) {
        final q = await _firestore
            .collection('users')
            .where('phone', isEqualTo: v)
            .limit(1)
            .get();
        if (q.docs.isNotEmpty) {
          return q.docs.first.data();
        }
      }
      return null;
    } catch (e) {
      AppLogger.error('Error getting any user by phone', e);
      return null;
    }
  }

  /// Create pending user (signup)
  Future<bool> createPendingUser({
    required String firstName,
    required String lastName,
    required String phone,
    String? city,
    String? skill,
    String? referral,
  }) async {
    try {
      // Check if already exists
      final exists = await checkPendingUser(phone);
      if (exists) {
        AppLogger.warning('Pending user already exists: $phone');
        return false;
      }

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

      AppLogger.info('Pending user created: $phone');
      return true;
    } catch (e) {
      AppLogger.error('Error creating pending user', e);
      return false;
    }
  }

  /// Create verified user (admin approval or after verification)
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
        if (city != null && city.isNotEmpty) 'city': city,
        if (skill != null && skill.isNotEmpty) 'skill': skill,
        if (referral != null && referral.isNotEmpty) 'referral': referral,
      });

      // Initialize user points
      await _firestore.collection('user_points').doc(uid).set({
        'userId': uid,
        'totalPoints': 0,
        'tier': 'Bronze',
        'lastUpdated': FieldValue.serverTimestamp(),
        'pointsHistory': [],
      });

      AppLogger.info('Verified user created: $uid ($phone)');
      return true;
    } catch (e) {
      AppLogger.error('Error creating verified user', e);
      return false;
    }
  }

  /// Update user after phone verification
  Future<bool> updateUserAfterVerification({
    required String uid,
    required String phone,
  }) async {
    try {
      // 1) If an ADMIN exists by phone (manually seeded), bind it to this uid
      try {
        final existingByPhone = await getAnyUserByPhone(phone);
        final existingRole = (existingByPhone?['role'] as String?)
            ?.toLowerCase();
        if (existingByPhone != null && existingRole == 'admin') {
          await _firestore.collection('users').doc(uid).set({
            ...existingByPhone,
            'uid': uid,
            'phone': phone,
            'role': 'admin',
            // Ensure admins are considered active without further gating
            'status': existingByPhone['status'] ?? 'approved',
            'createdAt':
                existingByPhone['createdAt'] ?? FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

          AppLogger.info('Admin bound to current uid: $uid ($phone)');
          return true;
        }
      } catch (e) {
        AppLogger.warning('Admin binding check failed, continuing as user: $e');
      }

      // 2) If not admin, check if user data exists from pending_users and promote
      final pendingDoc = await _firestore
          .collection('pending_users')
          .doc(phone)
          .get();

      if (pendingDoc.exists) {
        final pendingData = pendingDoc.data()!;
        final firstName = pendingData['firstName'] as String? ?? '';
        final lastName = pendingData['lastName'] as String? ?? '';
        final city = pendingData['city'] as String?;
        final skill = pendingData['skill'] as String?;
        final referral = pendingData['referral'] as String?;

        // Create verified user with data from pending_users
        await createVerifiedUser(
          uid: uid,
          firstName: firstName,
          lastName: lastName,
          phone: phone,
          city: city,
          skill: skill,
          referral: referral,
          verifiedBy: 'phone-verification',
        );

        // Optionally, mark pending user as approved or delete it
        await _firestore.collection('pending_users').doc(phone).update({
          'status': 'approved',
          'approvedAt': FieldValue.serverTimestamp(),
        });

        AppLogger.info('User updated after verification: $uid');
        return true;
      } else {
        // 3) No pending user: auto-create as verified carpenter
        await createVerifiedUser(
          uid: uid,
          firstName: 'User',
          lastName: '',
          phone: phone,
          verifiedBy: 'phone-verification',
        );
        return true;
      }
    } catch (e) {
      AppLogger.error('Error updating user after verification', e);
      return false;
    }
  }

  /// Get current user data
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      AppLogger.error('Error getting current user data', e);
      return null;
    }
  }

  /// Check if current user is admin
  Future<bool> isAdmin() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final userData = await getCurrentUserData();
      return userData?['role'] == 'admin';
    } catch (e) {
      AppLogger.error('Error checking admin status', e);
      return false;
    }
  }

  /// Get all pending users (admin only)
  Future<List<Map<String, dynamic>>> getPendingUsers() async {
    try {
      final query = await _firestore
          .collection('pending_users')
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      AppLogger.error('Error getting pending users', e);
      return [];
    }
  }

  /// Get all verified users/carpenters
  Future<List<Map<String, dynamic>>> getVerifiedUsers() async {
    try {
      final query = await _firestore
          .collection('users')
          .where('status', isEqualTo: 'verified')
          .where('role', isEqualTo: 'carpenter')
          .orderBy('totalPoints', descending: true)
          .get();

      return query.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      AppLogger.error('Error getting verified users', e);
      return [];
    }
  }

  /// Approve pending user (admin action)
  Future<bool> approvePendingUser({
    required String phoneNumber,
    required String verifiedBy,
  }) async {
    try {
      // Get pending user data
      final pendingDoc = await _firestore
          .collection('pending_users')
          .doc(phoneNumber)
          .get();

      if (!pendingDoc.exists) {
        AppLogger.warning('Pending user not found: $phoneNumber');
        return false;
      }

      // Note: This requires the user to have Firebase Auth account first
      // For now, we'll just mark as approved
      // In a full implementation, admin would create Firebase Auth user first

      await _firestore.collection('pending_users').doc(phoneNumber).update({
        'status': 'approved',
        'approvedAt': FieldValue.serverTimestamp(),
        'verifiedBy': verifiedBy,
      });

      AppLogger.info('Pending user approved: $phoneNumber');
      return true;
    } catch (e) {
      AppLogger.error('Error approving pending user', e);
      return false;
    }
  }
}
