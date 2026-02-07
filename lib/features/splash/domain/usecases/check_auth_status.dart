import '../repositories/splash_repository.dart';

class CheckAuthStatus {
  final SplashRepository repository;
  
  CheckAuthStatus(this.repository);
  
  Future<bool> call() async {
    return await repository.isUserLoggedIn();
  }
}
