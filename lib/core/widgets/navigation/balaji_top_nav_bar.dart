import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:balaji_points/core/theme/design_token.dart';
import 'package:balaji_points/core/theme/design_token_extensions.dart';

/// Standardized top navigation bar for Balaji Points app
/// Follows iOS and Android material design standards
/// Handles safe area automatically
/// 
/// Features:
/// - Customizable title (text or widget)
/// - Optional leading widget (back button by default)
/// - Optional action buttons on right side
/// - Background color customization
/// - Elevation/shadow control
/// - Center title option
/// - Custom height
/// - Gradient background support
/// - Safe area handling
/// 
/// Example usage:
/// ```dart
/// BalajiTopNavBar(
///   title: 'My Page',
///   onBackPressed: () => Navigator.pop(context),
///   actions: [
///     IconButton(
///       icon: Icon(Icons.settings),
///       onPressed: () {},
///     ),
///   ],
/// )
/// ```
class BalajiTopNavBar extends StatelessWidget implements PreferredSizeWidget {
  /// Title text to display in the navigation bar
  final String? titleText;

  /// Custom title widget (overrides titleText if provided)
  final Widget? titleWidget;

  /// Text style for the title
  final TextStyle? titleStyle;

  /// Whether to center the title (default: true)
  final bool centerTitle;

  /// Whether to show the back button (default: true if can pop)
  final bool? showBackButton;

  /// Custom leading widget (overrides back button if provided)
  final Widget? leading;

  /// Width of the leading widget (default: 56.0)
  final double? leadingWidth;

  /// Callback when back button is pressed (if not provided, uses Navigator.pop)
  final VoidCallback? onBackPressed;

  /// List of action widgets to display on the right side
  final List<Widget>? actions;

  /// Background color of the navigation bar
  final Color? backgroundColor;

  /// Gradient background (overrides backgroundColor if provided)
  final Gradient? backgroundGradient;

  /// Elevation of the navigation bar (default: 0)
  final double elevation;

  /// Whether to show bottom border (default: false)
  final bool showBottomBorder;

  /// Color of the bottom border
  final Color? bottomBorderColor;

  /// Custom height of the navigation bar (default: uses system height)
  final double? height;

  /// Icon color (for back button and actions)
  final Color? iconColor;

  /// Whether to use automatic status bar color adjustment (default: true)
  final bool automaticStatusBarColor;

  /// Status bar brightness (light or dark)
  final Brightness? statusBarBrightness;

  /// Whether to apply safe area (default: true)
  final bool applySafeArea;

  /// Custom bottom widget (e.g., search bar, tabs)
  final Widget? bottom;

  /// Height of the bottom widget
  final double? bottomHeight;

  /// Whether to show shadow (deprecated: use elevation instead)
  @Deprecated('Use elevation parameter instead')
  final bool? showShadow;

  /// Whether the navigation bar is transparent
  final bool isTransparent;

  /// Flex space height (for scrollable content)
  final double? flexibleSpace;

  const BalajiTopNavBar({
    super.key,
    this.titleText,
    this.titleWidget,
    this.titleStyle,
    this.centerTitle = true,
    this.showBackButton,
    this.leading,
    this.leadingWidth,
    this.onBackPressed,
    this.actions,
    this.backgroundColor,
    this.backgroundGradient,
    this.elevation = 0,
    this.showBottomBorder = false,
    this.bottomBorderColor,
    this.height,
    this.iconColor,
    this.automaticStatusBarColor = true,
    this.statusBarBrightness,
    this.applySafeArea = true,
    this.bottom,
    this.bottomHeight,
    @Deprecated('Use elevation parameter instead')
    this.showShadow,
    this.isTransparent = false,
    this.flexibleSpace,
  }) : assert(
          titleText != null || titleWidget != null || flexibleSpace != null,
          'Either titleText, titleWidget, or flexibleSpace must be provided',
        );

  @override
  Size get preferredSize {
    double totalHeight = height ?? kToolbarHeight;
    
    if (applySafeArea) {
      // Add status bar height for safe area
      totalHeight += MediaQueryData.fromView(
        WidgetsBinding.instance.platformDispatcher.views.first,
      ).padding.top;
    }
    
    if (bottom != null && bottomHeight != null) {
      totalHeight += bottomHeight!;
    }
    
    if (flexibleSpace != null) {
      totalHeight += flexibleSpace!;
    }
    
    return Size.fromHeight(totalHeight);
  }

  Color _getBackgroundColor(BuildContext context) {
    if (isTransparent) return Colors.transparent;
    if (backgroundColor != null) return backgroundColor!;
    return Theme.of(context).appBarTheme.backgroundColor ?? 
           context.colors.background;
  }

  Color _getIconColor(BuildContext context) {
    if (iconColor != null) return iconColor!;
    return Theme.of(context).appBarTheme.iconTheme?.color ?? 
           context.colors.textDark;
  }

  TextStyle _getTitleStyle(BuildContext context) {
    if (titleStyle != null) return titleStyle!;
    return Theme.of(context).appBarTheme.titleTextStyle ?? 
           context.text.heading5;
  }

  SystemUiOverlayStyle _getSystemOverlayStyle(BuildContext context) {
    if (statusBarBrightness != null) {
      return statusBarBrightness == Brightness.light
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark;
    }

    if (!automaticStatusBarColor) {
      return SystemUiOverlayStyle.dark;
    }

    // Determine status bar style based on background color brightness
    final bgColor = _getBackgroundColor(context);
    final brightness = ThemeData.estimateBrightnessForColor(bgColor);
    
    return brightness == Brightness.dark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;
  }

  Widget _buildLeading(BuildContext context) {
    // Use custom leading if provided
    if (leading != null) return leading!;

    // Check if should show back button
    final shouldShowBack = showBackButton ?? 
                          (ModalRoute.of(context)?.canPop ?? false);
    
    if (!shouldShowBack) return const SizedBox.shrink();

    // Build back button based on platform
    return IconButton(
      icon: Icon(
        Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
        color: _getIconColor(context),
        size: context.icons.lg,
      ),
      onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
      tooltip: 'Back',
    );
  }

  Widget _buildTitle(BuildContext context) {
    if (titleWidget != null) return titleWidget!;
    
    if (titleText == null) return const SizedBox.shrink();
    
    return Text(
      titleText!,
      style: _getTitleStyle(context),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
  }

  Widget _buildAppBarContent(BuildContext context) {
    Widget appBar = AppBar(
      systemOverlayStyle: _getSystemOverlayStyle(context),
      leading: _buildLeading(context),
      leadingWidth: leadingWidth,
      title: _buildTitle(context),
      centerTitle: centerTitle,
      actions: actions,
      backgroundColor: isTransparent ? Colors.transparent : null,
      elevation: elevation,
      automaticallyImplyLeading: false,
      flexibleSpace: flexibleSpace != null
          ? Container(
              height: flexibleSpace,
              decoration: backgroundGradient != null
                  ? BoxDecoration(gradient: backgroundGradient)
                  : null,
            )
          : null,
      bottom: bottom != null
          ? PreferredSize(
              preferredSize: Size.fromHeight(bottomHeight ?? 0),
              child: bottom!,
            )
          : null,
    );

    // Apply background gradient if provided and no flexible space
    if (backgroundGradient != null && flexibleSpace == null) {
      appBar = Container(
        decoration: BoxDecoration(gradient: backgroundGradient),
        child: appBar,
      );
    }

    // Apply background color override if provided
    if (backgroundColor != null && backgroundGradient == null) {
      appBar = Theme(
        data: Theme.of(context).copyWith(
          appBarTheme: Theme.of(context).appBarTheme.copyWith(
                backgroundColor: backgroundColor,
              ),
        ),
        child: appBar,
      );
    }

    // Add bottom border if requested
    if (showBottomBorder) {
      appBar = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(child: appBar),
          Container(
            height: 1,
            color: bottomBorderColor ?? 
                   context.colors.grey300,
          ),
        ],
      );
    }

    return appBar;
  }

  @override
  Widget build(BuildContext context) {
    Widget navBar = _buildAppBarContent(context);

    // Wrap in SafeArea if requested
    if (applySafeArea) {
      navBar = SafeArea(
        bottom: false,
        child: navBar,
      );
    }

    return navBar;
  }
}

/// Preset navigation bar configurations for common use cases
class BalajiTopNavBarPresets {
  BalajiTopNavBarPresets._();

  /// Default navigation bar with white background
  static BalajiTopNavBar standard({
    required String title,
    VoidCallback? onBackPressed,
    List<Widget>? actions,
    bool centerTitle = true,
  }) {
    return BalajiTopNavBar(
      titleText: title,
      onBackPressed: onBackPressed,
      actions: actions,
      centerTitle: centerTitle,
      backgroundColor: DesignToken.background,
      elevation: 0,
      showBottomBorder: true,
    );
  }

  /// Transparent navigation bar (for pages with custom backgrounds)
  static BalajiTopNavBar transparent({
    required String title,
    VoidCallback? onBackPressed,
    List<Widget>? actions,
    Color? iconColor,
    TextStyle? titleStyle,
  }) {
    return BalajiTopNavBar(
      titleText: title,
      onBackPressed: onBackPressed,
      actions: actions,
      isTransparent: true,
      iconColor: iconColor ?? DesignToken.white,
      titleStyle: titleStyle ?? 
                  DesignToken.heading5.copyWith(color: DesignToken.white),
      elevation: 0,
    );
  }

  /// Navigation bar with primary color background
  static BalajiTopNavBar primary({
    required String title,
    VoidCallback? onBackPressed,
    List<Widget>? actions,
    bool centerTitle = true,
  }) {
    return BalajiTopNavBar(
      titleText: title,
      onBackPressed: onBackPressed,
      actions: actions,
      centerTitle: centerTitle,
      backgroundColor: DesignToken.primary,
      iconColor: DesignToken.white,
      titleStyle: DesignToken.heading5.copyWith(color: DesignToken.white),
      elevation: 2,
    );
  }

  /// Navigation bar with gradient background
  static BalajiTopNavBar gradient({
    required String title,
    VoidCallback? onBackPressed,
    List<Widget>? actions,
    Gradient? gradient,
    bool centerTitle = true,
  }) {
    return BalajiTopNavBar(
      titleText: title,
      onBackPressed: onBackPressed,
      actions: actions,
      centerTitle: centerTitle,
      backgroundGradient: gradient ??
          LinearGradient(
            colors: DesignToken.primaryGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
      iconColor: DesignToken.white,
      titleStyle: DesignToken.heading5.copyWith(color: DesignToken.white),
      elevation: 2,
    );
  }

  /// Navigation bar without back button
  static BalajiTopNavBar noBack({
    required String title,
    List<Widget>? actions,
    Color? backgroundColor,
    bool centerTitle = true,
  }) {
    return BalajiTopNavBar(
      titleText: title,
      showBackButton: false,
      actions: actions,
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? DesignToken.background,
      showBottomBorder: true,
    );
  }

  /// Navigation bar with custom leading widget
  static BalajiTopNavBar custom({
    String? title,
    Widget? titleWidget,
    Widget? leading,
    List<Widget>? actions,
    Color? backgroundColor,
    double elevation = 0,
    bool centerTitle = true,
  }) {
    return BalajiTopNavBar(
      titleText: title,
      titleWidget: titleWidget,
      leading: leading,
      actions: actions,
      backgroundColor: backgroundColor,
      elevation: elevation,
      centerTitle: centerTitle,
    );
  }

  /// Navigation bar for modal sheets (with close button)
  static BalajiTopNavBar modal({
    required String title,
    required VoidCallback onClose,
    List<Widget>? actions,
    bool centerTitle = true,
  }) {
    return BalajiTopNavBar(
      titleText: title,
      centerTitle: centerTitle,
      showBackButton: false,
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: onClose,
        tooltip: 'Close',
      ),
      actions: actions,
      backgroundColor: DesignToken.background,
      showBottomBorder: true,
    );
  }
}
