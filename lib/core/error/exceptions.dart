/// Base exception class
/// 
/// All custom exceptions inherit from this abstract class.
/// Exceptions are thrown at the data layer and caught by repositories.
abstract class AppException implements Exception {
  final String message;
  
  const AppException({required this.message});
  
  @override
  String toString() => message;
}

/// Server exception (API/Network errors)
class ServerException extends AppException {
  const ServerException({required super.message});
}

/// Cache exception (local storage errors)
class CacheException extends AppException {
  const CacheException({required super.message});
}

/// Authentication exception
class AuthException extends AppException {
  const AuthException({required super.message});
}

/// Validation exception
class ValidationException extends AppException {
  const ValidationException({required super.message});
}

/// Permission exception
class PermissionException extends AppException {
  const PermissionException({required super.message});
}

/// Network exception (no internet)
class NetworkException extends AppException {
  const NetworkException({super.message = 'No internet connection'});
}

/// Not found exception
class NotFoundException extends AppException {
  const NotFoundException({required super.message});
}
