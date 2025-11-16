import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:balaji_points/config/theme.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    // Use mock UID for demo if no user logged in
    final userId = user?.uid ?? 'demo_user_id';

    return Scaffold(
      backgroundColor: AppColors.woodenBackground,
      body: Column(
        children: [
          // Navigation Bar
          SafeArea(
            bottom: false,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.9),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.monetization_on,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Earn Points',
                          style: AppTextStyles.nunitoBold.copyWith(
                            fontSize: 20,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Track earnings & bills',
                          style: AppTextStyles.nunitoRegular.copyWith(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),

                  // Total Points Card
                  _buildTotalPointsCard(userId),

                  const SizedBox(height: 20),

                  // Stats Cards Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.pending_actions,
                          label: 'Pending',
                          value: _buildPendingCount(userId),
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.check_circle,
                          label: 'Approved',
                          value: _buildApprovedCount(userId),
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Quick Action Button
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.shade600,
                          Colors.purple.shade500,
                          AppColors.secondary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => context.push('/add-bill'),
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 20,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.add_circle_outline,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                'Add New Bill',
                                style: AppTextStyles.nunitoBold.copyWith(
                                  fontSize: 18,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Recent Bills Section
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.receipt_long,
                          color: AppColors.primary,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Recent Bills',
                        style: AppTextStyles.nunitoBold.copyWith(
                          fontSize: 20,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Bills List
                  _buildBillsList(userId),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalPointsCard(String userId) {
    if (_auth.currentUser == null) {
      // Show mock data when not logged in
      return Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.primary.withOpacity(0.85),
              AppColors.primary.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 25,
              spreadRadius: 2,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Points',
                      style: AppTextStyles.nunitoRegular.copyWith(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '1250',
                      style: AppTextStyles.nunitoBold.copyWith(
                        fontSize: 36,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Silver',
                    style: AppTextStyles.nunitoSemiBold.copyWith(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.white.withOpacity(0.9),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '1000 ₹ = 1 Point',
                    style: AppTextStyles.nunitoRegular.copyWith(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Show real data when logged in
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() as Map<String, dynamic>?;
        final totalPoints = data?['totalPoints'] ?? 0;
        final tier = data?['tier'] ?? 'Bronze';

        return Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primary.withOpacity(0.85),
                AppColors.primary.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.4),
                blurRadius: 25,
                spreadRadius: 2,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Points',
                        style: AppTextStyles.nunitoRegular.copyWith(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$totalPoints',
                        style: AppTextStyles.nunitoBold.copyWith(
                          fontSize: 36,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      tier,
                      style: AppTextStyles.nunitoSemiBold.copyWith(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.white.withOpacity(0.9),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '1000 ₹ = 1 Point',
                      style: AppTextStyles.nunitoRegular.copyWith(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required Widget value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 16),
          value,
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTextStyles.nunitoMedium.copyWith(
              fontSize: 14,
              color: AppColors.textDark.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingCount(String userId) {
    if (_auth.currentUser == null) {
      // Show mock data
      return Text(
        '3',
        style: AppTextStyles.nunitoBold.copyWith(
          fontSize: 24,
          color: AppColors.textDark,
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bills')
          .where('carpenterId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .snapshots(),
      builder: (context, snapshot) {
        final count = snapshot.hasData ? snapshot.data!.docs.length : 0;
        return Text(
          '$count',
          style: AppTextStyles.nunitoBold.copyWith(
            fontSize: 24,
            color: AppColors.textDark,
          ),
        );
      },
    );
  }

  Widget _buildApprovedCount(String userId) {
    if (_auth.currentUser == null) {
      // Show mock data
      return Text(
        '12',
        style: AppTextStyles.nunitoBold.copyWith(
          fontSize: 24,
          color: AppColors.textDark,
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bills')
          .where('carpenterId', isEqualTo: userId)
          .where('status', isEqualTo: 'approved')
          .snapshots(),
      builder: (context, snapshot) {
        final count = snapshot.hasData ? snapshot.data!.docs.length : 0;
        return Text(
          '$count',
          style: AppTextStyles.nunitoBold.copyWith(
            fontSize: 24,
            color: AppColors.textDark,
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.check_circle;
      case 'pending':
        return Icons.pending;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.receipt;
    }
  }

  Widget _buildBillsList(String userId) {
    if (_auth.currentUser == null) {
      // Show mock bills when not logged in
      final mockBills = [
        {
          'storeName': 'Sri Balaji Hardware',
          'amount': 2500.0,
          'status': 'approved',
          'pointsEarned': 2,
          'date': DateTime.now().subtract(const Duration(days: 2)),
        },
        {
          'storeName': 'K K Timber & Plywood',
          'amount': 5000.0,
          'status': 'pending',
          'pointsEarned': 0,
          'date': DateTime.now().subtract(const Duration(days: 1)),
        },
        {
          'storeName': 'Hardware Store',
          'amount': 1200.0,
          'status': 'approved',
          'pointsEarned': 1,
          'date': DateTime.now().subtract(const Duration(hours: 5)),
        },
      ];

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: mockBills.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final bill = mockBills[index];
          final amount = bill['amount'] as double;
          final status = bill['status'] as String;
          final pointsEarned = bill['pointsEarned'] as int;
          final storeName = bill['storeName'] as String;
          final date = bill['date'] as DateTime;

          return Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  spreadRadius: 0.5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getStatusIcon(status),
                    color: _getStatusColor(status),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        storeName,
                        style: AppTextStyles.nunitoBold.copyWith(
                          fontSize: 16,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '₹${amount.toStringAsFixed(0)}',
                            style: AppTextStyles.nunitoSemiBold.copyWith(
                              fontSize: 14,
                              color: AppColors.primary,
                            ),
                          ),
                          if (pointsEarned > 0) ...[
                            const SizedBox(width: 8),
                            Text(
                              '• $pointsEarned pts',
                              style: AppTextStyles.nunitoRegular.copyWith(
                                fontSize: 13,
                                color: AppColors.textDark.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(date),
                        style: AppTextStyles.nunitoRegular.copyWith(
                          fontSize: 12,
                          color: AppColors.textDark.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getStatusColor(status).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: AppTextStyles.nunitoSemiBold.copyWith(
                      fontSize: 11,
                      color: _getStatusColor(status),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    // Show real bills when logged in
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bills')
          .where('carpenterId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(10)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 64,
                  color: AppColors.textDark.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'No bills yet',
                  style: AppTextStyles.nunitoSemiBold.copyWith(
                    fontSize: 16,
                    color: AppColors.textDark.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Submit your first bill to earn points',
                  style: AppTextStyles.nunitoRegular.copyWith(
                    fontSize: 14,
                    color: AppColors.textDark.withOpacity(0.5),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final bills = snapshot.data!.docs;

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: bills.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final bill = bills[index].data() as Map<String, dynamic>;
            final amount = bill['amount'] ?? 0.0;
            final status = bill['status'] ?? 'pending';
            final pointsEarned = bill['pointsEarned'] ?? 0;
            final createdAt = bill['createdAt'] as Timestamp?;
            final storeName = bill['storeName'] ?? '';

            return Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    spreadRadius: 0.5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getStatusIcon(status),
                      color: _getStatusColor(status),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          storeName.isNotEmpty ? storeName : 'Bill',
                          style: AppTextStyles.nunitoBold.copyWith(
                            fontSize: 16,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '₹${amount.toStringAsFixed(0)}',
                              style: AppTextStyles.nunitoSemiBold.copyWith(
                                fontSize: 14,
                                color: AppColors.primary,
                              ),
                            ),
                            if (pointsEarned > 0) ...[
                              const SizedBox(width: 8),
                              Text(
                                '• $pointsEarned pts',
                                style: AppTextStyles.nunitoRegular.copyWith(
                                  fontSize: 13,
                                  color: AppColors.textDark.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (createdAt != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            _formatDate(createdAt.toDate()),
                            style: AppTextStyles.nunitoRegular.copyWith(
                              fontSize: 12,
                              color: AppColors.textDark.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getStatusColor(status).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: AppTextStyles.nunitoSemiBold.copyWith(
                        fontSize: 11,
                        color: _getStatusColor(status),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime date) {
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
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
