// filepath: lib/presentation/screens/auth/pin_login_page.dart
import 'dart:math' as math;
import 'dart:ui';

import 'package:balaji_points/config/theme.dart' as LegacyTheme;
import 'package:balaji_points/core/theme/design_token.dart';
import 'package:balaji_points/l10n/app_localizations.dart';
import 'package:balaji_points/services/pin_auth_service.dart';
import 'package:balaji_points/services/session_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PINLoginPage extends StatefulWidget {
  final String phoneNumber;

  const PINLoginPage({super.key, required this.phoneNumber});

  @override
  State<PINLoginPage> createState() => _PINLoginPageState();
}

class _PINLoginPageState extends State<PINLoginPage>
    with SingleTickerProviderStateMixin {
  final _pinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late AnimationController _animationController;
  late List<FloatingElement> _floatingElements;

  bool _isLoggingIn = false;
  bool _rememberMe = true; // Remember me is checked by default
  final _pinAuthService = PinAuthService();
  final _sessionService = SessionService();

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // Initialize floating animated elements
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
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final pin = _pinController.text.trim();
    final phone = widget.phoneNumber;

    setState(() => _isLoggingIn = true);

    final userData = await _pinAuthService.verifyPin(phone: phone, pin: pin);

    if (!mounted) return;
    setState(() => _isLoggingIn = false);

    if (userData == null) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.invalidPin), backgroundColor: Colors.red),
      );
      return;
    }

    // Save session after successful login (only if remember me is checked)
    if (_rememberMe) {
      await _sessionService.saveSession(
        phoneNumber: phone,
        userId: userData['id'] as String? ?? phone,
        role: userData['role'] as String? ?? 'carpenter',
        firstName: userData['firstName'] as String?,
        lastName: userData['lastName'] as String?,
      );
    }

    if (!mounted) return;

    // Navigate based on role
    final role = (userData['role'] as String?)?.toLowerCase();
    if (role == 'admin') {
      context.go('/admin');
    } else {
      context.go('/');
    }
  }

  void _goToReset() {
    context.push('/pin-reset?phone=${widget.phoneNumber}');
  }

  void _goToSetup() {
    context.push('/pin-setup?phone=${widget.phoneNumber}');
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: true, // Allow direct back navigation
      child: Scaffold(
        backgroundColor: DesignToken.woodenBackground,

        appBar: AppBar(
          backgroundColor: DesignToken.transparent,
          elevation: 0,
          leading: BackButton(
            color: DesignToken.primary,
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
              padding: EdgeInsets.fromLTRB(24, 20, 24, bottomInset + 20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Logo
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/images/balaji_point_logo.png',
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Text(
                      l10n.appName,
                      style: LegacyTheme.AppTextStyles.nunitoBold.copyWith(
                        fontSize: 26,
                        color: DesignToken.primary,
                      ),
                    ),

                    const SizedBox(height: 6),
                    Text(
                      l10n.enter4DigitPin,
                      style: LegacyTheme.AppTextStyles.nunitoSemiBold.copyWith(
                        fontSize: 18,
                        color: DesignToken.primary,
                      ),
                    ),

                    const SizedBox(height: 4),
                    Text(
                      "+91 ${widget.phoneNumber}",
                      style: TextStyle(
                        fontSize: 14,
                        color: DesignToken.textDark.withOpacity(0.7),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Glass Card
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.all(28),
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
                              TextFormField(
                                controller: _pinController,
                                keyboardType: TextInputType.number,
                                obscureText: true,
                                maxLength: 4,
                                textAlign: TextAlign.center,
                                style: LegacyTheme.AppTextStyles.nunitoBold
                                    .copyWith(
                                      fontSize: 24,
                                      letterSpacing: 12,
                                      color: DesignToken.primary,
                                    ),
                                decoration: InputDecoration(
                                  labelText: l10n.fourDigitPin,
                                  labelStyle: LegacyTheme
                                      .AppTextStyles
                                      .nunitoMedium
                                      .copyWith(fontSize: 16),
                                  counterText: '',
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
                                  if (value == null || value.length != 4) {
                                    return l10n.enter4Digits;
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              // Remember Me Checkbox
                              Row(
                                children: [
                                  Checkbox(
                                    value: _rememberMe,
                                    onChanged: (value) {
                                      setState(() {
                                        _rememberMe = value ?? true;
                                      });
                                    },
                                    activeColor: DesignToken.secondary,
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _rememberMe = !_rememberMe;
                                        });
                                      },
                                      child: Text(
                                        l10n.rememberMe,
                                        style: LegacyTheme
                                            .AppTextStyles
                                            .nunitoRegular
                                            .copyWith(
                                              fontSize: 15,
                                              color: DesignToken.textDark
                                                  .withOpacity(0.8),
                                            ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              // Gradient Login Button
                              SizedBox(
                                width: double.infinity,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        DesignToken.secondary,
                                        DesignToken.secondary.withOpacity(0.8),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: DesignToken.secondary
                                            .withOpacity(0.4),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _isLoggingIn ? null : _login,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: DesignToken.transparent,
                                      shadowColor: DesignToken.transparent,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 18,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: _isLoggingIn
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              color: DesignToken.white,
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                        : Text(
                                            l10n.login,
                                            style: LegacyTheme
                                                .AppTextStyles
                                                .nunitoBold
                                                .copyWith(
                                                  fontSize: 18,
                                                  color: DesignToken.white,
                                                  letterSpacing: 0.5,
                                                ),
                                          ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 8),

                              TextButton(
                                onPressed: _goToReset,
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                                child: Text(
                                  l10n.forgotPin,
                                  style: LegacyTheme
                                      .AppTextStyles
                                      .nunitoSemiBold
                                      .copyWith(
                                        color: DesignToken.secondary,
                                        fontSize: 15,
                                      ),
                                ),
                              ),

                              TextButton(
                                onPressed: _goToSetup,
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                ),
                                child: Text(
                                  l10n.newUserSetPin,
                                  style: LegacyTheme.AppTextStyles.nunitoMedium
                                      .copyWith(
                                        color: DesignToken.textDark.withOpacity(
                                          0.7,
                                        ),
                                        fontSize: 14,
                                      ),
                                ),
                              ),
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
        return Colors.amber;
      case FloatingType.star:
        return DesignToken.secondary;
      case FloatingType.sparkle:
        return DesignToken.primary;
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
