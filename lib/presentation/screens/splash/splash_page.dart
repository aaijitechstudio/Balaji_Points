import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:balaji_points/core/theme/design_token.dart';
import 'package:balaji_points/config/theme.dart' hide AppColors;
import 'package:balaji_points/l10n/app_localizations.dart';
import 'package:balaji_points/services/session_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  final _sessionService = SessionService();
  late AnimationController _logoController;
  late AnimationController _backgroundController;
  late Animation<double> _fade;
  late Animation<double> _scale;
  late Animation<double> _rotation;
  late List<FloatingElement> _floatingElements;

  @override
  void initState() {
    super.initState();

    // Logo animation controller
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Background animation controller
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    // Logo animations
    _fade = CurvedAnimation(parent: _logoController, curve: Curves.easeInOut);

    _scale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _rotation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    // Create floating background elements
    final random = math.Random(42);
    _floatingElements = List.generate(
      15,
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

    // Start logo animation
    _logoController.forward();

    // Navigate after delay - check authentication
    Timer(const Duration(seconds: 3), () {
      _checkAuthAndNavigate();
    });
  }

  Future<void> _checkAuthAndNavigate() async {
    if (!mounted) return;

    try {
      // Check if user has an active session
      final isLoggedIn = await _sessionService.isLoggedIn();

      if (!mounted) return;

      if (isLoggedIn) {
        // User is logged in - check role and navigate accordingly
        final role = await _sessionService.getUserRole();

        if (!mounted) return;

        if (role?.toLowerCase() == 'admin') {
          context.go('/admin');
        } else {
          context.go('/');
        }
      } else {
        // No active session - navigate to login
        context.go('/login');
      }
    } catch (e) {
      // On error, navigate to login
      if (mounted) {
        context.go('/login');
      }
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopScope(
      canPop: false, // Prevent back button on splash
      child: Scaffold(
        backgroundColor: DesignToken.primary,
        body: Stack(
          children: [
            // Animated Background Elements
            IgnorePointer(
              child: RepaintBoundary(
                child: ListenableBuilder(
                  listenable: _backgroundController,
                  builder: (context, child) {
                    return CustomPaint(
                      size: Size.infinite,
                      painter: CelebrationPainter(
                        animationValue: _backgroundController.value,
                        elements: _floatingElements,
                      ),
                    );
                  },
                ),
              ),
            ),

            // Main Content
            Center(
              child: FadeTransition(
                opacity: _fade,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated Logo
                    ScaleTransition(
                      scale: _scale,
                      child: RotationTransition(
                        turns: _rotation,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: DesignToken.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: DesignToken.secondary.withOpacity(0.4),
                                blurRadius: 30,
                                spreadRadius: 5,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              'assets/images/balaji_point_logo.png',
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        DesignToken.primary,
                                        DesignToken.secondary,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.star,
                                    color: DesignToken.white,
                                    size: 50,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Brand Name with animation
                    FadeTransition(
                      opacity: _fade,
                      child: Text(
                        l10n?.appName ?? 'Balaji Points',
                        style: AppTextStyles.nunitoBold.copyWith(
                          fontSize: 32,
                          color: DesignToken.white,
                          letterSpacing: 1.5,
                          shadows: [
                            Shadow(
                              color: DesignToken.black.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Subtitle
                    FadeTransition(
                      opacity: _fade,
                      child: Text(
                        l10n?.rewardsLoyaltyProgram ??
                            'Rewards & Loyalty Program',
                        style: AppTextStyles.nunitoRegular.copyWith(
                          fontSize: 16,
                          color: DesignToken.white.withOpacity(0.9),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 60),

                    // Loading Indicator
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          DesignToken.white.withOpacity(0.8),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Footer
                    FadeTransition(
                      opacity: _fade,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          '${l10n?.poweredBy ?? 'Powered by'}\n${l10n?.companyName ?? 'Shree Balaji Plywood & Hardware'}',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.nunitoRegular.copyWith(
                            fontSize: 14,
                            color: DesignToken.white.withOpacity(0.8),
                            height: 1.5,
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
      // Calculate animated position
      final y = (element.y + animationValue * element.speed) % 1.2 - 0.1;
      final x = element.x;
      final opacity = (y < 0 || y > 1)
          ? 0.0
          : (y < 0.1 || y > 0.9 ? (y < 0.1 ? y / 0.1 : (1.0 - y) / 0.1) : 1.0);

      if (opacity <= 0) continue;

      final paint = Paint()
        ..color = _getColorForType(element.type).withOpacity(0.5 * opacity)
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
        return DesignToken.white;
      case FloatingType.points:
        return DesignToken.success;
    }
  }

  void _drawCoin(Canvas canvas, Paint paint) {
    canvas.drawCircle(Offset.zero, 10, paint);
    paint.color = DesignToken.white.withOpacity(0.6);
    canvas.drawCircle(Offset(-3, -3), 3, paint);
  }

  void _drawStar(Canvas canvas, Paint paint) {
    final path = Path();
    final outerRadius = 10.0;
    final innerRadius = 5.0;
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
    canvas.drawLine(Offset(-10, 0), Offset(10, 0), paint..strokeWidth = 2);
    canvas.drawLine(Offset(0, -10), Offset(0, 10), paint..strokeWidth = 2);
    canvas.drawCircle(Offset.zero, 4, paint);
  }

  void _drawPoints(Canvas canvas, Paint paint) {
    final path = Path();
    path.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: 18, height: 14),
        const Radius.circular(7),
      ),
    );
    canvas.drawPath(path, paint);
    paint.color = DesignToken.white.withOpacity(0.8);
    canvas.drawCircle(Offset(-5, 0), 2.5, paint);
    canvas.drawCircle(Offset(5, 0), 2.5, paint);
  }

  @override
  bool shouldRepaint(covariant CelebrationPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
