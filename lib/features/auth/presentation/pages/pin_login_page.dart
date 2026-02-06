import 'dart:math' as math;
import 'dart:ui';

import 'package:balaji_points/config/theme.dart' as LegacyTheme;
import 'package:balaji_points/core/theme/design_token.dart';
import 'package:balaji_points/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

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

  bool _rememberMe = true;

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

  void _login() {
    if (!_formKey.currentState!.validate()) return;

    final pin = _pinController.text.trim();
    final phone = widget.phoneNumber;

    context.read<AuthBloc>().add(
      LoginWithPinEvent(
        phoneNumber: phone,
        pin: pin,
        rememberMe: _rememberMe,
      ),
    );
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
      canPop: true,
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticatedState) {
            // Navigate based on role
            final role = (state.role ?? "carpenter").toLowerCase();
            if (role == 'admin') {
              context.go('/admin');
            } else {
              context.go('/');
            }
          } else if (state is AuthErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: DesignToken.error,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoggingIn = state is AuthLoadingState;

          return Scaffold(
            backgroundColor: DesignToken.woodenBackground,

            appBar: AppBar(
              backgroundColor: DesignToken.transparent,
              elevation: DesignToken.elevationNone,
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
                  padding: EdgeInsets.fromLTRB(
                    DesignToken.spacing2XL,
                    DesignToken.spacingXL,
                    DesignToken.spacing2XL,
                    bottomInset + DesignToken.spacingXL,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        SizedBox(height: DesignToken.heightXL),

                        // Logo
                        ClipRRect(
                          borderRadius: DesignToken.borderRadiusSM,
                          child: Image.asset(
                            'assets/images/balaji_point_logo.png',
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(height: DesignToken.heightMD),

                        Text(
                          l10n.appName,
                          style: LegacyTheme.AppTextStyles.nunitoBold.copyWith(
                            fontSize: DesignToken.fontSize4XL,
                            color: DesignToken.primary,
                          ),
                        ),

                        SizedBox(height: DesignToken.heightXS),
                        Text(
                          l10n.enter4DigitPin,
                          style: LegacyTheme.AppTextStyles.nunitoSemiBold.copyWith(
                            fontSize: DesignToken.fontSizeXL,
                            color: DesignToken.primary,
                          ),
                        ),

                        SizedBox(height: DesignToken.heightXS),
                        Text(
                          "+91 ${widget.phoneNumber}",
                          style: TextStyle(
                            fontSize: DesignToken.fontSizeMD,
                            color: DesignToken.textDark.withOpacity(0.7),
                          ),
                        ),

                        SizedBox(height: DesignToken.height3XL),

                        // Glass Card
                        ClipRRect(
                          borderRadius: DesignToken.borderRadius2XL,
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: EdgeInsets.all(DesignToken.padding3XL),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    DesignToken.white.withOpacity(0.9),
                                    DesignToken.white.withOpacity(0.7),
                                  ],
                                ),
                                borderRadius: DesignToken.borderRadius2XL,
                                border: Border.all(
                                  color: DesignToken.white.withOpacity(0.5),
                                  width: 1.5,
                                ),
                                boxShadow: DesignToken.shadowLG.map((shadow) => shadow.copyWith(
                                  color: DesignToken.primary.withOpacity(0.1),
                                )).toList(),
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
                                          fontSize: DesignToken.fontSize3XL,
                                          letterSpacing: 12,
                                          color: DesignToken.primary,
                                        ),
                                    decoration: InputDecoration(
                                      labelText: l10n.fourDigitPin,
                                      labelStyle: LegacyTheme
                                          .AppTextStyles
                                          .nunitoMedium
                                          .copyWith(fontSize: DesignToken.fontSizeLG),
                                      counterText: '',
                                      filled: true,
                                      fillColor: DesignToken.primary.withOpacity(
                                        0.05,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: DesignToken.borderRadiusLG,
                                        borderSide: BorderSide(
                                          color: DesignToken.primary.withOpacity(
                                            0.3,
                                          ),
                                          width: 1.5,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: DesignToken.borderRadiusLG,
                                        borderSide: BorderSide(
                                          color: DesignToken.primary.withOpacity(
                                            0.2,
                                          ),
                                          width: 1.5,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: DesignToken.borderRadiusLG,
                                        borderSide: const BorderSide(
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

                                  SizedBox(height: DesignToken.heightLG),

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
                                                  fontSize: DesignToken.fontSizeMD,
                                                  color: DesignToken.textDark
                                                      .withOpacity(0.8),
                                                ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: DesignToken.heightXL),

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
                                        borderRadius: DesignToken.borderRadiusLG,
                                        boxShadow: DesignToken.shadowMD.map((shadow) => shadow.copyWith(
                                          color: DesignToken.secondary.withOpacity(0.4),
                                        )).toList(),
                                      ),
                                      child: ElevatedButton(
                                        onPressed: isLoggingIn ? null : _login,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: DesignToken.transparent,
                                          shadowColor: DesignToken.transparent,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 18,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: DesignToken.borderRadiusLG,
                                          ),
                                        ),
                                        child: isLoggingIn
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
                                                      fontSize: DesignToken.fontSizeXL,
                                                      color: DesignToken.white,
                                                      letterSpacing: 0.5,
                                                    ),
                                              ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: DesignToken.heightSM),

                                  TextButton(
                                    onPressed: _goToReset,
                                    style: TextButton.styleFrom(
                                      padding: DesignToken.paddingVerticalMD,
                                    ),
                                    child: Text(
                                      l10n.forgotPin,
                                      style: LegacyTheme
                                          .AppTextStyles
                                          .nunitoSemiBold
                                          .copyWith(
                                            color: DesignToken.secondary,
                                            fontSize: DesignToken.fontSizeMD,
                                          ),
                                    ),
                                  ),

                                  TextButton(
                                    onPressed: _goToSetup,
                                    style: TextButton.styleFrom(
                                      padding: DesignToken.paddingVerticalSM,
                                    ),
                                    child: Text(
                                      l10n.newUserSetPin,
                                      style: LegacyTheme.AppTextStyles.nunitoMedium
                                          .copyWith(
                                            color: DesignToken.textDark.withOpacity(
                                              0.7,
                                            ),
                                            fontSize: DesignToken.fontSizeMD,
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
          );
        },
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
        Radius.circular(DesignToken.radiusSM),
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
