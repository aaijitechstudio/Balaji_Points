import 'package:flutter/material.dart';

/// Centralized design tokens for the application
/// Includes colors, spacing, text styles, icon sizes, button sizes, and other design constants
class DesignToken {
  DesignToken._();

  // ============================================================================
  // COLORS
  // ============================================================================

  // Primary Brand Colors
  static const Color primary = Color(0xFF192F6A); // Dark blue primary
  static const Color secondary = Color(0xFFEB5070); // Pink accent
  static const Color background = Color(0xFFFFFFFF); // White background
  static const Color textDark = Color(0xFF1E2A4A); // Dark navy text

  // Wooden Texture Colors (from brand identity)
  static const Color woodenBackground = Color(0xFFF5E6D3); // Light beige/wood
  static const Color woodenBase = Color(0xFFD4A574); // Medium wood tone
  static const Color woodenDark = Color(0xFFC4946A); // Darker wood grain

  // Status Colors
  static const Color success = Color(0xFF10B981); // Green
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color error = Color(0xFFEF4444); // Red
  static const Color info = Color(0xFF3B82F6); // Blue

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // Spin Wheel Colors
  static const Color spinAmber = Color(0xFFFBBF24); // Amber shade 400
  static const Color spinOrange = Color(0xFFF97316); // Orange shade 600
  static const Color spinRed = Color(0xFFEF4444); // Red shade 400
  static const Color spinPink = Color(0xFFEC4899); // Pink shade 500
  static const Color spinPurple = Color(0xFFA855F7); // Purple shade 500
  static const Color spinBlue = Color(0xFF3B82F6); // Blue shade 500
  static const Color spinGreen = Color(0xFF10B981); // Green shade 500
  static const Color spinYellow = Color(0xFFEAB308); // Yellow shade 500

  // Gradient Colors
  static const List<Color> primaryGradient = [primary, Color(0xFF2A4080)];

  static const List<Color> secondaryGradient = [secondary, Color(0xFFF66085)];

  static const List<Color> successGradient = [success, Color(0xFF34D399)];

  static const List<Color> woodenGradient = [
    woodenBackground,
    Color(0xFFE8D5BE),
  ];

  static const List<Color> spinWheelGradient = [spinAmber, spinOrange, spinRed];

  // Shadow Colors
  static Color shadow10 = black.withValues(alpha: 0.1);
  static Color shadow20 = black.withValues(alpha: 0.2);
  static Color shadow30 = black.withValues(alpha: 0.3);

  // Overlay Colors
  static Color overlay10 = black.withValues(alpha: 0.1);
  static Color overlay20 = black.withValues(alpha: 0.2);
  static Color overlay50 = black.withValues(alpha: 0.5);
  static Color overlay70 = black.withValues(alpha: 0.7);

  // Bill Status Colors
  static const Color billPending = warning;
  static const Color billApproved = success;
  static const Color billRejected = error;

  // User Status Colors
  static const Color verified = success;
  static const Color notVerified = warning;

  // Points Colors (for visual representation)
  static const Color pointsEarned = success;
  static const Color pointsSpent = error;
  static const Color pointsPending = warning;

  // Offer Card Colors
  static const Color offerBannerBg = Color(0xFFFEF3C7); // Yellow shade 100
  static const Color offerBasicBg = Color(0xFFDCFCE7); // Green shade 100
  static const Color offerFullWidthBg = Color(0xFFFCE7F3); // Pink shade 100

  // Tier Colors (Platinum, Gold, Silver, Bronze)
  static const Color tierPlatinum = Color(0xFF00D4FF); // Cyan
  static const Color tierGold = Color(0xFFFFD700); // Gold
  static const Color tierSilver = Color(0xFFC0C0C0); // Silver
  static const Color tierBronze = Color(0xFFCD7F32); // Bronze/Copper

  // Navy Background (for dashboard, redeem, role selection)
  static const Color navyBackground = Color(0xFF001F3F);

  // Leaderboard Rank Position Colors
  static const Color rank1Background = Color(0xFFFFF8E1); // Amber.shade100
  static const Color rank1Text = Color(0xFFF57F17); // Amber.shade700
  static const Color rank2Background = Color(0xFFEEEEEE); // Grey.shade200
  static const Color rank2Text = Color(0xFF616161); // Grey.shade700
  static const Color rank3Background = Color(0xFFEFEBE9); // Brown.shade100
  static const Color rank3Text = Color(0xFF5D4037); // Brown.shade700

  // Trophy/Medal Colors
  static const Color trophyGold = Color(0xFFFFC107); // Amber
  static const Color trophySilver = Color(0xFFBDBDBD); // Grey.shade400
  static const Color trophyBronze = Color(0xFF8D6E63); // Brown.shade400

  // Orange Shades (for warnings/incomplete profile)
  static const Color orangeLight = Color(0xFFFFB74D); // Orange.shade400
  static const Color orangeDark = Color(0xFFFF6F00); // DeepOrange.shade500
  static const Color orangeBackground = Color(0xFFFFF3E0); // Orange.shade50
  static const Color orange = Color(0xFFFF9800); // Base orange
  static const Color orangeShade50 = Color(0xFFFFF3E0);
  static const Color orangeShade200 = Color(0xFFFFCC80);
  static const Color orangeShade300 = Color(0xFFFFB74D);
  static const Color orangeShade400 = Color(0xFFFFA726);
  static const Color orangeShade500 = Color(0xFFFF9800);
  static const Color orangeShade600 = Color(0xFFFB8C00);
  static const Color orangeShade700 = Color(0xFFF57C00);
  static const Color orangeShade800 = Color(0xFFEF6C00);
  static const Color orangeShade900 = Color(0xFFE65100);
  static const Color deepOrangeShade500 = Color(0xFFFF6F00);

  // Blue Gradient Shades
  static const Color blueShade50 = Color(0xFFE3F2FD);
  static const Color blueShade300 = Color(0xFF64B5F6);
  static const Color blueShade400 = Color(0xFF42A5F5);
  static const Color blueShade500 = Color(0xFF2196F3);
  static const Color blueShade600 = Color(0xFF1E88E5);
  static const Color blueShade700 = Color(0xFF1976D2);
  static const Color blueAccent = Color(0xFF448AFF);

  // Purple Gradient Shades
  static const Color purpleShade300 = Color(0xFFBA68C8);
  static const Color purpleShade500 = Color(0xFF9C27B0);
  static const Color purpleShade600 = Color(0xFF8E24AA);
  static const Color purpleShade700 = Color(0xFF7B1FA2);

  // Amber Shades
  static const Color amber = Color(0xFFFFC107);
  static const Color amberShade50 = Color(0xFFFFF8E1);
  static const Color amberShade100 = Color(0xFFFFECB3);
  static const Color amberShade200 = Color(0xFFFFE082);
  static const Color amberShade300 = Color(0xFFFFD54F);
  static const Color amberShade400 = Color(0xFFFFCA28);
  static const Color amberShade500 = Color(0xFFFFC107);
  static const Color amberShade700 = Color(0xFFFFA000);
  static const Color amberShade800 = Color(0xFFFF8F00);
  static const Color amberShade900 = Color(0xFFFF6F00);

  // Green Shades
  static const Color greenShade50 = Color(0xFFE8F5E9);
  static const Color greenShade200 = Color(0xFFA5D6A7);
  static const Color greenShade300 = Color(0xFF81C784);
  static const Color greenShade600 = Color(0xFF43A047);
  static const Color greenShade700 = Color(0xFF388E3C);
  static const Color greenShade800 = Color(0xFF2E7D32);

  // Red Shades
  static const Color redShade50 = Color(0xFFFFEBEE);
  static const Color redShade200 = Color(0xFFEF9A9A);
  static const Color redShade300 = Color(0xFFE57373);
  static const Color redShade600 = Color(0xFFE53935);
  static const Color redShade700 = Color(0xFFD32F2F);
  static const Color redShade800 = Color(0xFFC62828);
  static const Color red = Color(0xFFF44336);

  // Brown Shades
  static const Color brownShade100 = Color(0xFFD7CCC8);
  static const Color brownShade400 = Color(0xFF8D6E63);
  static const Color brownShade700 = Color(0xFF5D4037);
  static const Color brownShade800 = Color(0xFF4E342E);
  static const Color brownShade900 = Color(0xFF3E2723);

  // Pink Shades
  static const Color pink = Color(0xFFE91E63);
  static const Color pinkShade300 = Color(0xFFF06292);
  static const Color pinkShade500 = Color(0xFFE91E63);

  // Indigo Shades
  static const Color indigoShade300 = Color(0xFF7986CB);

  // Yellow Shades
  static const Color yellowShade300 = Color(0xFFFFF176);
  static const Color yellowAccent = Color(0xFFFFFF00);
  static const Color yellow = Color(0xFFFFEB3B);

  // Transparent
  static const Color transparent = Color(0x00000000);

  // Black with opacity variants
  static const Color black12 = Color(0x1F000000); // Colors.black12
  static const Color black26 = Color(0x42000000); // Colors.black26
  static const Color black54 = Color(0x8A000000); // Colors.black54
  static const Color black87 = Color(0xDD000000); // Colors.black87

  // White with opacity variants
  static const Color white70 = Color(0xB3FFFFFF); // Colors.white70

  // Blue aliases for convenience
  static const Color blue500 = blueShade500;
  static const Color blue600 = blueShade600;
  static const Color blue700 = blueShade700;

  // Purple base color
  static const Color purple = purpleShade500;

  // Special Effect Colors
  static const Color confettiGold = Color(0xFFFFD700);
  static const Color confettiSilver = Color(0xFFC0C0C0);
  static const Color glowEffect = Color(0xFFFFEB3B);

  // ============================================================================
  // SPACING
  // ============================================================================

  // Spacing Scale (4px base unit)
  static const double spacingXS = 4.0;
  static const double spacingSM = 8.0;
  static const double spacingMD = 12.0;
  static const double spacingLG = 16.0;
  static const double spacingXL = 20.0;
  static const double spacing2XL = 24.0;
  static const double spacing3XL = 32.0;
  static const double spacing4XL = 40.0;
  static const double spacing5XL = 48.0;
  static const double spacing6XL = 60.0;

  // Padding
  static const double paddingXS = 4.0;
  static const double paddingSM = 8.0;
  static const double paddingMD = 12.0;
  static const double paddingLG = 16.0;
  static const double paddingXL = 20.0;
  static const double padding2XL = 24.0;
  static const double padding3XL = 32.0;
  static const double padding4XL = 40.0;

  // Margin
  static const double marginXS = 4.0;
  static const double marginSM = 8.0;
  static const double marginMD = 12.0;
  static const double marginLG = 16.0;
  static const double marginXL = 20.0;
  static const double margin2XL = 24.0;
  static const double margin3XL = 32.0;
  static const double margin4XL = 40.0;

  // SizedBox Heights (Common vertical spacing)
  static const double heightXS = 4.0;
  static const double heightSM = 8.0;
  static const double heightMD = 12.0;
  static const double heightLG = 16.0;
  static const double heightXL = 20.0;
  static const double height2XL = 24.0;
  static const double height3XL = 32.0;
  static const double height4XL = 40.0;
  static const double height5XL = 48.0;
  static const double height6XL = 60.0;

  // SizedBox Widths (Common horizontal spacing)
  static const double widthXS = 4.0;
  static const double widthSM = 8.0;
  static const double widthMD = 12.0;
  static const double widthLG = 16.0;
  static const double widthXL = 20.0;
  static const double width2XL = 24.0;
  static const double width3XL = 32.0;

  // EdgeInsets Presets
  static const EdgeInsets paddingAllXS = EdgeInsets.all(4.0);
  static const EdgeInsets paddingAllSM = EdgeInsets.all(8.0);
  static const EdgeInsets paddingAllMD = EdgeInsets.all(12.0);
  static const EdgeInsets paddingAllLG = EdgeInsets.all(16.0);
  static const EdgeInsets paddingAllXL = EdgeInsets.all(20.0);
  static const EdgeInsets paddingAll2XL = EdgeInsets.all(24.0);
  static const EdgeInsets paddingAll3XL = EdgeInsets.all(32.0);

  static const EdgeInsets paddingHorizontalSM = EdgeInsets.symmetric(
    horizontal: 8.0,
  );
  static const EdgeInsets paddingHorizontalMD = EdgeInsets.symmetric(
    horizontal: 12.0,
  );
  static const EdgeInsets paddingHorizontalLG = EdgeInsets.symmetric(
    horizontal: 16.0,
  );
  static const EdgeInsets paddingHorizontalXL = EdgeInsets.symmetric(
    horizontal: 20.0,
  );
  static const EdgeInsets paddingHorizontal2XL = EdgeInsets.symmetric(
    horizontal: 24.0,
  );

  static const EdgeInsets paddingVerticalSM = EdgeInsets.symmetric(
    vertical: 8.0,
  );
  static const EdgeInsets paddingVerticalMD = EdgeInsets.symmetric(
    vertical: 12.0,
  );
  static const EdgeInsets paddingVerticalLG = EdgeInsets.symmetric(
    vertical: 16.0,
  );
  static const EdgeInsets paddingVerticalXL = EdgeInsets.symmetric(
    vertical: 20.0,
  );
  static const EdgeInsets paddingVertical2XL = EdgeInsets.symmetric(
    vertical: 24.0,
  );

  // ============================================================================
  // BORDER RADIUS
  // ============================================================================

  static const double radiusXS = 4.0;
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 20.0;
  static const double radius2XL = 24.0;
  static const double radius3XL = 30.0;
  static const double radiusRound = 999.0; // For fully rounded elements

  // BorderRadius Presets
  static const BorderRadius borderRadiusXS = BorderRadius.all(
    Radius.circular(4.0),
  );
  static const BorderRadius borderRadiusSM = BorderRadius.all(
    Radius.circular(8.0),
  );
  static const BorderRadius borderRadiusMD = BorderRadius.all(
    Radius.circular(12.0),
  );
  static const BorderRadius borderRadiusLG = BorderRadius.all(
    Radius.circular(16.0),
  );
  static const BorderRadius borderRadiusXL = BorderRadius.all(
    Radius.circular(20.0),
  );
  static const BorderRadius borderRadius2XL = BorderRadius.all(
    Radius.circular(24.0),
  );
  static const BorderRadius borderRadiusRound = BorderRadius.all(
    Radius.circular(999.0),
  );

  // ============================================================================
  // ICON SIZES
  // ============================================================================

  static const double iconSizeXS = 12.0;
  static const double iconSizeSM = 16.0;
  static const double iconSizeMD = 20.0;
  static const double iconSizeLG = 24.0;
  static const double iconSizeXL = 32.0;
  static const double iconSize2XL = 40.0;
  static const double iconSize3XL = 48.0;
  static const double iconSize4XL = 64.0;

  // ============================================================================
  // BUTTON SIZES
  // ============================================================================

  // Button Heights
  static const double buttonHeightSM = 32.0;
  static const double buttonHeightMD = 40.0;
  static const double buttonHeightLG = 48.0;
  static const double buttonHeightXL = 56.0;
  static const double buttonHeight2XL = 64.0;

  // Button Padding
  static const EdgeInsets buttonPaddingSM = EdgeInsets.symmetric(
    horizontal: 12.0,
    vertical: 8.0,
  );
  static const EdgeInsets buttonPaddingMD = EdgeInsets.symmetric(
    horizontal: 16.0,
    vertical: 12.0,
  );
  static const EdgeInsets buttonPaddingLG = EdgeInsets.symmetric(
    horizontal: 20.0,
    vertical: 16.0,
  );
  static const EdgeInsets buttonPaddingXL = EdgeInsets.symmetric(
    horizontal: 24.0,
    vertical: 18.0,
  );

  // Button Minimum Width
  static const double buttonMinWidthSM = 80.0;
  static const double buttonMinWidthMD = 120.0;
  static const double buttonMinWidthLG = 160.0;
  static const double buttonMinWidthXL = 200.0;

  // ============================================================================
  // TEXT STYLES
  // ============================================================================

  // Font Family
  static const String fontFamily = 'Nunito';

  // Base Text Styles
  static const TextStyle textRegular = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle textMedium = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle textSemiBold = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle textBold = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
  );

  // Font Sizes
  static const double fontSizeXS = 10.0;
  static const double fontSizeSM = 12.0;
  static const double fontSizeMD = 14.0;
  static const double fontSizeLG = 16.0;
  static const double fontSizeXL = 18.0;
  static const double fontSize2XL = 20.0;
  static const double fontSize3XL = 24.0;
  static const double fontSize4XL = 28.0;
  static const double fontSize5XL = 32.0;

  // Heading Styles
  static const TextStyle heading1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32.0,
    fontWeight: FontWeight.w700,
    color: textDark,
  );

  static const TextStyle heading2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28.0,
    fontWeight: FontWeight.w700,
    color: textDark,
  );

  static const TextStyle heading3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24.0,
    fontWeight: FontWeight.w700,
    color: textDark,
  );

  static const TextStyle heading4 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20.0,
    fontWeight: FontWeight.w700,
    color: textDark,
  );

  static const TextStyle heading5 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    color: textDark,
  );

  static const TextStyle heading6 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    color: textDark,
  );

  // Body Text Styles
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    color: textDark,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    color: textDark,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    color: textDark,
  );

  // Label Styles
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: textDark,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    color: textDark,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10.0,
    fontWeight: FontWeight.w500,
    color: textDark,
  );

  // Legacy AppTextStyles (for backward compatibility)
  static const TextStyle nunitoRegular = textRegular;
  static const TextStyle nunitoMedium = textMedium;
  static const TextStyle nunitoSemiBold = textSemiBold;
  static const TextStyle nunitoBold = textBold;

  // ============================================================================
  // ELEVATION & SHADOWS
  // ============================================================================

  static const double elevationNone = 0.0;
  static const double elevationSM = 2.0;
  static const double elevationMD = 4.0;
  static const double elevationLG = 8.0;
  static const double elevationXL = 12.0;
  static const double elevation2XL = 16.0;

  // Shadow Presets
  static List<BoxShadow> shadowSM = [
    BoxShadow(color: shadow10, blurRadius: 4.0, offset: const Offset(0, 2)),
  ];

  static List<BoxShadow> shadowMD = [
    BoxShadow(color: shadow20, blurRadius: 8.0, offset: const Offset(0, 4)),
  ];

  static List<BoxShadow> shadowLG = [
    BoxShadow(color: shadow20, blurRadius: 12.0, offset: const Offset(0, 6)),
  ];

  static List<BoxShadow> shadowXL = [
    BoxShadow(color: shadow30, blurRadius: 16.0, offset: const Offset(0, 8)),
  ];

  // ============================================================================
  // ANIMATION DURATIONS
  // ============================================================================

  static const Duration animationDurationFast = Duration(milliseconds: 200);
  static const Duration animationDurationNormal = Duration(milliseconds: 300);
  static const Duration animationDurationSlow = Duration(milliseconds: 500);
  static const Duration animationDurationVerySlow = Duration(
    milliseconds: 1000,
  );

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Get color with opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }

  /// Get status color
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return billPending;
      case 'approved':
        return billApproved;
      case 'rejected':
        return billRejected;
      case 'verified':
        return verified;
      default:
        return grey500;
    }
  }

  /// Get transaction type color
  static Color getTransactionColor(String type) {
    switch (type.toLowerCase()) {
      case 'earned':
        return pointsEarned;
      case 'spent':
        return pointsSpent;
      case 'pending':
        return pointsPending;
      default:
        return grey500;
    }
  }

  /// Get tier color
  static Color getTierColor(String tier) {
    switch (tier) {
      case 'Platinum':
        return tierPlatinum;
      case 'Gold':
        return tierGold;
      case 'Silver':
        return tierSilver;
      case 'Bronze':
      default:
        return tierBronze;
    }
  }
}
