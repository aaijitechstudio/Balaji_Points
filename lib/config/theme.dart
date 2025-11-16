import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF192F6A); // light blue primary
  static const Color secondary = Color(0xFFEB5070); // pink accent
  static const Color background = Color.fromRGBO(
    255,
    255,
    255,
    1,
  ); // all screen white
  static const Color textDark = Color(0xFF1E2A4A); // dark navy for text
  // Wooden texture colors (from launching poster)
  static const Color woodenBackground = Color(0xFFF5E6D3); // light beige/wood
  static const Color woodenBase = Color(0xFFD4A574); // medium wood tone
  static const Color woodenDark = Color(0xFFC4946A); // darker wood grain
}

class AppTextStyles {
  static const TextStyle nunitoRegular = TextStyle(
    fontFamily: 'Nunito',
    fontWeight: FontWeight.w400,
  );

  static const TextStyle nunitoMedium = TextStyle(
    fontFamily: 'Nunito',
    fontWeight: FontWeight.w500,
  );

  static const TextStyle nunitoSemiBold = TextStyle(
    fontFamily: 'Nunito',
    fontWeight: FontWeight.w600,
  );

  static const TextStyle nunitoBold = TextStyle(
    fontFamily: 'Nunito',
    fontWeight: FontWeight.w700,
  );
}

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  fontFamily: 'Nunito',
  scaffoldBackgroundColor: AppColors.background,
  primaryColor: AppColors.primary,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.background,
    foregroundColor: AppColors.textDark,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: AppColors.textDark,
      fontSize: 20,
      fontWeight: FontWeight.w700,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(
      color: AppColors.textDark,
      fontSize: 16,
      fontWeight: FontWeight.w400,
    ),
    bodyMedium: TextStyle(
      color: AppColors.textDark,
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
    titleLarge: TextStyle(
      color: AppColors.textDark,
      fontSize: 20,
      fontWeight: FontWeight.w700,
    ),
    titleMedium: TextStyle(
      color: AppColors.textDark,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
    labelLarge: TextStyle(
      color: AppColors.textDark,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
  ),
  colorScheme: const ColorScheme.light(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    background: AppColors.background,
  ),
);
