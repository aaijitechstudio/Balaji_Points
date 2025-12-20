// filepath: lib/presentation/screens/auth/reset_pin_page.dart
import 'dart:math' as math;
import 'dart:ui';

import 'package:balaji_points/config/theme.dart' as LegacyTheme;
import 'package:balaji_points/core/theme/design_token.dart';
import 'package:balaji_points/l10n/app_localizations.dart';
import 'package:balaji_points/services/pin_auth_service.dart';
import 'package:balaji_points/services/session_service.dart';
import 'package:balaji_points/core/utils/back_button_handler.dart';
import 'package:balaji_points/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class ResetPINPage extends StatefulWidget {
  final String? phoneNumber;

  const ResetPINPage({super.key, this.phoneNumber});

  @override
  State<ResetPINPage> createState() => _ResetPINPageState();
}

class _ResetPINPageState extends State<ResetPINPage>
    with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  final _currentPinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late AnimationController _animationController;
  late List<FloatingElement> _floatingElements;

  final _pinAuthService = PinAuthService();
  final _sessionService = SessionService();

  bool _phoneChecked = false;
  bool _phoneExists = false;
  bool _isCheckingPhone = false;
  bool _isSaving = false;
  bool _isLoggedIn = false;
  String? _loggedInPhone;

  @override
  void initState() {
    super.initState();

    // Check if user is logged in
    _checkLoginStatus();

    if (widget.phoneNumber != null && widget.phoneNumber!.isNotEmpty) {
      _phoneController.text = widget.phoneNumber!;
      // Automatically verify pre-filled phone number
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkPhone();
      });
    }

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _floatingElements = List.generate(25, (index) {
      return FloatingElement(
        x: math.Random().nextDouble(),
        y: math.Random().nextDouble(),
        speed: 0.2 + math.Random().nextDouble() * 0.8,
        type: FloatingType.values[index % FloatingType.values.length],
      );
    });
  }

  Future<void> _checkLoginStatus() async {
    final isLoggedIn = await _sessionService.isLoggedIn();
    String? loggedInPhone;

    if (isLoggedIn) {
      loggedInPhone = await _sessionService.getPhoneNumber();
    }

    if (mounted) {
      setState(() {
        _isLoggedIn = isLoggedIn;
        _loggedInPhone = loggedInPhone;

        // If logged in, pre-fill phone number
        if (loggedInPhone != null && _phoneController.text.isEmpty) {
          _phoneController.text = loggedInPhone;
        }
      });

      // Automatically verify the phone number after pre-filling (if logged in)
      if (isLoggedIn &&
          loggedInPhone != null &&
          _phoneController.text.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _checkPhone();
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _phoneController.dispose();
    _pinController.dispose();
    _confirmPinController.dispose();
    _currentPinController.dispose();
    super.dispose();
  }

  Future<void> _checkPhone() async {
    final v = _phoneController.text.trim();
    final l10n = AppLocalizations.of(context)!;

    if (v.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(v)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.enterValidTenDigit),
          backgroundColor: DesignToken.error,
        ),
      );
      return;
    }

    // Security check: If logged in, verify phone matches
    if (_isLoggedIn && _loggedInPhone != null) {
      final normalizedLoggedIn = _pinAuthService.normalizePhone(
        _loggedInPhone!,
      );
      final normalizedInput = _pinAuthService.normalizePhone(v);

      if (normalizedLoggedIn != normalizedInput) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.canOnlyResetOwnPin),
            backgroundColor: DesignToken.error,
          ),
        );
        return;
      }
    }

    // Security check: If not logged in, deny reset
    if (!_isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.mustBeLoggedInToResetPin),
          backgroundColor: DesignToken.error,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    setState(() {
      _isCheckingPhone = true;
      _phoneChecked = false;
    });

    final hasPin = await _pinAuthService.hasPin(v);

    if (!mounted) return;

    setState(() {
      _isCheckingPhone = false;
      _phoneChecked = true;
      _phoneExists = hasPin;
    });

    if (!hasPin) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.noAccountFound),
          backgroundColor: DesignToken.error,
        ),
      );
    }
  }

  bool _hasPinData() {
    return _pinController.text.trim().isNotEmpty ||
        _confirmPinController.text.trim().isNotEmpty ||
        _currentPinController.text.trim().isNotEmpty;
  }

  Future<void> _saveNewPin() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context)!;

    // Security check: Must be logged in
    if (!_isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.mustBeLoggedInToResetPin),
          backgroundColor: DesignToken.error,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    if (!_phoneChecked || !_phoneExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseVerifyMobile),
          backgroundColor: DesignToken.orange,
        ),
      );
      return;
    }

    final pin = _pinController.text.trim();
    final confirm = _confirmPinController.text.trim();
    final currentPin = _currentPinController.text.trim();
    final phone = _phoneController.text.trim();

    // Verify current PIN is provided
    if (currentPin.isEmpty || currentPin.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.enterCurrentPin),
          backgroundColor: DesignToken.error,
        ),
      );
      return;
    }

    if (pin != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pinsDoNotMatch),
          backgroundColor: DesignToken.error,
        ),
      );
      return;
    }

    // Prevent setting same PIN
    if (currentPin == pin) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.newPinMustBeDifferent),
          backgroundColor: DesignToken.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    // Reset PIN with security verification
    final ok = await _pinAuthService.resetPin(
      phone: phone,
      newPin: pin,
      loggedInPhone: _loggedInPhone,
      currentPin: currentPin,
      isAdmin: false,
    );

    if (!mounted) return;

    setState(() => _isSaving = false);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pinResetSuccess),
          backgroundColor: DesignToken.success,
        ),
      );

      // Clear form
      _currentPinController.clear();
      _pinController.clear();
      _confirmPinController.clear();

      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.failedToResetPin),
          backgroundColor: DesignToken.error,
        ),
      );
    }
  }

  /// Make phone call to support number
  Future<void> _makePhoneCall(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cannot make phone call to $phoneNumber'),
              backgroundColor: DesignToken.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error making phone call: $e'),
            backgroundColor: DesignToken.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          // Check for dialogs first
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
            return;
          }

          if (_phoneChecked && _hasPinData()) {
            // On PIN entry step - ask to discard
            final shouldDiscard = await BackButtonHandler.showDiscardDialog(
              context,
            );
            if (shouldDiscard == true && mounted) {
              setState(() {
                _phoneChecked = false;
                _pinController.clear();
                _confirmPinController.clear();
                _currentPinController.clear();
              });
            }
          } else {
            // On phone step - go back to PIN login
            context.pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: DesignToken.woodenBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(l10n.resetPinTitle),
          leading: BackButton(
            color: DesignToken.primary,
            onPressed: () {
              if (_phoneChecked && _hasPinData()) {
                // Will be handled by PopScope
                Navigator.of(context).maybePop();
              } else {
                context.pop();
              }
            },
          ),
        ),
        body: Stack(
          children: [
            // Animated Background Elements
            IgnorePointer(
              child: RepaintBoundary(
                child: ListenableBuilder(
                  listenable: _animationController,
                  builder: (context, child) {
                    return CustomPaint(
                      size: Size.infinite,
                      painter: CelebrationPainter(
                        animationValue: _animationController.value,
                        elements: _floatingElements,
                      ),
                    );
                  },
                ),
              ),
            ),

            // Main Content
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24, 10, 24, bottomInset + 20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 6),

                    Text(
                      _isLoggedIn
                          ? l10n.resetPinSubtitle
                          : l10n.mustBeLoggedInToResetPin,
                      textAlign: TextAlign.center,
                      style: LegacyTheme.AppTextStyles.nunitoRegular.copyWith(
                        fontSize: 13,
                        color: _isLoggedIn
                            ? DesignToken.textDark.withOpacity(0.7)
                            : DesignToken.error,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Glass Card
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                DesignToken.white.withOpacity(0.9),
                                DesignToken.white.withOpacity(0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: DesignToken.white.withOpacity(0.5),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: DesignToken.primary.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Phone Number Field
                              TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                maxLength: 10,
                                enabled:
                                    !_isLoggedIn, // Disable if logged in (auto-filled)
                                style: LegacyTheme.AppTextStyles.nunitoSemiBold
                                    .copyWith(fontSize: 16),
                                decoration: InputDecoration(
                                  labelText: l10n.mobileNumber,
                                  prefixText: "+91 ",
                                  counterText: "",
                                  filled: true,
                                  fillColor: _isLoggedIn
                                      ? DesignToken.primary.withOpacity(0.1)
                                      : DesignToken.primary.withOpacity(0.05),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: DesignToken.primary.withOpacity(
                                        0.3,
                                      ),
                                      width: 1.5,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: DesignToken.primary.withOpacity(
                                        0.2,
                                      ),
                                      width: 1.5,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: DesignToken.primary,
                                      width: 2,
                                    ),
                                  ),
                                  disabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: DesignToken.primary.withOpacity(
                                        0.3,
                                      ),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  final v = value?.trim() ?? '';
                                  if (v.length != 10 ||
                                      !RegExp(r'^[0-9]+$').hasMatch(v)) {
                                    return l10n.enterValidTenDigit;
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 12),

                              // Check Number Button (only show if not logged in)
                              if (!_isLoggedIn) ...[
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          _phoneChecked && _phoneExists
                                              ? DesignToken.success
                                              : DesignToken.primary,
                                          _phoneChecked && _phoneExists
                                              ? DesignToken.greenShade700
                                              : DesignToken.primary.withOpacity(
                                                  0.8,
                                                ),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                              (_phoneChecked && _phoneExists
                                                      ? DesignToken.success
                                                      : DesignToken.primary)
                                                  .withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton.icon(
                                      onPressed: _isCheckingPhone
                                          ? null
                                          : _checkPhone,
                                      icon: _isCheckingPhone
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation(
                                                      DesignToken.white,
                                                    ),
                                              ),
                                            )
                                          : Icon(
                                              _phoneChecked && _phoneExists
                                                  ? Icons.check_circle
                                                  : Icons.search,
                                              size: 18,
                                            ),
                                      label: Text(
                                        _phoneChecked && _phoneExists
                                            ? l10n.verified
                                            : l10n.checkNumber,
                                        style: LegacyTheme
                                            .AppTextStyles
                                            .nunitoSemiBold
                                            .copyWith(fontSize: 14),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 10,
                                        ),
                                        foregroundColor: DesignToken.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],

                              // Auto-verify if logged in
                              if (_isLoggedIn && _loggedInPhone != null) ...[
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: DesignToken.success.withOpacity(
                                        0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: DesignToken.success,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          size: 18,
                                          color: DesignToken.success,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          l10n.verified,
                                          style: LegacyTheme
                                              .AppTextStyles
                                              .nunitoSemiBold
                                              .copyWith(
                                                fontSize: 14,
                                                color: DesignToken.success,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],

                              const SizedBox(height: 20),

                              // Current PIN Field (Required for logged-in users)
                              if (_isLoggedIn) ...[
                                TextFormField(
                                  controller: _currentPinController,
                                  keyboardType: TextInputType.number,
                                  obscureText: true,
                                  maxLength: 4,
                                  textAlign: TextAlign.center,
                                  style: LegacyTheme.AppTextStyles.nunitoBold
                                      .copyWith(
                                        fontSize: 20,
                                        letterSpacing: 8,
                                        color: DesignToken.primary,
                                      ),
                                  decoration: InputDecoration(
                                    labelText: l10n.currentPinLabel,
                                    counterText: "",
                                    filled: true,
                                    fillColor: DesignToken.primary.withOpacity(
                                      0.05,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color: DesignToken.primary.withOpacity(
                                          0.3,
                                        ),
                                        width: 1.5,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color: DesignToken.primary.withOpacity(
                                          0.2,
                                        ),
                                        width: 1.5,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color: DesignToken.primary,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    final v = value?.trim() ?? "";
                                    if (v.length != 4 ||
                                        !RegExp(r'^[0-9]+$').hasMatch(v)) {
                                      return l10n.enter4Digits;
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                              ],

                              // Admin Support Info (for users who forgot current PIN)
                              if (_isLoggedIn) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: DesignToken.primary.withOpacity(
                                      0.05,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: DesignToken.primary.withOpacity(
                                        0.2,
                                      ),
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.help_outline,
                                            size: 20,
                                            color: DesignToken.primary,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            l10n.forgotCurrentPin,
                                            style: LegacyTheme
                                                .AppTextStyles
                                                .nunitoSemiBold
                                                .copyWith(
                                                  fontSize: 14,
                                                  color: DesignToken.primary,
                                                ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        l10n.forgotPinHelp,
                                        style: LegacyTheme
                                            .AppTextStyles
                                            .nunitoRegular
                                            .copyWith(
                                              fontSize: 12,
                                              color: DesignToken.textDark
                                                  .withOpacity(0.7),
                                            ),
                                      ),
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: DesignToken.white,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: DesignToken.primary
                                                .withOpacity(0.2),
                                            width: 1,
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.support_agent,
                                                  size: 18,
                                                  color: DesignToken.secondary,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  l10n.adminSupportInfo,
                                                  style: LegacyTheme
                                                      .AppTextStyles
                                                      .nunitoSemiBold
                                                      .copyWith(
                                                        fontSize: 13,
                                                        color: DesignToken
                                                            .textDark,
                                                      ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            // Support Phone 1
                                            InkWell(
                                              onTap: () => _makePhoneCall(
                                                AppConstants.supportPhone1
                                                    .replaceAll('-', ''),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 8,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: DesignToken.success
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.phone_android,
                                                      size: 16,
                                                      color:
                                                          DesignToken.success,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        l10n.supportPhone1,
                                                        style: LegacyTheme
                                                            .AppTextStyles
                                                            .nunitoSemiBold
                                                            .copyWith(
                                                              fontSize: 13,
                                                              color: DesignToken
                                                                  .success,
                                                            ),
                                                      ),
                                                    ),
                                                    Icon(
                                                      Icons.call,
                                                      size: 16,
                                                      color:
                                                          DesignToken.success,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            // Support Phone 2
                                            InkWell(
                                              onTap: () => _makePhoneCall(
                                                AppConstants.supportPhone2
                                                    .replaceAll('-', ''),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 8,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: DesignToken.primary
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.phone,
                                                      size: 16,
                                                      color:
                                                          DesignToken.primary,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        l10n.supportPhone2,
                                                        style: LegacyTheme
                                                            .AppTextStyles
                                                            .nunitoSemiBold
                                                            .copyWith(
                                                              fontSize: 13,
                                                              color: DesignToken
                                                                  .primary,
                                                            ),
                                                      ),
                                                    ),
                                                    Icon(
                                                      Icons.call,
                                                      size: 16,
                                                      color:
                                                          DesignToken.primary,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],

                              // New PIN Field
                              TextFormField(
                                controller: _pinController,
                                keyboardType: TextInputType.number,
                                obscureText: true,
                                maxLength: 4,
                                textAlign: TextAlign.center,
                                style: LegacyTheme.AppTextStyles.nunitoBold
                                    .copyWith(
                                      fontSize: 20,
                                      letterSpacing: 8,
                                      color: DesignToken.primary,
                                    ),
                                decoration: InputDecoration(
                                  labelText: l10n.newPinLabel,
                                  counterText: "",
                                  filled: true,
                                  fillColor: DesignToken.primary.withOpacity(
                                    0.05,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: DesignToken.primary.withOpacity(
                                        0.3,
                                      ),
                                      width: 1.5,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: DesignToken.primary.withOpacity(
                                        0.2,
                                      ),
                                      width: 1.5,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: DesignToken.primary,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  final v = value?.trim() ?? "";
                                  if (v.length != 4 ||
                                      !RegExp(r'^[0-9]+$').hasMatch(v)) {
                                    return l10n.enter4Digits;
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              // Confirm PIN Field
                              TextFormField(
                                controller: _confirmPinController,
                                keyboardType: TextInputType.number,
                                obscureText: true,
                                maxLength: 4,
                                textAlign: TextAlign.center,
                                style: LegacyTheme.AppTextStyles.nunitoBold
                                    .copyWith(
                                      fontSize: 20,
                                      letterSpacing: 8,
                                      color: DesignToken.primary,
                                    ),
                                decoration: InputDecoration(
                                  labelText: l10n.confirmPin,
                                  counterText: "",
                                  filled: true,
                                  fillColor: DesignToken.primary.withOpacity(
                                    0.05,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: DesignToken.primary.withOpacity(
                                        0.3,
                                      ),
                                      width: 1.5,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: DesignToken.primary.withOpacity(
                                        0.2,
                                      ),
                                      width: 1.5,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: DesignToken.primary,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Reset Button with Gradient (only enabled if logged in)
                              SizedBox(
                                width: double.infinity,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: _isLoggedIn
                                          ? [
                                              DesignToken.secondary,
                                              DesignToken.secondary.withOpacity(
                                                0.8,
                                              ),
                                            ]
                                          : [
                                              Colors.grey,
                                              Colors.grey.withOpacity(0.8),
                                            ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            (_isLoggedIn
                                                    ? DesignToken.secondary
                                                    : Colors.grey)
                                                .withOpacity(0.4),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: (_isSaving || !_isLoggedIn)
                                        ? null
                                        : _saveNewPin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 18,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: _isSaving
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              valueColor:
                                                  AlwaysStoppedAnimation(
                                                    DesignToken.white,
                                                  ),
                                            ),
                                          )
                                        : Text(
                                            l10n.resetPin,
                                            style: LegacyTheme
                                                .AppTextStyles
                                                .nunitoBold
                                                .copyWith(
                                                  color: DesignToken.white,
                                                  fontSize: 18,
                                                ),
                                          ),
                                  ),
                                ),
                              ),

                              // Warning message for non-logged-in users
                              if (!_isLoggedIn) ...[
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: DesignToken.error.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: DesignToken.error.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        size: 20,
                                        color: DesignToken.error,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          l10n.contactAdminForPinReset,
                                          style: LegacyTheme
                                              .AppTextStyles
                                              .nunitoRegular
                                              .copyWith(
                                                fontSize: 13,
                                                color: DesignToken.error,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Floating Element Types
enum FloatingType { coin, star, sparkle, points }

// Floating Element Data
class FloatingElement {
  double x;
  double y;
  double speed;
  FloatingType type;
  double rotation = 0;

  FloatingElement({
    required this.x,
    required this.y,
    required this.speed,
    required this.type,
  });
}

// Celebration Background Painter
class CelebrationPainter extends CustomPainter {
  final double animationValue;
  final List<FloatingElement> elements;

  CelebrationPainter({required this.animationValue, required this.elements});

  @override
  void paint(Canvas canvas, Size size) {
    for (var element in elements) {
      final y = (element.y + animationValue * element.speed) % 1.2 - 0.1;
      final x = element.x;

      final opacity = (y < 0 || y > 1)
          ? 0.0
          : (y < 0.1 || y > 0.9 ? (y < 0.1 ? y / 0.1 : (1.0 - y) / 0.1) : 1.0);

      if (opacity <= 0) continue;

      final paint = Paint()
        ..color = _getColorForType(element.type).withOpacity(0.4 * opacity)
        ..style = PaintingStyle.fill;

      final position = Offset(x * size.width, y * size.height);
      final rotation =
          (animationValue * 2 * math.pi * element.speed) + element.rotation;

      canvas.save();
      canvas.translate(position.dx, position.dy);
      canvas.rotate(rotation);

      switch (element.type) {
        case FloatingType.coin:
          _drawCoin(canvas, paint);
          break;
        case FloatingType.star:
          _drawStar(canvas, paint);
          break;
        case FloatingType.sparkle:
          _drawSparkle(canvas, paint);
          break;
        case FloatingType.points:
          _drawPoints(canvas, paint);
          break;
      }

      canvas.restore();
    }
  }

  Color _getColorForType(FloatingType type) {
    switch (type) {
      case FloatingType.coin:
        return DesignToken.amber;
      case FloatingType.star:
        return DesignToken.secondary;
      case FloatingType.sparkle:
        return DesignToken.primary;
      case FloatingType.points:
        return DesignToken.success;
    }
  }

  void _drawCoin(Canvas canvas, Paint paint) {
    canvas.drawCircle(Offset.zero, 8, paint);
    paint.color = DesignToken.white.withOpacity(0.6);
    canvas.drawCircle(Offset(-3, -3), 2, paint);
  }

  void _drawStar(Canvas canvas, Paint paint) {
    final path = Path();
    final outerRadius = 8.0;
    final innerRadius = 4.0;

    for (int i = 0; i < 5; i++) {
      final angle = (i * 4 * math.pi / 5) - math.pi / 2;
      final x = math.cos(angle) * outerRadius;
      final y = math.sin(angle) * outerRadius;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      final innerAngle =
          (i * 4 * math.pi / 5) - math.pi / 2 + (2 * math.pi / 5);
      final innerX = math.cos(innerAngle) * innerRadius;
      final innerY = math.sin(innerAngle) * innerRadius;
      path.lineTo(innerX, innerY);
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawSparkle(Canvas canvas, Paint paint) {
    canvas.drawLine(Offset(-8, 0), Offset(8, 0), paint..strokeWidth = 2);
    canvas.drawLine(Offset(0, -8), Offset(0, 8), paint..strokeWidth = 2);
    canvas.drawCircle(Offset.zero, 3, paint);
  }

  void _drawPoints(Canvas canvas, Paint paint) {
    final path = Path();
    path.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: 16, height: 12),
        const Radius.circular(6),
      ),
    );
    canvas.drawPath(path, paint);

    paint.color = DesignToken.white.withOpacity(0.8);
    canvas.drawCircle(Offset(-4, 0), 2, paint);
    canvas.drawCircle(Offset(4, 0), 2, paint);
  }

  @override
  bool shouldRepaint(covariant CelebrationPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
