import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:balaji_points/config/theme.dart';
import 'package:balaji_points/services/bill_service.dart';
import 'package:balaji_points/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class PendingBillsList extends StatefulWidget {
  const PendingBillsList({super.key});

  @override
  State<PendingBillsList> createState() => _PendingBillsListState();
}

class _PendingBillsListState extends State<PendingBillsList> {
  final BillService _billService = BillService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Map<String, bool> _expanded = {};

  // ---------------- IMAGE VIEWER ----------------
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
                            const Icon(
                              Icons.error,
                              color: Colors.red,
                              size: 60,
                            ),
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
                          const Icon(
                            Icons.image_not_supported,
                            size: 60,
                            color: Colors.grey,
                          ),
                          Text(
                            l10n.noImageAvailable,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
              ),
            ),

            // close
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

  // ---------------- APPROVE HANDLER ----------------
  Future<void> _approveBill(Map<String, dynamic> bill) async {
    final billId = bill['billId'];
    final carpenterId = bill['carpenterId'];
    final amount = (bill['amount'] ?? 0).toDouble();

    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Approve Bill',
          style: AppTextStyles.nunitoBold.copyWith(
            fontSize: 20,
            color: AppColors.primary,
          ),
        ),
        content: Text(
          'Approve this bill of ₹${amount.toStringAsFixed(0)}?\n\n${(amount / 1000).floor()} points will be added to the carpenter.',
          style: AppTextStyles.nunitoRegular.copyWith(
            fontSize: 16,
            color: AppColors.textDark,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: AppTextStyles.nunitoSemiBold.copyWith(
                color: AppColors.textDark,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Approve',
              style: AppTextStyles.nunitoBold.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    _showLoadingDialog();

    try {
      final success = await _billService.approveBill(
        billId,
        carpenterId,
        amount,
      );

      Navigator.pop(context); // close loading

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: success ? Colors.green : Colors.red,
          content: Text(
            success
                ? 'Bill approved and points added successfully'
                : 'Failed to approve bill',
            style: const TextStyle(color: Colors.white),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      Navigator.pop(context); // close loading
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Error approving bill: ${e.toString()}',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  // ---------------- REJECT HANDLER ----------------
  Future<void> _rejectBill(String billId) async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Reject Bill',
          style: AppTextStyles.nunitoBold.copyWith(
            fontSize: 20,
            color: Colors.red.shade700,
          ),
        ),
        content: Text(
          'Are you sure you want to reject this bill?',
          style: AppTextStyles.nunitoRegular.copyWith(
            fontSize: 16,
            color: AppColors.textDark,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: AppTextStyles.nunitoSemiBold.copyWith(
                color: AppColors.textDark,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Reject',
              style: AppTextStyles.nunitoBold.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    _showLoadingDialog();

    try {
      final success = await _billService.rejectBill(billId);

      Navigator.pop(context); // close loading

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: success ? Colors.orange : Colors.red,
          content: Text(
            success ? 'Bill rejected successfully' : 'Failed to reject bill',
            style: const TextStyle(color: Colors.white),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      Navigator.pop(context); // close loading
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Error rejecting bill: ${e.toString()}',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  // ---------------- LOADING POPUP ----------------
  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('bills')
          .where('status', isEqualTo: "pending")
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(child: Text(l10n.errorLoadingBills));
        }

        if (!snap.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        final bills = snap.data!.docs;

        if (bills.isEmpty) {
          return Center(child: Text(l10n.noPendingBills));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: bills.length,
          itemBuilder: (_, i) {
            final bill = bills[i].data() as Map<String, dynamic>;
            bill['billId'] = bills[i].id;

            final billId = bill['billId'];
            final isExpanded = _expanded[billId] ?? false;

            final amount = bill['amount'] ?? 0;
            final name = bill['carpenterName'] ?? "Carpenter";
            final phone = bill['carpenterPhone'] ?? "";
            final imageUrl = bill['imageUrl'] ?? "";
            final billDate = bill['billDate'] as Timestamp?;
            final createdAt = bill['createdAt'] as Timestamp?;

            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  setState(() {
                    _expanded[billId] = !isExpanded;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ------------ HEADER -------------
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.receipt_long,
                              color: AppColors.primary,
                              size: 22,
                            ),
                          ),

                          const SizedBox(width: 10),

                          // Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '${(amount / 1000).floor()} pts',
                                      style: AppTextStyles.nunitoBold.copyWith(
                                        fontSize: 18,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '₹${amount.toStringAsFixed(0)}',
                                      style: AppTextStyles.nunitoRegular
                                          .copyWith(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                    ),
                                  ],
                                ),
                                Text(
                                  name,
                                  style: AppTextStyles.nunitoMedium.copyWith(
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  phone,
                                  style: AppTextStyles.nunitoRegular.copyWith(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Expand Arrow
                          IconButton(
                            icon: Icon(
                              isExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              size: 24,
                            ),
                            onPressed: () {
                              setState(() => _expanded[billId] = !isExpanded);
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // ------------ DATE ROW -------------
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 13,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            billDate != null
                                ? DateFormat(
                                    'dd MMM yyyy',
                                  ).format(billDate.toDate())
                                : l10n.noDate,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                          const Spacer(),
                          Text(
                            createdAt != null
                                ? DateFormat(
                                    'dd MMM, hh:mm a',
                                  ).format(createdAt.toDate())
                                : "",
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),

                      if (isExpanded && imageUrl.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () => _viewBillImage(imageUrl),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              imageUrl,
                              height: 170,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 12),

                      // ------------ ACTION BUTTONS -------------
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _rejectBill(billId),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[50],
                                elevation: 0,
                              ),
                              icon: const Icon(Icons.close, color: Colors.red),
                              label: Text(
                                l10n.reject,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _approveBill(bill),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                elevation: 0,
                              ),
                              icon: const Icon(Icons.check),
                              label: Text(l10n.approve),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
