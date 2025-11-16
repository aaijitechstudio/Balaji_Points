import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:balaji_points/config/theme.dart';
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

  void _showUserDetails(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => UserDetailsDialog(user: user),
    );
  }

  void _showAddCarpenterDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddCarpenterDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                        hintText: 'Search by name or phone...',
                        hintStyle: AppTextStyles.nunitoRegular.copyWith(
                          color: Colors.grey[400],
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppColors.primary,
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
                    label: const Text('Add'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
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
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(tier),
                        labelStyle: AppTextStyles.nunitoSemiBold.copyWith(
                          fontSize: 14,
                          color: isSelected ? Colors.white : AppColors.textDark,
                        ),
                        backgroundColor: Colors.grey[200],
                        selectedColor: AppColors.primary,
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
                        'Error loading users',
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
                  child: CircularProgressIndicator(color: AppColors.primary),
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
                        'No Users Found',
                        style: AppTextStyles.nunitoBold.copyWith(
                          fontSize: 20,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _searchQuery.isNotEmpty
                            ? 'Try a different search term'
                            : 'No carpenters registered yet',
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
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: InkWell(
                      onTap: () => _showUserDetails(user),
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Rank Badge
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    AppColors.secondary,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  '#${index + 1}',
                                  style: AppTextStyles.nunitoBold.copyWith(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Profile Image
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: AppColors.primary.withOpacity(
                                0.1,
                              ),
                              backgroundImage:
                                  profileImage != null && profileImage != ''
                                  ? NetworkImage(profileImage)
                                  : null,
                              child: profileImage == null || profileImage == ''
                                  ? const Icon(
                                      Icons.person,
                                      size: 30,
                                      color: AppColors.primary,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),

                            // User Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$firstName $lastName',
                                    style: AppTextStyles.nunitoBold.copyWith(
                                      fontSize: 16,
                                      color: AppColors.textDark,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.phone,
                                        size: 14,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
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
                                  const SizedBox(height: 4),
                                  if (createdAt != null)
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          size: 12,
                                          color: Colors.grey[500],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Joined ${DateFormat('dd MMM yyyy').format(createdAt)}',
                                          style: AppTextStyles.nunitoRegular
                                              .copyWith(
                                                fontSize: 11,
                                                color: Colors.grey[500],
                                              ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),

                            // Points and Tier
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getTierColor(tier),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    tier,
                                    style: AppTextStyles.nunitoBold.copyWith(
                                      fontSize: 11,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.stars,
                                      size: 16,
                                      color: AppColors.secondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$totalPoints',
                                      style: AppTextStyles.nunitoBold.copyWith(
                                        fontSize: 16,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
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
}

/// ---------------------------
/// Add Carpenter Dialog (Phone + OTP)
/// ---------------------------
/// This dialog sends OTP and verifies it. After verification it creates:
/// - FirebaseAuth sign-in with the phone (this will temporarily sign the app in
///   as that phone user)
/// - Firestore users/{uid} doc
/// - Firestore user_points/{uid} doc
/// Then it signs out the newly-signed-in user. IMPORTANT: this signs out the admin too.

class AddCarpenterDialog extends StatefulWidget {
  const AddCarpenterDialog({super.key});

  @override
  State<AddCarpenterDialog> createState() => _AddCarpenterDialogState();
}

class _AddCarpenterDialogState extends State<AddCarpenterDialog> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  String _verificationId = '';
  bool _codeSent = false;
  bool _verifying = false;
  bool _creating = false;

  final _auth = FirebaseAuth.instance;

  void _showSnack(String s) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s)));
  }

  Future<bool> _phoneExists(String phone) async {
    final q = await FirebaseFirestore.instance
        .collection('users')
        .where('phone', isEqualTo: phone)
        .get();
    return q.docs.isNotEmpty;
  }

  Future<void> _sendCode() async {
    final phoneRaw = _phoneController.text.trim();
    if (phoneRaw.isEmpty || phoneRaw.length < 6) {
      _showSnack('Enter a valid phone number');
      return;
    }

    // Normalize: assuming Indian numbers; accept with or without leading 0
    String phone = phoneRaw;
    if (phone.startsWith('0')) phone = phone.substring(1);
    if (!phone.startsWith('+')) phone = '+91$phone'; // change if multi-country

    // check duplicate
    final exists = await _phoneExists(phone);
    if (exists) {
      _showSnack('Phone number already exists');
      return;
    }

    setState(() => _verifying = true);

    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (PhoneAuthCredential credential) {
        // NOTE: automatic verification on Android may call this.
        // We'll try to sign in (and then create user) automatically if possible.
        _signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() => _verifying = false);
        _showSnack('Verification failed: ${e.message}');
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
          _codeSent = true;
          _verifying = false;
        });
        _showSnack('OTP sent');
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
      timeout: const Duration(seconds: 60),
    );
  }

  Future<void> _verifyCodeManually() async {
    final sms = _otpController.text.trim();
    if (sms.isEmpty) {
      _showSnack('Enter OTP');
      return;
    }

    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId,
      smsCode: sms,
    );

    await _signInWithCredential(credential);
  }

  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      setState(() {
        _verifying = true;
      });

      final userCred = await _auth.signInWithCredential(credential);
      final user = userCred.user;
      if (user == null) {
        setState(() => _verifying = false);
        _showSnack('Failed to sign in with OTP');
        return;
      }

      // Create Firestore user document (if not exists)
      final uid = user.uid;
      final phone = user.phoneNumber ?? _phoneController.text.trim();

      final userDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid);
      final doc = await userDocRef.get();
      if (!doc.exists) {
        await userDocRef.set({
          'userId': uid,
          'firstName': '',
          'lastName': '',
          'phone': phone,
          'profileImage': '',
          'role': 'carpenter',
          'totalPoints': 0,
          'tier': 'Bronze',
          'createdAt': Timestamp.now(),
        });
      }

      // create empty points doc if not exists
      final pointsRef = FirebaseFirestore.instance
          .collection('user_points')
          .doc(uid);
      final ptsDoc = await pointsRef.get();
      if (!ptsDoc.exists) {
        await pointsRef.set({'pointsHistory': []});
      }

      setState(() {
        _verifying = false;
        _creating = true;
      });

      // Sign out the newly created carpenter (this will sign out the app)
      await _auth.signOut();

      setState(() {
        _creating = false;
      });

      // Inform admin (they will have been signed out) and close dialog
      _showAdminSignedOutDialog();
    } on FirebaseAuthException catch (e) {
      setState(() {
        _verifying = false;
      });
      _showSnack('Auth error: ${e.message}');
    } catch (e) {
      setState(() {
        _verifying = false;
      });
      _showSnack('Error: $e');
    }
  }

  void _showAdminSignedOutDialog() {
    // After signOut, admin will be signed out too. Let them know to sign back in.
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Carpenter created'),
        content: const Text(
          'Carpenter account created successfully. The app has signed in as that carpenter during verification and has now signed out. You will need to sign in again as admin.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // close this alert
              Navigator.of(context).pop(); // close add dialog
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add Carpenter',
              style: AppTextStyles.nunitoBold.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone number',
                hintText: 'e.g. 9876543210 (no +91)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            if (!_codeSent)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _verifying ? null : _sendCode,
                      child: _verifying
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Send OTP'),
                    ),
                  ),
                ],
              ),
            if (_codeSent) ...[
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Enter OTP',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _verifying ? null : _verifyCodeManually,
                      child: _verifying
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Verify & Create'),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            if (_creating) const CircularProgressIndicator(),
            const SizedBox(height: 8),
            Text(
              'Note: The app will sign in as the verified carpenter temporarily during OTP verification and then sign out. The admin must sign in again.',
              style: AppTextStyles.nunitoRegular.copyWith(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
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
  const UserDetailsDialog({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
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
                  colors: [AppColors.primary, AppColors.secondary],
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
                        ? const Icon(
                            Icons.person,
                            size: 35,
                            color: AppColors.primary,
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
                            AppColors.primary.withOpacity(0.1),
                            AppColors.secondary.withOpacity(0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.stars,
                                size: 32,
                                color: AppColors.secondary,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '$totalPoints',
                                style: AppTextStyles.nunitoBold.copyWith(
                                  fontSize: 36,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Total Points',
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
                              '$tier Tier',
                              style: AppTextStyles.nunitoBold.copyWith(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    Text(
                      'Recent Activity',
                      style: AppTextStyles.nunitoBold.copyWith(
                        fontSize: 18,
                        color: AppColors.textDark,
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
                                color: AppColors.primary,
                              ),
                            ),
                          );
                        }

                        if (!snapshot.hasData || !snapshot.data!.exists) {
                          return Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'No activity yet',
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
                          return Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'No activity yet',
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
                                                color: AppColors.textDark,
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
