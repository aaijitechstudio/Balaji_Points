// lib/features/notifications/presentation/pages/notifications_page.dart
// Notifications screen for carpenters to view and manage their notifications

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:balaji_points/core/theme/design_token.dart';
import 'package:balaji_points/core/widgets/navigation/unified_app_bar.dart';
import 'package:balaji_points/config/theme.dart' hide AppColors;
import 'package:balaji_points/services/session_service.dart';
import 'dart:async';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final SessionService _sessionService = SessionService();
  String? _userId;
  String? _userRole;
  bool _isLoading = true;

  // Stream controllers for merging queries
  Stream<List<QueryDocumentSnapshot>>? _mergedNotificationsStream;
  StreamController<List<QueryDocumentSnapshot>>? _streamController;
  StreamSubscription<QuerySnapshot>? _userNotificationsSubscription;
  StreamSubscription<QuerySnapshot>? _broadcastNotificationsSubscription;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userId = await _sessionService.getUserId();
    final userRole = await _sessionService.getUserRole();
    setState(() {
      _userId = userId;
      _userRole = userRole;
      _isLoading = false;
    });

    // Create merged stream after userId is loaded
    if (userId != null) {
      _createMergedStream(userId);
    }
  }

  void _createMergedStream(String userId) {
    // Clean up existing subscriptions
    _userNotificationsSubscription?.cancel();
    _broadcastNotificationsSubscription?.cancel();
    _streamController?.close();

    debugPrint(
      '🔔 Creating notification stream for user: $userId (Role: $_userRole)',
    );

    // For carpenters: merge personal notifications + broadcast notifications
    // For admins: only admin-specific notifications
    if (_userRole != 'admin') {
      // CARPENTERS: Show personal + broadcast notifications
      // Need to merge two streams: personal notifications + broadcast notifications
      _createCarpenterMergedStream(userId);
      return;
    }

    // ADMINS: Only show admin-specific notifications
    final notificationsQuery = FirebaseFirestore.instance
        .collection('notification_logs')
        .where('userId', isEqualTo: userId)
        .orderBy('sentAt', descending: true)
        .limit(50);

    debugPrint(
      '✅ Admin Query: WHERE userId = $userId, ORDER BY sentAt DESC, LIMIT 50',
    );

    // Use broadcast stream to allow multiple listeners (StreamBuilder may rebuild)
    _streamController =
        StreamController<List<QueryDocumentSnapshot>>.broadcast();

    // Single stream - filter only carpenter-relevant notifications
    _userNotificationsSubscription = notificationsQuery.snapshots().listen((
      snapshot,
    ) {
      debugPrint(
        '📊 Received ${snapshot.docs.length} notifications from Firestore',
      );

      // SAFETY CHECK: Verify all notifications belong to this user
      if (snapshot.docs.isNotEmpty) {
        final firstDoc = snapshot.docs.first.data();
        final firstUserId = firstDoc['userId'];
        debugPrint(
          '   ✓ First notification userId: $firstUserId (Expected: $userId)',
        );

        // Double-check: filter out any notifications that don't belong to this user
        // (This should never happen due to Firestore query, but extra safety)
        final userNotifications = snapshot.docs.where((doc) {
          final data = doc.data();
          return data['userId'] == userId;
        }).toList();

        if (userNotifications.length != snapshot.docs.length) {
          debugPrint(
            '   ⚠️ WARNING: Filtered out ${snapshot.docs.length - userNotifications.length} notifications from other users!',
          );
        }
      }

      // Filter notifications based on user role
      List<QueryDocumentSnapshot> filteredDocs = snapshot.docs;

      if (_userRole == 'admin') {
        // Admins: show only admin-specific notifications
        filteredDocs = snapshot.docs.where((doc) {
          final data = doc.data();
          final type = data['type'] as String?;

          // Admin sees only these notification types
          const adminNotificationTypes = [
            'newPendingBill', // New bill to review
            'newUserRegistered', // New carpenter registered
            'dailySpinReminder', // Daily spin reminder (analytics)
          ];
          return adminNotificationTypes.contains(type);
        }).toList();

        debugPrint(
          '📊 After filtering: ${filteredDocs.length} admin notifications',
        );
      } else {
        // Carpenters: hide admin-only notifications + ensure user isolation
        filteredDocs = snapshot.docs.where((doc) {
          final data = doc.data();
          final type = data['type'] as String?;
          final notifUserId = data['userId'] as String?;

          // SAFETY: Ensure this notification belongs to THIS carpenter
          if (notifUserId != userId) {
            debugPrint(
              '   ⚠️ Skipping notification for different user: $notifUserId',
            );
            return false;
          }

          // Carpenter should NOT see these admin-only types
          const adminOnlyTypes = [
            'dailySpinReminder',
            'newPendingBill',
            'newUserRegistered',
          ];
          return !adminOnlyTypes.contains(type);
        }).toList();

        debugPrint(
          '📊 After filtering: ${filteredDocs.length} carpenter notifications (all for userId: $userId)',
        );
      }

      if (!_streamController!.isClosed) {
        _streamController!.add(filteredDocs);
      }
    });

    _mergedNotificationsStream = _streamController!.stream;

    setState(() {}); // Trigger rebuild with new stream
  }

  /// Create merged stream for carpenters (personal + broadcast notifications)
  void _createCarpenterMergedStream(String userId) {
    debugPrint('🔔 Creating CARPENTER notification stream with broadcasts');

    // Use broadcast stream to allow multiple listeners
    _streamController =
        StreamController<List<QueryDocumentSnapshot>>.broadcast();
    final Map<String, QueryDocumentSnapshot> combined = {};

    void updateCombined() {
      List<QueryDocumentSnapshot> result = combined.values.toList();

      // Filter out admin-only notifications
      result = result.where((doc) {
        final data = doc.data() as Map<String, dynamic>?;
        final type = data?['type'] as String?;

        // Carpenter should NOT see these admin-only types
        const adminOnlyTypes = [
          'dailySpinReminder', // Admin analytics
          'newPendingBill', // Admin notification
          'newUserRegistered', // Admin notification
        ];
        return !adminOnlyTypes.contains(type);
      }).toList();

      // DEDUPLICATION: Remove duplicate notifications based on unique key
      // Key = type + billId/data combination + approximate time
      final seen = <String>{};
      result = result.where((doc) {
        final data = doc.data() as Map<String, dynamic>?;
        final type = data?['type'] as String?;
        final notifData = data?['data'] as Map<String, dynamic>?;
        final billId = notifData?['billId'] as String?;
        final sentAt = data?['sentAt'] as Timestamp?;

        // Create unique key: type + billId + hour (to allow same bill notifications hours apart)
        final hourKey = sentAt != null
            ? '${sentAt.toDate().year}-${sentAt.toDate().month}-${sentAt.toDate().day}-${sentAt.toDate().hour}'
            : 'unknown';
        final uniqueKey = '$type-${billId ?? 'none'}-$hourKey';

        if (seen.contains(uniqueKey)) {
          debugPrint('   🔄 Skipping duplicate notification: $uniqueKey');
          return false; // Skip duplicate
        }
        seen.add(uniqueKey);
        return true;
      }).toList();

      // Sort by timestamp
      result.sort((a, b) {
        final aData = a.data() as Map<String, dynamic>?;
        final bData = b.data() as Map<String, dynamic>?;
        final aSentAt = aData?['sentAt'] as Timestamp?;
        final bSentAt = bData?['sentAt'] as Timestamp?;

        if (aSentAt == null && bSentAt == null) return 0;
        if (aSentAt == null) return 1;
        if (bSentAt == null) return -1;

        return bSentAt.compareTo(aSentAt); // Descending order
      });

      // Limit to 50 most recent
      if (result.length > 50) {
        result = result.sublist(0, 50);
      }

      debugPrint(
        '📊 Combined stream: ${result.length} carpenter notifications',
      );

      if (!_streamController!.isClosed) {
        _streamController!.add(result);
      }
    }

    // Stream 1: Personal notifications (bills, points, tier upgrades, etc.)
    final personalQuery = FirebaseFirestore.instance
        .collection('notification_logs')
        .where('userId', isEqualTo: userId)
        .orderBy('sentAt', descending: true)
        .limit(30); // Limit personal to 30

    debugPrint('   Stream 1: Personal notifications WHERE userId = $userId');

    _userNotificationsSubscription = personalQuery.snapshots().listen((
      snapshot,
    ) {
      // Add/update personal notifications
      for (var doc in snapshot.docs) {
        combined[doc.id] = doc;
      }
      updateCombined();
    });

    // Stream 2: Broadcast notifications (new offers, daily spin winners)
    final broadcastQuery = FirebaseFirestore.instance
        .collection('notification_logs')
        .where('isBroadcast', isEqualTo: true)
        .orderBy('sentAt', descending: true)
        .limit(20); // Limit broadcasts to 20

    debugPrint('   Stream 2: Broadcast notifications WHERE isBroadcast = true');

    _broadcastNotificationsSubscription = broadcastQuery.snapshots().listen((
      snapshot,
    ) {
      // Add/update broadcast notifications
      for (var doc in snapshot.docs) {
        combined[doc.id] = doc;
      }
      updateCombined();
    });

    _mergedNotificationsStream = _streamController!.stream;
    setState(() {}); // Trigger rebuild with new stream
  }

  @override
  void dispose() {
    _userNotificationsSubscription?.cancel();
    _broadcastNotificationsSubscription?.cancel();
    _streamController?.close();
    super.dispose();
  }

  Future<void> _deleteNotification(String notificationId) async {
    try {
      await FirebaseFirestore.instance
          .collection('notification_logs')
          .doc(notificationId)
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Notification deleted'),
            backgroundColor: DesignToken.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error deleting notification: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting notification: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _deleteAllNotifications() async {
    if (_userId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: DesignToken.borderRadiusXL),
        title: Row(
          children: [
            Container(
              padding: DesignToken.paddingAllSM,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.delete_outline,
                color: Colors.red.shade700,
                size: 24,
                semanticLabel: 'Delete all notifications',
              ),
            ),
            SizedBox(width: DesignToken.widthMD),
            const Expanded(
              child: Text(
                'Delete All Notifications',
                style: TextStyle(fontSize: DesignToken.fontSizeXL, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete all notifications? This action cannot be undone.',
          style: TextStyle(fontSize: DesignToken.fontSizeLG),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[600], fontSize: DesignToken.fontSizeLG),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: DesignToken.borderRadiusMD,
              ),
            ),
            child: const Text('Delete All', style: TextStyle(fontSize: DesignToken.fontSizeLG)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // Show loading indicator
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );
      }

      // Get user-specific notifications
      final userSnapshot = await FirebaseFirestore.instance
          .collection('notification_logs')
          .where('userId', isEqualTo: _userId)
          .get();

      // Combine notifications based on role
      final allDocs = <QueryDocumentSnapshot>[];
      allDocs.addAll(userSnapshot.docs);

      // Only admins can delete broadcast notification logs
      if (_userRole == 'admin') {
        final broadcastSnapshot = await FirebaseFirestore.instance
            .collection('notification_logs')
            .where('isBroadcast', isEqualTo: true)
            .get();
        allDocs.addAll(broadcastSnapshot.docs);
      }

      // Remove duplicates by document ID
      final uniqueDocs = <String, QueryDocumentSnapshot>{};
      for (var doc in allDocs) {
        uniqueDocs[doc.id] = doc;
      }

      final snapshot = uniqueDocs.values.toList();

      // Delete all notifications in batch
      final batch = FirebaseFirestore.instance.batch();
      for (var doc in snapshot) {
        // Get the document reference
        final docRef = doc.reference;
        batch.delete(docRef);
      }
      await batch.commit();

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${snapshot.length} notification(s) deleted'),
            backgroundColor: DesignToken.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error deleting all notifications: $e');

      // Close loading dialog if still open
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting notifications: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Just now';

    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }

  IconData _getNotificationIcon(String? type) {
    switch (type) {
      case 'billApproved':
        return Icons.check_circle;
      case 'billRejected':
        return Icons.cancel;
      case 'pointsWithdrawn':
        return Icons.remove_circle;
      case 'tierUpgraded':
        return Icons.trending_up;
      case 'dailySpinWon':
        return Icons.casino;
      case 'offerRedeemed':
        return Icons.card_giftcard;
      case 'newOfferAvailable':
        return Icons.notifications_active;
      case 'pointsMilestone':
        return Icons.emoji_events;
      // Admin notification types
      case 'newPendingBill':
        return Icons.receipt_long;
      case 'newUserRegistered':
        return Icons.person_add;
      case 'dailySpinReminder':
        return Icons.casino;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String? type) {
    switch (type) {
      case 'billApproved':
        return Colors.green;
      case 'billRejected':
        return Colors.red;
      case 'pointsWithdrawn':
        return Colors.orange;
      case 'tierUpgraded':
        return Colors.purple;
      case 'dailySpinWon':
        return Colors.amber;
      case 'offerRedeemed':
        return Colors.blue;
      case 'newOfferAvailable':
        return DesignToken.primary;
      case 'pointsMilestone':
        return Colors.amber.shade700;
      // Admin notification types
      case 'newPendingBill':
        return Colors.blue.shade600;
      case 'newUserRegistered':
        return Colors.teal;
      case 'dailySpinReminder':
        return Colors.amber.shade600;
      default:
        return DesignToken.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: DesignToken.primary,
        body: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (_userId == null) {
      return Scaffold(
        backgroundColor: DesignToken.primary,
        appBar: AppBar(
          backgroundColor: DesignToken.primary,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, semanticLabel: 'Go back'),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            'Notifications',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: const Center(child: Text('Unable to load notifications')),
      );
    }

    return Scaffold(
      backgroundColor: DesignToken.primary,
      body: Column(
        children: [
          UnifiedAppBar(
            title: 'Notifications',
            showProfileButton: false,
            backgroundColor: DesignToken.primary,
            iconColor: DesignToken.white,
            textColor: DesignToken.white,
            actions: [
              // Delete All Button
              StreamBuilder<List<QueryDocumentSnapshot>>(
                stream: _mergedNotificationsStream,
                builder: (context, snapshot) {
                  final hasNotifications =
                      snapshot.hasData && snapshot.data!.isNotEmpty;

                  if (!hasNotifications) {
                    return const SizedBox(width: DesignToken.height4XL);
                  }

                  return IconButton(
                    icon: Stack(
                      children: [
                        const Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                          size: 24,
                          semanticLabel: 'Delete all notifications',
                        ),
                        if (hasNotifications)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: DesignToken.paddingAllXS,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 8,
                                minHeight: 8,
                              ),
                            ),
                          ),
                      ],
                    ),
                    onPressed: _deleteAllNotifications,
                    tooltip: 'Delete All',
                  );
                },
              ),
            ],
          ),
          Expanded(
            child: Container(
              color: DesignToken.woodenBackground,
              child: SafeArea(
                top: false,
                child: _mergedNotificationsStream == null
                    ? const Center(child: CircularProgressIndicator())
                    : StreamBuilder<List<QueryDocumentSnapshot>>(
                        stream: _mergedNotificationsStream,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (snapshot.hasError) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 64,
                                    color: Colors.red.shade300,
                                    semanticLabel: 'Error',
                                  ),
                                  SizedBox(height: DesignToken.heightLG),
                                  Text(
                                    'Error loading notifications',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: DesignToken.fontSizeLG,
                                    ),
                                  ),
                                  SizedBox(height: DesignToken.heightSM),
                                  TextButton(
                                    onPressed: () => setState(() {}),
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            );
                          }

                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: DesignToken.paddingAll2XL,
                                    decoration: BoxDecoration(
                                      color: DesignToken.primary.withValues(
                                        alpha: 0.1,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.notifications_none,
                                      size: 64,
                                      color: DesignToken.primary.withValues(
                                        alpha: 0.5,
                                      ),
                                      semanticLabel: 'No notifications',
                                    ),
                                  ),
                                  SizedBox(height: DesignToken.height2XL),
                                  Text(
                                    'No Notifications',
                                    style: AppTextStyles.nunitoBold.copyWith(
                                      fontSize: DesignToken.fontSize3XL,
                                      color: DesignToken.textDark,
                                    ),
                                  ),
                                  SizedBox(height: DesignToken.heightSM),
                                  Text(
                                    'You don\'t have any notifications yet',
                                    style: AppTextStyles.nunitoRegular.copyWith(
                                      fontSize: DesignToken.fontSizeLG,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          final notifications = snapshot.data!;

                          return RefreshIndicator(
                            onRefresh: () async {
                              // Refresh is handled by StreamBuilder
                              await Future.delayed(
                                const Duration(milliseconds: 500),
                              );
                            },
                            color: DesignToken.primary,
                            child: ListView.builder(
                              padding: DesignToken.paddingAllLG,
                              itemCount: notifications.length,
                              itemBuilder: (context, index) {
                                final doc = notifications[index];
                                final data = doc.data() as Map<String, dynamic>;

                                final type = data['type'] as String?;
                                final title =
                                    data['title'] as String? ?? 'Notification';
                                final body = data['body'] as String? ?? '';
                                final sentAt = data['sentAt'] as Timestamp?;
                                final notificationColor = _getNotificationColor(
                                  type,
                                );

                                return Dismissible(
                                  key: Key(doc.id),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    margin: const EdgeInsets.only(bottom: DesignToken.paddingMD),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade400,
                                      borderRadius: DesignToken.borderRadiusLG,
                                    ),
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: DesignToken.padding2XL),
                                    child: const Icon(
                                      Icons.delete_rounded,
                                      color: Colors.white,
                                      size: 26,
                                      semanticLabel: 'Delete notification',
                                    ),
                                  ),
                                  onDismissed: (direction) {
                                    _deleteNotification(doc.id);
                                  },
                                  confirmDismiss: (direction) async {
                                    return await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  DesignToken.borderRadiusLG,
                                            ),
                                            title: const Text(
                                              'Delete Notification',
                                            ),
                                            content: const Text(
                                              'Are you sure you want to delete this notification?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.of(
                                                  context,
                                                ).pop(false),
                                                child: Text(
                                                  'Cancel',
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ),
                                              ElevatedButton(
                                                onPressed: () => Navigator.of(
                                                  context,
                                                ).pop(true),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.red.shade500,
                                                  foregroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                ),
                                                child: const Text('Delete'),
                                              ),
                                            ],
                                          ),
                                        ) ??
                                        false;
                                  },
                                  // Modern iOS-style notification card
                                  child: InkWell(
                                    onTap: () =>
                                        _handleNotificationTap(data, type),
                                    borderRadius: DesignToken.borderRadiusMD,
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: DesignToken.paddingMD),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: DesignToken.borderRadiusMD,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.04,
                                            ),
                                            blurRadius: 10,
                                            offset: const Offset(0, 2),
                                          ),
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.02,
                                            ),
                                            blurRadius: 4,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: DesignToken.borderRadiusMD,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border(
                                              left: BorderSide(
                                                color: notificationColor,
                                                width: 4,
                                              ),
                                            ),
                                          ),
                                          child: Padding(
                                            padding: DesignToken.paddingAllMD,
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // Icon with gradient background
                                                Container(
                                                  width: 44,
                                                  height: 44,
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                      colors: [
                                                        notificationColor
                                                            .withValues(
                                                              alpha: 0.2,
                                                            ),
                                                        notificationColor
                                                            .withValues(
                                                              alpha: 0.1,
                                                            ),
                                                      ],
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: Icon(
                                                    _getNotificationIcon(type),
                                                    color: notificationColor,
                                                    size: 22,
                                                    semanticLabel: 'Notification icon',
                                                  ),
                                                ),
                                                SizedBox(width: DesignToken.widthMD),
                                                // Content
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      // Title and time row
                                                      Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              title,
                                                              style: AppTextStyles
                                                                  .nunitoBold
                                                                  .copyWith(
                                                                    fontSize:
                                                                        15,
                                                                    color: DesignToken
                                                                        .textDark,
                                                                    letterSpacing:
                                                                        -0.2,
                                                                  ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 8,
                                                          ),
                                                          Text(
                                                            _formatTimestamp(
                                                              sentAt,
                                                            ),
                                                            style: TextStyle(
                                                              fontSize: DesignToken.fontSizeSM,
                                                              color: Colors
                                                                  .grey[400],
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: DesignToken.heightXS),
                                                      // Body text
                                                      Text(
                                                        body,
                                                        style: AppTextStyles
                                                            .nunitoRegular
                                                            .copyWith(
                                                              fontSize: DesignToken.fontSizeMD,
                                                              color: Colors
                                                                  .grey[600],
                                                              height: 1.3,
                                                            ),
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Handle notification tap - navigate based on notification type and role
  void _handleNotificationTap(Map<String, dynamic> data, String? type) {
    try {
      // Get screen route from notification data
      final screen = data['screen'] as String?;

      // If no screen specified, stay on notifications page
      if (screen == null || screen.isEmpty) {
        return;
      }

      // Navigate based on notification type and role
      if (_userRole == 'admin') {
        // Admin navigation
        switch (type) {
          case 'newPendingBill':
            // Navigate to admin home with pending bills tab
            context.go('/admin');
            break;
          case 'newUserRegistered':
            // Navigate to admin home with users tab
            context.go('/admin');
            break;
          default:
            // Use screen from data
            if (screen == '/admin' || screen == '/notifications') {
              context.go(screen);
            } else {
              // For other screens, navigate to admin home
              context.go('/admin');
            }
        }
      } else {
        // Carpenter navigation
        switch (type) {
          case 'billApproved':
          case 'billRejected':
          case 'pointsWithdrawn':
          case 'billSubmitted':
            // Navigate to home (bills are shown there)
            context.go('/');
            break;
          case 'tierUpgraded':
          case 'pointsMilestone':
            // Navigate to profile
            context.go('/profile');
            break;
          case 'dailySpinWon':
            // Navigate to daily spin
            context.go('/daily-spin');
            break;
          case 'offerRedeemed':
          case 'newOfferAvailable':
            // Navigate to home (offers are shown there)
            context.go('/');
            break;
          default:
            // Use screen from data, fallback to home
            if (screen == '/notifications') {
              // Already on notifications page
              return;
            } else if (screen == '/profile' || screen == '/daily-spin') {
              context.go(screen);
            } else {
              // Default to home
              context.go('/');
            }
        }
      }
    } catch (e) {
      debugPrint('Error navigating from notification: $e');
      // On error, stay on notifications page
    }
  }
}
