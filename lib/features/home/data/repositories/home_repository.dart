// lib/features/home/data/repositories/home_repository.dart
// Repository for home page data (offers, leaderboard, user data)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:balaji_points/features/home/data/models/offer_model.dart';
import 'package:balaji_points/features/home/data/models/carpenter_rank_model.dart';
import 'package:balaji_points/services/session_service.dart';
import 'package:balaji_points/core/utils/app_logger.dart';

class HomeRepository {
  final FirebaseFirestore _firestore;
  final SessionService _sessionService;

  HomeRepository({
    FirebaseFirestore? firestore,
    SessionService? sessionService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _sessionService = sessionService ?? SessionService();

  /// Load active offers from Firestore
  Future<List<OfferModel>> loadOffers({int limit = 10}) async {
    try {
      AppLogger.firestore('READ', 'offers (active)', data: {'limit': limit});

      final snapshot = await _firestore
          .collection('offers')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      final offers =
          snapshot.docs.map((doc) => OfferModel.fromFirestore(doc)).toList();

      AppLogger.firestore('READ', 'offers (success)',
          data: {'count': offers.length});

      return offers;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to load offers', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Load top carpenters for leaderboard
  Future<List<CarpenterRankModel>> loadTopCarpenters({int limit = 20}) async {
    try {
      AppLogger.firestore('READ', 'users (carpenters)', data: {'limit': limit});

      final currentUserId = await _sessionService.getUserId();

      // Fetch all carpenters (without orderBy to avoid index requirement)
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'carpenter')
          .get();

      final carpenters = <CarpenterRankModel>[];

      // Process all carpenters
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final firstName = (data['firstName'] ?? '') as String;
        final lastName = (data['lastName'] ?? '') as String;
        final name = ('$firstName $lastName').trim();
        // Check both 'points' and 'totalPoints' fields
        final points = (data['totalPoints'] ?? data['points'] ?? 0) as int;
        final imageUrl = data['imageUrl'] as String?;
        final tier = data['tier'] as String?;

        if (name.isEmpty) continue; // Skip users without names

        carpenters.add(CarpenterRankModel.fromMap(
          {
            'name': name,
            'points': points,
            'imageUrl': imageUrl,
            'tier': tier,
          },
          doc.id,
          rank: 0, // Will be set after sorting
          currentUserId: currentUserId,
        ));
      }

      // Sort by points descending
      carpenters.sort((a, b) => b.points.compareTo(a.points));

      // Debug: Log the sorted list
      AppLogger.info('Carpenters sorted by points', data: {
        'total': carpenters.length,
        'top3': carpenters.take(3).map((c) => '${c.name}: ${c.points}pts').toList(),
        'all_points': carpenters.map((c) => c.points).toList(),
      });

      // Assign ranks
      for (int i = 0; i < carpenters.length; i++) {
        carpenters[i] = carpenters[i].copyWith(rank: i + 1);
      }

      // Return top N
      final topCarpenters = carpenters.take(limit).toList();

      // Debug: Log final top carpenters
      AppLogger.firestore('READ', 'users (carpenters success)',
          data: {
            'count': topCarpenters.length,
            'top3_names': topCarpenters.take(3).map((c) => c.name).toList(),
            'top3_points': topCarpenters.take(3).map((c) => c.points).toList(),
          });

      return topCarpenters;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to load top carpenters',
          error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Get current user's rank
  Future<CarpenterRankModel?> getCurrentUserRank() async {
    try {
      final currentUserId = await _sessionService.getUserId();
      if (currentUserId == null) return null;

      AppLogger.firestore('READ', 'users (current user rank)',
          data: {'userId': currentUserId});

      // Fetch all carpenters to calculate rank
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'carpenter')
          .get();

      final carpenters = <Map<String, dynamic>>[];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        // Check both 'totalPoints' and 'points' fields
        final points = (data['totalPoints'] ?? data['points'] ?? 0) as int;
        carpenters.add({
          'id': doc.id,
          'points': points,
          'data': data,
        });
      }

      // Sort by points
      carpenters.sort((a, b) => (b['points'] as int).compareTo(a['points'] as int));

      // Find current user's rank
      int rank = 1;
      for (var carpenter in carpenters) {
        if (carpenter['id'] == currentUserId) {
          final data = carpenter['data'] as Map<String, dynamic>;
          final firstName = (data['firstName'] ?? '') as String;
          final lastName = (data['lastName'] ?? '') as String;
          final name = ('$firstName $lastName').trim();

          final userRank = CarpenterRankModel(
            id: currentUserId,
            rank: rank,
            name: name,
            points: carpenter['points'] as int,
            imageUrl: data['imageUrl'] as String?,
            isCurrentUser: true,
            tier: data['tier'] as String?,
          );

          AppLogger.firestore('READ', 'users (rank found)', data: {'rank': rank});
          return userRank;
        }
        rank++;
      }

      return null;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get current user rank',
          error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Load user data
  Future<Map<String, dynamic>?> loadUserData() async {
    try {
      final userId = await _sessionService.getUserId();
      if (userId == null) return null;

      AppLogger.firestore('READ', 'users/$userId');

      final doc = await _firestore.collection('users').doc(userId).get();

      if (!doc.exists) {
        AppLogger.warning('User document not found');
        return null;
      }

      final data = doc.data();
      if (data != null) {
        // Construct complete user data
        final firstName = data['firstName'] as String? ?? '';
        final lastName = data['lastName'] as String? ?? '';
        final userName = '$firstName $lastName'.trim();
        final points = data['points'] as int? ?? data['totalPoints'] as int? ?? 0;
        final role = data['role'] as String? ?? 'carpenter';
        
        AppLogger.firestore('READ', 'users/$userId (success)', data: {
          'userName': userName,
          'points': points,
          'role': role,
        });

        return {
          ...data,
          'userName': userName.isNotEmpty ? userName : null,
          'points': points,
          'role': role,
          'uid': userId, // Add user ID
          'imageUrl': data['imageUrl'], // Explicitly include imageUrl
        };
      }

      return data;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to load user data',
          error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Get notifications stream for carpenter
  Stream<QuerySnapshot> getNotificationsStream(String userId) {
    return _firestore
        .collection('notification_logs')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots();
  }

  /// Get today's top performer (winner)
  Future<CarpenterRankModel?> getTodaysWinner() async {
    try {
      AppLogger.firestore('READ', 'users (today winner)');

      // Get top carpenter
      final topCarpenters = await loadTopCarpenters(limit: 1);
      if (topCarpenters.isEmpty) return null;

      AppLogger.firestore('READ', 'users (winner found)',
          data: {'name': topCarpenters.first.name});

      return topCarpenters.first;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get today\'s winner',
          error: e, stackTrace: stackTrace);
      return null;
    }
  }
}
