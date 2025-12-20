import 'package:flutter/material.dart';
import 'package:balaji_points/core/theme/design_token.dart';

// Legacy exports for backward compatibility
// These are now part of DesignToken but kept here for existing code
class AppColors {
  static const Color primary = DesignToken.primary;
  static const Color secondary = DesignToken.secondary;
  static const Color background = DesignToken.background;
  static const Color textDark = DesignToken.textDark;
  static const Color woodenBackground = DesignToken.woodenBackground;
  static const Color woodenBase = DesignToken.woodenBase;
  static const Color woodenDark = DesignToken.woodenDark;
}

class AppTextStyles {
  static const TextStyle nunitoRegular = DesignToken.nunitoRegular;
  static const TextStyle nunitoMedium = DesignToken.nunitoMedium;
  static const TextStyle nunitoSemiBold = DesignToken.nunitoSemiBold;
  static const TextStyle nunitoBold = DesignToken.nunitoBold;
}

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  fontFamily: 'Nunito',
  scaffoldBackgroundColor: DesignToken.background,
  primaryColor: DesignToken.primary,
  appBarTheme: const AppBarTheme(
    backgroundColor: DesignToken.background,
    foregroundColor: DesignToken.textDark,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: DesignToken.textDark,
      fontSize: 20,
      fontWeight: FontWeight.w700,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: DesignToken.primary,
      foregroundColor: DesignToken.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(
      color: DesignToken.textDark,
      fontSize: 16,
      fontWeight: FontWeight.w400,
    ),
    bodyMedium: TextStyle(
      color: DesignToken.textDark,
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
    titleLarge: TextStyle(
      color: DesignToken.textDark,
      fontSize: 20,
      fontWeight: FontWeight.w700,
    ),
    titleMedium: TextStyle(
      color: DesignToken.textDark,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
    labelLarge: TextStyle(
      color: DesignToken.textDark,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: DesignToken.primary,
    foregroundColor: Colors.white,
  ),
  colorScheme: const ColorScheme.light(
    primary: DesignToken.primary,
    secondary: DesignToken.secondary,
    background: DesignToken.background,
  ),
);
