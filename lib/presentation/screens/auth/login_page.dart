import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:balaji_points/core/theme/design_token.dart';
import 'package:balaji_points/config/theme.dart' hide AppColors;
import 'package:balaji_points/l10n/app_localizations.dart';
import 'package:balaji_points/core/utils/back_button_handler.dart';
import '../../providers/locale_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<FloatingElement> _floatingElements;

  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    final random = math.Random(42);
    _floatingElements = List.generate(
      12,
      (index) => FloatingElement(
        x: random.nextDouble(),
        y: random.nextDouble(),
        speed: 0.3 + random.nextDouble() * 0.4,
        type: index % 4 == 0
            ? FloatingType.coin
            : (index % 4 == 1
                  ? FloatingType.star
                  : (index % 4 == 2
                        ? FloatingType.sparkle
                        : FloatingType.points)),
      ),
    );

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _goToPinLogin() {
    if (!_formKey.currentState!.validate()) return;

    final phone = _phoneController.text.trim();
    context.push('/pin-login?phone=$phone');
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

          // Show exit confirmation
          final shouldExit = await BackButtonHandler.showExitConfirmation(
            context,
          );
          if (shouldExit == true && mounted) {
            BackButtonHandler.exitApp();
          }
        }
      },
      child: Scaffold(
        backgroundColor: DesignToken.woodenBackground,
        body: Column(
          children: [
            SafeArea(bottom: false, child: Container()),

            Expanded(
              child: Stack(
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

                  SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: bottomInset + 20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            const SizedBox(height: 20),

                            // Language switcher
                            Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                height: 40,
                                decoration: BoxDecoration(
                                  color: DesignToken.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: DesignToken.primary.withOpacity(0.3),
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<Locale>(
                                    value: ref.watch(localeProvider),
                                    onChanged: (Locale? newLocale) {
                                      if (newLocale != null) {
                                        ref
                                            .read(localeProvider.notifier)
                                            .setLocale(newLocale);
                                      }
                                    },
                                    items: const [
                                      DropdownMenuItem(
                                        value: Locale('en'),
                                        child: Text("English"),
                                      ),
                                      DropdownMenuItem(
                                        value: Locale('hi'),
                                        child: Text("हिंदी"),
                                      ),
                                      DropdownMenuItem(
                                        value: Locale('ta'),
                                        child: Text("தமிழ்"),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Logo + name
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                'assets/images/balaji_point_logo.png',
                                width: 100,
                                height: 100,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Balaji Points",
                              style: AppTextStyles.nunitoBold.copyWith(
                                fontSize: 30,
                                color: DesignToken.primary,
                              ),
                            ),

                            const SizedBox(height: 24),

                            Text(
                              l10n.enterPhoneNumber,
                              style: AppTextStyles.nunitoRegular.copyWith(
                                fontSize: 16,
                                color: DesignToken.textDark.withOpacity(0.9),
                              ),
                            ),

                            const SizedBox(height: 30),

                            // Glass Card with phone + button
                            ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 10,
                                  sigmaY: 10,
                                ),
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
                                        color: DesignToken.primary.withOpacity(
                                          0.1,
                                        ),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      TextFormField(
                                        controller: _phoneController,
                                        maxLength: 10,
                                        keyboardType: TextInputType.phone,
                                        style: AppTextStyles.nunitoSemiBold
                                            .copyWith(
                                              fontSize: 18,
                                              color: DesignToken.textDark,
                                            ),
                                        decoration: InputDecoration(
                                          labelText: l10n.mobileNumber,
                                          labelStyle: AppTextStyles.nunitoMedium
                                              .copyWith(fontSize: 16),
                                          prefixText: "+91 ",
                                          prefixStyle: AppTextStyles
                                              .nunitoSemiBold
                                              .copyWith(
                                                fontSize: 18,
                                                color: DesignToken.primary,
                                              ),
                                          counterText: "",
                                          filled: true,
                                          fillColor: DesignToken.primary
                                              .withOpacity(0.05),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            borderSide: BorderSide(
                                              color: DesignToken.primary
                                                  .withOpacity(0.3),
                                              width: 1.5,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            borderSide: BorderSide(
                                              color: DesignToken.primary
                                                  .withOpacity(0.2),
                                              width: 1.5,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            borderSide: BorderSide(
                                              color: DesignToken.primary,
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                        validator: (value) {
                                          final v = value?.trim() ?? "";
                                          if (v.length != 10 ||
                                              !RegExp(
                                                r'^[0-9]+$',
                                              ).hasMatch(v)) {
                                            return l10n.enterValidTenDigit;
                                          }
                                          return null;
                                        },
                                      ),

                                      const SizedBox(height: 24),

                                      // Gradient Button
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              DesignToken.secondary,
                                              DesignToken.secondary.withOpacity(
                                                0.8,
                                              ),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
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
                                          onPressed: _goToPinLogin,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                DesignToken.transparent,
                                            shadowColor:
                                                DesignToken.transparent,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 18,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                          ),
                                          child: Text(
                                            l10n.continueWithPin,
                                            style: AppTextStyles.nunitoBold
                                                .copyWith(
                                                  fontSize: 18,
                                                  color: DesignToken.white,
                                                  letterSpacing: 0.5,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),
                            Text(
                              "${l10n.poweredBy} ${l10n.companyName}",
                              style: const TextStyle(
                                color: DesignToken.secondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
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
      // Calculate animated position
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
