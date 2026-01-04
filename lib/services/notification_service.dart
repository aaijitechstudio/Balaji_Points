import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/logger.dart';

/// Notification types for different events
enum NotificationType {
  billApproved,
  billRejected,
  pointsWithdrawn,
  tierUpgraded,
  dailySpinWon,
  offerRedeemed,
  newOfferAvailable,
  billSubmitted,
}

/// Notification Service for sending push notifications
///
/// This service handles sending notifications to users via FCM.
/// For production, notifications should be sent via Cloud Functions.
/// This service prepares notification data and can either:
/// 1. Queue notifications in Firestore (for Cloud Functions to process)
/// 2. Send directly via FCM REST API (requires server token)
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Send a notification to a specific user
  ///
  /// [userId] - User ID (phone number or Firebase Auth UID)
  /// [type] - Type of notification
  /// [title] - Notification title
  /// [body] - Notification body
  /// [data] - Additional data payload for deep linking
  Future<bool> sendNotification({
    required String userId,
    required NotificationType type,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      AppLogger.info('📤 Sending notification: $type to user: $userId');

      // Get user's FCM token
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        AppLogger.warning('User not found: $userId');
        return false;
      }

      final userData = userDoc.data();
      final fcmToken = userData?['fcmToken'] as String?;

      if (fcmToken == null || fcmToken.isEmpty) {
        AppLogger.warning('No FCM token found for user: $userId');
        return false;
      }

      // Check notification preferences (if enabled)
      final notificationPrefs =
          userData?['notificationPreferences'] as Map<String, dynamic>?;
      if (notificationPrefs != null) {
        final enabled = notificationPrefs['enabled'] as bool? ?? true;
        if (!enabled) {
          AppLogger.info('Notifications disabled for user: $userId');
          return false;
        }

        // Check specific notification type preference
        final typeKey = _getNotificationTypeKey(type);
        final typeEnabled = notificationPrefs[typeKey] as bool? ?? true;
        if (!typeEnabled) {
          AppLogger.info(
            'Notification type $typeKey disabled for user: $userId',
          );
          return false;
        }
      }

      // Prepare notification data
      final notificationData = {
        'type': type.name,
        'notificationId': _generateNotificationId(),
        'timestamp': FieldValue.serverTimestamp(),
        ...?data,
      };

      // Queue notification in Firestore for Cloud Functions to process
      // This is the recommended approach for production
      await _queueNotificationInFirestore(
        userId: userId,
        fcmToken: fcmToken,
        type: type,
        title: title,
        body: body,
        data: notificationData,
      );

      // Log analytics
      await _logNotificationAnalytics(
        type: type.name,
        title: title,
        body: body,
        sentCount: 1,
        skippedCount: 0,
        isBroadcast: false,
      );

      AppLogger.info('✅ Notification queued successfully: $type');
      return true;
    } catch (e) {
      AppLogger.error('Error sending notification', e);
      return false;
    }
  }

  /// Queue notification in Firestore for Cloud Functions to process
  Future<void> _queueNotificationInFirestore({
    required String userId,
    required String fcmToken,
    required NotificationType type,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection('notification_queue').add({
        'userId': userId,
        'fcmToken': fcmToken,
        'type': type.name,
        'title': title,
        'body': body,
        'data': data,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'priority': _getNotificationPriority(type),
      });

      AppLogger.info('Notification queued in Firestore');
    } catch (e) {
      AppLogger.error('Error queueing notification in Firestore', e);
      rethrow;
    }
  }

  /// Get notification type key for preferences
  String _getNotificationTypeKey(NotificationType type) {
    switch (type) {
      case NotificationType.billApproved:
        return 'billApproved';
      case NotificationType.billRejected:
        return 'billRejected';
      case NotificationType.pointsWithdrawn:
        return 'pointsWithdrawn';
      case NotificationType.tierUpgraded:
        return 'tierUpgraded';
      case NotificationType.dailySpinWon:
        return 'dailySpin';
      case NotificationType.offerRedeemed:
        return 'newOffers';
      case NotificationType.newOfferAvailable:
        return 'newOffers';
      case NotificationType.billSubmitted:
        return 'billApproved'; // Use same preference as bill approval
    }
  }

  /// Get notification priority based on type
  String _getNotificationPriority(NotificationType type) {
    switch (type) {
      case NotificationType.billApproved:
      case NotificationType.tierUpgraded:
      case NotificationType.pointsWithdrawn:
        return 'high';
      case NotificationType.billRejected:
      case NotificationType.dailySpinWon:
      case NotificationType.offerRedeemed:
      case NotificationType.newOfferAvailable:
      case NotificationType.billSubmitted:
        return 'normal';
    }
  }

  /// Generate unique notification ID
  String _generateNotificationId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Send bill approved notification
  Future<bool> sendBillApprovedNotification({
    required String userId,
    required double amount,
    required int points,
    required String billId,
  }) async {
    return await sendNotification(
      userId: userId,
      type: NotificationType.billApproved,
      title: '🎉 Bill Approved!',
      body:
          'Your bill of ₹${amount.toStringAsFixed(0)} has been approved. You earned $points points!',
      data: {
        'billId': billId,
        'amount': amount,
        'points': points,
        'screen': '/bills', // Navigate to bills screen
      },
    );
  }

  /// Send bill rejected notification
  Future<bool> sendBillRejectedNotification({
    required String userId,
    required double amount,
    required String billId,
  }) async {
    return await sendNotification(
      userId: userId,
      type: NotificationType.billRejected,
      title: 'Bill Rejected',
      body:
          'Your bill of ₹${amount.toStringAsFixed(0)} has been rejected. Please check and resubmit.',
      data: {
        'billId': billId,
        'amount': amount,
        'screen': '/bills', // Navigate to bills screen
      },
    );
  }

  /// Send points withdrawn notification
  Future<bool> sendPointsWithdrawnNotification({
    required String userId,
    required int points,
    required double amount,
    required String billId,
  }) async {
    return await sendNotification(
      userId: userId,
      type: NotificationType.pointsWithdrawn,
      title: 'Points Withdrawn',
      body:
          '$points points have been withdrawn from your account for bill ₹${amount.toStringAsFixed(0)}.',
      data: {
        'billId': billId,
        'points': points,
        'amount': amount,
        'screen': '/bills', // Navigate to bills screen
      },
    );
  }

  /// Send tier upgraded notification
  Future<bool> sendTierUpgradedNotification({
    required String userId,
    required String newTier,
    required int points,
  }) async {
    return await sendNotification(
      userId: userId,
      type: NotificationType.tierUpgraded,
      title: '🎊 Tier Upgraded!',
      body:
          'Congratulations! You\'ve been upgraded to $newTier tier with $points points!',
      data: {
        'tier': newTier,
        'points': points,
        'screen': '/profile', // Navigate to profile screen
      },
    );
  }

  /// Send daily spin won notification
  Future<bool> sendDailySpinWonNotification({
    required String userId,
    required int points,
  }) async {
    return await sendNotification(
      userId: userId,
      type: NotificationType.dailySpinWon,
      title: '🎰 Spin Result',
      body: 'You won $points points from today\'s spin!',
      data: {
        'points': points,
        'screen': '/daily-spin', // Navigate to daily spin screen
      },
    );
  }

  /// Send offer redeemed notification
  Future<bool> sendOfferRedeemedNotification({
    required String userId,
    required String offerTitle,
    required int points,
  }) async {
    return await sendNotification(
      userId: userId,
      type: NotificationType.offerRedeemed,
      title: 'Offer Redeemed',
      body:
          'You\'ve successfully redeemed $offerTitle. $points points deducted.',
      data: {
        'offerTitle': offerTitle,
        'points': points,
        'screen': '/offers', // Navigate to offers screen
      },
    );
  }

  /// Send new offer available notification
  Future<bool> sendNewOfferNotification({
    required String userId,
    required String offerTitle,
    required int points,
  }) async {
    return await sendNotification(
      userId: userId,
      type: NotificationType.newOfferAvailable,
      title: '🎁 New Offer Available!',
      body: '$offerTitle - Redeem for $points points',
      data: {
        'offerTitle': offerTitle,
        'points': points,
        'screen': '/offers', // Navigate to offers screen
      },
    );
  }

  /// Send broadcast notification to all users (for new offers)
  /// This will queue notifications for all users with FCM tokens
  Future<int> sendBroadcastNewOfferNotification({
    required String offerTitle,
    required int points,
  }) async {
    try {
      AppLogger.info('📢 Broadcasting new offer notification: $offerTitle');

      // Get all users (carpenters only, exclude admins)
      // Note: Firestore doesn't support isNotEqualTo directly
      // We'll fetch all users and filter in code, or use a different approach
      // For better performance with many users, consider using Cloud Functions
      final usersQuery = await _firestore.collection('users').get();

      // Filter to exclude admins and users without FCM tokens
      final validUsers = usersQuery.docs.where((doc) {
        final userData = doc.data();
        final role = userData['role'] as String?;
        final fcmToken = userData['fcmToken'] as String?;
        // Include carpenters and users without role (assumed to be carpenters)
        return role != 'admin' && fcmToken != null && fcmToken.isNotEmpty;
      }).toList();

      int successCount = 0;
      int skippedCount = 0;

      // Send notification to each user
      for (final userDoc in validUsers) {
        final userId = userDoc.id;
        final userData = userDoc.data();
        final fcmToken = userData['fcmToken'] as String?;

        // Check notification preferences
        final notificationPrefs =
            userData['notificationPreferences'] as Map<String, dynamic>?;
        if (notificationPrefs != null) {
          final enabled = notificationPrefs['enabled'] as bool? ?? true;
          if (!enabled) {
            skippedCount++;
            continue;
          }

          final newOffersEnabled =
              notificationPrefs['newOffers'] as bool? ?? true;
          if (!newOffersEnabled) {
            skippedCount++;
            continue;
          }
        }

        // Queue notification for this user
        // fcmToken is guaranteed to be non-null due to filter above
        try {
          await _queueNotificationInFirestore(
            userId: userId,
            fcmToken: fcmToken!,
            type: NotificationType.newOfferAvailable,
            title: '🎁 New Offer Available!',
            body: '$offerTitle - Redeem for $points points',
            data: {
              'type': NotificationType.newOfferAvailable.name,
              'notificationId': _generateNotificationId(),
              'timestamp': FieldValue.serverTimestamp(),
              'offerTitle': offerTitle,
              'points': points,
              'screen': '/offers',
            },
          );
          successCount++;
        } catch (e) {
          AppLogger.warning(
            'Failed to queue notification for user $userId: $e',
          );
          skippedCount++;
        }
      }

      AppLogger.info(
        '📢 Broadcast complete: $successCount sent, $skippedCount skipped',
      );

      // Log broadcast analytics
      await _logNotificationAnalytics(
        type: NotificationType.newOfferAvailable.name,
        title: '🎁 New Offer Available!',
        body: '$offerTitle - Redeem for $points points',
        sentCount: successCount,
        skippedCount: skippedCount,
        isBroadcast: true,
      );

      return successCount;
    } catch (e) {
      AppLogger.error('Error broadcasting new offer notification', e);
      return 0;
    }
  }

  /// Send points milestone notification
  Future<bool> sendPointsMilestoneNotification({
    required String userId,
    required int points,
    required int milestone,
  }) async {
    return await sendNotification(
      userId: userId,
      type: NotificationType.billApproved, // Reuse existing type
      title: '🎯 Milestone Reached!',
      body: 'Congratulations! You\'ve reached $milestone points!',
      data: {
        'points': points,
        'milestone': milestone,
        'screen': '/profile', // Navigate to profile screen
      },
    );
  }

  /// Log notification analytics
  Future<void> _logNotificationAnalytics({
    required String type,
    required String title,
    required String body,
    int sentCount = 1,
    int skippedCount = 0,
    bool isBroadcast = false,
  }) async {
    try {
      await _firestore.collection('notification_logs').add({
        'type': type,
        'title': title,
        'body': body,
        'sentCount': sentCount,
        'skippedCount': skippedCount,
        'isBroadcast': isBroadcast,
        'sentAt': FieldValue.serverTimestamp(),
        'status': 'queued',
      });

      AppLogger.info('Notification analytics logged: $type');
    } catch (e) {
      AppLogger.warning('Failed to log notification analytics: $e');
      // Don't throw - analytics logging is not critical
    }
  }

  /// Send bill submitted notification
  Future<bool> sendBillSubmittedNotification({
    required String userId,
    required double amount,
  }) async {
    return await sendNotification(
      userId: userId,
      type: NotificationType.billSubmitted,
      title: 'Bill Submitted',
      body:
          'Your bill of ₹${amount.toStringAsFixed(0)} has been submitted and is pending approval.',
      data: {
        'amount': amount,
        'screen': '/bills', // Navigate to bills screen
      },
    );
  }
}
