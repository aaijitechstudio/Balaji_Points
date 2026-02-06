import 'package:dartz/dartz.dart';
import 'package:balaji_points/core/error/failures.dart';
import 'package:balaji_points/features/splash/domain/entities/session.dart';

/// Abstract repository for splash functionality
/// 
/// This interface defines the contract for splash data operations.
/// Implementation should handle both local and remote data sources.
abstract class SplashRepository {
  /// Check the current session status
  /// 
  /// Returns the current session if user is logged in, or null if not.
  /// Uses [Right] for success and [Left] for failure.
  Future<Either<Failure, Session?>> checkSession();
}
