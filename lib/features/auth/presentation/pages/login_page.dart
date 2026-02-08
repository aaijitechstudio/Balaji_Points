import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:balaji_points/core/theme/design_token.dart';
import 'package:balaji_points/config/theme.dart' hide AppColors;
import 'package:balaji_points/l10n/app_localizations.dart';
import 'package:balaji_points/core/utils/back_button_handler.dart';
import 'package:balaji_points/core/utils/app_logger.dart';
import 'package:balaji_points/core/providers/locale_provider.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
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

  void _checkUserAndNavigate() {
    if (!_formKey.currentState!.validate()) return;

    final phone = _phoneController.text.trim();

    if (phone.isEmpty) {
      return;
    }

    context.read<AuthBloc>().add(CheckUserExistsEvent(phone));
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
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is UserExistsState) {
            AppLogger.info(
              'User exists, navigating to PIN login',
              data: state.phoneNumber,
            );
            context.push('/pin-login?phone=${state.phoneNumber}');
          } else if (state is UserDoesNotExistState) {
            AppLogger.info(
              'New user, navigating to PIN setup',
              data: state.phoneNumber,
            );
            context.push('/pin-setup?phone=${state.phoneNumber}');
          } else if (state is AuthErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${l10n.error}: ${state.message}'),
                backgroundColor: DesignToken.error,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        builder: (context, state) {
          final isChecking = state is CheckingUserState;

          return Scaffold(
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
                        padding: EdgeInsets.only(
                          bottom: bottomInset + DesignToken.spacingXL,
                        ),
                        child: Padding(
                          padding: DesignToken.paddingHorizontal2XL,
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                SizedBox(height: DesignToken.heightXL),

                                // Language switcher
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Consumer(
                                    builder: (context, ref, child) {
                                      return Container(
                                        padding:
                                            DesignToken.paddingHorizontalMD,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: DesignToken.white,
                                          borderRadius:
                                              DesignToken.borderRadiusMD,
                                          border: Border.all(
                                            color: DesignToken.primary
                                                .withOpacity(0.3),
                                          ),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<Locale>(
                                            value: ref.watch(localeProvider),
                                            onChanged: (Locale? newLocale) {
                                              if (newLocale != null) {
                                                ref
                                                    .read(
                                                      localeProvider.notifier,
                                                    )
                                                    .setLocale(newLocale);
                                              }
                                            },
                                            items: [
                                              DropdownMenuItem(
                                                value: const Locale('en'),
                                                child: Text(
                                                  l10n.languageEnglish,
                                                ),
                                              ),
                                              DropdownMenuItem(
                                                value: const Locale('hi'),
                                                child: Text(l10n.languageHindi),
                                              ),
                                              DropdownMenuItem(
                                                value: const Locale('ta'),
                                                child: Text(l10n.languageTamil),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                SizedBox(height: DesignToken.heightXL),

                                // Logo + name
                                ClipRRect(
                                  borderRadius: DesignToken.borderRadiusSM,
                                  child: Image.asset(
                                    'assets/images/balaji_point_logo.png',
                                    width: 100,
                                    height: 100,
                                  ),
                                ),
                                SizedBox(height: DesignToken.heightLG),
                                Text(
                                  "Balaji Points",
                                  style: AppTextStyles.nunitoBold.copyWith(
                                    fontSize: DesignToken.fontSize5XL,
                                    color: DesignToken.primary,
                                  ),
                                ),

                                SizedBox(height: DesignToken.height2XL),

                                Text(
                                  l10n.enterPhoneNumber,
                                  style: AppTextStyles.nunitoRegular.copyWith(
                                    fontSize: DesignToken.fontSizeLG,
                                    color: DesignToken.textDark.withOpacity(
                                      0.9,
                                    ),
                                  ),
                                ),

                                SizedBox(height: DesignToken.height3XL),

                                // Glass Card with phone + button
                                ClipRRect(
                                  borderRadius: DesignToken.borderRadius2XL,
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 10,
                                      sigmaY: 10,
                                    ),
                                    child: Container(
                                      padding: EdgeInsets.all(
                                        DesignToken.padding3XL,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            DesignToken.white.withOpacity(0.9),
                                            DesignToken.white.withOpacity(0.7),
                                          ],
                                        ),
                                        borderRadius:
                                            DesignToken.borderRadius2XL,
                                        border: Border.all(
                                          color: DesignToken.white.withOpacity(
                                            0.5,
                                          ),
                                          width: 1.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: DesignToken.primary
                                                .withOpacity(0.1),
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
                                                  fontSize:
                                                      DesignToken.fontSizeXL,
                                                  color: DesignToken.textDark,
                                                ),
                                            decoration: InputDecoration(
                                              labelText: l10n.mobileNumber,
                                              labelStyle: AppTextStyles
                                                  .nunitoMedium
                                                  .copyWith(
                                                    fontSize:
                                                        DesignToken.fontSizeLG,
                                                  ),
                                              prefixText: "+91 ",
                                              prefixStyle: AppTextStyles
                                                  .nunitoSemiBold
                                                  .copyWith(
                                                    fontSize:
                                                        DesignToken.fontSizeXL,
                                                    color: DesignToken.primary,
                                                  ),
                                              counterText: "",
                                              filled: true,
                                              fillColor: DesignToken.primary
                                                  .withOpacity(0.05),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    DesignToken.borderRadiusLG,
                                                borderSide: BorderSide(
                                                  color: DesignToken.primary
                                                      .withOpacity(0.3),
                                                  width: 1.5,
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    DesignToken.borderRadiusLG,
                                                borderSide: BorderSide(
                                                  color: DesignToken.primary
                                                      .withOpacity(0.2),
                                                  width: 1.5,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    DesignToken.borderRadiusLG,
                                                borderSide: const BorderSide(
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

                                          SizedBox(
                                            height: DesignToken.height2XL,
                                          ),

                                          // Gradient Button
                                          Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  DesignToken.secondary,
                                                  DesignToken.secondary
                                                      .withOpacity(0.8),
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius:
                                                  DesignToken.borderRadiusLG,
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
                                              onPressed: isChecking
                                                  ? null
                                                  : _checkUserAndNavigate,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    DesignToken.transparent,
                                                shadowColor:
                                                    DesignToken.transparent,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 18,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: DesignToken
                                                      .borderRadiusLG,
                                                ),
                                              ),
                                              child: isChecking
                                                  ? const SizedBox(
                                                      width: 24,
                                                      height: 24,
                                                      child:
                                                          CircularProgressIndicator(
                                                            color: DesignToken
                                                                .white,
                                                            strokeWidth: 2.5,
                                                          ),
                                                    )
                                                  : Text(
                                                      l10n.continueWithPin,
                                                      style: AppTextStyles
                                                          .nunitoBold
                                                          .copyWith(
                                                            fontSize:
                                                                DesignToken
                                                                    .fontSizeXL,
                                                            color: DesignToken
                                                                .white,
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

                                SizedBox(height: DesignToken.height2XL),
                                Text(
                                  "${l10n.poweredBy} ${l10n.companyName}",
                                  style: DesignToken.labelMedium.copyWith(
                                    color: DesignToken.secondary,
                                  ),
                                ),
                                SizedBox(height: DesignToken.height3XL),
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
