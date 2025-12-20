import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:balaji_points/l10n/app_localizations.dart';
import 'package:balaji_points/config/theme.dart';

/// Utility class for handling Android back button scenarios
class BackButtonHandler {
  /// Show exit confirmation dialog
  static Future<bool?> showExitConfirmation(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return false;

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Exit App?',
          style: AppTextStyles.nunitoBold.copyWith(fontSize: 20),
        ),
        content: Text(
          'Do you want to exit the app?',
          style: AppTextStyles.nunitoRegular.copyWith(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              l10n.cancel,
              style: AppTextStyles.nunitoMedium.copyWith(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Exit',
              style: AppTextStyles.nunitoSemiBold.copyWith(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  /// Show discard changes dialog
  static Future<bool?> showDiscardDialog(
    BuildContext context, {
    String? customMessage,
  }) async {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return false;

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Discard Changes?',
          style: AppTextStyles.nunitoBold.copyWith(fontSize: 20),
        ),
        content: Text(
          customMessage ??
              'You have unsaved changes. Do you want to discard them?',
          style: AppTextStyles.nunitoRegular.copyWith(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              l10n.cancel,
              style: AppTextStyles.nunitoMedium.copyWith(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Discard',
              style: AppTextStyles.nunitoSemiBold.copyWith(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  /// Exit app
  static void exitApp() {
    SystemNavigator.pop();
  }

  /// Show snackbar message for double-tap exit
  static void showDoubleTapExitMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Press back again to exit',
          style: AppTextStyles.nunitoMedium.copyWith(color: Colors.white),
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.grey[800],
      ),
    );
  }
}
