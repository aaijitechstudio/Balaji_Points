import '../repositories/splash_repository.dart';

class GetUserRole {
  final SplashRepository repository;
  
  GetUserRole(this.repository);
  
  Future<String?> call() async {
    return await repository.getUserRole();
  }
}
