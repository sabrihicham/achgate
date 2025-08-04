import 'package:flutter/material.dart';

/// Helper class for responsive design
class ResponsiveHelper {
  // Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1200;

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < desktopBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }

  static double getContentWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (isDesktop(context)) {
      return screenWidth * 0.8; // 80% on desktop
    } else if (isTablet(context)) {
      return screenWidth * 0.9; // 90% on tablet
    } else {
      return screenWidth * 0.95; // 95% on mobile
    }
  }

  static EdgeInsets getScreenPadding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.all(32);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24);
    } else {
      return const EdgeInsets.all(16);
    }
  }

  static double getCardBorderRadius(BuildContext context) {
    if (isDesktop(context)) {
      return 20;
    } else if (isTablet(context)) {
      return 16;
    } else {
      return 12;
    }
  }

  static int getGridColumns(BuildContext context) {
    if (isDesktop(context)) {
      return 3;
    } else if (isTablet(context)) {
      return 2;
    } else {
      return 1;
    }
  }
}

/// Extension for easier responsive design
extension ResponsiveExtension on BuildContext {
  bool get isMobile => ResponsiveHelper.isMobile(this);
  bool get isTablet => ResponsiveHelper.isTablet(this);
  bool get isDesktop => ResponsiveHelper.isDesktop(this);

  double get contentWidth => ResponsiveHelper.getContentWidth(this);
  EdgeInsets get screenPadding => ResponsiveHelper.getScreenPadding(this);
  double get cardBorderRadius => ResponsiveHelper.getCardBorderRadius(this);
  int get gridColumns => ResponsiveHelper.getGridColumns(this);
}
