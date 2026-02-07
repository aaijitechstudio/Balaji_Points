import '../repositories/splash_repository.dart';

class ProcessPendingNotifications {
  final SplashRepository repository;
  
  ProcessPendingNotifications(this.repository);
  
  Future<void> call() async {
    return await repository.processPendingNotifications();
  }
}
