// filepath: lib/features/auth/domain/repositories/auth_repository.dart
import 'package:dartz/dartz.dart';
import 'package:balaji_points/core/error/failures.dart';
import 'package:balaji_points/features/auth/domain/entities/user.dart';

/// Auth repository interface (for PIN-based authentication)
abstract class AuthRepository {
  // Check if user exists by phone
  Future<Either<Failure, bool>> checkUserExists(String phoneNumber);
  
  // PIN login
  Future<Either<Failure, User>> loginWithPin(String phoneNumber, String pin);
  
  // Setup PIN for new user
  Future<Either<Failure, User>> setupPin({
    required String phoneNumber,
    required String pin,
    required String firstName,
    String? lastName,
    String? profileImageUrl,
  });
  
  // Reset PIN
  Future<Either<Failure, bool>> resetPin({
    required String phoneNumber,
    required String oldPin,
    required String newPin,
  });
  
  // Verify PIN
  Future<Either<Failure, bool>> verifyPin(String phoneNumber, String pin);
  
  // Check if authenticated
  Future<Either<Failure, bool>> isAuthenticated();
  
  // Get current user
  Future<Either<Failure, User?>> getCurrentUser();
  
  // Logout
  Future<Either<Failure, void>> logout();
}
