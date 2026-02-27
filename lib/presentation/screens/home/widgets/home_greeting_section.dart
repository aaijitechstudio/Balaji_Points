import 'package:flutter/material.dart';
import 'package:balaji_points/core/theme/design_token.dart';
import 'package:balaji_points/config/theme.dart' as LegacyTheme;

class HomeGreetingSection extends StatefulWidget {
  final String userName;

  const HomeGreetingSection({
    super.key,
    required this.userName,
  });

  @override
  State<HomeGreetingSection> createState() => _HomeGreetingSectionState();
}

class _HomeGreetingSectionState extends State<HomeGreetingSection> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hour = now.hour;
    final isDayTime = hour >= 6 && hour < 18;

    final greeting = hour < 12
        ? 'Good Morning'
        : (hour < 17 ? 'Good Afternoon' : 'Good Evening');

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignToken.paddingLG,
      ),
      child: Container(
        padding: const EdgeInsets.all(DesignToken.paddingLG),
        decoration: BoxDecoration(
          borderRadius: DesignToken.borderRadiusXL,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              DesignToken.primary.withValues(alpha: 0.08),
              DesignToken.secondary.withValues(alpha: 0.10),
            ],
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$greeting,',
                    style: LegacyTheme.AppTextStyles.nunitoRegular.copyWith(
                      fontSize: DesignToken.fontSizeLG,
                      color: DesignToken.textDark.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: DesignToken.heightSM),
                  Text(
                    widget.userName,
                    style: LegacyTheme.AppTextStyles.nunitoBold.copyWith(
                      fontSize: DesignToken.fontSize2XL,
                      color: DesignToken.textDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: DesignToken.widthLG),
            _SunMoonBadge(
              isDayTime: isDayTime,
              pressed: _pressed,
              onPressedChanged: (pressed) {
                setState(() {
                  _pressed = pressed;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SunMoonBadge extends StatelessWidget {
  final bool isDayTime;
  final bool pressed;
  final ValueChanged<bool> onPressedChanged;

  const _SunMoonBadge({
    required this.isDayTime,
    required this.pressed,
    required this.onPressedChanged,
  });

  @override
  Widget build(BuildContext context) {
    final icon = isDayTime ? Icons.wb_sunny_outlined : Icons.nightlight_round;

    return GestureDetector(
      onTapDown: (_) => onPressedChanged(true),
      onTapUp: (_) => onPressedChanged(false),
      onTapCancel: () => onPressedChanged(false),
      child: AnimatedScale(
        duration: DesignToken.animationDurationFast,
        scale: pressed ? 0.9 : 1.0,
        child: Container(
          padding: const EdgeInsets.all(DesignToken.paddingSM),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDayTime
                  ? [
                      DesignToken.amberShade300,
                      DesignToken.amberShade500,
                    ]
                  : [
                      DesignToken.blueShade600,
                      DesignToken.purpleShade600,
                    ],
            ),
            boxShadow: [
              BoxShadow(
                color: DesignToken.black.withValues(alpha: 0.15),
                blurRadius: DesignToken.elevationLG,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: DesignToken.white,
            size: DesignToken.iconSizeXL,
          ),
        ),
      ),
    );
  }
}

