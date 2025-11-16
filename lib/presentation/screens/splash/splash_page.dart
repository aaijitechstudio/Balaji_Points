import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:balaji_points/config/theme.dart';
import 'package:balaji_points/services/user_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  final UserService _userService = UserService();
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
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        // Not logged in - go to login
        if (mounted) {
          context.go('/login');
        }
        return;
      }

      // User is logged in - check profile completion and role
      final userData = await _userService.getCurrentUserData();

      if (!mounted) return;

      // Check if profile is incomplete
      final firstName = userData?['firstName'] as String? ?? '';
      if (firstName.trim().isEmpty || firstName == 'User') {
        context.go('/edit-profile?firstTime=true');
        return;
      }

      // Check if user is admin
      final role = (userData?['role'] as String?)?.toLowerCase();
      if (role == 'admin') {
        context.go('/admin');
      } else {
        context.go('/');
      }
    } catch (e) {
      // On error, go to login
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
    return Scaffold(
      backgroundColor: AppColors.primary,
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
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.secondary.withOpacity(0.4),
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
                                      AppColors.primary,
                                      AppColors.secondary,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.star,
                                  color: Colors.white,
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
                      'Balaji Points',
                      style: AppTextStyles.nunitoBold.copyWith(
                        fontSize: 32,
                        color: Colors.white,
                        letterSpacing: 1.5,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
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
                      'Rewards & Loyalty Program',
                      style: AppTextStyles.nunitoRegular.copyWith(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
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
                        Colors.white.withOpacity(0.8),
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
                        'Powered by\nShree Balaji Plywood & Hardware',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.nunitoRegular.copyWith(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
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
        return Colors.amber;
      case FloatingType.star:
        return AppColors.secondary;
      case FloatingType.sparkle:
        return Colors.white;
      case FloatingType.points:
        return Colors.green;
    }
  }

  void _drawCoin(Canvas canvas, Paint paint) {
    canvas.drawCircle(Offset.zero, 10, paint);
    paint.color = Colors.white.withOpacity(0.6);
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
    paint.color = Colors.white.withOpacity(0.8);
    canvas.drawCircle(Offset(-5, 0), 2.5, paint);
    canvas.drawCircle(Offset(5, 0), 2.5, paint);
  }

  @override
  bool shouldRepaint(covariant CelebrationPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
