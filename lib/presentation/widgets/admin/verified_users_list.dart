import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:balaji_points/core/theme/design_token.dart';
import 'package:balaji_points/config/theme.dart' hide AppColors;

class VerifiedUsersList extends StatelessWidget {
  const VerifiedUsersList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignToken.woodenBackground,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('status', isEqualTo: 'verified')
            .where('role', isEqualTo: 'carpenter')
            .orderBy('totalPoints', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: AppTextStyles.nunitoRegular.copyWith(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: DesignToken.textDark.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Verified Carpenters',
                    style: AppTextStyles.nunitoSemiBold.copyWith(
                      fontSize: 18,
                      color: DesignToken.textDark.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            );
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final doc = users[index];
              final data = doc.data() as Map<String, dynamic>;
              final uid = doc.id;
              final firstName = data['firstName'] ?? '';
              final lastName = data['lastName'] ?? '';
              final phone = data['phone'] ?? '';
              final totalPoints = data['totalPoints'] ?? 0;
              final tier = data['tier'] ?? 'Bronze';
              final city = data['city'] ?? 'N/A';
              final skill = data['skill'] ?? 'N/A';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  childrenPadding: const EdgeInsets.all(16),
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [DesignToken.primary, DesignToken.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${firstName[0]}${lastName.isNotEmpty ? lastName[0] : ''}',
                        style: AppTextStyles.nunitoBold.copyWith(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$firstName $lastName',
                        style: AppTextStyles.nunitoBold.copyWith(
                          fontSize: 16,
                          color: DesignToken.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.phone,
                            size: 14,
                            color: DesignToken.textDark.withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            phone,
                            style: AppTextStyles.nunitoRegular.copyWith(
                              fontSize: 13,
                              color: DesignToken.textDark.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getTierColor(tier).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getTierColor(tier).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          tier,
                          style: AppTextStyles.nunitoSemiBold.copyWith(
                            fontSize: 11,
                            color: _getTierColor(tier),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.stars, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            '$totalPoints',
                            style: AppTextStyles.nunitoBold.copyWith(
                              fontSize: 14,
                              color: DesignToken.textDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  children: [
                    _buildDetailRow(Icons.location_city, 'City', city),
                    const SizedBox(height: 8),
                    _buildDetailRow(Icons.build, 'Skill', skill),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CarpenterDetailPage(
                              userId: uid,
                              userName: '$firstName $lastName',
                              phone: phone,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.person, size: 18),
                      label: Text(
                        'View Details',
                        style: AppTextStyles.nunitoSemiBold.copyWith(
                          fontSize: 14,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignToken.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: DesignToken.textDark.withOpacity(0.6)),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: AppTextStyles.nunitoMedium.copyWith(
            fontSize: 13,
            color: DesignToken.textDark.withOpacity(0.7),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.nunitoSemiBold.copyWith(
              fontSize: 13,
              color: DesignToken.textDark,
            ),
          ),
        ),
      ],
    );
  }

  Color _getTierColor(String tier) {
    switch (tier.toLowerCase()) {
      case 'bronze':
        return Colors.brown;
      case 'silver':
        return Colors.grey;
      case 'gold':
        return Colors.amber;
      case 'platinum':
        return Colors.blue;
      default:
        return DesignToken.primary;
    }
  }
}

// Carpenter Detail Page
class CarpenterDetailPage extends StatelessWidget {
  final String userId;
  final String userName;
  final String phone;

  const CarpenterDetailPage({
    super.key,
    required this.userId,
    required this.userName,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignToken.primary,
      appBar: AppBar(
        backgroundColor: DesignToken.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          userName,
          style: AppTextStyles.nunitoBold.copyWith(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>?;
          final totalPoints = data?['totalPoints'] ?? 0;
          final tier = data?['tier'] ?? 'Bronze';

          return Container(
            color: DesignToken.woodenBackground,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Stats Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [DesignToken.primary, DesignToken.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: DesignToken.primary.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              'Total Points',
                              '$totalPoints',
                              Icons.stars,
                            ),
                            _buildStatItem(
                              'Tier',
                              tier,
                              Icons.workspace_premium,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Bills Section
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('bills')
                        .where('userId', isEqualTo: userId)
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, billsSnapshot) {
                      if (!billsSnapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final bills = billsSnapshot.data!.docs;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Purchase Bills',
                            style: AppTextStyles.nunitoBold.copyWith(
                              fontSize: 18,
                              color: DesignToken.textDark,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (bills.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  'No bills yet',
                                  style: AppTextStyles.nunitoRegular.copyWith(
                                    color: DesignToken.textDark.withOpacity(
                                      0.5,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          else
                            ...bills.map((billDoc) {
                              final billData =
                                  billDoc.data() as Map<String, dynamic>;
                              final amount = billData['amount'] ?? 0.0;
                              final points = billData['points'] ?? 0;
                              final status = billData['status'] ?? 'pending';
                              final createdAt =
                                  billData['createdAt'] as Timestamp?;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '₹${amount.toStringAsFixed(0)}',
                                          style: AppTextStyles.nunitoBold
                                              .copyWith(
                                                fontSize: 18,
                                                color: DesignToken.primary,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Points: $points',
                                          style: AppTextStyles.nunitoRegular
                                              .copyWith(
                                                fontSize: 13,
                                                color: DesignToken.textDark
                                                    .withOpacity(0.7),
                                              ),
                                        ),
                                        if (createdAt != null)
                                          Text(
                                            _formatDate(createdAt.toDate()),
                                            style: AppTextStyles.nunitoRegular
                                                .copyWith(
                                                  fontSize: 12,
                                                  color: DesignToken.textDark
                                                      .withOpacity(0.5),
                                                ),
                                          ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: status == 'approved'
                                            ? Colors.green.withOpacity(0.1)
                                            : Colors.orange.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        status.toUpperCase(),
                                        style: AppTextStyles.nunitoSemiBold
                                            .copyWith(
                                              fontSize: 11,
                                              color: status == 'approved'
                                                  ? Colors.green.shade700
                                                  : Colors.orange.shade700,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.nunitoBold.copyWith(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.nunitoRegular.copyWith(
            fontSize: 12,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
