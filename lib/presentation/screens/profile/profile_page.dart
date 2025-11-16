import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:balaji_points/config/theme.dart';
import 'package:balaji_points/services/user_service.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> with WidgetsBindingObserver {
  final UserService _userService = UserService();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUserData();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Reload user data when app comes to foreground
    if (state == AppLifecycleState.resumed) {
      _loadUserData();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final data = await _userService.getCurrentUserData();
      if (mounted) {
        setState(() {
          _userData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getUserDisplayName() {
    if (_userData == null) return 'User';
    final firstName = _userData!['firstName'] as String? ?? '';
    final lastName = _userData!['lastName'] as String? ?? '';
    return '$firstName $lastName'.trim().isEmpty ? 'User' : '$firstName $lastName'.trim();
  }

  String _getUserTier() {
    return _userData?['tier'] as String? ?? 'Bronze';
  }

  int _getUserPoints() {
    return _userData?['totalPoints'] as int? ?? 0;
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Logout',
          style: AppTextStyles.nunitoBold.copyWith(fontSize: 22),
        ),
        content: Text(
          'Are you sure want to logout?',
          style: AppTextStyles.nunitoRegular.copyWith(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'No',
              style: AppTextStyles.nunitoMedium.copyWith(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Yes',
              style: AppTextStyles.nunitoSemiBold.copyWith(fontSize: 16),
            ),
          ),
        ],
      ),
    );

    // If user confirmed logout
    if (shouldLogout == true && context.mounted) {
      try {
        // Sign out from Firebase
        await FirebaseAuth.instance.signOut();

        // Navigate to login screen
        if (context.mounted) {
          context.go('/login');
        }
      } catch (e) {
        // Show error if logout fails
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logout failed: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Column(
        children: [
          // Top Safe Area with Primary Color
          SafeArea(bottom: false, child: Container(color: AppColors.primary)),
          // Content
          Expanded(
            child: Container(
              color: AppColors.woodenBackground,
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          // Compact Profile Info Card
                          Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Profile Avatar
                          Stack(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 28,
                                  backgroundColor: Colors.white,
                                  backgroundImage: _userData?['profileImage'] != null
                                      ? NetworkImage(_userData!['profileImage'] as String)
                                      : null,
                                  child: _userData?['profileImage'] == null
                                      ? const Icon(
                                          Icons.person,
                                          color: AppColors.secondary,
                                          size: 32,
                                        )
                                      : null,
                                ),
                              ),
                              // Edit Button
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.secondary,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.edit,
                                    size: 12,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),

                          // User Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _getUserDisplayName(),
                                  style: AppTextStyles.nunitoBold.copyWith(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: Colors.amber.shade300,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${_getUserTier()} Tier',
                                      style: AppTextStyles.nunitoMedium
                                          .copyWith(
                                            fontSize: 12,
                                            color: Colors.white.withOpacity(
                                              0.9,
                                            ),
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Points Display
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.monetization_on,
                                      color: Colors.amber.shade300,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _getUserPoints().toString().replaceAllMapped(
                                            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                            (Match m) => '${m[1]},',
                                          ),
                                      style: AppTextStyles.nunitoBold.copyWith(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Points',
                                  style: AppTextStyles.nunitoRegular.copyWith(
                                    fontSize: 10,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Content Section
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section Title
                          Text(
                            'Account',
                            style: AppTextStyles.nunitoBold.copyWith(
                              fontSize: 20,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // My Details
                          _buildModernProfileTile(
                            icon: Icons.person_outline,
                            title: 'My Details',
                            subtitle: 'View and edit profile information',
                            iconColor: AppColors.primary,
                            onTap: () {
                              context.push('/edit-profile');
                            },
                          ),
                          const SizedBox(height: 12),

                          // Reward History
                          _buildModernProfileTile(
                            icon: Icons.history_rounded,
                            title: 'Reward History',
                            subtitle: 'View all your rewards and transactions',
                            iconColor: Colors.orange.shade600,
                            onTap: () {},
              ),
              const SizedBox(height: 12),

                          // Settings
                          _buildModernProfileTile(
                            icon: Icons.settings_outlined,
                            title: 'Settings',
                            subtitle: 'App preferences and notifications',
                            iconColor: Colors.grey.shade700,
                            onTap: () {},
                          ),

                          const SizedBox(height: 32),

                          // Section Title
                          Text(
                            'Support',
                            style: AppTextStyles.nunitoBold.copyWith(
                              fontSize: 20,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Help & Support
                          _buildModernProfileTile(
                            icon: Icons.help_outline_rounded,
                            title: 'Help & Support',
                            subtitle: 'Get help and contact support',
                            iconColor: Colors.blue.shade600,
                            onTap: () {
                              _showSupportDialog(context);
                            },
                          ),

                          const SizedBox(height: 32),

                          // Logout Button
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () => _handleLogout(context, ref),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade600,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.logout, size: 22),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Logout',
                                    style: AppTextStyles.nunitoBold.copyWith(
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _makePhoneCall(BuildContext context, String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        throw 'Could not launch $phoneUri';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not make call: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with Gradient
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.support_agent,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Help & Support',
                              style: AppTextStyles.nunitoBold.copyWith(
                                fontSize: 22,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Get in touch with us',
                              style: AppTextStyles.nunitoRegular.copyWith(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Phone Numbers Section with Action Buttons
                      _buildModernContactSection(
                        title: 'Contact Us',
                        icon: Icons.phone_rounded,
                        iconColor: Colors.green.shade600,
                        children: [
                          _buildActionableContactItem(
                            context: context,
                            icon: Icons.phone_android_rounded,
                            label: 'Mobile',
                            value: '96006 - 09121',
                            phoneNumber: '9600609121',
                            onTap: () => _makePhoneCall(context, '9600609121'),
                          ),
                          const SizedBox(height: 12),
                          _buildActionableContactItem(
                            context: context,
                            icon: Icons.phone_rounded,
                            label: 'Landline',
                            value: '0424 - 3557187',
                            phoneNumber: '04243557187',
                            onTap: () => _makePhoneCall(context, '04243557187'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernContactSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: iconColor.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: AppTextStyles.nunitoBold.copyWith(
                  fontSize: 18,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildActionableContactItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required String phoneNumber,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.green.shade700, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.nunitoMedium.copyWith(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: AppTextStyles.nunitoSemiBold.copyWith(
                    fontSize: 16,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Call Button
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade600, Colors.green.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    Icons.call_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernProfileTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
        onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon Container
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),
                // Title and Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.nunitoSemiBold.copyWith(
                          fontSize: 16,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppTextStyles.nunitoRegular.copyWith(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // Arrow Icon
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey[400],
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
