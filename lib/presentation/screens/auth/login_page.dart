import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:balaji_points/config/theme.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with TickerProviderStateMixin {
  // Removed email/password fields - using phone + OTP only

  late AnimationController _animationController;
  late List<FloatingElement> _floatingElements;

  @override
  void initState() {
    super.initState();
    // Create floating elements first (before animation controller)
    // Use a seeded random for consistent behavior
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

    // Initialize animation controller after elements
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Start animation after dependencies are resolved and widget is fully mounted
    Future.microtask(() {
      if (mounted && !_animationController.isAnimating) {
        _animationController.repeat();
      }
    });
  }

  @override
  void dispose() {
    if (_animationController.isAnimating) {
      _animationController.stop();
    }
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      backgroundColor: AppColors.woodenBackground,
      body: Column(
        children: [
          // Top Safe Area (no background color)
          SafeArea(
            bottom: false,
            child: Container(), // Empty container, no color
          ),

          // Main Content
          Expanded(
            child: Container(
              color: AppColors.woodenBackground,
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

                  // Login Content
                  SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: bottomInset + 20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 40),

                          // Logo Section with "Balaji Points" Brand Name
                          Column(
                            children: [
                              // Logo with rounded corners
                              ClipRRect(
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
                                        color: AppColors.primary,
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
                              const SizedBox(height: 16),
                              // Brand Name
                              Text(
                                'Balaji Points',
                                style: AppTextStyles.nunitoBold.copyWith(
                                  fontSize: 30,
                                  color: AppColors.primary,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Welcome Text
                          Text(
                            'Welcome Back',
                            style: AppTextStyles.nunitoBold.copyWith(
                              fontSize: 22,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sign in with your phone number',
                            style: AppTextStyles.nunitoRegular.copyWith(
                              fontSize: 16,
                              color: AppColors.textDark.withOpacity(0.9),
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Phone Login Card
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Info Text
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.primary.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: AppColors.primary,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Login using your registered phone number. You will receive an OTP to verify.',
                                          style: AppTextStyles.nunitoRegular
                                              .copyWith(
                                                fontSize: 13,
                                                color: AppColors.textDark
                                                    .withOpacity(0.8),
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // Phone Login Button (Primary)
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.secondary.withOpacity(
                                          0.3,
                                        ),
                                        blurRadius: 15,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () => context.go('/phone-login'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.secondary,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 18,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.phone,
                                          size: 24,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          "Continue with Phone",
                                          style: AppTextStyles.nunitoBold
                                              .copyWith(
                                                fontSize: 18,
                                                color: Colors.white,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          const SizedBox(height: 8),

                          // Footer
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Powered by ',
                                  style: AppTextStyles.nunitoMedium.copyWith(
                                    fontSize: 14,
                                    color: AppColors.textDark.withOpacity(0.6),
                                  ),
                                ),
                                TextSpan(
                                  text: 'Shree Balaji Plywood & Hardware',
                                  style: AppTextStyles.nunitoSemiBold.copyWith(
                                    fontSize: 14,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 20),
                        ],
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
