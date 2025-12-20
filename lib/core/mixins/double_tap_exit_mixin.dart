import 'package:flutter/material.dart';
import '../utils/back_button_handler.dart';

/// Mixin for handling double-tap to exit behavior
mixin DoubleTapExitMixin<T extends StatefulWidget> on State<T> {
  DateTime? _lastBackPress;

  /// Handle double-tap exit logic
  /// Returns true if app should exit, false otherwise
  Future<bool> handleDoubleTapExit() async {
    final now = DateTime.now();

    if (_lastBackPress == null ||
        now.difference(_lastBackPress!) > const Duration(seconds: 2)) {
      _lastBackPress = now;
      if (mounted) {
        BackButtonHandler.showDoubleTapExitMessage(context);
      }
      return false; // Don't exit
    } else {
      BackButtonHandler.exitApp(); // Exit app
      return true; // Exit
    }
  }

  /// Reset the back press timer
  void resetBackPressTimer() {
    _lastBackPress = null;
  }
}
