// filepath: lib/features/auth/data/repositories/auth_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:balaji_points/core/error/failures.dart';
import 'package:balaji_points/features/auth/domain/entities/user.dart';
import 'package:balaji_points/features/auth/domain/repositories/auth_repository.dart';
import 'package:balaji_points/features/auth/data/datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, bool>> checkUserExists(String phoneNumber) async {
    try {
      final result = await remoteDataSource.checkUserExists(phoneNumber);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> loginWithPin(String phoneNumber, String pin) async {
    try {
      final userModel = await remoteDataSource.verifyPin(phoneNumber, pin);
      await remoteDataSource.saveSession(userModel, true);
      return Right(userModel.toEntity());
    } catch (e) {
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
    try {
      final userModel = await remoteDataSource.setupPin(
        phoneNumber: phoneNumber,
        pin: pin,
        firstName: firstName,
        lastName: lastName,
        profileImageUrl: profileImageUrl,
      );
      await remoteDataSource.saveSession(userModel, true);
      return Right(userModel.toEntity());
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> resetPin({
    required String phoneNumber,
    required String oldPin,
    required String newPin,
  }) async {
    try {
      final result = await remoteDataSource.resetPin(
        phoneNumber: phoneNumber,
        oldPin: oldPin,
        newPin: newPin,
      );
      return Right(result);
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.clearSession();
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
