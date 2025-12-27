import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:balaji_points/core/theme/design_token.dart';
import 'package:balaji_points/config/theme.dart' hide AppColors;

class CarpenterSelectionWidget extends StatefulWidget {
  final Map<String, dynamic>? selectedCarpenter;
  final Function(Map<String, dynamic>) onCarpenterSelected;

  const CarpenterSelectionWidget({
    super.key,
    this.selectedCarpenter,
    required this.onCarpenterSelected,
  });

  @override
  State<CarpenterSelectionWidget> createState() =>
      _CarpenterSelectionWidgetState();
}

class _CarpenterSelectionWidgetState extends State<CarpenterSelectionWidget> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCarpenterSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: DesignToken.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.person_search,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Select Carpenter',
                        style: AppTextStyles.nunitoBold.copyWith(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                  style: AppTextStyles.nunitoRegular.copyWith(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search by name or phone',
                    hintStyle: AppTextStyles.nunitoRegular.copyWith(
                      color: Colors.grey[400],
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: DesignToken.primary,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),

              // Carpenters List
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error loading carpenters',
                          style: AppTextStyles.nunitoRegular.copyWith(
                            color: Colors.red,
                          ),
                        ),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: DesignToken.primary,
                        ),
                      );
                    }

                    var carpenters = snapshot.data?.docs ?? [];

                    // Filter to show only carpenters (exclude admins)
                    carpenters = carpenters.where((doc) {
                      final user = doc.data() as Map<String, dynamic>;
                      final role = user['role'] as String?;
                      return role != 'admin' &&
                          (role == null || role.isEmpty || role == 'carpenter');
                    }).toList();

                    // Apply search filter
                    if (_searchQuery.isNotEmpty) {
                      carpenters = carpenters.where((doc) {
                        final user = doc.data() as Map<String, dynamic>;
                        final firstName =
                            (user['firstName'] ?? '').toString().toLowerCase();
                        final lastName =
                            (user['lastName'] ?? '').toString().toLowerCase();
                        final phone =
                            (user['phone'] ?? '').toString().toLowerCase();
                        final fullName = '$firstName $lastName'.trim();

                        return fullName.contains(_searchQuery) ||
                            phone.contains(_searchQuery);
                      }).toList();
                    }

                    if (carpenters.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? 'No carpenters found'
                                  : 'No carpenters available',
                              style: AppTextStyles.nunitoRegular.copyWith(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: carpenters.length,
                      itemBuilder: (context, index) {
                        final doc = carpenters[index];
                        final user = doc.data() as Map<String, dynamic>;
                        final userId = doc.id;
                        final firstName = user['firstName'] ?? '';
                        final lastName = user['lastName'] ?? '';
                        final name = ('$firstName $lastName').trim().isEmpty
                            ? 'Carpenter'
                            : ('$firstName $lastName').trim();
                        final phone = user['phone'] ?? '';
                        final profileImage = user['profileImage'] as String?;
                        final tier = user['tier'] ?? 'Bronze';
                        final points = user['totalPoints'] ?? 0;

                        final isSelected = widget.selectedCarpenter != null &&
                            widget.selectedCarpenter!['userId'] == userId;

                        return InkWell(
                          onTap: () {
                            widget.onCarpenterSelected({
                              'userId': userId,
                              'firstName': firstName,
                              'lastName': lastName,
                              'name': name,
                              'phone': phone,
                              'profileImage': profileImage,
                              'tier': tier,
                              'totalPoints': points,
                            });
                            Navigator.pop(context);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? DesignToken.primary.withOpacity(0.1)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? DesignToken.primary
                                    : Colors.grey[300]!,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                // Profile Image
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: DesignToken.primary.withOpacity(0.1),
                                    border: Border.all(
                                      color: DesignToken.primary.withOpacity(0.3),
                                      width: 2,
                                    ),
                                  ),
                                  child: profileImage != null &&
                                          profileImage.isNotEmpty
                                      ? ClipOval(
                                          child: Image.network(
                                            profileImage,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Icon(
                                              Icons.person,
                                              color: DesignToken.primary,
                                              size: 28,
                                            ),
                                          ),
                                        )
                                      : Icon(
                                          Icons.person,
                                          color: DesignToken.primary,
                                          size: 28,
                                        ),
                                ),
                                const SizedBox(width: 12),
                                // Name and Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: AppTextStyles.nunitoBold.copyWith(
                                          fontSize: 16,
                                          color: DesignToken.textDark,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        phone,
                                        style: AppTextStyles.nunitoRegular
                                            .copyWith(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: DesignToken.primary
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              tier,
                                              style: AppTextStyles.nunitoSemiBold
                                                  .copyWith(
                                                fontSize: 10,
                                                color: DesignToken.primary,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '$points pts',
                                            style: AppTextStyles.nunitoRegular
                                                .copyWith(
                                              fontSize: 11,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle,
                                    color: DesignToken.primary,
                                    size: 24,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedCarpenter = widget.selectedCarpenter;

    return InkWell(
      onTap: _showCarpenterSelectionDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selectedCarpenter != null
                ? DesignToken.primary
                : DesignToken.primary.withOpacity(0.3),
            width: selectedCarpenter != null ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.person,
              color: DesignToken.primary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: selectedCarpenter != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedCarpenter['name'] ?? 'Carpenter',
                          style: AppTextStyles.nunitoBold.copyWith(
                            fontSize: 16,
                            color: DesignToken.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          selectedCarpenter['phone'] ?? '',
                          style: AppTextStyles.nunitoRegular.copyWith(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    )
                  : Text(
                      'Select Carpenter',
                      style: AppTextStyles.nunitoRegular.copyWith(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: DesignToken.primary,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

