import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:balaji_points/config/theme.dart';
import '../../../core/logger.dart';
import '../../../services/user_service.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _skillController = TextEditingController();
  final _referralController = TextEditingController();

  bool _isSubmitting = false;
  late AnimationController _animationController;
  late List<FloatingElement> _floatingElements;
  final UserService _userService = UserService();

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
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _skillController.dispose();
    _referralController.dispose();
    super.dispose();
  }

  Future<void> _submitSignup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final phoneNumber = _phoneController.text.trim();

      // Check if phone number already exists
      final exists = await _userService.checkPendingUser(phoneNumber);

      if (exists) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'This phone number is already registered and pending approval.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

      // Create pending user using UserService
      final success = await _userService.createPendingUser(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: phoneNumber,
        city: _cityController.text.trim().isNotEmpty
            ? _cityController.text.trim()
            : null,
        skill: _skillController.text.trim().isNotEmpty
            ? _skillController.text.trim()
            : null,
        referral: _referralController.text.trim().isNotEmpty
            ? _referralController.text.trim()
            : null,
      );

      if (!success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to create account. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

      AppLogger.info('Signup submitted successfully for phone: $phoneNumber');

      if (mounted) {
        // Show success dialog
        _showSuccessDialog();
      }
    } catch (e) {
      AppLogger.error('Signup failed', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Signup failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Request Submitted',
                style: AppTextStyles.nunitoBold.copyWith(
                  fontSize: 20,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Your account is awaiting approval from admin. You\'ll be notified once approved.',
          style: AppTextStyles.nunitoRegular.copyWith(
            fontSize: 16,
            color: AppColors.textDark,
          ),
        ),
        actions: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondary.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // Use the widget's context for navigation
                if (mounted) {
                  context.go('/login');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'Go to Login',
                style: AppTextStyles.nunitoBold.copyWith(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      backgroundColor: AppColors.woodenBackground,
      body: SafeArea(
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

            // Signup Content
            SingleChildScrollView(
              padding: EdgeInsets.only(bottom: bottomInset + 20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),

                      // Back Button
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          color: AppColors.primary,
                          onPressed: () => context.go('/login'),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Logo and Title
                      Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              'assets/images/balaji_point_logo.png',
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.star,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Create Account',
                            style: AppTextStyles.nunitoBold.copyWith(
                              fontSize: 26,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Fill in your details to get started',
                            style: AppTextStyles.nunitoRegular.copyWith(
                              fontSize: 14,
                              color: AppColors.textDark.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Signup Card
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
                            // First Name
                            TextFormField(
                              controller: _firstNameController,
                              cursorColor: AppColors.primary,
                              style: AppTextStyles.nunitoRegular.copyWith(
                                color: AppColors.textDark,
                                fontSize: 16,
                              ),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppColors.primary.withOpacity(0.05),
                                labelText: "First Name *",
                                labelStyle: AppTextStyles.nunitoMedium.copyWith(
                                  color: AppColors.primary.withOpacity(0.7),
                                ),
                                prefixIcon: Container(
                                  margin: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.person_outline,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: AppColors.primary.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: AppColors.primary.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: AppColors.primary,
                                    width: 2,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your first name';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            // Last Name
                            TextFormField(
                              controller: _lastNameController,
                              cursorColor: AppColors.primary,
                              style: AppTextStyles.nunitoRegular.copyWith(
                                color: AppColors.textDark,
                                fontSize: 16,
                              ),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppColors.primary.withOpacity(0.05),
                                labelText: "Last Name *",
                                labelStyle: AppTextStyles.nunitoMedium.copyWith(
                                  color: AppColors.primary.withOpacity(0.7),
                                ),
                                prefixIcon: Container(
                                  margin: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.person_outline,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: AppColors.primary.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: AppColors.primary.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: AppColors.primary,
                                    width: 2,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your last name';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            // Phone Number
                            TextFormField(
                              controller: _phoneController,
                              cursorColor: AppColors.primary,
                              keyboardType: TextInputType.phone,
                              maxLength: 10,
                              style: AppTextStyles.nunitoRegular.copyWith(
                                color: AppColors.textDark,
                                fontSize: 16,
                              ),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppColors.primary.withOpacity(0.05),
                                labelText: "Phone Number *",
                                labelStyle: AppTextStyles.nunitoMedium.copyWith(
                                  color: AppColors.primary.withOpacity(0.7),
                                ),
                                prefixIcon: Container(
                                  margin: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.phone_outlined,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: AppColors.primary.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: AppColors.primary.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: AppColors.primary,
                                    width: 2,
                                  ),
                                ),
                                counterText: '',
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your phone number';
                                }
                                if (value.trim().length != 10) {
                                  return 'Phone number must be 10 digits';
                                }
                                if (!RegExp(
                                  r'^[0-9]+$',
                                ).hasMatch(value.trim())) {
                                  return 'Phone number must contain only digits';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            // City (Optional)
                            TextField(
                              controller: _cityController,
                              cursorColor: AppColors.primary,
                              style: AppTextStyles.nunitoRegular.copyWith(
                                color: AppColors.textDark,
                                fontSize: 16,
                              ),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppColors.primary.withOpacity(0.05),
                                labelText: "City (Optional)",
                                labelStyle: AppTextStyles.nunitoMedium.copyWith(
                                  color: AppColors.primary.withOpacity(0.7),
                                ),
                                prefixIcon: Container(
                                  margin: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.location_city_outlined,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: AppColors.primary.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: AppColors.primary.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: AppColors.primary,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Skill (Optional)
                            TextField(
                              controller: _skillController,
                              cursorColor: AppColors.primary,
                              style: AppTextStyles.nunitoRegular.copyWith(
                                color: AppColors.textDark,
                                fontSize: 16,
                              ),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppColors.primary.withOpacity(0.05),
                                labelText: "Skill/Expertise (Optional)",
                                labelStyle: AppTextStyles.nunitoMedium.copyWith(
                                  color: AppColors.primary.withOpacity(0.7),
                                ),
                                prefixIcon: Container(
                                  margin: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.build_outlined,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: AppColors.primary.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: AppColors.primary.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: AppColors.primary,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Referral (Optional)
                            TextField(
                              controller: _referralController,
                              cursorColor: AppColors.primary,
                              style: AppTextStyles.nunitoRegular.copyWith(
                                color: AppColors.textDark,
                                fontSize: 16,
                              ),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppColors.primary.withOpacity(0.05),
                                labelText: "Referral Code (Optional)",
                                labelStyle: AppTextStyles.nunitoMedium.copyWith(
                                  color: AppColors.primary.withOpacity(0.7),
                                ),
                                prefixIcon: Container(
                                  margin: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.card_giftcard_outlined,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: AppColors.primary.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: AppColors.primary.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: AppColors.primary,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Submit Button
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.secondary.withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _isSubmitting ? null : _submitSignup,
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
                                child: _isSubmitting
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : Text(
                                        "Create Account",
                                        style: AppTextStyles.nunitoBold
                                            .copyWith(
                                              fontSize: 18,
                                              color: Colors.white,
                                            ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Already have account link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: AppTextStyles.nunitoRegular.copyWith(
                              fontSize: 14,
                              color: AppColors.textDark.withOpacity(0.7),
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.go('/login'),
                            child: Text(
                              'Login',
                              style: AppTextStyles.nunitoSemiBold.copyWith(
                                fontSize: 14,
                                color: AppColors.secondary,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
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
