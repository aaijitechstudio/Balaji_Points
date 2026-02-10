// lib/core/widgets/navigation/unified_app_bar.dart
// UNIFIED APP BAR - Single app bar widget for entire app
// Combines best features of HomeNavBar and BalajiTopNavBar

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:balaji_points/core/theme/design_token.dart';
import 'package:balaji_points/config/theme.dart' hide AppColors;

/// Unified app bar for all screens in Balaji Points app
///
/// Features:
/// - Logo display (optional)
/// - Title (text or widget)
/// - Back button (automatic or custom)
/// - Profile button with image (optional)
/// - Notification button with badge (optional)
/// - Custom actions (optional)
/// - Gradient or solid background
/// - Design token integration
///
/// Usage Examples:
///
/// **Simple page with back button:**
/// ```dart
/// UnifiedAppBar(title: 'Profile')
/// ```
///
/// **Home screen with logo, notifications, profile:**
/// ```dart
/// UnifiedAppBar(
///   showLogo: true,
///   showNotificationButton: true,
///   notificationCount: 5,
///   onNotificationTap: () => context.push('/notifications'),
///   showProfileButton: true,
///   userImageUrl: userImage,
/// )
/// ```
///
/// **Custom transparent app bar:**
/// ```dart
/// UnifiedAppBar(
///   title: 'Bills',
///   backgroundColor: Colors.transparent,
/// )
/// ```
class UnifiedAppBar extends StatelessWidget {
  // ============================================================================
  // TITLE
  // ============================================================================

  /// Title text to display
  final String? title;

  /// Custom title widget (overrides title if provided)
  final Widget? titleWidget;

  /// Title text style
  final TextStyle? titleStyle;

  /// Subtitle text (shows below title)
  final String? subtitle;

  // ============================================================================
  // LOGO
  // ============================================================================

  /// Whether to show the Balaji Points logo
  final bool showLogo;

  /// Custom logo widget (overrides default logo)
  final Widget? customLogo;

  // ============================================================================
  // BACK BUTTON
  // ============================================================================

  /// Whether to show back button (auto-detects if Navigator can pop)
  final bool? showBackButton;

  /// Custom back button callback
  final VoidCallback? onBackPressed;

  /// Custom leading widget (overrides back button)
  final Widget? leading;

  // ============================================================================
  // PROFILE BUTTON
  // ============================================================================

  /// Whether to show profile button on right
  final bool showProfileButton;

  /// User profile image URL
  final String? userImageUrl;

  /// Callback when profile button is tapped
  final VoidCallback? onProfileTap;

  // ============================================================================
  // NOTIFICATION BUTTON
  // ============================================================================

  /// Whether to show notification button
  final bool showNotificationButton;

  /// Notification count for badge
  final int notificationCount;

  /// Callback when notification button is tapped
  final VoidCallback? onNotificationTap;

  // ============================================================================
  // ACTIONS
  // ============================================================================

  /// Custom action widgets to display on right (before profile/notifications)
  final List<Widget>? actions;

  // ============================================================================
  // STYLING
  // ============================================================================

  /// Background color (null for transparent)
  final Color? backgroundColor;

  /// Background gradient (overrides backgroundColor if provided)
  final Gradient? backgroundGradient;

  /// Icon color (for back button, notifications, etc.)
  final Color? iconColor;

  /// Text color (for title)
  final Color? textColor;

  /// Whether to show bottom border
  final bool showBottomBorder;

  /// Elevation/shadow depth
  final double elevation;

  const UnifiedAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.titleStyle,
    this.subtitle,
    this.showLogo = false,
    this.customLogo,
    this.showBackButton,
    this.onBackPressed,
    this.leading,
    this.showProfileButton = false,
    this.userImageUrl,
    this.onProfileTap,
    this.showNotificationButton = false,
    this.notificationCount = 0,
    this.onNotificationTap,
    this.actions,
    this.backgroundColor,
    this.backgroundGradient,
    this.iconColor,
    this.textColor,
    this.showBottomBorder = false,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    // Determine colors based on background
    final bool isTransparent =
        backgroundColor == DesignToken.transparent || backgroundColor == null;
    final bool isDark =
        backgroundColor == DesignToken.secondary || backgroundGradient != null;

    final effectiveIconColor =
        iconColor ??
        (isDark || isTransparent ? DesignToken.white : DesignToken.textDark);
    final effectiveTextColor =
        textColor ??
        (isDark || isTransparent ? DesignToken.white : DesignToken.textDark);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        gradient: backgroundGradient,
        border: showBottomBorder
            ? Border(bottom: BorderSide(color: DesignToken.grey200, width: 1))
            : null,
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color: DesignToken.black.withValues(alpha: 0.1),
                  blurRadius: elevation * 2,
                  offset: Offset(0, elevation),
                ),
              ]
            : null,
      ),
      child: SafeArea(
        bottom: false,
        child: Container(
          height: kToolbarHeight,
          padding: EdgeInsets.symmetric(
            horizontal: DesignToken.spacingLG,
            vertical: DesignToken.spacingXS,
          ),
          child: Row(
            children: [
              // LEFT SIDE - Leading widget, back button, or logo
              _buildLeftSide(context, effectiveIconColor, effectiveTextColor),

              // SPACER
              const Spacer(),

              // RIGHT SIDE - Actions, notifications, profile
              _buildRightSide(context, effectiveIconColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeftSide(
    BuildContext context,
    Color iconColor,
    Color textColor,
  ) {
    // Custom leading widget takes priority
    if (leading != null) {
      return leading!;
    }

    // Back button (if can pop or explicitly requested)
    final shouldShowBack = showBackButton ?? Navigator.of(context).canPop();
    if (shouldShowBack && !showLogo) {
      return IconButton(
        icon: Icon(Icons.arrow_back, color: iconColor),
        onPressed:
            onBackPressed ??
            () {
              if (Navigator.of(context).canPop()) {
                context.pop();
              }
            },
        tooltip: 'Back',
      );
    }

    // Logo + Title layout
    if (showLogo) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo
          customLogo ?? _buildDefaultLogo(),
          SizedBox(width: DesignToken.spacingXS),

          // Title and subtitle
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              titleWidget ??
                  Text(
                    title ?? 'Balaji Points',
                    style:
                        titleStyle ??
                        AppTextStyles.nunitoBold.copyWith(
                          fontSize: subtitle != null ? 18 : 20,
                          color: textColor,
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
                    color: textColor.withValues(alpha: 0.9),
                    letterSpacing: 0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ],
      );
    }

    // Just title (no logo, no back button)
    return titleWidget ??
        Text(
          title ?? '',
          style:
              titleStyle ??
              AppTextStyles.nunitoBold.copyWith(
                fontSize: DesignToken.fontSize2XL,
                color: textColor,
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
  }

  Widget _buildDefaultLogo() {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: DesignToken.white.withValues(alpha: 0.9),
        borderRadius: DesignToken.borderRadiusXS,

        boxShadow: [
          BoxShadow(
            color: DesignToken.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
    );
  }

  Widget _buildRightSide(BuildContext context, Color iconColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Custom actions
        if (actions != null && actions!.isNotEmpty) ...actions!,

        // Notification button
        if (showNotificationButton) _buildNotificationButton(iconColor),

        // Profile button
        if (showProfileButton) _buildProfileButton(context),
      ],
    );
  }

  Widget _buildNotificationButton(Color iconColor) {
    return Stack(
      children: [
        IconButton(
          icon: Icon(Icons.notifications_outlined, color: iconColor, size: 26),
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
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
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
      onTap: onProfileTap ?? () => context.push('/profile'),
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
                      child: const Center(
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              DesignToken.primary,
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
}
