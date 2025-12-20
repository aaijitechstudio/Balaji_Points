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
}
