import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:balaji_points/l10n/app_localizations.dart';
import 'package:balaji_points/core/theme/design_token.dart';
import 'package:balaji_points/core/widgets/navigation/unified_app_bar.dart';
import 'package:balaji_points/config/theme.dart' hide AppColors;
import 'package:balaji_points/services/session_service.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final SessionService _sessionService = SessionService();
  int _refreshKey = 0;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final phoneNumber = await _sessionService.getPhoneNumber();
    if (mounted) {
      setState(() {
        _userId = phoneNumber;
      });
    }
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _refreshKey++; // Force rebuild of StreamBuilders
    });
    // Add a small delay to show the refresh indicator
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Use phone number from session (PIN-based auth)
    final userId = _userId ?? 'loading';

    return Scaffold(
      backgroundColor: DesignToken.primary,
      body: Column(
        children: [
          // Standard Navigation Bar - Material Design kToolbarHeight (56dp)
          UnifiedAppBar(
            title: l10n.wallet,
            backgroundColor: DesignToken.primary,
            iconColor: DesignToken.white,
            textColor: DesignToken.white,
            showProfileButton: false,
          ),
          // Content with wooden background
          Expanded(
            child: Container(
              color: DesignToken.woodenBackground,
              child: RefreshIndicator(
                key: ValueKey(_refreshKey),
                onRefresh: _handleRefresh,
                color: DesignToken.primary,
                backgroundColor: DesignToken.white,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: DesignToken.paddingAllXL,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: DesignToken.heightSM),

                      // Total Points Card
                      _buildTotalPointsCard(userId),

                      SizedBox(height: DesignToken.heightXL),

                      // Stats Cards Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.pending_actions,
                              label: l10n.pending,
                              value: _buildPendingCount(userId),
                              color: DesignToken.orange,
                            ),
                          ),
                          SizedBox(width: DesignToken.widthMD),
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.check_circle,
                              label: l10n.approved,
                              value: _buildApprovedCount(userId),
                              color: DesignToken.success,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: DesignToken.heightXL),

                      // Quick Action Button
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              DesignToken.blue600,
                              Colors.purple.shade500,
                              DesignToken.secondary,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: DesignToken.borderRadiusXL,
                          boxShadow: [
                            BoxShadow(
                              color: DesignToken.secondary.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Material(
                          color: DesignToken.transparent,
                          child: InkWell(
                            onTap: () => context.push('/add-bill'),
                            borderRadius: DesignToken.borderRadiusXL,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 20,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: DesignToken.paddingAllSM,
                                    decoration: BoxDecoration(
                                      color: DesignToken.white.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.add_circle_outline,
                                      color: DesignToken.white,
                                      size: 28,
                                      semanticLabel: 'Add new bill',
                                    ),
                                  ),
                                  SizedBox(width: DesignToken.widthLG),
                                  Text(
                                    l10n.addNewBill,
                                    style: AppTextStyles.nunitoBold.copyWith(
                                      fontSize: DesignToken.fontSizeXL,
                                      color: DesignToken.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: DesignToken.height2XL),

                      // Recent Bills Section
                      Row(
                        children: [
                          Container(
                            padding: DesignToken.paddingAllSM,
                            decoration: BoxDecoration(
                              color: DesignToken.primary.withOpacity(0.1),
                              borderRadius: DesignToken.borderRadiusSM,
                            ),
                            child: Icon(
                              Icons.receipt_long,
                              color: DesignToken.primary,
                              size: 18,
                              semanticLabel: 'Recent bills',
                            ),
                          ),
                          SizedBox(width: DesignToken.widthMD),
                          Text(
                            l10n.recentBills,
                            style: AppTextStyles.nunitoBold.copyWith(
                              fontSize: DesignToken.fontSize2XL,
                              color: DesignToken.textDark,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: DesignToken.heightLG),

                      // Bills List
                      _buildBillsList(userId),

                      SizedBox(height: DesignToken.heightXL),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalPointsCard(String userId) {
    final l10n = AppLocalizations.of(context)!;
    if (userId == 'loading' || _userId == null) {
      // Show loading state
      return Container(
        padding: DesignToken.paddingAll2XL,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              DesignToken.primary,
              DesignToken.primary.withOpacity(0.85),
              DesignToken.primary.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: DesignToken.borderRadius2XL,
          boxShadow: [
            BoxShadow(
              color: DesignToken.primary.withOpacity(0.4),
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
                        fontSize: DesignToken.fontSizeMD,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    SizedBox(height: DesignToken.heightSM),
                    Text(
                      '',
                      style: AppTextStyles.nunitoBold.copyWith(
                        fontSize: DesignToken.fontSize5XL,
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
                    borderRadius: DesignToken.borderRadiusXL,
                  ),
                  child: Text(
                    'Silver',
                    style: AppTextStyles.nunitoSemiBold.copyWith(
                      fontSize: DesignToken.fontSizeMD,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: DesignToken.heightXL),
            Container(
              padding: DesignToken.paddingAllMD,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: DesignToken.borderRadiusMD,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.white.withOpacity(0.9),
                    size: 18,
                    semanticLabel: 'Information',
                  ),
                  SizedBox(width: DesignToken.widthSM),
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
          padding: DesignToken.paddingAll2XL,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                DesignToken.primary,
                DesignToken.primary.withOpacity(0.85),
                DesignToken.primary.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: DesignToken.borderRadius2XL,
            boxShadow: [
              BoxShadow(
                color: DesignToken.primary.withOpacity(0.4),
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
                        l10n.totalPoints,
                        style: AppTextStyles.nunitoRegular.copyWith(
                          fontSize: DesignToken.fontSizeMD,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      SizedBox(height: DesignToken.heightSM),
                      Text(
                        '$totalPoints',
                        style: AppTextStyles.nunitoBold.copyWith(
                          fontSize: DesignToken.fontSize5XL,
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
                      borderRadius: DesignToken.borderRadiusXL,
                    ),
                    child: Text(
                      tier,
                      style: AppTextStyles.nunitoSemiBold.copyWith(
                        fontSize: DesignToken.fontSizeMD,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: DesignToken.heightXL),
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
      padding: DesignToken.paddingAllXL,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: DesignToken.borderRadiusXL,
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
            padding: DesignToken.paddingAllMD,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: DesignToken.borderRadiusMD,
            ),
            child: Icon(icon, color: color, size: 26, semanticLabel: label),
          ),
          SizedBox(height: DesignToken.heightLG),
          value,
          SizedBox(height: DesignToken.heightSM),
          Text(
            label,
            style: AppTextStyles.nunitoMedium.copyWith(
              fontSize: DesignToken.fontSizeMD,
              color: DesignToken.textDark.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingCount(String userId) {
    if (userId == 'loading' || _userId == null) {
      // Show loading state
      return Text(
        '...',
        style: AppTextStyles.nunitoBold.copyWith(
          fontSize: DesignToken.fontSize3XL,
          color: DesignToken.textDark,
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
            fontSize: DesignToken.fontSize3XL,
            color: DesignToken.textDark,
          ),
        );
      },
    );
  }

  Widget _buildApprovedCount(String userId) {
    if (userId == 'loading' || _userId == null) {
      // Show loading state
      return Text(
        '...',
        style: AppTextStyles.nunitoBold.copyWith(
          fontSize: DesignToken.fontSize3XL,
          color: DesignToken.textDark,
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
            fontSize: DesignToken.fontSize3XL,
            color: DesignToken.textDark,
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

  String _getStatusLabel(String status, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (status.toLowerCase()) {
      case 'approved':
        return l10n.statusApproved;
      case 'pending':
        return l10n.statusPending;
      case 'rejected':
        return l10n.statusRejected;
      default:
        return status.toUpperCase();
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
    if (userId == 'loading' || _userId == null) {
      // Show loading state
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
        separatorBuilder: (context, index) => SizedBox(height: DesignToken.heightMD),
        itemBuilder: (context, index) {
          final bill = mockBills[index];
          final amount = bill['amount'] as double;
          final status = bill['status'] as String;
          final pointsEarned = bill['pointsEarned'] as int;
          final storeName = bill['storeName'] as String;
          final date = bill['date'] as DateTime;

          return Container(
            padding: DesignToken.paddingAllLG,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: DesignToken.borderRadiusLG,
              border: Border.all(
                color: DesignToken.primary.withOpacity(0.1),
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
                    borderRadius: DesignToken.borderRadiusMD,
                  ),
                  child: Icon(
                    _getStatusIcon(status),
                    color: _getStatusColor(status),
                    size: 24,
                    semanticLabel: 'Bill status: $status',
                  ),
                ),
                SizedBox(width: DesignToken.widthLG),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        storeName,
                        style: AppTextStyles.nunitoBold.copyWith(
                          fontSize: DesignToken.fontSizeLG,
                          color: DesignToken.textDark,
                        ),
                      ),
                      SizedBox(height: DesignToken.heightXS),
                      Row(
                        children: [
                          Text(
                            '₹${amount.toStringAsFixed(0)}',
                            style: AppTextStyles.nunitoSemiBold.copyWith(
                              fontSize: DesignToken.fontSizeMD,
                              color: DesignToken.primary,
                            ),
                          ),
                          if (pointsEarned > 0) ...[
                            SizedBox(width: DesignToken.widthSM),
                            Text(
                              '• $pointsEarned pts',
                              style: AppTextStyles.nunitoRegular.copyWith(
                                fontSize: DesignToken.fontSizeMD,
                                color: DesignToken.textDark.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: DesignToken.heightXS),
                      Text(
                        _formatDate(date),
                        style: AppTextStyles.nunitoRegular.copyWith(
                          fontSize: DesignToken.fontSizeSM,
                          color: DesignToken.textDark.withOpacity(0.5),
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
                    borderRadius: DesignToken.borderRadiusMD,
                    border: Border.all(
                      color: _getStatusColor(status).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    _getStatusLabel(status, context),
                    style: AppTextStyles.nunitoSemiBold.copyWith(
                      fontSize: DesignToken.fontSizeSM,
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
    debugPrint('WalletPage: === LOADING BILLS ===');
    debugPrint('  User ID (carpenterId): $userId');

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bills')
          .where('carpenterId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(10)
          .snapshots(),
      builder: (context, snapshot) {
        debugPrint(
          'WalletPage: StreamBuilder state: ${snapshot.connectionState}',
        );
        debugPrint('  Has data: ${snapshot.hasData}');
        debugPrint('  Docs count: ${snapshot.data?.docs.length ?? 0}');

        if (snapshot.hasError) {
          debugPrint('WalletPage: ❌ ERROR loading bills: ${snapshot.error}');
          return Container(
            padding: const EdgeInsets.all(DesignToken.padding4XL),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: DesignToken.borderRadiusLG,
            ),
            child: Column(
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red, semanticLabel: 'Error loading bills'),
                SizedBox(height: DesignToken.heightLG),
                Text(
                  'Error loading bills',
                  style: AppTextStyles.nunitoSemiBold.copyWith(
                    fontSize: DesignToken.fontSizeLG,
                    color: Colors.red,
                  ),
                ),
                SizedBox(height: DesignToken.heightSM),
                Text(
                  '${snapshot.error}',
                  style: AppTextStyles.nunitoRegular.copyWith(
                    fontSize: DesignToken.fontSizeSM,
                    color: DesignToken.textDark.withOpacity(0.5),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(DesignToken.padding4XL),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          debugPrint('WalletPage: No bills found for user $userId');
          return Container(
            padding: const EdgeInsets.all(DesignToken.padding4XL),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: DesignToken.borderRadiusLG,
            ),
            child: Column(
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 64,
                  color: DesignToken.textDark.withOpacity(0.3),
                  semanticLabel: 'No bills yet',
                ),
                SizedBox(height: DesignToken.heightLG),
                Text(
                  AppLocalizations.of(context)!.noBillsYet,
                  style: AppTextStyles.nunitoSemiBold.copyWith(
                    fontSize: DesignToken.fontSizeLG,
                    color: DesignToken.textDark.withOpacity(0.6),
                  ),
                ),
                SizedBox(height: DesignToken.heightSM),
                Text(
                  AppLocalizations.of(context)!.submitFirstBill,
                  style: AppTextStyles.nunitoRegular.copyWith(
                    fontSize: DesignToken.fontSizeMD,
                    color: DesignToken.textDark.withOpacity(0.5),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final bills = snapshot.data!.docs;
        debugPrint('WalletPage: ✅ Found ${bills.length} bills');

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: bills.length,
          separatorBuilder: (context, index) => SizedBox(height: DesignToken.heightMD),
          itemBuilder: (context, index) {
            final bill = bills[index].data() as Map<String, dynamic>;
            final amount = bill['amount'] ?? 0.0;
            final status = bill['status'] ?? 'pending';
            final pointsEarned = bill['pointsEarned'] ?? 0;
            final createdAt = bill['createdAt'] as Timestamp?;
            final storeName = bill['storeName'] ?? '';

            debugPrint(
              '  Bill[$index]: amount=$amount, status=$status, carpenterId=${bill['carpenterId']}, createdAt=$createdAt',
            );

            return Container(
              padding: DesignToken.paddingAllLG,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: DesignToken.borderRadiusLG,
                border: Border.all(
                  color: DesignToken.primary.withOpacity(0.1),
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
                      borderRadius: DesignToken.borderRadiusMD,
                    ),
                    child: Icon(
                      _getStatusIcon(status),
                      color: _getStatusColor(status),
                      size: 24,
                      semanticLabel: 'Bill status: $status',
                    ),
                  ),
                  SizedBox(width: DesignToken.widthLG),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          storeName.isNotEmpty
                              ? storeName
                              : AppLocalizations.of(context)!.billLabel,
                          style: AppTextStyles.nunitoBold.copyWith(
                            fontSize: DesignToken.fontSizeLG,
                            color: DesignToken.textDark,
                          ),
                        ),
                        SizedBox(height: DesignToken.heightXS),
                        Row(
                          children: [
                            Text(
                              '₹${amount.toStringAsFixed(0)}',
                              style: AppTextStyles.nunitoSemiBold.copyWith(
                                fontSize: DesignToken.fontSizeMD,
                                color: DesignToken.primary,
                              ),
                            ),
                            if (pointsEarned > 0) ...[
                              SizedBox(width: DesignToken.widthSM),
                              Text(
                                '• $pointsEarned pts',
                                style: AppTextStyles.nunitoRegular.copyWith(
                                  fontSize: DesignToken.fontSizeMD,
                                  color: DesignToken.textDark.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (createdAt != null) ...[
                          SizedBox(height: DesignToken.heightXS),
                          Text(
                            _formatDate(createdAt.toDate()),
                            style: AppTextStyles.nunitoRegular.copyWith(
                              fontSize: DesignToken.fontSizeSM,
                              color: DesignToken.textDark.withOpacity(0.5),
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
                      borderRadius: DesignToken.borderRadiusMD,
                      border: Border.all(
                        color: _getStatusColor(status).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: AppTextStyles.nunitoSemiBold.copyWith(
                        fontSize: DesignToken.fontSizeSM,
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
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return l10n.justNow;
        }
        return l10n.minutesAgo(difference.inMinutes);
      }
      return l10n.hoursAgo(difference.inHours);
    } else if (difference.inDays == 1) {
      return l10n.yesterday;
    } else if (difference.inDays < 7) {
      return l10n.daysAgo(difference.inDays);
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
