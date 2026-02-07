import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:balaji_points/core/constants/app_constants.dart';

/// Theme mode notifier for managing light/dark theme
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    _loadThemeMode();
    return ThemeMode.light;
  }

  /// Load theme mode from shared preferences
  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeString = prefs.getString(AppConstants.keyThemeMode);

    if (themeModeString != null) {
      state = ThemeMode.values.firstWhere(
        (mode) => mode.toString() == themeModeString,
        orElse: () => ThemeMode.light,
      );
    }
  }

  /// Toggle between light and dark theme
  Future<void> toggleTheme() async {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await _saveThemeMode();
  }

  /// Set specific theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _saveThemeMode();
  }

  /// Save theme mode to shared preferences
  Future<void> _saveThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyThemeMode, state.toString());
  }

  /// Check if current theme is dark
  bool get isDarkMode => state == ThemeMode.dark;
}

/// Provider for theme mode
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  () => ThemeModeNotifier(),
);
