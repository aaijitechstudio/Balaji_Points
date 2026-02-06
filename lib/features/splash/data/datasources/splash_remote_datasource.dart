import 'package:balaji_points/features/splash/data/models/session_model.dart';
import 'package:balaji_points/services/session_service.dart';

/// Remote data source for splash feature
/// 
/// This class handles all remote/local data operations for the splash feature.
/// It wraps the SessionService for session checking operations.
abstract class SplashRemoteDataSource {
  /// Check the current session from secure storage
  /// 
  /// Returns session data if user is logged in.
  /// Throws an exception if session check fails.
  Future<SessionModel?> checkSession();
}

/// Implementation of SplashRemoteDataSource
class SplashRemoteDataSourceImpl implements SplashRemoteDataSource {
  final SessionService sessionService;

  SplashRemoteDataSourceImpl(this.sessionService);

  @override
  Future<SessionModel?> checkSession() async {
    try {
      // Check if user is logged in
      final isLoggedIn = await sessionService.isLoggedIn();

      if (!isLoggedIn) {
        return null;
      }

      // Get session data
      final sessionData = await sessionService.getSessionData();

      // Convert to SessionModel
      return SessionModel(
        id: sessionData['userId'],
        phoneNumber: sessionData['phoneNumber'],
        firstName: sessionData['firstName'],
        lastName: sessionData['lastName'],
        role: sessionData['role'],
      );
    } catch (e) {
      throw Exception('Failed to check session: $e');
    }
  }
}
