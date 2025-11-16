import 'package:firebase_auth/firebase_auth.dart';
import '../core/logger.dart';

class PhoneAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Verification ID storage
  String? _verificationId;
  int? _resendToken;

  /// Send OTP to phone number
  Future<bool> sendOTP({
    required String phoneNumber,
    Function(String verificationId)? onCodeSent,
    Function(String error)? onError,
  }) async {
    try {
      // Format phone number (ensure country code)
      String formattedPhone = _formatPhoneNumber(phoneNumber);

      AppLogger.info('Sending OTP to: $formattedPhone');

      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification completed (SMS code received automatically)
          AppLogger.info('Auto-verification completed');
          try {
            await _auth.signInWithCredential(credential);
            AppLogger.info('User signed in successfully');
          } catch (e) {
            AppLogger.error('Auto sign-in failed', e);
            onError?.call('Auto sign-in failed: ${e.toString()}');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          AppLogger.error('Verification failed', e);
          String errorMessage = _getErrorMessage(e.code);
          onError?.call(errorMessage);
        },
        codeSent: (String verificationId, int? resendToken) {
          AppLogger.info('OTP code sent successfully');
          _verificationId = verificationId;
          _resendToken = resendToken;
          onCodeSent?.call(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          AppLogger.info('Auto retrieval timeout');
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
      );

      return true;
    } catch (e) {
      AppLogger.error('Error sending OTP', e);
      onError?.call('Failed to send OTP: ${e.toString()}');
      return false;
    }
  }

  /// Verify OTP code
  Future<UserCredential?> verifyOTP({
    required String otpCode,
    Function(String error)? onError,
  }) async {
    try {
      if (_verificationId == null) {
        onError?.call('Verification ID not found. Please request OTP again.');
        return null;
      }

      AppLogger.info('Verifying OTP code');

      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otpCode,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      AppLogger.info('OTP verified successfully');

      // Clear verification ID after successful verification
      _verificationId = null;
      _resendToken = null;

      return userCredential;
    } catch (e) {
      AppLogger.error('OTP verification failed', e);
      String errorMessage = _getErrorMessage(e.toString());
      onError?.call(errorMessage);
      return null;
    }
  }

  /// Resend OTP
  Future<bool> resendOTP({
    required String phoneNumber,
    Function(String verificationId)? onCodeSent,
    Function(String error)? onError,
  }) async {
    try {
      String formattedPhone = _formatPhoneNumber(phoneNumber);

      AppLogger.info('Resending OTP to: $formattedPhone');

      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        forceResendingToken: _resendToken,
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await _auth.signInWithCredential(credential);
            AppLogger.info('Auto sign-in after resend');
          } catch (e) {
            AppLogger.error('Auto sign-in failed after resend', e);
            onError?.call('Auto sign-in failed: ${e.toString()}');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          AppLogger.error('Resend verification failed', e);
          String errorMessage = _getErrorMessage(e.code);
          onError?.call(errorMessage);
        },
        codeSent: (String verificationId, int? resendToken) {
          AppLogger.info('OTP resent successfully');
          _verificationId = verificationId;
          _resendToken = resendToken;
          onCodeSent?.call(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
      );

      return true;
    } catch (e) {
      AppLogger.error('Error resending OTP', e);
      onError?.call('Failed to resend OTP: ${e.toString()}');
      return false;
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _verificationId = null;
      _resendToken = null;
      AppLogger.info('User signed out successfully');
    } catch (e) {
      AppLogger.error('Sign out failed', e);
      rethrow;
    }
  }

  /// Get current authenticated user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  /// Format phone number to include country code (India: +91)
  String _formatPhoneNumber(String phone) {
    // Remove any spaces, dashes, or special characters
    String cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // If already has country code, return as is
    if (cleaned.startsWith('+')) {
      return cleaned;
    }

    // If starts with 0, remove it
    if (cleaned.startsWith('0')) {
      cleaned = cleaned.substring(1);
    }

    // Add India country code (+91) if not present
    if (!cleaned.startsWith('91')) {
      return '+91$cleaned';
    }

    return '+$cleaned';
  }

  /// Get user-friendly error message
  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'invalid-phone-number':
        return 'Invalid phone number. Please check and try again.';
      case 'too-many-requests':
        return 'Too many requests. Please wait a few minutes before trying again.';
      case 'session-expired':
        return 'Verification session expired. Please request a new OTP.';
      case 'invalid-verification-code':
        return 'Invalid OTP code. Please check and try again.';
      case 'invalid-verification-id':
        return 'Verification ID expired. Please request a new OTP.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        if (errorCode.contains('network')) {
          return 'Network error. Please check your internet connection.';
        }
        return 'An error occurred: $errorCode';
    }
  }

  /// Clear verification state
  void clearVerificationState() {
    _verificationId = null;
    _resendToken = null;
  }
}
