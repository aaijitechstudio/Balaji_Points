import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:balaji_points/config/theme.dart';
import 'package:balaji_points/services/bill_service.dart';
import 'package:intl/intl.dart';

class PendingBillsList extends StatefulWidget {
  const PendingBillsList({super.key});

  @override
  State<PendingBillsList> createState() => _PendingBillsListState();
}

class _PendingBillsListState extends State<PendingBillsList> {
  final BillService _billService = BillService();

  // Store expanded state of each card
  final Map<String, bool> _expanded = {};

  Future<void> _approveBill(Map<String, dynamic> bill) async {
    final shouldApprove = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Approve Bill',
          style: AppTextStyles.nunitoBold.copyWith(fontSize: 18),
        ),
        content: Text(
          'Approve bill of ₹${bill['amount']} for ${bill['carpenterPhone']}?',
          style: AppTextStyles.nunitoRegular.copyWith(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: AppTextStyles.nunitoMedium.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Approve', style: AppTextStyles.nunitoSemiBold),
          ),
        ],
      ),
    );

    if (shouldApprove != true) return;

    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                const Text("Approving bill..."),
              ],
            ),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 4),
          ),
        );
      }

      final success = await _billService.approveBill(
        bill['billId'],
        bill['carpenterId'],
        bill['amount'].toDouble(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? "Bill approved!" : "Failed to approve bill. Try again.",
          ),
          backgroundColor: success ? Colors.green : Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );

      if (success) setState(() {});
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _rejectBill(String billId) async {
    final shouldReject = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Reject Bill',
          style: AppTextStyles.nunitoBold.copyWith(fontSize: 18),
        ),
        content: Text(
          'Are you sure you want to reject this bill?',
          style: AppTextStyles.nunitoRegular.copyWith(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: AppTextStyles.nunitoMedium.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Reject', style: AppTextStyles.nunitoSemiBold),
          ),
        ],
      ),
    );

    if (shouldReject == true) {
      final success = await _billService.rejectBill(billId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? "Bill Rejected" : "Failed to reject"),
            backgroundColor: success ? Colors.orange : Colors.red,
          ),
        );
        if (success) setState(() {});
      }
    }
  }

  void _viewBillImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black.withOpacity(0.8),
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Image.network(imageUrl, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 30,
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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bills')
          .where('status', isEqualTo: "pending")
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snap) {
        if (snap.hasError) {
          return const Center(child: Text("Error loading bills"));
        }

        if (!snap.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        final bills = snap.data!.docs;

        if (bills.isEmpty) {
          return const Center(child: Text("No Pending Bills"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: bills.length,
          itemBuilder: (context, index) {
            final bill = bills[index].data() as Map<String, dynamic>;
            bill["billId"] = bills[index].id;

            final billId = bill["billId"];
            final isExpanded = _expanded[billId] ?? false;

            final amount = bill["amount"] ?? 0;
            final phone = bill["carpenterPhone"] ?? "Unknown";
            final name = bill["carpenterName"] ?? "Carpenter";
            final imageUrl = bill["imageUrl"] ?? "";
            final billDate = bill["billDate"] as Timestamp?;
            final createdAt = bill["createdAt"] as Timestamp?;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _expanded[billId] = !isExpanded;
                });
              },
              child: Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ---------------- HEADER ------------------
                      Row(
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

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "₹${amount.toStringAsFixed(2)}",
                                  style: AppTextStyles.nunitoBold.copyWith(
                                    fontSize: 18,
                                  ),
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

                          // PENDING + EXPAND ARROW
                          Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange[100],
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  "Pending",
                                  style: AppTextStyles.nunitoSemiBold.copyWith(
                                    fontSize: 10,
                                    color: Colors.orange[900],
                                  ),
                                ),
                              ),

                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: Icon(
                                  isExpanded
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  size: 24,
                                  color: Colors.grey[700],
                                ),
                                onPressed: () {
                                  setState(() {
                                    _expanded[billId] = !isExpanded;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // ---------------- DATE ROW ------------------
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
                                : "No date",
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

                      // ---------------- IMAGE EXPANDED ------------------
                      if (isExpanded && imageUrl.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () => _viewBillImage(imageUrl),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              imageUrl,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // ---------------- ACTION BUTTONS ------------------
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _rejectBill(billId.toString()),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[50],
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                              ),
                              icon: const Icon(
                                Icons.close,
                                size: 18,
                                color: Colors.red,
                              ),
                              label: Text(
                                "Reject",
                                style: AppTextStyles.nunitoSemiBold.copyWith(
                                  fontSize: 13,
                                  color: Colors.red,
                                ),
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
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                              ),
                              icon: const Icon(Icons.check, size: 18),
                              label: Text(
                                "Approve",
                                style: AppTextStyles.nunitoSemiBold.copyWith(
                                  fontSize: 13,
                                ),
                              ),
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
