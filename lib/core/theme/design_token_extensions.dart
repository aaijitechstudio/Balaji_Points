import 'package:flutter/material.dart';
import 'package:balaji_points/core/theme/design_token.dart';

/// Extensions for easy access to design tokens from BuildContext
/// Usage: context.colors.primary, context.spacing.lg, context.text.heading1
extension DesignTokenContext on BuildContext {
  /// Access color tokens
  DesignTokenColors get colors => const DesignTokenColors();

  /// Access spacing tokens
  DesignTokenSpacing get spacing => const DesignTokenSpacing();

  /// Access text style tokens
  DesignTokenText get text => const DesignTokenText();

  /// Access border radius tokens
  DesignTokenRadius get radius => const DesignTokenRadius();

  /// Access icon size tokens
  DesignTokenIcons get icons => const DesignTokenIcons();

  /// Access elevation tokens
  DesignTokenElevation get elevation => const DesignTokenElevation();
}

/// Color tokens accessor
class DesignTokenColors {
  const DesignTokenColors();

  // Brand Colors
  Color get primary => DesignToken.primary;
  Color get secondary => DesignToken.secondary;
  Color get background => DesignToken.background;
  Color get textDark => DesignToken.textDark;

  // Status Colors
  Color get success => DesignToken.success;
  Color get warning => DesignToken.warning;
  Color get error => DesignToken.error;
  Color get info => DesignToken.info;

  // Neutral Colors
  Color get white => DesignToken.white;
  Color get black => DesignToken.black;
  Color get grey50 => DesignToken.grey50;
  Color get grey100 => DesignToken.grey100;
  Color get grey200 => DesignToken.grey200;
  Color get grey300 => DesignToken.grey300;
  Color get grey400 => DesignToken.grey400;
  Color get grey500 => DesignToken.grey500;
  Color get grey600 => DesignToken.grey600;
  Color get grey700 => DesignToken.grey700;
  Color get grey800 => DesignToken.grey800;
  Color get grey900 => DesignToken.grey900;

  // Tier Colors
  Color get tierPlatinum => DesignToken.tierPlatinum;
  Color get tierGold => DesignToken.tierGold;
  Color get tierSilver => DesignToken.tierSilver;
  Color get tierBronze => DesignToken.tierBronze;

  // Special Colors
  Color get navyBackground => DesignToken.navyBackground;

  // Gradients
  List<Color> get primaryGradient => DesignToken.primaryGradient;
  List<Color> get secondaryGradient => DesignToken.secondaryGradient;
  List<Color> get successGradient => DesignToken.successGradient;
}

/// Spacing tokens accessor
class DesignTokenSpacing {
  const DesignTokenSpacing();

  // Spacing values
  double get xs => DesignToken.spacingXS;
  double get sm => DesignToken.spacingSM;
  double get md => DesignToken.spacingMD;
  double get lg => DesignToken.spacingLG;
  double get xl => DesignToken.spacingXL;
  double get xl2 => DesignToken.spacing2XL;
  double get xl3 => DesignToken.spacing3XL;
  double get xl4 => DesignToken.spacing4XL;
  double get xl5 => DesignToken.spacing5XL;
  double get xl6 => DesignToken.spacing6XL;

  // EdgeInsets presets
  EdgeInsets get paddingXS => DesignToken.paddingAllXS;
  EdgeInsets get paddingSM => DesignToken.paddingAllSM;
  EdgeInsets get paddingMD => DesignToken.paddingAllMD;
  EdgeInsets get paddingLG => DesignToken.paddingAllLG;
  EdgeInsets get paddingXL => DesignToken.paddingAllXL;
  EdgeInsets get paddingXL2 => DesignToken.paddingAll2XL;
  EdgeInsets get paddingXL3 => DesignToken.paddingAll3XL;

  EdgeInsets get paddingHorizontalSM => DesignToken.paddingHorizontalSM;
  EdgeInsets get paddingHorizontalMD => DesignToken.paddingHorizontalMD;
  EdgeInsets get paddingHorizontalLG => DesignToken.paddingHorizontalLG;
  EdgeInsets get paddingHorizontalXL => DesignToken.paddingHorizontalXL;
  EdgeInsets get paddingHorizontalXL2 => DesignToken.paddingHorizontal2XL;

  EdgeInsets get paddingVerticalSM => DesignToken.paddingVerticalSM;
  EdgeInsets get paddingVerticalMD => DesignToken.paddingVerticalMD;
  EdgeInsets get paddingVerticalLG => DesignToken.paddingVerticalLG;
  EdgeInsets get paddingVerticalXL => DesignToken.paddingVerticalXL;
  EdgeInsets get paddingVerticalXL2 => DesignToken.paddingVertical2XL;

  // SizedBox helpers
  SizedBox get heightXS => const SizedBox(height: DesignToken.heightXS);
  SizedBox get heightSM => const SizedBox(height: DesignToken.heightSM);
  SizedBox get heightMD => const SizedBox(height: DesignToken.heightMD);
  SizedBox get heightLG => const SizedBox(height: DesignToken.heightLG);
  SizedBox get heightXL => const SizedBox(height: DesignToken.heightXL);
  SizedBox get heightXL2 => const SizedBox(height: DesignToken.height2XL);
  SizedBox get heightXL3 => const SizedBox(height: DesignToken.height3XL);
  SizedBox get heightXL4 => const SizedBox(height: DesignToken.height4XL);

  SizedBox get widthXS => const SizedBox(width: DesignToken.widthXS);
  SizedBox get widthSM => const SizedBox(width: DesignToken.widthSM);
  SizedBox get widthMD => const SizedBox(width: DesignToken.widthMD);
  SizedBox get widthLG => const SizedBox(width: DesignToken.widthLG);
  SizedBox get widthXL => const SizedBox(width: DesignToken.widthXL);
  SizedBox get widthXL2 => const SizedBox(width: DesignToken.width2XL);
  SizedBox get widthXL3 => const SizedBox(width: DesignToken.width3XL);
}

/// Text style tokens accessor
class DesignTokenText {
  const DesignTokenText();

  // Heading styles
  TextStyle get heading1 => DesignToken.heading1;
  TextStyle get heading2 => DesignToken.heading2;
  TextStyle get heading3 => DesignToken.heading3;
  TextStyle get heading4 => DesignToken.heading4;
  TextStyle get heading5 => DesignToken.heading5;
  TextStyle get heading6 => DesignToken.heading6;

  // Body styles
  TextStyle get bodyLarge => DesignToken.bodyLarge;
  TextStyle get bodyMedium => DesignToken.bodyMedium;
  TextStyle get bodySmall => DesignToken.bodySmall;

  // Label styles
  TextStyle get labelLarge => DesignToken.labelLarge;
  TextStyle get labelMedium => DesignToken.labelMedium;
  TextStyle get labelSmall => DesignToken.labelSmall;

  // Weight variations
  TextStyle get regular => DesignToken.textRegular;
  TextStyle get medium => DesignToken.textMedium;
  TextStyle get semiBold => DesignToken.textSemiBold;
  TextStyle get bold => DesignToken.textBold;

  // Font sizes
  double get xs => DesignToken.fontSizeXS;
  double get sm => DesignToken.fontSizeSM;
  double get md => DesignToken.fontSizeMD;
  double get lg => DesignToken.fontSizeLG;
  double get xl => DesignToken.fontSizeXL;
  double get xl2 => DesignToken.fontSize2XL;
  double get xl3 => DesignToken.fontSize3XL;
  double get xl4 => DesignToken.fontSize4XL;
  double get xl5 => DesignToken.fontSize5XL;
}

/// Border radius tokens accessor
class DesignTokenRadius {
  const DesignTokenRadius();

  double get xs => DesignToken.radiusXS;
  double get sm => DesignToken.radiusSM;
  double get md => DesignToken.radiusMD;
  double get lg => DesignToken.radiusLG;
  double get xl => DesignToken.radiusXL;
  double get xl2 => DesignToken.radius2XL;
  double get xl3 => DesignToken.radius3XL;
  double get round => DesignToken.radiusRound;

  BorderRadius get borderXS => DesignToken.borderRadiusXS;
  BorderRadius get borderSM => DesignToken.borderRadiusSM;
  BorderRadius get borderMD => DesignToken.borderRadiusMD;
  BorderRadius get borderLG => DesignToken.borderRadiusLG;
  BorderRadius get borderXL => DesignToken.borderRadiusXL;
  BorderRadius get borderXL2 => DesignToken.borderRadius2XL;
  BorderRadius get borderRound => DesignToken.borderRadiusRound;
}

/// Icon size tokens accessor
class DesignTokenIcons {
  const DesignTokenIcons();

  double get xs => DesignToken.iconSizeXS;
  double get sm => DesignToken.iconSizeSM;
  double get md => DesignToken.iconSizeMD;
  double get lg => DesignToken.iconSizeLG;
  double get xl => DesignToken.iconSizeXL;
  double get xl2 => DesignToken.iconSize2XL;
  double get xl3 => DesignToken.iconSize3XL;
  double get xl4 => DesignToken.iconSize4XL;
}

/// Elevation tokens accessor
class DesignTokenElevation {
  const DesignTokenElevation();

  double get none => DesignToken.elevationNone;
  double get sm => DesignToken.elevationSM;
  double get md => DesignToken.elevationMD;
  double get lg => DesignToken.elevationLG;
  double get xl => DesignToken.elevationXL;
  double get xl2 => DesignToken.elevation2XL;

  List<BoxShadow> get shadowSM => DesignToken.shadowSM;
  List<BoxShadow> get shadowMD => DesignToken.shadowMD;
  List<BoxShadow> get shadowLG => DesignToken.shadowLG;
  List<BoxShadow> get shadowXL => DesignToken.shadowXL;
}
