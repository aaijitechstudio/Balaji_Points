import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart' as log_pkg;

/// Enhanced Application Logger
/// 
/// Provides comprehensive logging for:
/// - Screen navigation
/// - API calls (requests/responses)
/// - Business logic events
/// - Error tracking
/// 
/// Usage:
/// ```dart
/// AppLogger.navigation('HomeScreen', action: 'opened');
/// AppLogger.apiRequest('POST', '/api/bills', body: {...});
/// AppLogger.apiResponse('POST', '/api/bills', statusCode: 200);
/// AppLogger.info('User logged in successfully');
/// AppLogger.error('Failed to load data', error: e);
/// ```
class AppLogger {
  static final log_pkg.Logger _logger = log_pkg.Logger(
    printer: log_pkg.PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: log_pkg.DateTimeFormat.onlyTimeAndSinceStart,
    ),
    level: kDebugMode ? log_pkg.Level.debug : log_pkg.Level.warning,
  );

  // ═══════════════════════════════════════════════════════════════
  // 📱 SCREEN NAVIGATION LOGS
  // ═══════════════════════════════════════════════════════════════
  
  /// Log screen navigation
  /// 
  /// Example:
  /// ```dart
  /// AppLogger.navigation('HomeScreen', action: 'opened');
  /// AppLogger.navigation('LoginScreen', action: 'closed', extra: 'User logged in');
  /// ```
  static void navigation(String screenName, {String action = 'navigated', String? extra}) {
    if (kDebugMode) {
      final message = '🧭 NAVIGATION: $screenName - $action${extra != null ? ' ($extra)' : ''}';
      _logger.d(message);
    }
  }

  /// Log screen lifecycle events
  /// 
  /// Example:
  /// ```dart
  /// AppLogger.screenLifecycle('HomeScreen', 'initState');
  /// AppLogger.screenLifecycle('HomeScreen', 'dispose');
  /// ```
  static void screenLifecycle(String screenName, String lifecycle) {
    if (kDebugMode) {
      _logger.t('🔄 LIFECYCLE: $screenName.$lifecycle');
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 🌐 API CALL LOGS
  // ═══════════════════════════════════════════════════════════════
  
  /// Log API request
  /// 
  /// Example:
  /// ```dart
  /// AppLogger.apiRequest('POST', '/api/bills/create', body: billData);
  /// AppLogger.apiRequest('GET', '/api/user/profile');
  /// ```
  static void apiRequest(String method, String endpoint, {Map<String, dynamic>? body, Map<String, dynamic>? params}) {
    if (kDebugMode) {
      final buffer = StringBuffer();
      buffer.write('🚀 API REQUEST: $method $endpoint');
      
      if (params != null && params.isNotEmpty) {
        buffer.write('\n   Params: $params');
      }
      
      if (body != null && body.isNotEmpty) {
        buffer.write('\n   Body: ${_sanitizeBody(body)}');
      }
      
      _logger.i(buffer.toString());
    }
  }

  /// Log API response
  /// 
  /// Example:
  /// ```dart
  /// AppLogger.apiResponse('POST', '/api/bills/create', statusCode: 200, duration: 450);
  /// AppLogger.apiResponse('GET', '/api/user', statusCode: 401, error: 'Unauthorized');
  /// ```
  static void apiResponse(
    String method,
    String endpoint, {
    required int statusCode,
    int? duration,
    dynamic data,
    String? error,
  }) {
    if (kDebugMode) {
      final isSuccess = statusCode >= 200 && statusCode < 300;
      final emoji = isSuccess ? '✅' : '❌';
      final durationText = duration != null ? ' (${duration}ms)' : '';
      
      final buffer = StringBuffer();
      buffer.write('$emoji API RESPONSE: $method $endpoint - $statusCode$durationText');
      
      if (error != null) {
        buffer.write('\n   Error: $error');
      }
      
      if (data != null && kDebugMode) {
        buffer.write('\n   Data: ${_sanitizeData(data)}');
      }
      
      if (isSuccess) {
        _logger.i(buffer.toString());
      } else {
        _logger.w(buffer.toString());
      }
    }
  }

  /// Log Firestore operation
  /// 
  /// Example:
  /// ```dart
  /// AppLogger.firestore('READ', 'users/{userId}');
  /// AppLogger.firestore('WRITE', 'bills/{billId}', data: billData);
  /// ```
  static void firestore(String operation, String path, {dynamic data, String? error}) {
    if (kDebugMode) {
      final emoji = error == null ? '🔥' : '❌';
      final buffer = StringBuffer();
      buffer.write('$emoji FIRESTORE: $operation $path');
      
      if (data != null) {
        buffer.write('\n   Data: ${_sanitizeData(data)}');
      }
      
      if (error != null) {
        buffer.write('\n   Error: $error');
      }
      
      _logger.i(buffer.toString());
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 🎯 BUSINESS LOGIC LOGS
  // ═══════════════════════════════════════════════════════════════
  
  /// Log BLoC events
  /// 
  /// Example:
  /// ```dart
  /// AppLogger.blocEvent('AuthBloc', 'LoginRequested');
  /// AppLogger.blocEvent('BillsBloc', 'LoadBills', data: {'userId': userId});
  /// ```
  static void blocEvent(String blocName, String eventName, {dynamic data}) {
    if (kDebugMode) {
      final buffer = StringBuffer();
      buffer.write('📤 BLOC EVENT: $blocName.$eventName');
      
      if (data != null) {
        buffer.write('\n   Data: $data');
      }
      
      _logger.d(buffer.toString());
    }
  }

  /// Log BLoC state changes
  /// 
  /// Example:
  /// ```dart
  /// AppLogger.blocState('AuthBloc', 'Authenticated');
  /// AppLogger.blocState('BillsBloc', 'BillsLoaded', data: {'count': 10});
  /// ```
  static void blocState(String blocName, String stateName, {dynamic data}) {
    if (kDebugMode) {
      final buffer = StringBuffer();
      buffer.write('📥 BLOC STATE: $blocName.$stateName');
      
      if (data != null) {
        buffer.write('\n   Data: $data');
      }
      
      _logger.d(buffer.toString());
    }
  }

  /// Log use case execution
  /// 
  /// Example:
  /// ```dart
  /// AppLogger.useCase('LoginUseCase', params: {'email': email});
  /// AppLogger.useCase('CreateBillUseCase', result: 'Success');
  /// ```
  static void useCase(String useCaseName, {dynamic params, dynamic result, String? error}) {
    if (kDebugMode) {
      final emoji = error == null ? '⚙️' : '❌';
      final buffer = StringBuffer();
      buffer.write('$emoji USE CASE: $useCaseName');
      
      if (params != null) {
        buffer.write('\n   Params: $params');
      }
      
      if (result != null) {
        buffer.write('\n   Result: $result');
      }
      
      if (error != null) {
        buffer.write('\n   Error: $error');
      }
      
      _logger.i(buffer.toString());
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 📊 GENERAL LOGS
  // ═══════════════════════════════════════════════════════════════
  
  /// Debug log (development only)
  static void debug(String message, {dynamic data}) {
    if (kDebugMode) {
      _logger.d(data != null ? '$message\n   $data' : message);
    }
  }

  /// Info log (important events)
  static void info(String message, {dynamic data}) {
    _logger.i(data != null ? '$message\n   $data' : message);
  }

  /// Warning log (potential issues)
  static void warning(String message, {dynamic data}) {
    _logger.w(data != null ? '$message\n   $data' : message);
  }

  /// Error log (errors and exceptions)
  static void error(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  // ═══════════════════════════════════════════════════════════════
  // 🚀 APP LIFECYCLE LOGS
  // ═══════════════════════════════════════════════════════════════
  
  /// Log app initialization
  static void appInit(String phase, {String? detail}) {
    _logger.i('🚀 APP INIT: $phase${detail != null ? ' - $detail' : ''}');
  }

  /// Log performance metrics
  static void performance(String operation, int durationMs, {String? detail}) {
    final emoji = durationMs < 100 ? '⚡' : durationMs < 500 ? '🟡' : '🔴';
    _logger.i('$emoji PERFORMANCE: $operation took ${durationMs}ms${detail != null ? ' - $detail' : ''}');
  }

  // ═══════════════════════════════════════════════════════════════
  // 🔒 HELPER METHODS
  // ═══════════════════════════════════════════════════════════════
  
  /// Sanitize request body to hide sensitive data
  static String _sanitizeBody(Map<String, dynamic> body) {
    final sanitized = Map<String, dynamic>.from(body);
    
    // Hide sensitive fields
    const sensitiveFields = ['password', 'pin', 'token', 'secret', 'apiKey', 'accessToken'];
    
    for (final field in sensitiveFields) {
      if (sanitized.containsKey(field)) {
        sanitized[field] = '***HIDDEN***';
      }
    }
    
    return sanitized.toString();
  }

  /// Sanitize response data
  static String _sanitizeData(dynamic data) {
    if (data is Map) {
      return _sanitizeBody(Map<String, dynamic>.from(data));
    }
    
    // Limit string length for logs
    final dataStr = data.toString();
    return dataStr.length > 500 ? '${dataStr.substring(0, 500)}... (truncated)' : dataStr;
  }

  // ═══════════════════════════════════════════════════════════════
  // 📱 AUTH SPECIFIC LOGS
  // ═══════════════════════════════════════════════════════════════
  
  /// Log authentication events
  static void auth(String event, {String? userId, String? detail}) {
    _logger.i('🔐 AUTH: $event${userId != null ? ' (User: $userId)' : ''}${detail != null ? ' - $detail' : ''}');
  }
}
