import 'package:balaji_points/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:balaji_points/core/theme/design_token.dart';
import 'package:balaji_points/config/theme.dart' hide AppColors;
import 'package:balaji_points/l10n/app_localizations.dart';
import 'package:balaji_points/services/pin_auth_service.dart';
import 'package:intl/intl.dart';

/// Full single-file implementation:
/// - Users list (carpenters)
/// - Add Carpenter dialog (Phone + OTP)
/// NOTE: OTP verification uses FirebaseAuth and will sign the app in as the verified user
/// while verifying. After creating the user the code signs out that user. Admin will
/// therefore be signed out and must sign in again. See notes above for Server-side option.

class UsersList extends StatefulWidget {
  const UsersList({super.key});

  @override
  State<UsersList> createState() => _UsersListState();
}

class _UsersListState extends State<UsersList> {
  String _searchQuery = '';
  String _selectedTier = 'All';
  final List<String> _tiers = ['All', 'Platinum', 'Gold', 'Silver', 'Bronze'];
  final _userService = UserService();

  void _showUserDetails(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) =>
          UserDetailsDialog(user: user, onDelete: () => _deleteCarpenter(user)),
    );
  }

  void _showAddCarpenterDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddCarpenterDialog(),
    );
  }

  Future<void> _deleteCarpenter(Map<String, dynamic> user) async {
    final l10n = AppLocalizations.of(context)!;
    final userId = user['userId'] as String?;
    final firstName = user['firstName'] ?? '';
    final lastName = user['lastName'] ?? '';
    final userName = '$firstName $lastName'.trim().isEmpty
        ? 'Carpenter'
        : '$firstName $lastName'.trim();

    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.failedToDeleteCarpenter),
          backgroundColor: DesignToken.error,
        ),
      );
      return;
    }

    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: DesignToken.error,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.deleteCarpenter,
                style: AppTextStyles.nunitoBold.copyWith(
                  fontSize: 20,
                  color: DesignToken.error,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          l10n.deleteCarpenterConfirmation.replaceAll('{userName}', userName),
          style: AppTextStyles.nunitoRegular.copyWith(
            fontSize: 16,
            color: DesignToken.textDark,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              l10n.cancel,
              style: AppTextStyles.nunitoSemiBold.copyWith(
                color: DesignToken.textDark,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignToken.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              l10n.delete,
              style: AppTextStyles.nunitoBold.copyWith(
                color: DesignToken.white,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Show loading indicator
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: DesignToken.primary),
        ),
      );
    }

    try {
      final success = await _userService.deleteCarpenter(userId);

      if (mounted) {
        Navigator.pop(context); // Close loading dialog

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.carpenterDeletedSuccess),
              backgroundColor: DesignToken.success,
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.failedToDeleteCarpenter),
              backgroundColor: DesignToken.error,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog

        // Parse error message for better user feedback
        String errorMessage = l10n.failedToDeleteCarpenter;
        final errorStr = e.toString().toLowerCase();

        if (errorStr.contains('permission') ||
            errorStr.contains('permission_denied')) {
          errorMessage =
              '${l10n.failedToDeleteCarpenter}\nPermission denied. Please check Firestore security rules.';
        } else if (errorStr.contains('network') ||
            errorStr.contains('connection')) {
          errorMessage =
              '${l10n.failedToDeleteCarpenter}\nNetwork error. Please check your connection.';
        } else {
          errorMessage = '${l10n.failedToDeleteCarpenter}\n${e.toString()}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: DesignToken.error,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Dismiss',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        // Search + Add button
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.toLowerCase();
                        });
                      },
                      style: AppTextStyles.nunitoRegular.copyWith(fontSize: 16),
                      decoration: InputDecoration(
                        hintText: l10n.searchByNameOrPhone,
                        hintStyle: AppTextStyles.nunitoRegular.copyWith(
                          color: Colors.grey[400],
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: DesignToken.primary,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _showAddCarpenterDialog,
                    icon: const Icon(Icons.add),
                    label: Text(l10n.add),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DesignToken.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Tier Filter
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _tiers.map((tier) {
                    final isSelected = _selectedTier == tier;
                    final tierLabel = tier == 'All'
                        ? l10n.all
                        : tier == 'Platinum'
                        ? l10n.platinum
                        : tier == 'Gold'
                        ? l10n.gold
                        : tier == 'Silver'
                        ? l10n.silver
                        : l10n.bronze;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(tierLabel),
                        labelStyle: AppTextStyles.nunitoSemiBold.copyWith(
                          fontSize: 14,
                          color: isSelected
                              ? Colors.white
                              : DesignToken.textDark,
                        ),
                        backgroundColor: Colors.grey[200],
                        selectedColor: DesignToken.primary,
                        onSelected: (selected) {
                          setState(() {
                            _selectedTier = tier;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        // Users List
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('role', isEqualTo: 'carpenter')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                final l10n = AppLocalizations.of(context)!;
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.errorLoadingUsers,
                        style: AppTextStyles.nunitoBold.copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        snapshot.error.toString(),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.nunitoRegular.copyWith(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: const CircularProgressIndicator(
                    color: DesignToken.primary,
                  ),
                );
              }

              var users = snapshot.data?.docs ?? [];

              // Apply filters
              users = users.where((doc) {
                final user = doc.data() as Map<String, dynamic>;
                final firstName = (user['firstName'] ?? '')
                    .toString()
                    .toLowerCase();
                final lastName = (user['lastName'] ?? '')
                    .toString()
                    .toLowerCase();
                final phone = (user['phone'] ?? '').toString().toLowerCase();
                final tier = user['tier'] ?? 'Bronze';

                final matchesSearch =
                    _searchQuery.isEmpty ||
                    firstName.contains(_searchQuery) ||
                    lastName.contains(_searchQuery) ||
                    phone.contains(_searchQuery);

                final matchesTier =
                    _selectedTier == 'All' || tier == _selectedTier;

                return matchesSearch && matchesTier;
              }).toList();

              // Sort by points (descending)
              users.sort((a, b) {
                final aPoints =
                    (a.data() as Map<String, dynamic>)['totalPoints'] ?? 0;
                final bPoints =
                    (b.data() as Map<String, dynamic>)['totalPoints'] ?? 0;
                return bPoints.compareTo(aPoints);
              });

              if (users.isEmpty) {
                final l10n = AppLocalizations.of(context)!;
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_off_outlined,
                        size: 80,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        l10n.noUsersFound,
                        style: AppTextStyles.nunitoBold.copyWith(
                          fontSize: 20,
                          color: DesignToken.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _searchQuery.isNotEmpty
                            ? l10n.tryDifferentSearch
                            : l10n.noCarpentersYet,
                        style: AppTextStyles.nunitoRegular.copyWith(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index].data() as Map<String, dynamic>;
                  final userId = users[index].id;
                  user['userId'] = userId;

                  final firstName = user['firstName'] ?? '';
                  final lastName = user['lastName'] ?? '';
                  final phone = user['phone'] ?? '';
                  final totalPoints = user['totalPoints'] ?? 0;
                  final tier = user['tier'] ?? 'Bronze';
                  final profileImage = user['profileImage'] ?? '';
                  final createdAt = user['createdAt'] is Timestamp
                      ? (user['createdAt'] as Timestamp).toDate()
                      : (user['createdAt'] is DateTime
                            ? user['createdAt'] as DateTime
                            : null);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade200, width: 1),
                    ),
                    child: InkWell(
                      onTap: () => _showUserDetails(user),
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // Top Row: Rank, Profile, Name, Actions
                            Row(
                              children: [
                                // Rank Badge
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        DesignToken.primary,
                                        DesignToken.secondary,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '#${index + 1}',
                                      style: AppTextStyles.nunitoBold.copyWith(
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Profile Image
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: DesignToken.primary
                                      .withOpacity(0.1),
                                  backgroundImage:
                                      profileImage != null && profileImage != ''
                                      ? NetworkImage(profileImage)
                                      : null,
                                  child:
                                      profileImage == null || profileImage == ''
                                      ? Icon(
                                          Icons.person,
                                          size: 24,
                                          color: DesignToken.primary,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),

                                // User Name
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$firstName $lastName',
                                        style: AppTextStyles.nunitoBold
                                            .copyWith(
                                              fontSize: 16,
                                              color: DesignToken.textDark,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        phone,
                                        style: AppTextStyles.nunitoRegular
                                            .copyWith(
                                              fontSize: 13,
                                              color: Colors.grey[600],
                                            ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Delete Button
                                OutlinedButton(
                                  onPressed: () => _deleteCarpenter(user),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: DesignToken.error,
                                    side: BorderSide(
                                      color: DesignToken.error,
                                      width: 1.5,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    l10n.delete,
                                    style: AppTextStyles.nunitoSemiBold
                                        .copyWith(
                                          fontSize: 13,
                                          color: DesignToken.error,
                                        ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Bottom Row: Tier, Points, Joined Date
                            Row(
                              children: [
                                // Tier Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getTierColor(tier),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    tier,
                                    style: AppTextStyles.nunitoBold.copyWith(
                                      fontSize: 11,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Points
                                Flexible(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.stars,
                                        size: 16,
                                        color: DesignToken.secondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          '$totalPoints Points',
                                          style: AppTextStyles.nunitoSemiBold
                                              .copyWith(
                                                fontSize: 14,
                                                color: DesignToken.primary,
                                              ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 8),

                                // Joined Date
                                if (createdAt != null)
                                  Flexible(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          size: 14,
                                          color: Colors.grey[500],
                                        ),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            DateFormat(
                                              'dd MMM yyyy',
                                            ).format(createdAt),
                                            style: AppTextStyles.nunitoRegular
                                                .copyWith(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
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
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

/// ---------------------------
/// Add Carpenter Dialog (Phone + PIN)
/// ---------------------------
/// This dialog creates a new carpenter with phone + PIN authentication
/// Uses PinAuthService to create user without signing out admin

class AddCarpenterDialog extends StatefulWidget {
  const AddCarpenterDialog({super.key});

  @override
  State<AddCarpenterDialog> createState() => _AddCarpenterDialogState();
}

class _AddCarpenterDialogState extends State<AddCarpenterDialog> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  bool _creating = false;

  final _pinAuthService = PinAuthService();

  void _showSnack(String s, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(s),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<bool> _phoneExists(String phone) async {
    final normalized = _pinAuthService.normalizePhone(phone);
    final q = await FirebaseFirestore.instance
        .collection('users')
        .where('phone', isEqualTo: normalized)
        .limit(1)
        .get();
    return q.docs.isNotEmpty;
  }

  Future<void> _createCarpenter() async {
    final l10n = AppLocalizations.of(context)!;
    final phoneRaw = _phoneController.text.trim();
    final pin = _pinController.text.trim();
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();

    if (phoneRaw.isEmpty || phoneRaw.length < 10) {
      _showSnack(l10n.enterValidPhone, isError: true);
      return;
    }

    if (pin.isEmpty || pin.length < 4) {
      _showSnack('PIN must be at least 4 digits', isError: true);
      return;
    }

    // Check duplicate
    final exists = await _phoneExists(phoneRaw);
    if (exists) {
      _showSnack(l10n.phoneAlreadyExists, isError: true);
      return;
    }

    setState(() => _creating = true);

    try {
      final success = await _pinAuthService.setPinForPhone(
        phone: phoneRaw,
        pin: pin,
        firstName: firstName.isNotEmpty ? firstName : null,
        lastName: lastName.isNotEmpty ? lastName : null,
      );

      setState(() => _creating = false);

      if (success) {
        if (mounted) {
          _showSnack('Carpenter created successfully!');
          Navigator.of(context).pop();
        }
      } else {
        if (mounted) {
          _showSnack('Failed to create carpenter', isError: true);
        }
      }
    } catch (e) {
      setState(() => _creating = false);
      if (mounted) {
        _showSnack('Error: $e', isError: true);
      }
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _pinController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.addCarpenter,
              style: AppTextStyles.nunitoBold.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: l10n.phoneNumberLabel,
                hintText: l10n.phoneNumberHint,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.phone),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'PIN (4-6 digits)',
                hintText: 'Enter PIN',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _firstNameController,
              decoration: const InputDecoration(
                labelText: 'First Name (Optional)',
                hintText: 'Enter first name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _lastNameController,
              decoration: const InputDecoration(
                labelText: 'Last Name (Optional)',
                hintText: 'Enter last name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 20),
            if (_creating)
              const CircularProgressIndicator()
            else
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(l10n.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _createCarpenter,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignToken.primary,
                      ),
                      child: const Text('Create'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------
/// User Details Dialog (unchanged)
/// ---------------------------

class UserDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback? onDelete;
  const UserDetailsDialog({super.key, required this.user, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final firstName = user['firstName'] ?? '';
    final lastName = user['lastName'] ?? '';
    final phone = user['phone'] ?? '';
    final totalPoints = user['totalPoints'] ?? 0;
    final tier = user['tier'] ?? 'Bronze';
    final profileImage = user['profileImage'] ?? '';
    final createdAt = user['createdAt'] is Timestamp
        ? (user['createdAt'] as Timestamp).toDate()
        : (user['createdAt'] is DateTime
              ? user['createdAt'] as DateTime
              : null);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [DesignToken.primary, DesignToken.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    backgroundImage: profileImage != null && profileImage != ''
                        ? NetworkImage(profileImage)
                        : null,
                    child: profileImage == null || profileImage == ''
                        ? Icon(
                            Icons.person,
                            size: 35,
                            color: DesignToken.primary,
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$firstName $lastName',
                          style: AppTextStyles.nunitoBold.copyWith(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          phone,
                          style: AppTextStyles.nunitoRegular.copyWith(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Points Summary Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            DesignToken.primary.withOpacity(0.1),
                            DesignToken.secondary.withOpacity(0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: DesignToken.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.stars,
                                size: 32,
                                color: DesignToken.secondary,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '$totalPoints',
                                style: AppTextStyles.nunitoBold.copyWith(
                                  fontSize: 36,
                                  color: DesignToken.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.totalPointsLabel,
                            style: AppTextStyles.nunitoRegular.copyWith(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: _getTierColor(tier),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              l10n.tierLabel(tier),
                              style: AppTextStyles.nunitoBold.copyWith(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Delete Button Section
                    if (onDelete != null) ...[
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: DesignToken.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: DesignToken.error.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: DesignToken.error,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.dangerZone,
                                  style: AppTextStyles.nunitoBold.copyWith(
                                    fontSize: 16,
                                    color: DesignToken.error,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              l10n.deleteCarpenterWarning,
                              style: AppTextStyles.nunitoRegular.copyWith(
                                fontSize: 13,
                                color: DesignToken.textDark.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.of(
                                    context,
                                  ).pop(); // Close dialog first
                                  onDelete?.call();
                                },
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 18,
                                ),
                                label: Text(l10n.deleteCarpenter),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: DesignToken.error,
                                  side: BorderSide(
                                    color: DesignToken.error,
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),
                    Text(
                      l10n.recentActivity,
                      style: AppTextStyles.nunitoBold.copyWith(
                        fontSize: 18,
                        color: DesignToken.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),

                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('user_points')
                          .doc(user['userId'])
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(
                                color: DesignToken.primary,
                              ),
                            ),
                          );
                        }

                        if (!snapshot.hasData || !snapshot.data!.exists) {
                          final l10n = AppLocalizations.of(context)!;
                          return Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              l10n.noActivityYet,
                              style: AppTextStyles.nunitoRegular.copyWith(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }

                        final data =
                            snapshot.data!.data() as Map<String, dynamic>;
                        final history = (data['pointsHistory'] ?? []) as List;

                        if (history.isEmpty) {
                          final l10n = AppLocalizations.of(context)!;
                          return Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              l10n.noActivityYet,
                              style: AppTextStyles.nunitoRegular.copyWith(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }

                        final recentHistory = history.reversed
                            .take(10)
                            .toList();

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: recentHistory.length,
                          itemBuilder: (context, index) {
                            final transaction =
                                recentHistory[index] as Map<String, dynamic>;
                            final points = transaction['points'] ?? 0;
                            final reason = transaction['reason'] ?? 'Unknown';
                            final date = transaction['date'] is Timestamp
                                ? (transaction['date'] as Timestamp).toDate()
                                : null;
                            final isPositive = points > 0;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[200]!),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isPositive
                                          ? Colors.green.withOpacity(0.1)
                                          : Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      isPositive ? Icons.add : Icons.remove,
                                      color: isPositive
                                          ? Colors.green
                                          : Colors.red,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          reason,
                                          style: AppTextStyles.nunitoMedium
                                              .copyWith(
                                                fontSize: 14,
                                                color: DesignToken.textDark,
                                              ),
                                        ),
                                        if (date != null)
                                          Text(
                                            DateFormat(
                                              'dd MMM yyyy, hh:mm a',
                                            ).format(date),
                                            style: AppTextStyles.nunitoRegular
                                                .copyWith(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${isPositive ? '+' : ''}$points',
                                    style: AppTextStyles.nunitoBold.copyWith(
                                      fontSize: 16,
                                      color: isPositive
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Color _getTierColor(String tier) {
  switch (tier) {
    case 'Platinum':
      return const Color(0xFF00D4FF);
    case 'Gold':
      return const Color(0xFFFFD700);
    case 'Silver':
      return const Color(0xFFC0C0C0);
    case 'Bronze':
    default:
      return const Color(0xFFCD7F32);
  }
}
