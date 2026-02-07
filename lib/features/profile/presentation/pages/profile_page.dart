import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:balaji_points/l10n/app_localizations.dart';
import 'package:balaji_points/core/theme/design_token.dart';
import 'package:balaji_points/config/theme.dart' hide AppColors;
import 'package:balaji_points/services/user_service.dart';
import 'package:balaji_points/services/session_service.dart';
import 'package:balaji_points/services/fcm_service.dart';
import 'package:balaji_points/core/providers/theme_provider.dart';
import 'package:balaji_points/core/providers/locale_provider.dart';
import 'package:balaji_points/core/widgets/navigation/home_nav_bar.dart';

class ProfilePage extends ConsumerStatefulWidget {
  final bool showBottomNav;

  const ProfilePage({super.key, this.showBottomNav = true});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage>
    with WidgetsBindingObserver {
  final UserService _userService = UserService();
  final SessionService _sessionService = SessionService();
  final FCMService _fcmService = FCMService();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUserData();
    _loadAppVersion();
  }

  Future<void> _handleRefresh() async {
    await _loadUserData();
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _appVersion =
              'Version ${packageInfo.version} (${packageInfo.buildNumber})';
        });
      }
    } catch (e) {
      debugPrint('ProfilePage: Error loading app version: $e');
      if (mounted) {
        setState(() {
          _appVersion = 'Version 1.0.0';
        });
      }
    }
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

  Future<void> _loadUserData({bool forceRefresh = false}) async {
    try {
      debugPrint(
        'ProfilePage: Loading user data (forceRefresh: $forceRefresh)',
      );
      final data = await _userService.getCurrentUserData(
        forceRefresh: forceRefresh,
      );
      if (mounted) {
        setState(() {
          _userData = data;
          _isLoading = false;
        });
        // Debug: Log loaded data
        debugPrint('ProfilePage: User data loaded successfully');
        debugPrint('  firstName: ${data?['firstName']}');
        debugPrint('  lastName: ${data?['lastName']}');
        debugPrint('  profileImage: ${data?['profileImage']}');
      }
    } catch (e) {
      debugPrint('ProfilePage: Error loading user data: $e');
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
    return '$firstName $lastName'.trim().isEmpty
        ? 'User'
        : '$firstName $lastName'.trim();
  }

  String _getUserTier() {
    return _userData?['tier'] as String? ?? 'Bronze';
  }

  int _getUserPoints() {
    return _userData?['totalPoints'] as int? ?? 0;
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;

    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: DesignToken.borderRadiusXL),
        title: Text(
          l10n.logout,
          style: AppTextStyles.nunitoBold.copyWith(fontSize: DesignToken.fontSize2XL),
        ),
        content: Text(
          l10n.logoutConfirmation,
          style: AppTextStyles.nunitoRegular.copyWith(fontSize: DesignToken.fontSizeLG),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              l10n.no,
              style: AppTextStyles.nunitoMedium.copyWith(
                color: Colors.grey[600],
                fontSize: DesignToken.fontSizeLG,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignToken.error,
              foregroundColor: DesignToken.white,
              shape: RoundedRectangleBorder(
                borderRadius: DesignToken.borderRadiusMD,
              ),
            ),
            child: Text(
              l10n.yes,
              style: AppTextStyles.nunitoSemiBold.copyWith(fontSize: DesignToken.fontSizeLG),
            ),
          ),
        ],
      ),
    );

    // If user confirmed logout
    if (shouldLogout == true && context.mounted) {
      try {
        // Delete FCM token before clearing session
        await _fcmService.deleteToken();

        // Clear session (logout)
        await _sessionService.clearSession();

        // Navigate to login screen
        if (context.mounted) {
          context.go('/login');
        }
      } catch (e) {
        // Show error if logout fails
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10n.logoutFailed}: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _onBottomNavTapped(int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/');
        break;
      case 2:
        // Already on profile page
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: DesignToken.primary,
      body: Column(
        children: [
          // Modern Navigation Bar - Consistent height
          HomeNavBar(
            title: l10n.profile,
            showLogo: false,
            showProfileButton:
                false, // Don't show profile button on profile screen
          ),
          // Content with wooden background
          Expanded(
            child: Container(
              color: DesignToken.woodenBackground,
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: DesignToken.primary,
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _handleRefresh,
                      color: DesignToken.primary,
                      backgroundColor: DesignToken.white,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            SizedBox(height: DesignToken.height2XL),

                            // Simple Profile Card
                            Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              padding: DesignToken.paddingAllXL,
                              decoration: BoxDecoration(
                                color: DesignToken.white,
                                borderRadius: DesignToken.borderRadiusLG,
                                boxShadow: [
                                  BoxShadow(
                                    color: DesignToken.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Profile Image
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: DesignToken.primary,
                                        width: 3,
                                      ),
                                    ),
                                    child: ClipOval(
                                      child:
                                          _userData?['profileImage'] != null &&
                                              (_userData!['profileImage']
                                                      as String)
                                                  .isNotEmpty
                                          ? Image.network(
                                              _userData!['profileImage']
                                                  as String,
                                              fit: BoxFit.cover,
                                              semanticLabel: 'Profile picture',
                                              loadingBuilder: (context, child, loadingProgress) {
                                                if (loadingProgress == null)
                                                  return child;
                                                return Container(
                                                  color: DesignToken.secondary
                                                      .withValues(alpha: 0.3),
                                                  child: Center(
                                                    child: CircularProgressIndicator(
                                                      value:
                                                          loadingProgress
                                                                  .expectedTotalBytes !=
                                                              null
                                                          ? loadingProgress
                                                                    .cumulativeBytesLoaded /
                                                                loadingProgress
                                                                    .expectedTotalBytes!
                                                          : null,
                                                      strokeWidth: 3,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                            Color
                                                          >(
                                                            DesignToken.primary,
                                                          ),
                                                    ),
                                                  ),
                                                );
                                              },
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                    debugPrint(
                                                      'ProfilePage: Error loading profile image: $error',
                                                    );
                                                    return Container(
                                                      color:
                                                          DesignToken.secondary,
                                                      child: const Icon(
                                                        Icons.person,
                                                        color:
                                                            DesignToken.white,
                                                        size: 40,
                                                        semanticLabel: 'Default profile picture',
                                                      ),
                                                    );
                                                  },
                                            )
                                          : Container(
                                              color: DesignToken.secondary,
                                              child: const Icon(
                                                Icons.person,
                                                color: DesignToken.white,
                                                size: 40,
                                                semanticLabel: 'Profile picture placeholder',
                                              ),
                                            ),
                                    ),
                                  ),
                                  SizedBox(height: DesignToken.heightLG),

                                  // User Name
                                  Text(
                                    _getUserDisplayName(),
                                    style: AppTextStyles.nunitoBold.copyWith(
                                      fontSize: DesignToken.fontSize2XL,
                                      color: DesignToken.textDark,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: DesignToken.heightXS),

                                  // User Display ID
                                  if (_userData?['userDisplayId'] != null)
                                    Text(
                                      '#BP${_userData!['userDisplayId']}',
                                      style: AppTextStyles.nunitoMedium
                                          .copyWith(
                                            fontSize: DesignToken.fontSizeMD,
                                            color: DesignToken.primary
                                                .withValues(alpha: 0.7),
                                            letterSpacing: 0.5,
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                  SizedBox(height: DesignToken.heightSM),

                                  // Phone Number
                                  if (_userData?['phone'] != null)
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.phone,
                                          size: 16,
                                          color: Colors.grey[600],
                                          semanticLabel: 'Phone number',
                                        ),
                                        SizedBox(width: DesignToken.widthSM),
                                        Text(
                                          _userData!['phone'] as String,
                                          style: AppTextStyles.nunitoRegular
                                              .copyWith(
                                                fontSize: DesignToken.fontSizeMD,
                                                color: Colors.grey[600],
                                              ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  SizedBox(height: DesignToken.heightSM),

                                  // Points and Tier
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.monetization_on,
                                        color: DesignToken.amberShade700,
                                        size: 18,
                                        semanticLabel: 'Points balance',
                                      ),
                                      SizedBox(width: DesignToken.widthXS),
                                      Text(
                                        l10n.points(_getUserPoints()),
                                        style: AppTextStyles.nunitoSemiBold
                                            .copyWith(
                                              fontSize: DesignToken.fontSizeLG,
                                              color: DesignToken.primary,
                                            ),
                                      ),
                                      SizedBox(width: DesignToken.widthMD),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: DesignToken.secondary
                                              .withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          _getUserTier(),
                                          style: AppTextStyles.nunitoSemiBold
                                              .copyWith(
                                                fontSize: DesignToken.fontSizeMD,
                                                color: DesignToken.secondary,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: DesignToken.height2XL),

                            // Simple Menu Items
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Edit Profile Button
                                  _buildSimpleButton(
                                    icon: Icons.edit,
                                    title: l10n.editProfile,
                                    onTap: () async {
                                      // Navigate to edit profile and wait for return
                                      await context.push('/edit-profile');
                                      // Force refresh user data from server when returning
                                      debugPrint(
                                        'ProfilePage: Returned from edit profile, force refreshing data',
                                      );
                                      await _loadUserData(forceRefresh: true);
                                    },
                                  ),
                                  SizedBox(height: DesignToken.heightMD),

                                  // Change PIN Button
                                  _buildSimpleButton(
                                    icon: Icons.lock_reset,
                                    title: l10n.changePin,
                                    onTap: () async {
                                      // Get current phone number from session
                                      final phoneNumber = await _sessionService
                                          .getPhoneNumber();
                                      if (phoneNumber != null &&
                                          context.mounted) {
                                        context.push(
                                          '/pin-reset?phone=$phoneNumber',
                                        );
                                      }
                                    },
                                  ),
                                  SizedBox(height: DesignToken.heightMD),

                                  // Help & Support Button
                                  _buildSimpleButton(
                                    icon: Icons.phone,
                                    title: l10n.helpSupport,
                                    onTap: () => _showSupportDialog(context),
                                  ),
                                  SizedBox(height: DesignToken.heightMD),

                                  // Language Selection Button
                                  _buildLanguageSelector(ref),
                                  SizedBox(height: DesignToken.heightMD),

                                  // Theme Toggle Button
                                  _buildThemeToggleButton(ref),
                                  SizedBox(height: DesignToken.heightMD),

                                  // Notification Settings Button
                                  _buildSimpleButton(
                                    icon: Icons.notifications,
                                    title: 'Notification Settings',
                                    onTap: () {
                                      context.push('/notification-settings');
                                    },
                                  ),

                                  SizedBox(height: DesignToken.height2XL),

                                  // Logout Button
                                  Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(top: DesignToken.paddingSM),
                                    decoration: BoxDecoration(
                                      borderRadius: DesignToken.borderRadiusLG,
                                      boxShadow: [
                                        BoxShadow(
                                          color: DesignToken.error.withOpacity(
                                            0.2,
                                          ),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          _handleLogout(context, ref),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            DesignToken.redShade600,
                                        foregroundColor: DesignToken.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 18,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.logout,
                                            size: 22,
                                            semanticLabel: 'Logout',
                                          ),
                                          SizedBox(width: DesignToken.widthMD),
                                          Text(
                                            l10n.logout,
                                            style: AppTextStyles.nunitoBold
                                                .copyWith(
                                                  fontSize: DesignToken.fontSizeXL,
                                                  color: DesignToken.white,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: DesignToken.heightXL),

                                  // App Version
                                  if (_appVersion.isNotEmpty)
                                    Center(
                                      child: Text(
                                        _appVersion,
                                        style: AppTextStyles.nunitoRegular
                                            .copyWith(
                                              fontSize: DesignToken.fontSizeMD,
                                              color: DesignToken.textDark
                                                  .withOpacity(0.5),
                                            ),
                                      ),
                                    ),

                                  SizedBox(height: DesignToken.heightXL),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: widget.showBottomNav
          ? BottomNavigationBar(
              currentIndex: 2, // Profile tab selected
              onTap: _onBottomNavTapped,
              selectedItemColor: DesignToken.secondary,
              unselectedItemColor: DesignToken.white,
              backgroundColor: DesignToken.primary,
              type: BottomNavigationBarType.fixed,
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(
                    Icons.home,
                    semanticLabel: 'Home',
                  ),
                  label: l10n.home,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(
                    Icons.monetization_on_outlined,
                    semanticLabel: 'Add points',
                  ),
                  label: l10n.addPoints,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(
                    Icons.person_outline,
                    semanticLabel: 'Profile',
                  ),
                  label: l10n.profile,
                ),
              ],
            )
          : null,
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
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: DesignToken.paddingAllXL,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: DesignToken.borderRadius2XL,
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
                  padding: DesignToken.paddingAll2XL,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [DesignToken.primary, DesignToken.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(DesignToken.radius2XL),
                      topRight: Radius.circular(DesignToken.radius2XL),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: DesignToken.paddingAllMD,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: DesignToken.borderRadiusMD,
                        ),
                        child: const Icon(
                          Icons.support_agent,
                          color: Colors.white,
                          size: 28,
                          semanticLabel: 'Help and support',
                        ),
                      ),
                      SizedBox(width: DesignToken.widthLG),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.helpSupport,
                              style: AppTextStyles.nunitoBold.copyWith(
                                fontSize: DesignToken.fontSize2XL,
                                color: DesignToken.white,
                              ),
                            ),
                            SizedBox(height: DesignToken.heightXS),
                            Text(
                              l10n.getInTouch,
                              style: AppTextStyles.nunitoRegular.copyWith(
                                fontSize: DesignToken.fontSizeMD,
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
                          semanticLabel: 'Close dialog',
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Padding(
                  padding: DesignToken.paddingAll2XL,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Phone Numbers Section with Action Buttons
                      _buildModernContactSection(
                        title: l10n.contactUs,
                        icon: Icons.phone_rounded,
                        iconColor: Colors.green.shade600,
                        children: [
                          _buildActionableContactItem(
                            context: context,
                            icon: Icons.phone_android_rounded,
                            label: l10n.mobile,
                            value: l10n.supportPhone1,
                            phoneNumber: '9600609121',
                            onTap: () => _makePhoneCall(context, '9600609121'),
                          ),
                          SizedBox(height: DesignToken.heightMD),
                          _buildActionableContactItem(
                            context: context,
                            icon: Icons.phone_rounded,
                            label: l10n.landline,
                            value: l10n.supportPhone2,
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
      padding: DesignToken.paddingAllXL,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.05),
        borderRadius: DesignToken.borderRadiusLG,
        border: Border.all(color: iconColor.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: DesignToken.paddingAllSM,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: DesignToken.borderRadiusMD,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 22,
                  semanticLabel: title,
                ),
              ),
              SizedBox(width: DesignToken.widthMD),
              Text(
                title,
                style: AppTextStyles.nunitoBold.copyWith(
                  fontSize: DesignToken.fontSizeXL,
                  color: DesignToken.textDark,
                ),
              ),
            ],
          ),
          SizedBox(height: DesignToken.heightLG),
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
      padding: DesignToken.paddingAllLG,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: DesignToken.borderRadiusMD,
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
            padding: DesignToken.paddingAllSM,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: DesignToken.borderRadiusSM,
            ),
            child: Icon(
              icon,
              color: Colors.green.shade700,
              size: 20,
              semanticLabel: label,
            ),
          ),
          SizedBox(width: DesignToken.widthLG),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.nunitoMedium.copyWith(
                    fontSize: DesignToken.fontSizeSM,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: DesignToken.heightSM),
                Text(
                  value,
                  style: AppTextStyles.nunitoSemiBold.copyWith(
                    fontSize: DesignToken.fontSizeLG,
                    color: DesignToken.textDark,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: DesignToken.widthMD),
          // Call Button
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade600, Colors.green.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: DesignToken.borderRadiusMD,
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
                borderRadius: DesignToken.borderRadiusMD,
                onTap: onTap,
                child: Padding(
                  padding: DesignToken.paddingAllMD,
                  child: Icon(
                    Icons.call_rounded,
                    color: Colors.white,
                    size: 22,
                    semanticLabel: 'Call',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: DesignToken.borderRadiusMD,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: DesignToken.borderRadiusMD,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: DesignToken.paddingLG, horizontal: DesignToken.paddingXL),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: DesignToken.primary,
                  size: 24,
                  semanticLabel: title,
                ),
                SizedBox(width: DesignToken.widthLG),
                Text(
                  title,
                  style: AppTextStyles.nunitoSemiBold.copyWith(
                    fontSize: DesignToken.fontSizeLG,
                    color: DesignToken.textDark,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                  semanticLabel: 'Navigate',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isHindi = locale.languageCode == 'hi';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: DesignToken.borderRadiusMD,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: DesignToken.paddingMD, horizontal: DesignToken.paddingXL),
        child: Row(
          children: [
            const Icon(
              Icons.language,
              color: DesignToken.primary,
              size: 24,
              semanticLabel: 'Language',
            ),
            SizedBox(width: DesignToken.widthLG),
            Text(
              isHindi ? 'भाषा' : 'Language',
              style: AppTextStyles.nunitoSemiBold.copyWith(
                fontSize: DesignToken.fontSizeLG,
                color: DesignToken.textDark,
              ),
            ),
            const Spacer(),
            // Language Dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: DesignToken.paddingMD, vertical: DesignToken.paddingXS),
              decoration: BoxDecoration(
                color: DesignToken.primary.withOpacity(0.1),
                borderRadius: DesignToken.borderRadiusSM,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Locale>(
                  value: locale,
                  isDense: true,
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: DesignToken.primary,
                    size: 20,
                    semanticLabel: 'Language dropdown',
                  ),
                  style: AppTextStyles.nunitoSemiBold.copyWith(
                    fontSize: DesignToken.fontSizeMD,
                    color: DesignToken.primary,
                  ),
                  dropdownColor: Colors.white,
                  borderRadius: DesignToken.borderRadiusMD,
                  onChanged: (Locale? newLocale) {
                    if (newLocale != null) {
                      ref.read(localeProvider.notifier).setLocale(newLocale);
                    }
                  },
                  items: const [
                    DropdownMenuItem(
                      value: Locale('en'),
                      child: Text('English'),
                    ),
                    DropdownMenuItem(value: Locale('hi'), child: Text('हिंदी')),
                    DropdownMenuItem(value: Locale('ta'), child: Text('தமிழ்')),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeToggleButton(WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: DesignToken.borderRadiusMD,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: DesignToken.paddingMD, horizontal: DesignToken.paddingXL),
        child: Row(
          children: [
            Icon(
              isDark ? Icons.dark_mode : Icons.light_mode,
              color: DesignToken.primary,
              size: 24,
              semanticLabel: isDark ? 'Dark mode' : 'Light mode',
            ),
            SizedBox(width: DesignToken.widthLG),
            Text(
              l10n.darkMode,
              style: AppTextStyles.nunitoSemiBold.copyWith(
                fontSize: DesignToken.fontSizeLG,
                color: DesignToken.textDark,
              ),
            ),
            const Spacer(),
            Switch(
              value: isDark,
              onChanged: (value) {
                ref.read(themeModeProvider.notifier).toggleTheme();
              },
              activeTrackColor: DesignToken.primary,
            ),
          ],
        ),
      ),
    );
  }
}
