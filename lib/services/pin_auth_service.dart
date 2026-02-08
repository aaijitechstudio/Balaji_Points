// filepath: lib/services/pin_auth_service.dart
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';

import 'package:balaji_points/core/utils/app_logger.dart';
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
      AppLogger.error('Error setting PIN for phone $phone', error: e, stackTrace: st);
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
      AppLogger.error('Error verifying PIN for phone $phone', error: e, stackTrace: st);
      return null;
    }
  }

  /// Check if a user exists (by phone number) in the users collection.
  /// Returns true if user document exists, false otherwise.
  Future<bool> userExists(String phone) async {
    try {
      final normalized = normalizePhone(phone);

      // Check by phone field first
      final queryByPhone = await _firestore
          .collection('users')
          .where('phone', isEqualTo: normalized)
          .limit(1)
          .get();

      if (queryByPhone.docs.isNotEmpty) {
        return true;
      }

      // Also check by document ID (phone might be document ID)
      final docRef = _firestore.collection('users').doc(normalized);
      final doc = await docRef.get();

      if (doc.exists) {
        return true;
      }

      return false;
    } catch (e) {
      AppLogger.error('Error checking user existence for phone $phone', error: e);
      return false;
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
      AppLogger.error('Error checking PIN for phone $phone', error: e);
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
      AppLogger.error('Error resetting PIN for phone $phone', error: e, stackTrace: st);
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
  /// Returns false if account already exists with a PIN (user should use Reset PIN instead).
  /// If account exists but has no PIN, it will complete the account setup.
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

      // Check if user exists by querying phone field (more reliable than document ID)
      // Also check by document ID in case phone is used as document ID
      final queryByPhone = await usersRef
          .where('phone', isEqualTo: normalized)
          .limit(1)
          .get();

      DocumentSnapshot? userDoc;
      DocumentReference? userDocRef;

      if (queryByPhone.docs.isNotEmpty) {
        // User found by phone field
        userDoc = queryByPhone.docs.first;
        userDocRef = userDoc.reference;
        AppLogger.info('User found by phone field query: ${userDoc.id}');
      } else {
        // Check by document ID (phone number might be document ID)
        final docRef = usersRef.doc(normalized);
        userDoc = await docRef.get();
        if (userDoc.exists) {
          userDocRef = docRef;
          AppLogger.info('User found by document ID: $normalized');
        }
      }

      if (userDoc != null && userDoc.exists && userDocRef != null) {
        final userData = userDoc.data() as Map<String, dynamic>?;

        // Check if PIN exists - must have both hash and salt, and they must not be empty
        final pinHash = userData?['pinHash'] as String?;
        final pinSalt = userData?['pinSalt'] as String?;

        final hasPin =
            pinHash != null &&
            pinHash.toString().trim().isNotEmpty &&
            pinSalt != null &&
            pinSalt.toString().trim().isNotEmpty;

        AppLogger.info(
          'User document exists. PIN hash: ${pinHash != null ? "present (${pinHash.length} chars)" : "null"}, PIN salt: ${pinSalt != null ? "present (${pinSalt.length} chars)" : "null"}, Has PIN: $hasPin',
        );

        if (hasPin) {
          // User already exists with PIN - they should use Reset PIN instead
          AppLogger.warning(
            'Account already exists with PIN for phone $normalized. Use Reset PIN instead.',
          );
          return false;
        } else {
          // User document exists but no PIN set - complete the account setup
          AppLogger.info(
            'User document exists but no PIN set. Completing account setup for $normalized.',
          );

          // Generate salt and hash for PIN
          final salt = _generateSalt();
          final pinHash = _hashPin(pin, salt);

          // Update existing document with PIN and other missing fields
          final updateData = <String, dynamic>{
            'pinHash': pinHash,
            'pinSalt': salt,
            'pinUpdatedAt': FieldValue.serverTimestamp(),
          };

          // Only set fields if they don't exist or are empty
          if (userData?['firstName'] == null ||
              (userData?['firstName'] as String).isEmpty) {
            updateData['firstName'] = firstName;
          }
          if (userData?['lastName'] == null ||
              (userData?['lastName'] as String).isEmpty) {
            updateData['lastName'] = lastName ?? '';
          }
          if (userData?['role'] == null) {
            updateData['role'] = 'carpenter';
          }
          if (userData?['status'] == null) {
            updateData['status'] = 'verified';
          }
          if (userData?['totalPoints'] == null) {
            updateData['totalPoints'] = 0;
          }
          if (userData?['tier'] == null) {
            updateData['tier'] = 'Bronze';
          }
          if (userData?['createdAt'] == null) {
            updateData['createdAt'] = FieldValue.serverTimestamp();
          }
          if (userData?['verifiedAt'] == null) {
            updateData['verifiedAt'] = FieldValue.serverTimestamp();
          }
          if (userData?['verifiedBy'] == null) {
            updateData['verifiedBy'] = 'pin';
          }

          await userDocRef.set(updateData, SetOptions(merge: true));

          // Ensure user_points document exists
          final userIdForPoints = userDoc.id; // Use the actual document ID
          final pointsDocRef = _firestore
              .collection('user_points')
              .doc(userIdForPoints);
          final pointsDoc = await pointsDocRef.get();
          if (!pointsDoc.exists) {
            await pointsDocRef.set({
              'userId': userIdForPoints,
              'totalPoints': 0,
              'tier': 'Bronze',
              'lastUpdated': FieldValue.serverTimestamp(),
              'pointsHistory': [],
            });
          }

          AppLogger.info(
            'Account setup completed for existing user: $normalized',
          );
          return true;
        }
      }

      // Generate unique display ID for user (e.g., #BP41)
      final userDisplayId = await _getNextUserDisplayId();

      // Generate salt and hash for PIN
      final salt = _generateSalt();
      final pinHash = _hashPin(pin, salt);

      // Use batch write for atomic operation - both succeed or both fail
      final batch = _firestore.batch();

      // Create new account with phone as document ID
      final newUserDocRef = usersRef.doc(normalized);
      batch.set(newUserDocRef, {
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

      // Initialize user_points document with same ID (phone number)
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
    } on FirebaseException catch (e, st) {
      AppLogger.error(
        'Firebase error creating account for phone $phone',
        error: e,
        stackTrace: st,
      );

      // Re-throw Firebase exceptions so they can be handled in UI
      if (e.code == 'permission-denied') {
        throw Exception(
          'Firebase permission denied. Please check Firestore rules or contact support.',
        );
      }
      throw Exception('Firebase error: ${e.message}');
    } catch (e, st) {
      AppLogger.error(
        'Error creating account for phone $phone',
        error: e,
        stackTrace: st,
      );
      rethrow; // Re-throw so UI can handle it
    }
  }
}
