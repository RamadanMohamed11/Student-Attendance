import 'package:flutter/material.dart';

/// A utility class that provides responsive design helpers
class ResponsiveHelper {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 650;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 650 &&
      MediaQuery.of(context).size.width < 1100;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  /// Returns a value based on the current screen size
  /// [mobile] is used for small screens (< 650)
  /// [tablet] is used for medium screens (>= 650 and < 1100)
  /// [desktop] is used for large screens (>= 1100)
  static T responsive<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    required T desktop,
  }) {
    final size = MediaQuery.of(context).size;
    if (size.width >= 1100) {
      return desktop;
    } else if (size.width >= 650) {
      return tablet ?? desktop;
    } else {
      return mobile;
    }
  }

  /// Returns a widget based on the current screen size
  /// [mobile] is used for small screens (< 650)
  /// [tablet] is used for medium screens (>= 650 and < 1100)
  /// [desktop] is used for large screens (>= 1100)
  static Widget responsiveWidget({
    required BuildContext context,
    required Widget mobile,
    Widget? tablet,
    required Widget desktop,
  }) {
    final size = MediaQuery.of(context).size;
    if (size.width >= 1100) {
      return desktop;
    } else if (size.width >= 650) {
      return tablet ?? desktop;
    } else {
      return mobile;
    }
  }
}

/// A widget that adapts its layout based on screen size
class ResponsiveLayout extends StatelessWidget {
  final Widget mobileLayout;
  final Widget? tabletLayout;
  final Widget desktopLayout;

  const ResponsiveLayout({
    super.key,
    required this.mobileLayout,
    this.tabletLayout,
    required this.desktopLayout,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1100) {
          return desktopLayout;
        } else if (constraints.maxWidth >= 650) {
          return tabletLayout ?? desktopLayout;
        } else {
          return mobileLayout;
        }
      },
    );
  }
}
