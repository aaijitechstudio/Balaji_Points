/// Base failure class
/// 
/// All failures inherit from this abstract class.
/// Used with Either<Failure, Success> pattern for error handling.
abstract class Failure {
  final String message;
  
  const Failure({required this.message});
  
  @override
  String toString() => message;
}

/// Server/Network failure
class ServerFailure extends Failure {
  const ServerFailure({required super.message});
  
  factory ServerFailure.fromException(Exception e) {
    return ServerFailure(message: e.toString());
  }
}

/// Cache failure (local storage)
class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

/// Authentication failure
class AuthFailure extends Failure {
  const AuthFailure({required super.message});
}

/// Validation failure
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}

/// Permission failure
class PermissionFailure extends Failure {
  const PermissionFailure({required super.message});
}

/// Network connection failure
class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No internet connection'});
}

/// Not found failure
class NotFoundFailure extends Failure {
  const NotFoundFailure({required super.message});
}

/// Unexpected failure
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({required super.message});
}
