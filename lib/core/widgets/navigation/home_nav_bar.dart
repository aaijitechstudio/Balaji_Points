import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:balaji_points/core/theme/design_token.dart';
import 'package:balaji_points/config/theme.dart' hide AppColors;

class HomeNavBar extends StatelessWidget {
  final String? userImageUrl;
  final String? title;
  final String? subtitle;
  final bool showProfileButton;
  final bool showLogo;
  final bool showBackButton;
  final VoidCallback? onProfileTap;
  final VoidCallback? onBackTap;
  final List<Widget>? actions;
  final bool showNotificationButton;
  final int notificationCount;
  final VoidCallback? onNotificationTap;

  const HomeNavBar({
    super.key,
    this.userImageUrl,
    this.title,
    this.subtitle,
    this.showProfileButton = true,
    this.showLogo = true,
    this.showBackButton = false,
    this.onProfileTap,
    this.onBackTap,
    this.actions,
    this.showNotificationButton = false,
    this.notificationCount = 0,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: DesignToken.transparent, // Make transparent to show gradient
      ),
      child: SafeArea(
        bottom: false,
        child: Container(
          height: kToolbarHeight,
          padding: EdgeInsets.symmetric(
            horizontal: DesignToken.spacingLG,
            vertical: DesignToken.spacingXS,
          ),
          decoration: const BoxDecoration(
            color: DesignToken.transparent, // Make transparent to show gradient
          ),
          child: Row(
            children: [
              // Left side - Logo (or Back Button if needed)
              if (showBackButton)
                _buildBackButton(context)
              else if (showLogo)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo with rounded corners
                    Container(
                      padding: EdgeInsets.all(DesignToken.spacingSM),
                      child: Image.asset(
                        'assets/images/balaji_point_logo.png',
                        width: 28,
                        height: 28,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: DesignToken.secondary,
                              borderRadius: DesignToken.borderRadiusSM,
                            ),
                            child: const Icon(
                              Icons.star_rounded,
                              color: DesignToken.white,
                              size: 18,
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: DesignToken.spacingXS),
                    // Title and Subtitle
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title ?? 'Balaji Points',
                          style: AppTextStyles.nunitoBold.copyWith(
                            fontSize: subtitle != null ? 18 : 20,
                            color: DesignToken.white,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            style: AppTextStyles.nunitoRegular.copyWith(
                              fontSize: 12,
                              color: DesignToken.white.withValues(alpha: 0.9),
                              letterSpacing: 0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ],
                )
              else
                const SizedBox.shrink(),

              // Spacer to push actions to right
              const Spacer(),

              // Right side - Actions (Profile and Notifications)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Custom actions if provided
                  if (actions != null && actions!.isNotEmpty)
                    ...actions!,
                  
                  // Notification button
                  if (showNotificationButton)
                    _buildNotificationButton(context),
                  
                  // Profile button
                  if (showProfileButton)
                    _buildProfileButton(context),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationButton(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(
            Icons.notifications_outlined,
            color: DesignToken.white,
            size: 26,
          ),
          onPressed: onNotificationTap,
          tooltip: 'Notifications',
        ),
        if (notificationCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: DesignToken.error,
                shape: BoxShape.circle,
                border: Border.all(color: DesignToken.white, width: 2),
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Center(
                child: Text(
                  notificationCount > 99 ? '99+' : '$notificationCount',
                  style: const TextStyle(
                    color: DesignToken.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProfileButton(BuildContext context) {
    return GestureDetector(
      onTap:
          onProfileTap ??
          () {
            context.push('/profile');
          },
      child: Container(
        width: 40,
        height: 40,
        margin: const EdgeInsets.only(left: 8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: DesignToken.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: DesignToken.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipOval(
          child: userImageUrl != null && userImageUrl!.isNotEmpty
              ? Image.network(
                  userImageUrl!,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: DesignToken.grey200,
                      child: Center(
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                            strokeWidth: 2,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              DesignToken.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: DesignToken.white.withValues(alpha: 0.9),
                      child: const Icon(
                        Icons.person,
                        color: DesignToken.primary,
                        size: 24,
                      ),
                    );
                  },
                )
              : Container(
                  color: DesignToken.white.withValues(alpha: 0.9),
                  child: const Icon(
                    Icons.person,
                    color: DesignToken.primary,
                    size: 24,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: DesignToken.white, size: 24),
      onPressed:
          onBackTap ??
          () {
            if (Navigator.of(context).canPop()) {
              context.pop();
            }
          },
      tooltip: 'Back',
    );
  }
}
