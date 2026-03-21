import 'package:flutter/material.dart';

/// Bottom chrome for the carpenter [DashboardPage]: notched bar + FAB stack.
/// Keep scroll/padding math in sync with [DashboardPage] `_kStackHeight` (98).
class CarpenterShellLayout {
  CarpenterShellLayout._();

  /// Height of the custom bottom bar + FAB overlap (matches dashboard stack).
  static const double barStackHeight = 98.0;

  /// Extra margin above the bar for comfortable scroll end.
  static const double scrollEndMargin = 24.0;

  /// Use as `SingleChildScrollView` / `ListView` bottom padding inside the shell.
  static double bottomPaddingForScrollView(MediaQueryData mq) =>
      scrollEndMargin + barStackHeight + mq.padding.bottom;

  static EdgeInsets scrollViewPadding(MediaQueryData mq) => EdgeInsets.only(
        bottom: bottomPaddingForScrollView(mq),
      );
}
