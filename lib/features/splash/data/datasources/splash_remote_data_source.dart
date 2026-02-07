import 'package:balaji_points/services/session_service.dart';
import 'package:balaji_points/services/fcm_service.dart';

abstract class SplashRemoteDataSource {
  Future<bool> isUserLoggedIn();
  Future<String?> getUserRole();
  Future<void> processPendingNotifications();
}

class SplashRemoteDataSourceImpl implements SplashRemoteDataSource {
  final SessionService sessionService;
  final FCMService fcmService;
  
  SplashRemoteDataSourceImpl({
    required this.sessionService,
    required this.fcmService,
  });
  
  @override
  Future<bool> isUserLoggedIn() async {
    return await sessionService.isLoggedIn();
  }
  
  @override
  Future<String?> getUserRole() async {
    return await sessionService.getUserRole();
  }
  
  @override
  Future<void> processPendingNotifications() async {
    fcmService.processPendingNavigation();
  }
}
