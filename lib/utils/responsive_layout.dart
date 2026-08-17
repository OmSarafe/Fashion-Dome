import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Shared screen-size rules for the whole application.
abstract final class AppBreakpoints {
  static const double compact = 360;
  static const double tablet = 600;
  static const double desktop = 1024;
  static const double maxContentWidth = 1280;
}

abstract final class ResponsiveLayout {
  static bool isCompact(double width) => width < AppBreakpoints.compact;

  static bool isTablet(double width) => width >= AppBreakpoints.tablet;

  static bool isDesktop(double width) => width >= AppBreakpoints.desktop;

  static double horizontalPadding(double width) {
    if (width < AppBreakpoints.compact) return 16;
    if (width < AppBreakpoints.tablet) return 24;
    if (width < AppBreakpoints.desktop) return 32;
    return 40;
  }

  static int productGridColumns(double width) {
    if (width < 330) return 1;
    if (width < 600) return 2;
    if (width < 840) return 3;
    if (width < 1120) return 4;
    return 5;
  }

  static double productCardAspectRatio(double width) {
    if (width < 330) return 0.78;
    if (width < 600) return 0.62;
    return 0.66;
  }

  static double usableWidth(double width, {double? maxWidth}) {
    final limit = maxWidth ?? AppBreakpoints.maxContentWidth;
    return math.min(width, limit);
  }
}

/// Keeps page content readable on wide displays while preserving a bounded
/// height so descendants can safely use [Expanded].
class ResponsiveContent extends StatelessWidget {
  const ResponsiveContent({
    super.key,
    required this.child,
    this.maxWidth = AppBreakpoints.maxContentWidth,
    this.addHorizontalPadding = true,
  });

  final Widget child;
  final double maxWidth;
  final bool addHorizontalPadding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final contentWidth = ResponsiveLayout.usableWidth(
          constraints.maxWidth,
          maxWidth: maxWidth,
        );
        final padding = addHorizontalPadding
            ? ResponsiveLayout.horizontalPadding(constraints.maxWidth)
            : 0.0;

        return Center(
          child: SizedBox(
            width: contentWidth,
            height: constraints.maxHeight,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

/// A full-width bottom surface whose interactive content stays comfortably
/// sized on tablets and desktop windows.
class ResponsiveBottomBar extends StatelessWidget {
  const ResponsiveBottomBar({
    super.key,
    required this.child,
    this.maxWidth = 760,
    this.padding,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontal = ResponsiveLayout.horizontalPadding(
          constraints.maxWidth,
        );
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: padding ??
                  EdgeInsets.fromLTRB(horizontal, 12, horizontal, 16),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
