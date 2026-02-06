import 'package:dartz/dartz.dart';
import 'package:balaji_points/core/error/failures.dart';
import 'package:balaji_points/features/auth/domain/entities/user.dart';
import 'package:balaji_points/features/auth/domain/repositories/auth_repository.dart';

/// Use case for PIN login
class LoginWithPinUseCase {
  final AuthRepository repository;
  
  LoginWithPinUseCase(this.repository);
  
  Future<Either<Failure, User>> call(String userId, String pin) async {
    // Validation
    if (userId.isEmpty || pin.isEmpty) {
      return Left(ValidationFailure(message: 'User ID and PIN are required'));
    }
    
    if (pin.length != 4) {
      return Left(ValidationFailure(message: 'PIN must be 4 digits'));
    }
    
    return repository.loginWithPin(userId, pin);
  }
}
