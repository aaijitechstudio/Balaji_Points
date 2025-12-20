// filepath: lib/presentation/screens/auth/pin_setup_page.dart
import 'dart:math' as math;
import 'dart:ui';

import 'package:balaji_points/config/theme.dart' as LegacyTheme;
import 'package:balaji_points/core/theme/app_colors.dart';
import 'package:balaji_points/l10n/app_localizations.dart';
import 'package:balaji_points/services/pin_auth_service.dart';
import 'package:balaji_points/services/session_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PINSetupPage extends StatefulWidget {
  final String? phoneNumber;

  const PINSetupPage({super.key, this.phoneNumber});

  @override
  State<PINSetupPage> createState() => _PINSetupPageState();
}

class _PINSetupPageState extends State<PINSetupPage>
    with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late AnimationController _animationController;
  late List<FloatingElement> _floatingElements;

  bool _isSaving = false;

  final _pinAuthService = PinAuthService();
  final _sessionService = SessionService();

  @override
  void initState() {
    super.initState();

    if (widget.phoneNumber != null && widget.phoneNumber!.isNotEmpty) {
      _phoneController.text = widget.phoneNumber!;
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

  @override
  void dispose() {
    _animationController.dispose();
    _phoneController.dispose();
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _savePin() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context)!;
    final phone = _phoneController.text.trim();
    final pin = _pinController.text.trim();
    final confirm = _confirmPinController.text.trim();

    if (pin != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pinsDoNotMatch),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    // Create account with minimal information - carpenter can fill details later
    final success = await _pinAuthService.createAccount(
      phone: phone,
      pin: pin,
      firstName: '', // Empty for now - can be filled later
    );

    if (!mounted) return;

    if (success) {
      // Save session with minimal information
      await _sessionService.saveSession(
        phoneNumber: phone,
        userId: phone,
        role: 'carpenter',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pinCreatedSuccess),
          backgroundColor: Colors.green,
        ),
      );

      context.go('/');
    } else {
      // Account already exists - guide user to Reset PIN
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.accountExistsUseReset),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: l10n.resetPin,
            textColor: Colors.white,
            onPressed: () {
              context.push('/reset-pin', extra: phone);
            },
          ),
        ),
      );
    }

    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.woodenBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(
          color: AppColors.primary,
          onPressed: () => context.pop(),
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
                  const SizedBox(height: 10),

                  // Logo
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/images/balaji_point_logo.png',
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    l10n.createPinTitle,
                    style: LegacyTheme.AppTextStyles.nunitoBold.copyWith(
                      fontSize: 24,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 4),
                  Text(
                    l10n.createPinSubtitle,
                    style: LegacyTheme.AppTextStyles.nunitoRegular.copyWith(
                      fontSize: 14,
                      color: AppColors.textDark.withOpacity(0.7),
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
                              Colors.white.withOpacity(0.9),
                              Colors.white.withOpacity(0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.5),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Phone Number
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              maxLength: 10,
                              style: LegacyTheme.AppTextStyles.nunitoSemiBold.copyWith(
                                fontSize: 16,
                              ),
                              decoration: InputDecoration(
                                labelText: l10n.mobileNumber,
                                prefixText: "+91 ",
                                counterText: "",
                                filled: true,
                                fillColor: AppColors.primary.withOpacity(0.05),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: AppColors.primary.withOpacity(0.3),
                                    width: 1.5,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: AppColors.primary.withOpacity(0.2),
                                    width: 1.5,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: AppColors.primary,
                                    width: 2,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                final v = value?.trim() ?? '';
                                if (v.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(v)) {
                                  return l10n.enterValidTenDigit;
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            // PIN
                            TextFormField(
                              controller: _pinController,
                              keyboardType: TextInputType.number,
                              obscureText: true,
                              maxLength: 4,
                              textAlign: TextAlign.center,
                              style: LegacyTheme.AppTextStyles.nunitoBold.copyWith(
                                fontSize: 20,
                                letterSpacing: 8,
                                color: AppColors.primary,
                              ),
                              decoration: InputDecoration(
                                labelText: l10n.fourDigitPin,
                                counterText: '',
                                filled: true,
                                fillColor: AppColors.primary.withOpacity(0.05),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: AppColors.primary.withOpacity(0.3),
                                    width: 1.5,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: AppColors.primary.withOpacity(0.2),
                                    width: 1.5,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: AppColors.primary,
                                    width: 2,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.length != 4) {
                                  return l10n.enter4Digits;
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // Confirm PIN
                            TextFormField(
                              controller: _confirmPinController,
                              keyboardType: TextInputType.number,
                              obscureText: true,
                              maxLength: 4,
                              textAlign: TextAlign.center,
                              style: LegacyTheme.AppTextStyles.nunitoBold.copyWith(
                                fontSize: 20,
                                letterSpacing: 8,
                                color: AppColors.primary,
                              ),
                              decoration: InputDecoration(
                                labelText: l10n.confirmPin,
                                counterText: '',
                                filled: true,
                                fillColor: AppColors.primary.withOpacity(0.05),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: AppColors.primary.withOpacity(0.3),
                                    width: 1.5,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: AppColors.primary.withOpacity(0.2),
                                    width: 1.5,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: AppColors.primary,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Save Button with Gradient
                            SizedBox(
                              width: double.infinity,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.secondary,
                                      AppColors.secondary.withOpacity(0.8),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.secondary.withOpacity(0.4),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _isSaving ? null : _savePin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(vertical: 18),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: _isSaving
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : Text(
                                          l10n.savePin,
                                          style: LegacyTheme.AppTextStyles.nunitoBold.copyWith(
                                            fontSize: 18,
                                            color: Colors.white,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
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
        return Colors.amber;
      case FloatingType.star:
        return AppColors.secondary;
      case FloatingType.sparkle:
        return AppColors.primary;
      case FloatingType.points:
        return Colors.green;
    }
  }

  void _drawCoin(Canvas canvas, Paint paint) {
    canvas.drawCircle(Offset.zero, 8, paint);
    paint.color = Colors.white.withOpacity(0.6);
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

    paint.color = Colors.white.withOpacity(0.8);
    canvas.drawCircle(Offset(-4, 0), 2, paint);
    canvas.drawCircle(Offset(4, 0), 2, paint);
  }

  @override
  bool shouldRepaint(covariant CelebrationPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
