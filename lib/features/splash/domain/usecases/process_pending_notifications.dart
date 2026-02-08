import 'package:dartz/dartz.dart';
import 'package:balaji_points/core/error/failures.dart';
import '../repositories/splash_repository.dart';

class ProcessPendingNotifications {
  final SplashRepository repository;
  
  ProcessPendingNotifications(this.repository);
  
  Future<Either<Failure, void>> call() async {
    // This is a placeholder - notifications are handled separately
    // For now, just return success
    return const Right(null);
  }
}
