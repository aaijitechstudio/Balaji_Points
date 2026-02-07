import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:balaji_points/core/providers/daily_spin_provider.dart';
import 'package:balaji_points/core/theme/design_token.dart';

class DailySpinPage extends ConsumerStatefulWidget {
  const DailySpinPage({super.key});

  @override
  ConsumerState<DailySpinPage> createState() => _DailySpinPageState();
}

class _DailySpinPageState extends ConsumerState<DailySpinPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  bool _isSpinning = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.decelerate));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _spin() async {
    if (_isSpinning) return;

    setState(() {
      _isSpinning = true;
    });

    _controller.reset();
    _controller.forward();

    // Perform the spin and get points
    final points = await ref.read(dailySpinProvider.notifier).performSpin();

    // Wait for animation to complete
    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _isSpinning = false;
    });

    // Show result dialog
    if (mounted) {
      _showResultDialog(points);
    }

    // Refresh state
    ref.read(dailySpinProvider.notifier).refresh();
  }

  void _showResultDialog(int points) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: DesignToken.borderRadiusXL),
        title: const Text(
          '🎉 Congratulations!',
          style: TextStyle(
            fontSize: DesignToken.fontSize3XL,
            fontWeight: FontWeight.bold,
            color: DesignToken.secondary,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You won',
              style: TextStyle(fontSize: DesignToken.fontSizeXL, color: Colors.grey[700]),
            ),
            SizedBox(height: DesignToken.heightSM),
            Text(
              '$points Points!',
              style: TextStyle(
                fontSize: DesignToken.fontSize5XL,
                fontWeight: FontWeight.bold,
                color: DesignToken.secondary,
              ),
            ),
            SizedBox(height: DesignToken.heightXL),
            Text(
              'Points have been added to your account.',
              style: TextStyle(fontSize: DesignToken.fontSizeMD, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignToken.secondary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: DesignToken.borderRadiusMD,
                ),
              ),
              child: const Text('Great!', style: TextStyle(fontSize: DesignToken.fontSizeLG)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final spinState = ref.watch(dailySpinProvider);

    return PopScope(
      canPop: !_isSpinning,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          // Check for dialogs first
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
            return;
          }

          if (_isSpinning) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Please wait for spin to complete'),
                backgroundColor: DesignToken.orange,
              ),
            );
          } else {
            context.pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: DesignToken.background,
        appBar: AppBar(
          title: const Text('Daily Spin'),
          backgroundColor: DesignToken.background,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: DesignToken.paddingAll2XL,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: DesignToken.height4XL),
                  Text(
                    'Spin & Win Points!',
                    style: TextStyle(
                      fontSize: DesignToken.fontSize4XL,
                      fontWeight: FontWeight.bold,
                      color: DesignToken.secondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: DesignToken.heightSM),
                  Text(
                    'Get your daily spin and win exciting points',
                    style: TextStyle(fontSize: DesignToken.fontSizeLG, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: DesignToken.height6XL),

                  // Spin Wheel
                  AnimatedBuilder(
                    animation: _rotationAnimation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _rotationAnimation.value * 20 * 3.14159,
                        child: Container(
                          width: 280,
                          height: 280,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Colors.pink.shade400,
                                Colors.pink.shade600,
                                DesignToken.secondary,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.pink.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Segments (simplified - you can make this more elaborate)
                              CustomPaint(
                                size: const Size(280, 280),
                                painter: SpinWheelPainter(),
                              ),
                              // Center circle
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: DesignToken.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: DesignToken.black.withOpacity(0.1),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.radio_button_checked,
                                  size: 40,
                                  color: DesignToken.secondary,
                                  semanticLabel: 'Spin wheel center',
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: DesignToken.height6XL),

                  // Spin Button
                  if (!spinState.isLoading)
                    ElevatedButton(
                      onPressed: spinState.canSpin && !_isSpinning
                          ? _spin
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignToken.secondary,
                        disabledBackgroundColor: Colors.grey[300],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 60,
                          vertical: 18,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(DesignToken.radius3XL),
                        ),
                      ),
                      child: Text(
                        _isSpinning ? 'Spinning...' : 'Spin Now!',
                        style: const TextStyle(
                          fontSize: DesignToken.fontSize2XL,
                          fontWeight: FontWeight.bold,
                          color: DesignToken.white,
                        ),
                      ),
                    )
                  else
                    const CircularProgressIndicator(),

                  SizedBox(height: DesignToken.height3XL),

                  // Info
                  if (!spinState.canSpin && spinState.lastSpinDate != null)
                    Container(
                      padding: DesignToken.paddingAllLG,
                      decoration: BoxDecoration(
                        color: DesignToken.blueShade50,
                        borderRadius: DesignToken.borderRadiusMD,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.info_outline, color: DesignToken.blue700, semanticLabel: 'Information'),
                          SizedBox(width: DesignToken.widthSM),
                          Text(
                            'You\'ve already spun today!\nCome back tomorrow for another chance.',
                            style: TextStyle(
                              color: DesignToken.blue700,
                              fontSize: DesignToken.fontSizeMD,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SpinWheelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw 8 segments with different colors
    final segments = 8;
    final segmentAngle = (2 * 3.14159) / segments;

    final colors = [
      DesignToken.redShade300,
      DesignToken.orangeShade300,
      DesignToken.yellowShade300,
      DesignToken.greenShade300,
      DesignToken.blueShade300,
      DesignToken.indigoShade300,
      Colors.purple.shade300,
      Colors.pink.shade300,
    ];

    for (int i = 0; i < segments; i++) {
      paint.color = colors[i % colors.length];
      final startAngle = i * segmentAngle - 3.14159 / 2;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        segmentAngle,
        true,
        paint,
      );

      // Draw lines between segments
      final linePaint = Paint()
        ..color = DesignToken.white
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        center,
        Offset(
          center.dx + radius * 0.9 * math.cos(i * segmentAngle - 3.14159 / 2),
          center.dy + radius * 0.9 * math.sin(i * segmentAngle - 3.14159 / 2),
        ),
        linePaint,
      );
    }

    // Draw points text on segments
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i < segments; i++) {
      final angle = i * segmentAngle + segmentAngle / 2 - 3.14159 / 2;
      final points = (i + 1) * 10;
      textPainter.text = TextSpan(
        text: '$points',
        style: TextStyle(
          color: DesignToken.white,
          fontSize: DesignToken.fontSize3XL,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();

      final x =
          center.dx + (radius * 0.7) * math.cos(angle) - textPainter.width / 2;
      final y =
          center.dy + (radius * 0.7) * math.sin(angle) - textPainter.height / 2;

      textPainter.paint(canvas, Offset(x, y));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
