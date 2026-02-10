// lib/features/home/presentation/widgets/hero_section/points_display.dart
// Prominent points display with tier badge and animation

import 'package:flutter/material.dart';
import 'package:balaji_points/core/theme/design_token.dart';
import 'package:balaji_points/core/theme/design_token_extensions.dart';

class PointsDisplay extends StatefulWidget {
  final int points;
  final String tier;
  final bool animate;

  const PointsDisplay({
    super.key,
    required this.points,
    required this.tier,
    this.animate = true,
  });

  @override
  State<PointsDisplay> createState() => _PointsDisplayState();
}

class _PointsDisplayState extends State<PointsDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  int _displayedPoints = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    if (widget.animate) {
      _controller.forward();
      _animatePoints();
    } else {
      _displayedPoints = widget.points;
    }
  }

  @override
  void didUpdateWidget(PointsDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.points != widget.points) {
      _animatePoints();
      _controller.forward(from: 0.0);
    }
  }

  void _animatePoints() {
    final duration = Duration(milliseconds: widget.animate ? 800 : 0);
    final steps = 30;
    final increment = (widget.points - _displayedPoints) / steps;

    int currentStep = 0;
    Future.doWhile(() async {
      await Future.delayed(Duration(milliseconds: duration.inMilliseconds ~/ steps));
      if (!mounted) return false;

      currentStep++;
      setState(() {
        if (currentStep >= steps) {
          _displayedPoints = widget.points;
        } else {
          _displayedPoints += increment.round();
        }
      });

      return currentStep < steps;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getTierColor() {
    return DesignToken.getTierColor(widget.tier);
  }

  String _getTierEmoji() {
    switch (widget.tier.toLowerCase()) {
      case 'bronze':
        return '🥉';
      case 'silver':
        return '🥈';
      case 'gold':
        return '🥇';
      case 'platinum':
        return '💎';
      default:
        return '⭐';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: context.spacing.paddingXL,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              DesignToken.primary,
              DesignToken.primary.withOpacity(0.8),
            ],
          ),
          borderRadius: context.radius.borderMD,
          boxShadow: [
            BoxShadow(
              color: DesignToken.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Trophy icon and points
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  '🏆',
                  style: TextStyle(fontSize: 32),
                ),
                SizedBox(width: context.spacing.md),
                Text(
                  _displayedPoints.toString(),
                  style: context.text.heading1.copyWith(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1,
                  ),
                ),
                SizedBox(width: context.spacing.sm),
                Text(
                  'Points',
                  style: context.text.bodyLarge.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            SizedBox(height: context.spacing.md),

            // Tier badge
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.spacing.lg,
                vertical: context.spacing.sm,
              ),
              decoration: BoxDecoration(
                color: _getTierColor().withOpacity(0.2),
                borderRadius: context.radius.borderSM,
                border: Border.all(
                  color: _getTierColor(),
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getTierEmoji(),
                    style: const TextStyle(fontSize: 18),
                  ),
                  SizedBox(width: context.spacing.sm),
                  Text(
                    '${widget.tier} Tier',
                    style: context.text.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
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
