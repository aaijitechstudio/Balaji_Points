// filepath: lib/services/pin_auth_service.dart
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';

import '../core/logger.dart';
import 'user_service.dart';

class PinAuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Normalize phone into a canonical format (e.g. "6376814539" -> "6376814539").
  /// You can later adapt for country codes if needed.
  String normalizePhone(String phone) {
    return phone.replaceAll(RegExp(r'[^0-9]'), '');
  }

  /// Generate a random salt (16 bytes → hex string).
  String _generateSalt() {
    final rand = Random.secure();
    final bytes = List<int>.generate(16, (_) => rand.nextInt(256));
    return base64UrlEncode(bytes);
  }

  /// Create salted hash using SHA-256 (simple and safe enough for this use case).
  String _hashPin(String pin, String salt) {
    final bytes = utf8.encode('$pin::$salt');
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Create or update user with PIN.
  /// - If user with this phone exists → update PIN + profile info.
  /// - If not → create new user + user_points doc.
  Future<bool> setPinForPhone({
    required String phone,
    required String pin,
    String? firstName,
    String? lastName,
    String? profileImageUrl,
  }) async {
    try {
      final normalized = normalizePhone(phone);
      final usersRef = _firestore.collection('users');

      // Find user by phone
      final existingQuery = await usersRef
          .where('phone', isEqualTo: normalized)
          .limit(1)
          .get();

      final salt = _generateSalt();
      final pinHash = _hashPin(pin, salt);

      if (existingQuery.docs.isNotEmpty) {
        // Update existing user
        final doc = existingQuery.docs.first;
        final data = <String, dynamic>{
          'pinHash': pinHash,
          'pinSalt': salt,
          'pinUpdatedAt': FieldValue.serverTimestamp(),
        };

        if (firstName != null && firstName.isNotEmpty) {
          data['firstName'] = firstName;
        }
        if (lastName != null && lastName.isNotEmpty) {
          data['lastName'] = lastName;
        }
        if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
          data['profileImage'] = profileImageUrl;
        }

        await doc.reference.set(data, SetOptions(merge: true));
        AppLogger.info('PIN updated for existing user: $normalized');
        return true;
      } else {
        // Create new user
        final docRef = usersRef.doc();
        final uid = docRef.id;

        await docRef.set({
          'uid': uid,
          'userId': uid,
          'firstName': firstName ?? 'User',
          'lastName': lastName ?? '',
          'phone': normalized,
          'profileImage': profileImageUrl ?? '',
          'role': 'carpenter',
          'status': 'verified',
          'totalPoints': 0,
          'tier': 'Bronze',
          'createdAt': FieldValue.serverTimestamp(),
          'verifiedAt': FieldValue.serverTimestamp(),
          'verifiedBy': 'pin',
          'pinHash': pinHash,
          'pinSalt': salt,
          'pinUpdatedAt': FieldValue.serverTimestamp(),
        });

        // Initialize user_points
        await _firestore.collection('user_points').doc(uid).set({
          'userId': uid,
          'totalPoints': 0,
          'tier': 'Bronze',
          'lastUpdated': FieldValue.serverTimestamp(),
          'pointsHistory': [],
        });

        AppLogger.info('New user created with PIN: $normalized');
        return true;
      }
    } catch (e, st) {
      AppLogger.error('Error setting PIN for phone $phone', e, st);
      return false;
    }
  }

  /// Verify phone + PIN. Returns user data if valid, null otherwise.
  Future<Map<String, dynamic>?> verifyPin({
    required String phone,
    required String pin,
  }) async {
    try {
      final normalized = normalizePhone(phone);
      final usersRef = _firestore.collection('users');

      final query = await usersRef
          .where('phone', isEqualTo: normalized)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        return null;
      }

      final doc = query.docs.first;
      final data = doc.data();
      final salt = data['pinSalt'] as String?;
      final storedHash = data['pinHash'] as String?;

      if (salt == null || storedHash == null) {
        // PIN not setup
        return null;
      }

      final computedHash = _hashPin(pin, salt);
      if (computedHash == storedHash) {
        AppLogger.info('PIN verified for $normalized');
        return {...data, 'docId': doc.id};
      }

      return null;
    } catch (e, st) {
      AppLogger.error('Error verifying PIN for phone $phone', e, st);
      return null;
    }
  }

  /// Check if a phone already has a PIN set.
  Future<bool> hasPin(String phone) async {
    try {
      final normalized = normalizePhone(phone);
      final query = await _firestore
          .collection('users')
          .where('phone', isEqualTo: normalized)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return false;
      final data = query.docs.first.data();
      return data['pinHash'] != null && data['pinSalt'] != null;
    } catch (e) {
      AppLogger.error('Error checking PIN for phone $phone', e);
      return false;
    }
  }

  /// Reset PIN for an existing phone with security verification
  ///
  /// Security checks:
  /// - If loggedInPhone is provided, verifies it matches the target phone
  /// - If currentPin is provided, verifies it matches the stored PIN
  /// - If isAdmin is true, skips verification (admin privilege)
  ///
  /// Returns true if reset successful, false otherwise
  Future<bool> resetPin({
    required String phone,
    required String newPin,
    String? loggedInPhone,
    String? currentPin,
    bool isAdmin = false,
  }) async {
    try {
      final normalized = normalizePhone(phone);
      final usersRef = _firestore.collection('users');

      final query = await usersRef
          .where('phone', isEqualTo: normalized)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        AppLogger.warning(
          'PIN reset failed: User not found for phone $normalized',
        );
        return false;
      }

      final doc = query.docs.first;
      final userData = doc.data();

      // Security Verification
      if (isAdmin) {
        // Admin PIN reset - verify admin status first
        final userService = UserService();
        final isActuallyAdmin = await userService.isAdmin();
        if (!isActuallyAdmin) {
          AppLogger.warning(
            'PIN reset denied: User is not authorized as admin for phone $normalized',
          );
          return false;
        }
        // Admin verified - skip security checks and proceed
        AppLogger.info('Admin PIN reset authorized for phone $normalized');
      } else {
        // Regular user reset - apply security checks
        // Check 1: Verify phone ownership (if logged in)
        if (loggedInPhone != null) {
          final normalizedLoggedIn = normalizePhone(loggedInPhone);
          if (normalized != normalizedLoggedIn) {
            AppLogger.warning(
              'PIN reset denied: Phone mismatch. Logged in: $normalizedLoggedIn, Requested: $normalized',
            );
            return false;
          }
        } else {
          // Not logged in and not admin - deny reset
          AppLogger.warning(
            'PIN reset denied: User not logged in and not admin for phone $normalized',
          );
          return false;
        }

        // Check 2: Verify current PIN (if provided)
        if (currentPin != null) {
          final salt = userData['pinSalt'] as String?;
          final storedHash = userData['pinHash'] as String?;

          if (salt == null || storedHash == null) {
            AppLogger.warning(
              'PIN reset denied: No PIN set for phone $normalized',
            );
            return false;
          }

          final computedHash = _hashPin(currentPin, salt);
          if (computedHash != storedHash) {
            AppLogger.warning(
              'PIN reset denied: Current PIN verification failed for phone $normalized',
            );
            return false;
          }
        } else {
          // Current PIN required for non-admin resets
          AppLogger.warning(
            'PIN reset denied: Current PIN not provided for phone $normalized',
          );
          return false;
        }
      }

      // All security checks passed - proceed with reset
      final salt = _generateSalt();
      final hash = _hashPin(newPin, salt);

      await doc.reference.set({
        'pinHash': hash,
        'pinSalt': salt,
        'pinUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      AppLogger.info('PIN reset successful for $normalized');
      return true;
    } catch (e, st) {
      AppLogger.error('Error resetting PIN for phone $phone', e, st);
      return false;
    }
  }

  /// Generate next user display ID (auto-increment)
  Future<int> _getNextUserDisplayId() async {
    final counterRef = _firestore.collection('counters').doc('user_counter');

    // Use transaction for atomic increment
    return await _firestore.runTransaction((transaction) async {
      final counterDoc = await transaction.get(counterRef);

      int nextId;
      if (!counterDoc.exists) {
        // Initialize counter starting from 41
        nextId = 41;
        transaction.set(counterRef, {'lastId': nextId});
      } else {
        final currentId = counterDoc.data()?['lastId'] as int? ?? 40;
        nextId = currentId + 1;
        transaction.update(counterRef, {'lastId': nextId});
      }

      return nextId;
    });
  }

  /// Create a new account with phone number as the unique identifier.
  /// Phone number is used as the document ID for easier lookups.
  /// Returns true if account creation is successful.
  /// Returns false if account already exists (user should use Reset PIN instead).
  /// firstName defaults to empty string - can be filled later via profile update.
  Future<bool> createAccount({
    required String phone,
    required String pin,
    String firstName = '',
    String? lastName,
    String? profileImageUrl,
  }) async {
    try {
      final normalized = normalizePhone(phone);
      final usersRef = _firestore.collection('users');

      // Check if user already exists by querying phone field
      final existingQuery = await usersRef
          .where('phone', isEqualTo: normalized)
          .limit(1)
          .get();

      if (existingQuery.docs.isNotEmpty) {
        // User already exists - they should use Reset PIN instead
        AppLogger.warning(
          'Account already exists for phone $normalized. Use Reset PIN instead.',
        );
        return false;
      }

      // Generate unique display ID for user (e.g., #BP41)
      final userDisplayId = await _getNextUserDisplayId();

      // Generate salt and hash for PIN
      final salt = _generateSalt();
      final pinHash = _hashPin(pin, salt);

      // Use batch write for atomic operation - both succeed or both fail
      final batch = _firestore.batch();

      // Create new account with phone as document ID
      final userDocRef = usersRef.doc(normalized);
      batch.set(userDocRef, {
        'phone': normalized, // Phone number is the unique identifier
        'userDisplayId': userDisplayId, // Display ID like 41 (shown as #BP41)
        'firstName': firstName,
        'lastName': lastName ?? '',
        'profileImage': profileImageUrl ?? '',
        'role': 'carpenter',
        'status': 'verified',
        'totalPoints': 0,
        'tier': 'Bronze',
        'createdAt': FieldValue.serverTimestamp(),
        'verifiedAt': FieldValue.serverTimestamp(),
        'verifiedBy': 'pin',
        'pinHash': pinHash,
        'pinSalt': salt,
        'pinUpdatedAt': FieldValue.serverTimestamp(),
      });

      // Initialize user_points document with same ID
      final pointsDocRef = _firestore.collection('user_points').doc(normalized);
      batch.set(pointsDocRef, {
        'userId': normalized,
        'totalPoints': 0,
        'tier': 'Bronze',
        'lastUpdated': FieldValue.serverTimestamp(),
        'pointsHistory': [],
      });

      // Commit batch - atomic operation
      await batch.commit();

      AppLogger.info('New account created successfully: $normalized');
      return true;
    } catch (e, st) {
      AppLogger.error('Error creating account for phone $phone', e, st);
      return false;
    }
  }
}
