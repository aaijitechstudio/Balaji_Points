import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:balaji_points/config/theme.dart';
import '../../../services/phone_auth_service.dart';
import '../../../services/user_service.dart';
import '../../../core/logger.dart';

class PhoneLoginPage extends ConsumerStatefulWidget {
  const PhoneLoginPage({super.key});

  @override
  ConsumerState<PhoneLoginPage> createState() => _PhoneLoginPageState();
}

class _PhoneLoginPageState extends ConsumerState<PhoneLoginPage>
    with TickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _otpSent = false;
  String? _verificationId;

  late AnimationController _animationController;
  late List<FloatingElement> _floatingElements;

  final PhoneAuthService _phoneAuthService = PhoneAuthService();
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    // Create floating elements for background animation
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
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOTP() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final phoneNumber = _phoneController.text.trim();

    // Check if running on iOS simulator - Phone Auth doesn't work on simulator
    // Note: This is a best-effort detection. The try-catch below will also catch any crashes.
    if (Platform.isIOS && !kIsWeb && kDebugMode) {
      // In debug mode on iOS, be cautious - show a warning but still try
      // The try-catch will handle any actual crashes
      AppLogger.info(
        'Running on iOS - attempting phone auth (may fail on simulator)',
      );
    }

    // Do not read Firestore before authentication; send OTP first.
    try {
      final success = await _phoneAuthService.sendOTP(
        phoneNumber: phoneNumber,
        onCodeSent: (verificationId) {
          setState(() {
            _otpSent = true;
            _verificationId = verificationId;
            _isLoading = false;
          });
          AppLogger.info('OTP sent successfully');
        },
        onError: (error) {
          setState(() {
            _isLoading = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(error), backgroundColor: Colors.red),
            );
          }
        },
      );

      if (!success && mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      // Catch any unexpected crashes (especially on simulator)
      AppLogger.error('Phone auth error', e, stackTrace);
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Platform.isIOS
                  ? 'Phone authentication requires a real iOS device. Simulator is not supported.'
                  : 'Error: ${e.toString()}',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    if (_otpSent && _verificationId != null) {
      // Navigate to OTP verification page
      return OTPVerificationPage(
        phoneNumber: _phoneController.text.trim(),
        verificationId: _verificationId!,
        phoneAuthService: _phoneAuthService,
        userService: _userService,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.woodenBackground,
      body: Column(
        children: [
          SafeArea(bottom: false, child: Container()),
          Expanded(
            child: Container(
              color: AppColors.woodenBackground,
              child: Stack(
                children: [
                  // Animated Background
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
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            const SizedBox(height: 40),

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
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
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
                                Text(
                                  'Balaji Points',
                                  style: AppTextStyles.nunitoBold.copyWith(
                                    fontSize: 30,
                                    color: AppColors.primary,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Login with Phone Number',
                                  style: AppTextStyles.nunitoSemiBold.copyWith(
                                    fontSize: 20,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Enter your registered phone number',
                                  style: AppTextStyles.nunitoRegular.copyWith(
                                    fontSize: 14,
                                    color: AppColors.textDark.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 40),

                            // Phone Input Card
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
                                  // Phone Number Field
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
                                      fillColor: AppColors.primary.withOpacity(
                                        0.05,
                                      ),
                                      labelText: "Phone Number",
                                      labelStyle: AppTextStyles.nunitoMedium
                                          .copyWith(
                                            color: AppColors.primary
                                                .withOpacity(0.7),
                                          ),
                                      hintText: "Enter 10 digit phone number",
                                      hintStyle: AppTextStyles.nunitoRegular
                                          .copyWith(color: Colors.grey[400]),
                                      prefixIcon: Container(
                                        margin: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withOpacity(
                                            0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const SizedBox(width: 8),
                                            Text(
                                              '+91',
                                              style: AppTextStyles.nunitoBold
                                                  .copyWith(
                                                    color: AppColors.primary,
                                                    fontSize: 16,
                                                  ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              width: 1,
                                              height: 20,
                                              color: AppColors.primary
                                                  .withOpacity(0.3),
                                            ),
                                            const SizedBox(width: 8),
                                          ],
                                        ),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                          color: AppColors.primary.withOpacity(
                                            0.2,
                                          ),
                                          width: 1,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                          color: AppColors.primary.withOpacity(
                                            0.2,
                                          ),
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
                                      if (value == null ||
                                          value.trim().isEmpty) {
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

                                  const SizedBox(height: 24),

                                  // Send OTP Button
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.secondary
                                              .withOpacity(0.3),
                                          blurRadius: 15,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : _sendOTP,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.secondary,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 18,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: _isLoading
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Colors.white),
                                              ),
                                            )
                                          : Text(
                                              "Send OTP",
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

                            const SizedBox(height: 20),
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
  }
}

// OTP Verification Page
class OTPVerificationPage extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;
  final PhoneAuthService phoneAuthService;
  final UserService userService;

  const OTPVerificationPage({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
    required this.phoneAuthService,
    required this.userService,
  });

  @override
  State<OTPVerificationPage> createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  final _otpController = TextEditingController();
  bool _isVerifying = false;
  bool _isResending = false;
  int _resendTimer = 60;
  bool _canResend = false;
  bool _autoHandled = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    // If auto-verification already signed the user in, handle immediately
    Future.microtask(() async {
      if (!mounted || _autoHandled) return;
      final current = widget.phoneAuthService.getCurrentUser();
      if (current != null) {
        _autoHandled = true;
        setState(() {
          _isVerifying = true;
        });
        await widget.userService.updateUserAfterVerification(
          uid: current.uid,
          phone: widget.phoneNumber,
        );
        final userData = await widget.userService.getCurrentUserData();
        final role = (userData?['role'] as String?)?.toLowerCase();
        if (!mounted) return;
        if (role == 'admin') {
          context.go('/admin');
        } else {
          context.go('/');
        }
      }
    });
  }

  void _startResendTimer() {
    _canResend = false;
    _resendTimer = 60;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _resendTimer--;
          if (_resendTimer <= 0) {
            _canResend = true;
          }
        });
        return _resendTimer > 0;
      }
      return false;
    });
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.trim().length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 6-digit OTP'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    final userCredential = await widget.phoneAuthService.verifyOTP(
      otpCode: _otpController.text.trim(),
      onError: (error) {
        setState(() {
          _isVerifying = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), backgroundColor: Colors.red),
          );
        }
      },
    );

    final user = userCredential?.user;
    if (user == null) {
      setState(() {
        _isVerifying = false;
      });
      return;
    }

    // Update user after verification - this will check for existing admin or create new user
    await widget.userService.updateUserAfterVerification(
      uid: user.uid,
      phone: widget.phoneNumber,
    );

    final userData = await widget.userService.getCurrentUserData();
    final role = (userData?['role'] as String?)?.toLowerCase();

    setState(() {
      _isVerifying = false;
    });

    if (!mounted) return;

    if (role == 'admin') {
      context.go('/admin');
    } else {
      context.go('/');
    }
  }

  Future<void> _resendOTP() async {
    setState(() {
      _isResending = true;
    });

    await widget.phoneAuthService.resendOTP(
      phoneNumber: widget.phoneNumber,
      onCodeSent: (verificationId) {
        setState(() {
          _isResending = false;
        });
        _startResendTimer();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP resent successfully'),
            backgroundColor: Colors.green,
          ),
        );
      },
      onError: (error) {
        setState(() {
          _isResending = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), backgroundColor: Colors.red),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.woodenBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Back Button
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  color: AppColors.primary,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),

              const SizedBox(height: 40),

              // Logo
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

              const SizedBox(height: 24),

              Text(
                'Verify OTP',
                style: AppTextStyles.nunitoBold.copyWith(
                  fontSize: 26,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Enter the 6-digit code sent to',
                style: AppTextStyles.nunitoRegular.copyWith(
                  fontSize: 14,
                  color: AppColors.textDark.withOpacity(0.7),
                ),
              ),

              const SizedBox(height: 4),

              Text(
                '+91 ${widget.phoneNumber}',
                style: AppTextStyles.nunitoSemiBold.copyWith(
                  fontSize: 16,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 40),

              // OTP Input Card
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
                    TextFormField(
                      controller: _otpController,
                      cursorColor: AppColors.primary,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.nunitoBold.copyWith(
                        color: AppColors.textDark,
                        fontSize: 24,
                        letterSpacing: 8,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.primary.withOpacity(0.05),
                        hintText: "000000",
                        hintStyle: AppTextStyles.nunitoBold.copyWith(
                          color: Colors.grey[400],
                          fontSize: 24,
                          letterSpacing: 8,
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
                    ),

                    const SizedBox(height: 24),

                    // Verify Button
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
                        onPressed: _isVerifying ? null : _verifyOTP,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: _isVerifying
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                "Verify OTP",
                                style: AppTextStyles.nunitoBold.copyWith(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Resend OTP
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Didn\'t receive OTP? ',
                          style: AppTextStyles.nunitoRegular.copyWith(
                            fontSize: 14,
                            color: AppColors.textDark.withOpacity(0.7),
                          ),
                        ),
                        if (_canResend && !_isResending)
                          TextButton(
                            onPressed: _resendOTP,
                            child: Text(
                              'Resend',
                              style: AppTextStyles.nunitoSemiBold.copyWith(
                                fontSize: 14,
                                color: AppColors.secondary,
                              ),
                            ),
                          )
                        else
                          Text(
                            'Resend in ${_resendTimer}s',
                            style: AppTextStyles.nunitoSemiBold.copyWith(
                              fontSize: 14,
                              color: AppColors.textDark.withOpacity(0.5),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Reuse animation classes from login_page.dart
enum FloatingType { coin, star, sparkle, points }

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
