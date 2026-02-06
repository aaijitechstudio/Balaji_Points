import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:balaji_points/core/theme/design_token.dart';
import 'package:balaji_points/config/theme.dart' hide AppColors;
import 'package:balaji_points/services/bill_service.dart';
import 'package:balaji_points/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

/// Bill Details Screen - Shows comprehensive bill information for admin
/// Displays carpenter details, bill images, dates, status, and actions
class BillDetailsPage extends StatefulWidget {
  final String billId;
  final Map<String, dynamic>? initialBillData;

  const BillDetailsPage({
    super.key,
    required this.billId,
    this.initialBillData,
  });

  @override
  State<BillDetailsPage> createState() => _BillDetailsPageState();
}

class _BillDetailsPageState extends State<BillDetailsPage> {
  final BillService _billService = BillService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? _billData;
  Map<String, dynamic>? _carpenterData;
  bool _isLoading = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadBillData();
  }

  Future<void> _loadBillData() async {
    setState(() => _isLoading = true);

    try {
      // Load bill data
      final billDoc = await _firestore.collection('bills').doc(widget.billId).get();
      if (billDoc.exists) {
        _billData = billDoc.data();
        _billData!['billId'] = billDoc.id;

        // Load carpenter data
        final carpenterId = _billData!['carpenterId'] as String?;
        if (carpenterId != null) {
          await _loadCarpenterData(carpenterId);
        }
      }
    } catch (e) {
      print('Error loading bill data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadCarpenterData(String carpenterId) async {
    try {
      // Try direct document lookup
      final doc = await _firestore.collection('users').doc(carpenterId).get();
      if (doc.exists) {
        _carpenterData = doc.data();
        return;
      }

      // Try query by phone
      final query = await _firestore
          .collection('users')
          .where('phone', isEqualTo: carpenterId)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        _carpenterData = query.docs.first.data();
      }
    } catch (e) {
      print('Error loading carpenter data: $e');
    }
  }

  void _viewBillImage(String imageUrl) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black87,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error, color: Colors.red, size: 60),
                            const SizedBox(height: 8),
                            Text(
                              l10n.failedToLoadImage,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
                          const SizedBox(height: 8),
                          Text(
                            l10n.noImageAvailable,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
              ),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _approveBill() async {
    final l10n = AppLocalizations.of(context)!;
    final amount = _billData!['amount'].toString();
    final phone = _billData!['carpenterPhone'] ?? '';
    final confirmed = await _showConfirmDialog(
      title: l10n.approveBill,
      message: l10n.approveBillConfirmation(amount, phone),
      confirmText: l10n.approve,
      confirmColor: Colors.green,
    );

    if (confirmed != true) return;

    setState(() => _isProcessing = true);

    try {
      final carpenterId = _billData!['carpenterId'] as String;
      final amount = _billData!['amount'] as double;

      final success = await _billService.approveBill(
        widget.billId,
        carpenterId,
        amount,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bill approved successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate action taken
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to approve bill'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _rejectBill() async {
    final confirmed = await _showConfirmDialog(
      title: 'Reject Bill',
      message: 'Are you sure you want to reject this bill?',
      confirmText: 'Reject',
      confirmColor: Colors.red,
    );

    if (confirmed != true) return;

    setState(() => _isProcessing = true);

    try {
      final success = await _billService.rejectBill(widget.billId);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bill rejected successfully'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate action taken
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to reject bill'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _withdrawBill() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await _showConfirmDialog(
      title: l10n.withdrawBill,
      message: l10n.withdrawBillConfirmation,
      confirmText: l10n.withdraw,
      confirmColor: Colors.orange,
    );

    if (confirmed != true) return;

    setState(() => _isProcessing = true);

    try {
      final success = await _billService.withdrawBill(widget.billId);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bill withdrawn successfully. Points have been reversed.'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate action taken
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to withdraw bill'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<bool?> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmText,
    required Color confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: AppTextStyles.nunitoBold.copyWith(fontSize: 20, color: confirmColor),
        ),
        content: Text(
          message,
          style: AppTextStyles.nunitoRegular.copyWith(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: AppTextStyles.nunitoSemiBold.copyWith(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              confirmText,
              style: AppTextStyles.nunitoBold.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: DesignToken.primary,
        appBar: AppBar(
          title: Text(
            'Bill Details',
            style: AppTextStyles.nunitoBold.copyWith(fontSize: 20, color: Colors.white),
          ),
          backgroundColor: DesignToken.primary,
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (_billData == null) {
      return Scaffold(
        backgroundColor: DesignToken.primary,
        appBar: AppBar(
          title: Text(
            'Bill Details',
            style: AppTextStyles.nunitoBold.copyWith(fontSize: 20, color: Colors.white),
          ),
          backgroundColor: DesignToken.primary,
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.white),
              const SizedBox(height: 16),
              Text(
                'Bill not found',
                style: AppTextStyles.nunitoBold.copyWith(fontSize: 18, color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    final status = _billData!['status'] as String? ?? 'pending';
    final amount = _billData!['amount'] ?? 0;
    // For approved bills, use pointsEarned field; otherwise calculate from amount
    final points = status == 'approved'
        ? (_billData!['pointsEarned'] as num?)?.toInt() ?? (amount / 1000).floor()
        : (amount / 1000).floor();
    final imageUrl = _billData!['imageUrl'] as String? ?? '';
    final carpenterPhone = _billData!['carpenterPhone'] as String? ?? '';
    final billDate = _billData!['billDate'] as Timestamp?;
    final createdAt = _billData!['createdAt'] as Timestamp?;
    final approvedAt = _billData!['approvedAt'] as Timestamp?;

    final carpenterName = _carpenterData != null
        ? '${_carpenterData!['firstName'] ?? ''} ${_carpenterData!['lastName'] ?? ''}'.trim()
        : 'Carpenter';
    final profileImageUrl = _carpenterData?['profileImage'] as String?;
    final carpenterTier = _carpenterData?['tier'] as String? ?? 'Bronze';
    final carpenterPoints = _carpenterData?['totalPoints'] as int? ?? 0;

    return Scaffold(
      backgroundColor: DesignToken.primary,
      appBar: AppBar(
        title: Text(
          'Bill Details',
          style: AppTextStyles.nunitoBold.copyWith(fontSize: 20, color: Colors.white),
        ),
        backgroundColor: DesignToken.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: DesignToken.woodenBackground,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: status == 'approved'
                            ? Colors.green
                            : status == 'rejected'
                                ? Colors.red
                                : Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            status == 'approved'
                                ? Icons.check_circle
                                : status == 'rejected'
                                    ? Icons.cancel
                                    : Icons.pending,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            status == 'approved'
                                ? 'APPROVED'
                                : status == 'rejected'
                                    ? 'REJECTED'
                                    : 'PENDING APPROVAL',
                            style: AppTextStyles.nunitoBold.copyWith(
                              fontSize: 14,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Carpenter Information Card
                    Card(
                      elevation: 4,
                      shadowColor: DesignToken.primary.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white,
                              DesignToken.primary.withValues(alpha: 0.03),
                            ],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.person_outline, size: 20, color: DesignToken.primary),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Carpenter Information',
                                    style: AppTextStyles.nunitoBold.copyWith(
                                      fontSize: 16,
                                      color: DesignToken.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                            Row(
                              children: [
                                // Profile Image
                                Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: DesignToken.primary.withValues(alpha: 0.1),
                                    border: Border.all(
                                      color: DesignToken.primary.withValues(alpha: 0.3),
                                      width: 3,
                                    ),
                                  ),
                                  child: profileImageUrl != null && profileImageUrl.isNotEmpty
                                      ? ClipOval(
                                          child: Image.network(
                                            profileImageUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Icon(
                                              Icons.person,
                                              color: DesignToken.primary,
                                              size: 36,
                                            ),
                                          ),
                                        )
                                      : Icon(Icons.person, color: DesignToken.primary, size: 36),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        carpenterName,
                                        style: AppTextStyles.nunitoBold.copyWith(
                                          fontSize: 18,
                                          color: DesignToken.textDark,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      if (carpenterPhone.isNotEmpty)
                                        Row(
                                          children: [
                                            Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                                            const SizedBox(width: 4),
                                            Text(
                                              carpenterPhone,
                                              style: AppTextStyles.nunitoRegular.copyWith(
                                                fontSize: 14,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ],
                                        ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.workspace_premium, size: 14, color: Colors.amber[700]),
                                          const SizedBox(width: 4),
                                          Text(
                                            '$carpenterTier Tier',
                                            style: AppTextStyles.nunitoSemiBold.copyWith(
                                              fontSize: 13,
                                              color: Colors.amber[700],
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Icon(Icons.stars, size: 14, color: DesignToken.secondary),
                                          const SizedBox(width: 4),
                                          Text(
                                            '$carpenterPoints pts',
                                            style: AppTextStyles.nunitoSemiBold.copyWith(
                                              fontSize: 13,
                                              color: DesignToken.secondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                    const SizedBox(height: 16),

                    // Bill Amount & Points Card
                    Card(
                      elevation: 4,
                      shadowColor: DesignToken.secondary.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white,
                              DesignToken.secondary.withValues(alpha: 0.05),
                            ],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.receipt_long, size: 20, color: DesignToken.primary),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Bill Summary',
                                    style: AppTextStyles.nunitoBold.copyWith(
                                      fontSize: 16,
                                      color: DesignToken.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.green.shade300, width: 2),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(Icons.currency_rupee, size: 32, color: Colors.green.shade700),
                                        const SizedBox(height: 8),
                                        Text(
                                          '₹${amount.toStringAsFixed(0)}',
                                          style: AppTextStyles.nunitoBold.copyWith(
                                            fontSize: 24,
                                            color: Colors.green.shade700,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Bill Amount',
                                          style: AppTextStyles.nunitoRegular.copyWith(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: DesignToken.secondary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: DesignToken.secondary.withValues(alpha: 0.5), width: 2),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(Icons.monetization_on, size: 32, color: DesignToken.secondary),
                                        const SizedBox(height: 8),
                                        Text(
                                          '$points',
                                          style: AppTextStyles.nunitoBold.copyWith(
                                            fontSize: 24,
                                            color: DesignToken.secondary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Points Earned',
                                          style: AppTextStyles.nunitoRegular.copyWith(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                    // Dates Information Card
                    Card(
                      elevation: 4,
                      shadowColor: Colors.blue.withValues(alpha: 0.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white,
                              Colors.blue.withValues(alpha: 0.03),
                            ],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.timeline, size: 20, color: DesignToken.primary),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Timeline',
                                    style: AppTextStyles.nunitoBold.copyWith(
                                      fontSize: 16,
                                      color: DesignToken.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (billDate != null) ...[
                                _buildDateRow(
                                  icon: Icons.receipt_long,
                                  label: 'Bill Date',
                                  date: billDate.toDate(),
                                  color: Colors.blue,
                                ),
                                const SizedBox(height: 8),
                              ],
                              if (createdAt != null) ...[
                                _buildDateRow(
                                  icon: Icons.upload_file,
                                  label: 'Submitted',
                                  date: createdAt.toDate(),
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 8),
                              ],
                              if (approvedAt != null)
                                _buildDateRow(
                                  icon: status == 'approved' ? Icons.check_circle : Icons.cancel,
                                  label: status == 'approved' ? 'Approved' : 'Rejected',
                                  date: approvedAt.toDate(),
                                  color: status == 'approved' ? Colors.green : Colors.red,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Bill Image Card
                    if (imageUrl.isNotEmpty) ...[
                      Card(
                        elevation: 4,
                        shadowColor: DesignToken.primary.withValues(alpha: 0.2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white,
                                DesignToken.primary.withValues(alpha: 0.02),
                              ],
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.image_outlined, size: 20, color: DesignToken.primary),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Bill Image',
                                          style: AppTextStyles.nunitoBold.copyWith(
                                            fontSize: 16,
                                            color: DesignToken.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    TextButton.icon(
                                      onPressed: () => _viewBillImage(imageUrl),
                                      icon: const Icon(Icons.zoom_in, size: 18),
                                      label: const Text('View Full Size'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: DesignToken.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                GestureDetector(
                                  onTap: () => _viewBillImage(imageUrl),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: DesignToken.primary.withValues(alpha: 0.2),
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: DesignToken.primary.withValues(alpha: 0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        imageUrl,
                                        width: double.infinity,
                                        height: 250,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          height: 250,
                                          color: Colors.grey[200],
                                          child: Center(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.error_outline, color: Colors.grey[400], size: 48),
                                                const SizedBox(height: 8),
                                                Text(
                                                  l10n.failedToLoadImage,
                                                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 80), // Space for action buttons
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Action Buttons (for pending and approved bills)
          if (status == 'pending')
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isProcessing ? null : _rejectBill,
                        icon: _isProcessing
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.close, size: 20),
                        label: Text(
                          l10n.reject,
                          style: AppTextStyles.nunitoBold.copyWith(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: _isProcessing ? null : _approveBill,
                        icon: _isProcessing
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.check_circle, size: 20),
                        label: Text(
                          l10n.approveBill,
                          style: AppTextStyles.nunitoBold.copyWith(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Withdraw Button (only for approved bills)
          if (status == 'approved')
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white,
                    Colors.orange.withValues(alpha: 0.05),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: SafeArea(
                top: false,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.orange.shade400,
                        Colors.orange.shade600,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _isProcessing ? null : _withdrawBill,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isProcessing)
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.restore,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  l10n.withdrawApproval,
                                  style: AppTextStyles.nunitoBold.copyWith(
                                    fontSize: 17,
                                    color: Colors.white,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  l10n.reversePointsAndUndoApproval,
                                  style: AppTextStyles.nunitoRegular.copyWith(
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Approve Button (only for rejected bills)
          if (status == 'rejected')
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white,
                    Colors.green.withValues(alpha: 0.05),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: SafeArea(
                top: false,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.green.shade400,
                        Colors.green.shade600,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _isProcessing ? null : _approveBill,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isProcessing)
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  l10n.approveBillAction,
                                  style: AppTextStyles.nunitoBold.copyWith(
                                    fontSize: 17,
                                    color: Colors.white,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  l10n.awardPointsAndMarkAsApproved,
                                  style: AppTextStyles.nunitoRegular.copyWith(
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDateRow({
    required IconData icon,
    required String label,
    required DateTime date,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.nunitoRegular.copyWith(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                DateFormat('dd MMM yyyy, hh:mm a').format(date),
                style: AppTextStyles.nunitoSemiBold.copyWith(
                  fontSize: 14,
                  color: DesignToken.textDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
