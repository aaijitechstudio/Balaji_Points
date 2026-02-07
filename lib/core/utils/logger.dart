import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart' as log_pkg;

/// Custom logger for the application
/// 
/// Usage:
/// ```dart
/// Logger.d('Debug message');
/// Logger.i('Info message');
/// Logger.w('Warning message');
/// Logger.e('Error message', error: e, stackTrace: st);
/// ```
class Logger {
  static final log_pkg.Logger _logger = log_pkg.Logger(
    printer: log_pkg.PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      printTime: false,
    ),
    level: kDebugMode ? log_pkg.Level.debug : log_pkg.Level.warning,
  );

  /// Debug log - for development only
  static void d(String message, {dynamic data}) {
    if (kDebugMode) {
      _logger.d(message, error: data);
    }
  }

  /// Info log - for important information
  static void i(String message, {dynamic data}) {
    _logger.i(message, error: data);
  }

  /// Warning log - for potential issues
  static void w(String message, {dynamic data}) {
    _logger.w(message, error: data);
  }

  /// Error log - for errors
  static void e(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
  }) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
}
