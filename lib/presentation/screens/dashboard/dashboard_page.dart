import 'package:balaji_points/core/mixins/double_tap_exit_mixin.dart';
import 'package:balaji_points/core/theme/design_token.dart';
import 'package:balaji_points/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ── Layout constants ──────────────────────────────────────────────────────────
const _kBarHeight = 64.0;
const _kFabSize = 56.0;
const _kFabOverlap = 22.0; // px FAB sits above bar top edge
const _kBarTop = _kFabSize - _kFabOverlap; // 34 — bar starts here in stack
const _kStackHeight = _kBarTop + _kBarHeight; // 98

// ─────────────────────────────────────────────────────────────────────────────
class DashboardPage extends StatefulWidget {
  final Widget? child;

  const DashboardPage({super.key, this.child});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with DoubleTapExitMixin {
  // Center Add-Points tab never calls this — it pushes a route directly.
  void _onItemTapped(int index) {
    final router = GoRouter.of(context);
    switch (index) {
      case 0:
        router.go('/');
        break;
      case 1:
        router.go('/wallet');
        break;
      case 2:
        router.go('/notifications');
        break;
      case 3:
        router.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Bar background adapts to theme:
    // - Light: uses surface color from ColorScheme
    // - Dark: uses DesignToken.navyBackground for stronger contrast
    final barColor =
        theme.bottomNavigationBarTheme.backgroundColor ??
            (isDark ? DesignToken.navyBackground : DesignToken.white);

    // Softer shadow in light mode, stronger in dark mode
    final shadowColor = Colors.black.withValues(alpha: isDark ? 0.55 : 0.10);

    // Thin top border to visually separate content from the bar.
    final topBorderColor = Colors.black.withValues(
      alpha: isDark ? 0.24 : 0.06,
    );

    // Determine which tab should appear selected based on current route.
    final location = GoRouterState.of(context).uri.path;
    int currentIndex = 0;
    if (location.startsWith('/wallet')) {
      currentIndex = 1;
    } else if (location.startsWith('/notifications')) {
      currentIndex = 2;
    } else if (location.startsWith('/profile')) {
      currentIndex = 3;
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
            return;
          }
          await handleDoubleTapExit();
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Stack(
          children: [
            // Main content scrolls independently and can extend visually
            // behind the custom bottom bar.
            SafeArea(
              top: false,
              bottom: false,
              child: widget.child ?? const SizedBox.shrink(),
            ),
            // Custom bottom bar overlaid on top
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                top: false,
                bottom: true,
                child: SizedBox(
                  height: _kStackHeight,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // ── Notched dark pill bar ───────────────────────
                      Positioned(
                        left: 0,
                        right: 0,
                        top: _kBarTop,
                        bottom: 0,
                        child: CustomPaint(
                          painter: _NotchedBarPainter(
                            barColor: barColor,
                            shadowColor: shadowColor,
                            topBorderColor: topBorderColor,
                          ),
                          child: Row(
                            children: [
                              _DarkNavItem(
                                index: 0,
                                currentIndex: currentIndex,
                                icon: Icons.home_rounded,
                                label: l10n.home,
                                onTap: _onItemTapped,
                              ),
                              _DarkNavItem(
                                index: 1,
                                currentIndex: currentIndex,
                                icon: Icons.account_balance_wallet_outlined,
                                label: l10n.earn,
                                onTap: _onItemTapped,
                              ),
                              // Space for the floating FAB
                              const SizedBox(width: _kFabSize + 20),
                              _DarkNavItem(
                                index: 2,
                                currentIndex: currentIndex,
                                icon: Icons.notifications_outlined,
                                label: l10n.notifications,
                                onTap: _onItemTapped,
                              ),
                              _DarkNavItem(
                                index: 3,
                                currentIndex: currentIndex,
                                icon: Icons.person_outline,
                                label: l10n.profile,
                                onTap: _onItemTapped,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // ── Center floating Add-Points FAB ──────────────
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: _AddPointsFab(
                            onTap: () => context.push('/add-bill'),
                          ),
                        ),
                      ),
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

// ─────────────────────────────────────────────────────────────────────────────
// NOTCHED BAR PAINTER
// ─────────────────────────────────────────────────────────────────────────────
class _NotchedBarPainter extends CustomPainter {
  final Color barColor;
  final Color shadowColor;
  final Color topBorderColor;

  const _NotchedBarPainter({
    required this.barColor,
    required this.shadowColor,
    required this.topBorderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;

    const cr = 28.0; // bar corner radius (pill ends)
    const nd = 28.0; // notch depth below bar top
    const nw = 42.0; // notch half-width at bar top
    const sm = 20.0; // cubic bezier smoothing arm length

    final path =
        Path()
          // bottom-left → top-left
          ..moveTo(cr, h)
          ..lineTo(0, h)
          ..lineTo(0, cr)
          ..quadraticBezierTo(0, 0, cr, 0)
          // top-left → left edge of notch
          ..lineTo(cx - nw - sm, 0)
          // smooth left curve INTO the notch
          ..cubicTo(cx - nw, 0, cx - nw * 0.5, nd, cx, nd)
          // smooth right curve OUT of the notch
          ..cubicTo(cx + nw * 0.5, nd, cx + nw, 0, cx + nw + sm, 0)
          // right edge of notch → top-right
          ..lineTo(w - cr, 0)
          ..quadraticBezierTo(w, 0, w, cr)
          // top-right → bottom-right
          ..lineTo(w, h)
          ..close();

    // Drop-shadow
    canvas.drawShadow(path, shadowColor, 14, false);
    // Fill
    canvas.drawPath(path, Paint()..color = barColor);

    // Gradient border around the bar (matches app accent colors).
    final rect = path.getBounds();
    final gradient = LinearGradient(
      colors: DesignToken.primaryGradient,
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..shader = gradient.createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// FLOATING CENTER FAB
// ─────────────────────────────────────────────────────────────────────────────
class _AddPointsFab extends StatefulWidget {
  final VoidCallback onTap;

  const _AddPointsFab({required this.onTap});

  @override
  State<_AddPointsFab> createState() => _AddPointsFabState();
}

class _AddPointsFabState extends State<_AddPointsFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _scale;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => AnimatedScale(
          duration: const Duration(milliseconds: 100),
          scale: _pressed ? 0.90 : _scale.value,
          child: child,
        ),
        child: Container(
          width: _kFabSize,
          height: _kFabSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [DesignToken.primary, DesignToken.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: DesignToken.primary.withValues(alpha: 0.55),
                blurRadius: 18,
                spreadRadius: 2,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Glowing coin plate
              Container(
                width: _kFabSize - 10,
                height: _kFabSize - 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: <Color>[
                      DesignToken.amberShade300,
                      DesignToken.amber,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: DesignToken.amber.withValues(alpha: 0.50),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: DesignToken.white.withValues(alpha: 0.80),
                    width: 2,
                  ),
                ),
              ),
              // Main coin icon
              const Icon(
                Icons.monetization_on,
                color: DesignToken.white,
                size: 28,
              ),
              // Small + badge attached to the coin
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: DesignToken.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: DesignToken.white,
                      width: 1.5,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.add,
                      size: 11,
                      color: DesignToken.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DARK NAV ITEM (icon + animated dot, no background pill)
// ─────────────────────────────────────────────────────────────────────────────
class _DarkNavItem extends StatelessWidget {
  final int index;
  final int currentIndex;
  final IconData icon;
  final String label;
  final ValueChanged<int> onTap;

  const _DarkNavItem({
    required this.index,
    required this.currentIndex,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool sel = index == currentIndex;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;

    final Color activeColor =
        isDark ? Colors.white : colorScheme.primary;
    final Color inactiveColor =
        isDark ? Colors.white.withValues(alpha: 0.55)
            : colorScheme.onSurface.withValues(alpha: 0.55);

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          splashColor: Colors.white.withValues(alpha: 0.08),
          highlightColor: Colors.white.withValues(alpha: 0.04),
          onTap: () => onTap(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            height: _kBarHeight,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: sel
                  ? (isDark
                      ? Colors.white.withValues(alpha: 0.10)
                      : activeColor.withValues(alpha: 0.12))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon — scales up when selected
                AnimatedScale(
                  duration: const Duration(milliseconds: 220),
                  scale: sel ? 1.18 : 1.0,
                  curve: Curves.easeOutBack,
                  child: Icon(
                    icon,
                    size: 24,
                    color: sel ? activeColor : inactiveColor,
                  ),
                ),
                const SizedBox(height: 5),
                // Animated dot indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  width: sel ? 22 : 0,
                  height: sel ? 4 : 0,
                  decoration: BoxDecoration(
                    gradient: sel
                        ? const LinearGradient(
                            colors: [Color(0xFFFFFFFF), Color(0xCCFFFFFF)],
                          )
                        : null,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
