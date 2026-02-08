// filepath: lib/features/auth/data/repositories/auth_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:balaji_points/core/error/failures.dart';
import 'package:balaji_points/core/utils/app_logger.dart';
import 'package:balaji_points/features/auth/domain/entities/user.dart';
import 'package:balaji_points/features/auth/domain/repositories/auth_repository.dart';
import 'package:balaji_points/features/auth/data/datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, bool>> checkUserExists(String phoneNumber) async {
    AppLogger.apiRequest('GET', '/auth/check-user', params: {'phone': phoneNumber});
    final startTime = DateTime.now();
    
    try {
      final result = await remoteDataSource.checkUserExists(phoneNumber);
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      
      AppLogger.apiResponse('GET', '/auth/check-user', 
        statusCode: 200, 
        duration: duration,
        data: {'exists': result},
      );
      
      return Right(result);
    } catch (e) {
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      AppLogger.apiResponse('GET', '/auth/check-user', 
        statusCode: 500, 
        duration: duration,
        error: e.toString(),
      );
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> loginWithPin(String phoneNumber, String pin) async {
    AppLogger.apiRequest('POST', '/auth/login', body: {'phone': phoneNumber, 'pin': '***'});
    final startTime = DateTime.now();
    
    try {
      final userModel = await remoteDataSource.verifyPin(phoneNumber, pin);
      await remoteDataSource.saveSession(userModel, true);
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      
      AppLogger.apiResponse('POST', '/auth/login', 
        statusCode: 200, 
        duration: duration,
        data: {'userId': userModel.id},
      );
      AppLogger.auth('Login successful', userId: userModel.id);
      
      return Right(userModel.toEntity());
    } catch (e) {
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      AppLogger.apiResponse('POST', '/auth/login', 
        statusCode: 401, 
        duration: duration,
        error: e.toString(),
      );
      AppLogger.auth('Login failed', detail: e.toString());
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> setupPin({
    required String phoneNumber,
    required String pin,
    required String firstName,
    String? lastName,
    String? profileImageUrl,
  }) async {
    AppLogger.apiRequest('POST', '/auth/setup-pin', body: {
      'phone': phoneNumber, 
      'firstName': firstName,
      'lastName': lastName,
    });
    final startTime = DateTime.now();
    
    try {
      final userModel = await remoteDataSource.setupPin(
        phoneNumber: phoneNumber,
        pin: pin,
        firstName: firstName,
        lastName: lastName,
        profileImageUrl: profileImageUrl,
      );
      await remoteDataSource.saveSession(userModel, true);
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      
      AppLogger.apiResponse('POST', '/auth/setup-pin', 
        statusCode: 201, 
        duration: duration,
        data: {'userId': userModel.id},
      );
      AppLogger.auth('PIN setup successful', userId: userModel.id);
      
      return Right(userModel.toEntity());
    } catch (e) {
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      AppLogger.apiResponse('POST', '/auth/setup-pin', 
        statusCode: 500, 
        duration: duration,
        error: e.toString(),
      );
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> resetPin({
    required String phoneNumber,
    required String oldPin,
    required String newPin,
  }) async {
    AppLogger.apiRequest('POST', '/auth/reset-pin', body: {'phone': phoneNumber});
    final startTime = DateTime.now();
    
    try {
      final result = await remoteDataSource.resetPin(
        phoneNumber: phoneNumber,
        oldPin: oldPin,
        newPin: newPin,
      );
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      
      AppLogger.apiResponse('POST', '/auth/reset-pin', 
        statusCode: 200, 
        duration: duration,
      );
      AppLogger.auth('PIN reset successful', detail: phoneNumber);
      
      return Right(result);
    } catch (e) {
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      AppLogger.apiResponse('POST', '/auth/reset-pin', 
        statusCode: 400, 
        duration: duration,
        error: e.toString(),
      );
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    AppLogger.auth('Logout requested');
    final startTime = DateTime.now();
    
    try {
      await remoteDataSource.clearSession();
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      
      AppLogger.performance('Logout', duration);
      AppLogger.auth('Logout successful');
      
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final userModel = await remoteDataSource.getCurrentSession();
      return Right(userModel?.toEntity());
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    try {
      final user = await remoteDataSource.getCurrentSession();
      return Right(user != null);
    } catch (e) {
      return const Right(false);
    }
  }

  @override
  Future<Either<Failure, bool>> verifyPin(String phoneNumber, String pin) async {
    try {
      await remoteDataSource.verifyPin(phoneNumber, pin);
      return const Right(true);
    } catch (e) {
      return const Right(false);
    }
  }
}
