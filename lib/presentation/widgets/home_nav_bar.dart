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
  });

  @override
  Widget build(BuildContext context) {
    // Debug: Log the image URL
    if (userImageUrl != null && userImageUrl!.isNotEmpty) {
      debugPrint('HomeNavBar: Loading profile image from: $userImageUrl');
    } else {
      debugPrint('HomeNavBar: No profile image URL available');
    }

    final theme = Theme.of(context);
    final appBarColor =
        theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface;
    final appBarForeground =
        theme.appBarTheme.foregroundColor ?? theme.colorScheme.onSurface;

    return Container(
      color: appBarColor,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: kToolbarHeight, // Material Design standard: 56dp
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: appBarColor,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Left side - Profile Image, Back Button, or empty space
              if (showProfileButton)
                _buildProfileButton(context)
              else if (showBackButton)
                _buildBackButton(context)
              else
                const SizedBox(width: 44),

              // Center - Logo and Title
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (showLogo) ...[
                      // Logo with modern styling
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
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
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.star,
                                color: Colors.white,
                                size: 18,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    // Title and Subtitle
                    Flexible(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: showLogo
                            ? CrossAxisAlignment.start
                            : CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title ?? 'Balaji Points',
                            style: AppTextStyles.nunitoBold.copyWith(
                              fontSize: subtitle != null ? 18 : 22,
                              color: appBarForeground,
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
                                fontSize: 11,
                                color: appBarForeground.withValues(alpha: 0.7),
                                letterSpacing: 0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Right side - Actions or Balance space
              if (actions != null && actions!.isNotEmpty)
                Row(mainAxisSize: MainAxisSize.min, children: actions!)
              else
                const SizedBox(width: 44),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileButton(BuildContext context) {
    return GestureDetector(
      onTap:
          onProfileTap ??
          () {
            debugPrint('Profile button tapped, navigating to /profile');
            context.push('/profile');
          },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.2),
              Colors.white.withValues(alpha: 0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipOval(
          child: userImageUrl != null && userImageUrl!.isNotEmpty
              ? Image.network(
                  userImageUrl!,
                  key: ValueKey<String>(userImageUrl!),
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: DesignToken.secondary.withValues(alpha: 0.3),
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
                              Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint('HomeNavBar: Error loading image: $error');
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            DesignToken.secondary,
                            DesignToken.secondary.withValues(alpha: 0.8),
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 24,
                      ),
                    );
                  },
                )
              : Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        DesignToken.secondary,
                        DesignToken.secondary.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    final theme = Theme.of(context);
    final appBarForeground =
        theme.appBarTheme.foregroundColor ?? theme.colorScheme.onSurface;
    return IconButton(
      icon: Icon(Icons.arrow_back, color: appBarForeground, size: 24),
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
