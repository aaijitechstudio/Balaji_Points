// lib/presentation/screens/notifications/notifications_page.dart
// Notifications screen for carpenters to view and manage their notifications

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:balaji_points/core/theme/design_token.dart';
import 'package:balaji_points/config/theme.dart' hide AppColors;
import 'package:balaji_points/services/session_service.dart';
import 'package:balaji_points/presentation/widgets/home_nav_bar.dart';
import 'dart:async';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final SessionService _sessionService = SessionService();
  String? _userId;
  bool _isLoading = true;

  // Stream controllers for merging queries
  Stream<List<QueryDocumentSnapshot>>? _mergedNotificationsStream;
  StreamController<List<QueryDocumentSnapshot>>? _streamController;
  StreamSubscription<QuerySnapshot>? _userNotificationsSubscription;
  StreamSubscription<QuerySnapshot>? _broadcastNotificationsSubscription;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final userId = await _sessionService.getUserId();
    setState(() {
      _userId = userId;
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

    // Create streams for user-specific and broadcast notifications
    final userNotificationsStream = FirebaseFirestore.instance
        .collection('notification_logs')
        .where('userId', isEqualTo: userId)
        .orderBy('sentAt', descending: true)
        .snapshots();

    final broadcastNotificationsStream = FirebaseFirestore.instance
        .collection('notification_logs')
        .where('isBroadcast', isEqualTo: true)
        .orderBy('sentAt', descending: true)
        .snapshots();

    // Merge both streams manually using StreamController
    // Use broadcast stream to allow multiple listeners (StreamBuilder may rebuild)
    _streamController =
        StreamController<List<QueryDocumentSnapshot>>.broadcast();
    final Map<String, QueryDocumentSnapshot> combined = {};

    void updateCombined() {
      final List<QueryDocumentSnapshot> result = combined.values.toList();
      result.sort((a, b) {
        final aData = a.data() as Map<String, dynamic>;
        final bData = b.data() as Map<String, dynamic>;
        final aSentAt = aData['sentAt'] as Timestamp?;
        final bSentAt = bData['sentAt'] as Timestamp?;

        if (aSentAt == null && bSentAt == null) return 0;
        if (aSentAt == null) return 1;
        if (bSentAt == null) return -1;

        return bSentAt.compareTo(aSentAt); // Descending order
      });

      if (!_streamController!.isClosed) {
        _streamController!.add(result);
      }
    }

    // Listen to user notifications
    _userNotificationsSubscription = userNotificationsStream.listen((snapshot) {
      // Update combined map with user notifications
      for (var doc in snapshot.docs) {
        combined[doc.id] = doc;
      }
      updateCombined();
    });

    // Listen to broadcast notifications
    _broadcastNotificationsSubscription = broadcastNotificationsStream.listen((
      snapshot,
    ) {
      // Update combined map with broadcast notifications
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.delete_outline,
                color: Colors.red.shade700,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Delete All Notifications',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete all notifications? This action cannot be undone.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Delete All', style: TextStyle(fontSize: 16)),
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

      // Get all notifications for this user (both user-specific and broadcast)
      // We need to get user-specific notifications and broadcast notifications separately
      // since Firestore doesn't support OR queries
      final userSnapshot = await FirebaseFirestore.instance
          .collection('notification_logs')
          .where('userId', isEqualTo: _userId)
          .get();

      final broadcastSnapshot = await FirebaseFirestore.instance
          .collection('notification_logs')
          .where('isBroadcast', isEqualTo: true)
          .get();

      // Combine both snapshots
      final allDocs = <QueryDocumentSnapshot>[];
      allDocs.addAll(userSnapshot.docs);
      allDocs.addAll(broadcastSnapshot.docs);

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
            icon: const Icon(Icons.arrow_back, color: Colors.white),
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
          HomeNavBar(
            title: 'Notifications',
            showProfileButton: false,
            showLogo: false,
            showBackButton: true,
            actions: [
              // Delete All Button
              StreamBuilder<List<QueryDocumentSnapshot>>(
                stream: _mergedNotificationsStream,
                builder: (context, snapshot) {
                  final hasNotifications =
                      snapshot.hasData && snapshot.data!.isNotEmpty;

                  if (!hasNotifications) {
                    return const SizedBox(width: 44);
                  }

                  return IconButton(
                    icon: Stack(
                      children: [
                        const Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                          size: 24,
                        ),
                        if (hasNotifications)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
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
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Error loading notifications',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
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
                                  padding: const EdgeInsets.all(24),
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
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'No Notifications',
                                  style: AppTextStyles.nunitoBold.copyWith(
                                    fontSize: 24,
                                    color: DesignToken.textDark,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'You don\'t have any notifications yet',
                                  style: AppTextStyles.nunitoRegular.copyWith(
                                    fontSize: 16,
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
                            padding: const EdgeInsets.all(16),
                            itemCount: notifications.length,
                            itemBuilder: (context, index) {
                              final doc = notifications[index];
                              final data = doc.data() as Map<String, dynamic>;

                              final type = data['type'] as String?;
                              final title =
                                  data['title'] as String? ?? 'Notification';
                              final body = data['body'] as String? ?? '';
                              final sentAt = data['sentAt'] as Timestamp?;
                              final delivered =
                                  data['delivered'] as bool? ?? true;

                              return Dismissible(
                                key: Key(doc.id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                    size: 28,
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
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
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
                                                    Colors.red.shade600,
                                                foregroundColor: Colors.white,
                                              ),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      ) ??
                                      false;
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: DesignToken.primary.withValues(
                                        alpha: 0.1,
                                      ),
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.05,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Icon
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: _getNotificationColor(
                                            type,
                                          ).withValues(alpha: 0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          _getNotificationIcon(type),
                                          color: _getNotificationColor(type),
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      // Content
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    title,
                                                    style: AppTextStyles
                                                        .nunitoBold
                                                        .copyWith(
                                                          fontSize: 16,
                                                          color: DesignToken
                                                              .textDark,
                                                        ),
                                                  ),
                                                ),
                                                if (!delivered)
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 6,
                                                          vertical: 2,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Colors
                                                          .orange
                                                          .shade100,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            4,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      'Failed',
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors
                                                            .orange
                                                            .shade800,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              body,
                                              style: AppTextStyles.nunitoRegular
                                                  .copyWith(
                                                    fontSize: 14,
                                                    color: Colors.grey[700],
                                                  ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              _formatTimestamp(sentAt),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[500],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Delete button
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete_outline,
                                          color: Colors.grey[400],
                                          size: 20,
                                        ),
                                        onPressed: () =>
                                            _deleteNotification(doc.id),
                                        tooltip: 'Delete',
                                      ),
                                    ],
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
        ],
      ),
    );
  }
}
