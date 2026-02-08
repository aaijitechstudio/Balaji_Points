import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:balaji_points/core/theme/design_token.dart';
import 'package:balaji_points/config/theme.dart';
import 'package:balaji_points/services/session_service.dart';
import 'package:balaji_points/core/utils/app_logger.dart';
import 'package:balaji_points/core/widgets/navigation/home_nav_bar.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SessionService _sessionService = SessionService();
  bool _isLoading = true;

  // Notification preferences
  bool _enabled = true;
  bool _billApproved = true;
  bool _billRejected = true;
  bool _pointsWithdrawn = true;
  bool _tierUpgraded = true;
  bool _dailySpin = true;
  bool _newOffers = true;

  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      setState(() => _isLoading = true);

      // Get user ID
      final phoneNumber = await _sessionService.getPhoneNumber();
      final sessionUserId = await _sessionService.getUserId();
      _userId = sessionUserId ?? phoneNumber;

      if (_userId == null || _userId!.isEmpty) {
        AppLogger.warning('No user ID found for notification preferences');
        setState(() => _isLoading = false);
        return;
      }

      // Load preferences from Firestore
      final userDoc = await _firestore.collection('users').doc(_userId!).get();

      if (userDoc.exists) {
        final userData = userDoc.data();
        final prefs =
            userData?['notificationPreferences'] as Map<String, dynamic>?;

        if (prefs != null) {
          setState(() {
            _enabled = prefs['enabled'] as bool? ?? true;
            _billApproved = prefs['billApproved'] as bool? ?? true;
            _billRejected = prefs['billRejected'] as bool? ?? true;
            _pointsWithdrawn = prefs['pointsWithdrawn'] as bool? ?? true;
            _tierUpgraded = prefs['tierUpgraded'] as bool? ?? true;
            _dailySpin = prefs['dailySpin'] as bool? ?? true;
            _newOffers = prefs['newOffers'] as bool? ?? true;
          });
        }
      }
    } catch (e) {
      AppLogger.error('Error loading notification preferences', error:  e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading preferences: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _savePreferences() async {
    if (_userId == null || _userId!.isEmpty) {
      AppLogger.warning('Cannot save preferences: No user ID');
      return;
    }

    try {
      await _firestore.collection('users').doc(_userId!).set({
        'notificationPreferences': {
          'enabled': _enabled,
          'billApproved': _billApproved,
          'billRejected': _billRejected,
          'pointsWithdrawn': _pointsWithdrawn,
          'tierUpgraded': _tierUpgraded,
          'dailySpin': _dailySpin,
          'newOffers': _newOffers,
        },
      }, SetOptions(merge: true));

      AppLogger.info('Notification preferences saved successfully');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification preferences saved'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      AppLogger.error('Error saving notification preferences', error:  e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving preferences: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignToken.primary,
      body: Column(
        children: [
          // Navigation Bar
          HomeNavBar(
            title: 'Notification Settings',
            showLogo: false,
            showProfileButton: false,
            showBackButton: true,
          ),
          // Content
          Expanded(
            child: Container(
              color: DesignToken.woodenBackground,
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: DesignToken.primary,
                      ),
                    )
                  : SingleChildScrollView(
                      padding: DesignToken.paddingAllXL,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: DesignToken.heightXL),
                          // Master Switch
                          _buildMasterSwitch(),
                          SizedBox(height: DesignToken.height2XL),
                          // Notification Types
                          if (_enabled) ...[
                            _buildSectionTitle('Bill Notifications'),
                            SizedBox(height: DesignToken.heightMD),
                            _buildPreferenceSwitch(
                              title: 'Bill Approved',
                              subtitle:
                                  'Get notified when your bill is approved',
                              icon: Icons.check_circle,
                              iconColor: Colors.green,
                              value: _billApproved,
                              onChanged: (value) {
                                setState(() => _billApproved = value);
                                _savePreferences();
                              },
                            ),
                            SizedBox(height: DesignToken.heightMD),
                            _buildPreferenceSwitch(
                              title: 'Bill Rejected',
                              subtitle:
                                  'Get notified when your bill is rejected',
                              icon: Icons.cancel,
                              iconColor: Colors.orange,
                              value: _billRejected,
                              onChanged: (value) {
                                setState(() => _billRejected = value);
                                _savePreferences();
                              },
                            ),
                            SizedBox(height: DesignToken.heightMD),
                            _buildPreferenceSwitch(
                              title: 'Points Withdrawn',
                              subtitle:
                                  'Get notified when points are withdrawn',
                              icon: Icons.remove_circle,
                              iconColor: Colors.red,
                              value: _pointsWithdrawn,
                              onChanged: (value) {
                                setState(() => _pointsWithdrawn = value);
                                _savePreferences();
                              },
                            ),
                            SizedBox(height: DesignToken.height2XL),
                            _buildSectionTitle('Achievement Notifications'),
                            SizedBox(height: DesignToken.heightMD),
                            _buildPreferenceSwitch(
                              title: 'Tier Upgraded',
                              subtitle:
                                  'Get notified when you upgrade to a new tier',
                              icon: Icons.stars,
                              iconColor: Colors.amber,
                              value: _tierUpgraded,
                              onChanged: (value) {
                                setState(() => _tierUpgraded = value);
                                _savePreferences();
                              },
                            ),
                            SizedBox(height: DesignToken.height2XL),
                            _buildSectionTitle('Activity Notifications'),
                            SizedBox(height: DesignToken.heightMD),
                            _buildPreferenceSwitch(
                              title: 'Daily Spin',
                              subtitle:
                                  'Get notified when you win points from daily spin',
                              icon: Icons.casino,
                              iconColor: Colors.purple,
                              value: _dailySpin,
                              onChanged: (value) {
                                setState(() => _dailySpin = value);
                                _savePreferences();
                              },
                            ),
                            SizedBox(height: DesignToken.heightMD),
                            _buildPreferenceSwitch(
                              title: 'New Offers',
                              subtitle:
                                  'Get notified when new offers are available',
                              icon: Icons.card_giftcard,
                              iconColor: Colors.blue,
                              value: _newOffers,
                              onChanged: (value) {
                                setState(() => _newOffers = value);
                                _savePreferences();
                              },
                            ),
                          ],
                          SizedBox(height: DesignToken.height4XL),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMasterSwitch() {
    return Container(
      padding: DesignToken.paddingAllXL,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: DesignToken.borderRadiusLG,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: DesignToken.paddingAllMD,
            decoration: BoxDecoration(
              color: DesignToken.primary.withOpacity(0.1),
              borderRadius: DesignToken.borderRadiusMD,
            ),
            child: Icon(
              Icons.notifications_active,
              color: DesignToken.primary,
              size: 28,
            ),
          ),
          SizedBox(width: DesignToken.widthLG),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enable Notifications',
                  style: AppTextStyles.nunitoBold.copyWith(
                    fontSize: DesignToken.fontSizeXL,
                    color: DesignToken.textDark,
                  ),
                ),
                SizedBox(height: DesignToken.heightXS),
                Text(
                  _enabled
                      ? 'You will receive notifications'
                      : 'All notifications are disabled',
                  style: AppTextStyles.nunitoRegular.copyWith(
                    fontSize: DesignToken.fontSizeMD,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _enabled,
            onChanged: (value) {
              setState(() => _enabled = value);
              _savePreferences();
            },
            activeTrackColor: DesignToken.primary,
            activeColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: AppTextStyles.nunitoBold.copyWith(
          fontSize: DesignToken.fontSizeLG,
          color: DesignToken.textDark,
        ),
      ),
    );
  }

  Widget _buildPreferenceSwitch({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool value,
    required ValueChanged<bool> onChanged,
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
              color: iconColor.withOpacity(0.1),
              borderRadius: DesignToken.borderRadiusSM,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          SizedBox(width: DesignToken.widthLG),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.nunitoSemiBold.copyWith(
                    fontSize: DesignToken.fontSizeLG,
                    color: DesignToken.textDark,
                  ),
                ),
                SizedBox(height: DesignToken.heightXS),
                Text(
                  subtitle,
                  style: AppTextStyles.nunitoRegular.copyWith(
                    fontSize: DesignToken.fontSizeMD,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: DesignToken.widthMD),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: DesignToken.primary,
            activeColor: Colors.white,
          ),
        ],
      ),
    );
  }
}
