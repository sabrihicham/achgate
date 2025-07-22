import 'package:flutter/material.dart';

/// Brand Colors for Jeddah Health Cluster II (تجمع جدة الصحي الثاني)
/// 
/// This class defines the complete color palette for the healthcare platform
/// following the official brand guidelines.
class AppColors {
  // Prevent instantiation
  AppColors._();

  // ============ PRIMARY COLORS ============
  /// Primary dark blue - Main brand color
  /// Used for: Primary buttons, headers, main navigation
  static const Color primaryDark = Color(0xFF15508A);

  /// Primary medium blue - Interactive elements
  /// Used for: Links, focus states, secondary buttons
  static const Color primaryMedium = Color(0xFF1691D0);

  /// Primary light blue - Decorative elements
  /// Used for: Backgrounds, decorative patterns, subtle accents
  static const Color primaryLight = Color(0xFF2CAAE2);

  // ============ NEUTRAL COLORS ============
  /// Secondary gray - Supporting text and borders
  /// Used for: Secondary text, default borders, placeholders
  static const Color secondaryGray = Color(0xFFA09EA4);

  /// Dark text color - Primary content
  /// Used for: Main text content, headings
  static const Color onSurface = Color(0xFF333333);

  /// Light surface color - Form backgrounds
  /// Used for: Input fields, card backgrounds
  static const Color surfaceLight = Color(0xFFF8F9FA);

  /// Pure background - Main backgrounds
  /// Used for: Page backgrounds, modal backgrounds
  static const Color background = Color(0xFFFFFFFF);

  // ============ TEXT COLORS ============
  /// Text on primary colored backgrounds
  static const Color onPrimary = Color(0xFFFFFFFF);

  /// Text on secondary colored backgrounds  
  static const Color onSecondary = Color(0xFFFFFFFF);

  /// Variant text color for less emphasis
  static const Color onSurfaceVariant = Color(0xFFA09EA4);

  // ============ STATE COLORS ============
  /// Success color - Compatible with brand palette
  static const Color success = Color(0xFF10B981);

  /// Error color - Attention and warnings
  static const Color error = Color(0xFFEF4444);

  /// Warning color - Cautions and alerts
  static const Color warning = Color(0xFFF59E0B);

  /// Info color - Information and tips
  static const Color info = Color(0xFF3B82F6);

  // ============ UTILITY COLORS ============
  /// Border and divider color
  static const Color outline = Color(0xFFE9ECEF);

  /// Disabled state color
  static const Color disabled = Color(0xFFD1D5DB);

  /// Surface variant for cards and containers
  static const Color surfaceVariant = Color(0xFFF1F3F4);

  // ============ GRADIENT COLORS ============
  /// Brand gradient - Primary to secondary
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDark, primaryMedium, primaryLight],
    stops: [0.0, 0.5, 1.0],
  );

  /// Subtle gradient for backgrounds
  static const LinearGradient subtleGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [background, surfaceLight],
    stops: [0.0, 1.0],
  );

  // ============ OPACITY VARIANTS ============
  /// Light overlay for decorative elements
  static Color get primaryLightOverlay => primaryLight.withOpacity(0.1);

  /// Medium overlay for hover states
  static Color get primaryMediumOverlay => primaryMedium.withOpacity(0.1);

  /// Dark overlay for pressed states
  static Color get primaryDarkOverlay => primaryDark.withOpacity(0.1);

  /// Shadow color for elevated elements
  static Color get shadowColor => Colors.black.withOpacity(0.08);

  // ============ SEMANTIC COLOR METHODS ============
  /// Get success color with opacity
  static Color successWithOpacity(double opacity) => success.withOpacity(opacity);

  /// Get error color with opacity
  static Color errorWithOpacity(double opacity) => error.withOpacity(opacity);

  /// Get warning color with opacity
  static Color warningWithOpacity(double opacity) => warning.withOpacity(opacity);

  /// Get info color with opacity
  static Color infoWithOpacity(double opacity) => info.withOpacity(opacity);

  // ============ ACCESSIBILITY HELPERS ============
  /// Check if a color provides sufficient contrast for accessibility
  static bool hasGoodContrast(Color foreground, Color background) {
    final luminance1 = foreground.computeLuminance();
    final luminance2 = background.computeLuminance();
    final lightest = luminance1 > luminance2 ? luminance1 : luminance2;
    final darkest = luminance1 > luminance2 ? luminance2 : luminance1;
    final contrast = (lightest + 0.05) / (darkest + 0.05);
    return contrast >= 4.5; // WCAG AA standard
  }

  // ============ COLOR PALETTE MAP ============
  /// Complete color palette for design systems
  static const Map<String, Color> colorPalette = {
    'primary-dark': primaryDark,
    'primary-medium': primaryMedium,
    'primary-light': primaryLight,
    'secondary-gray': secondaryGray,
    'on-surface': onSurface,
    'surface-light': surfaceLight,
    'background': background,
    'on-primary': onPrimary,
    'on-secondary': onSecondary,
    'success': success,
    'error': error,
    'warning': warning,
    'info': info,
    'outline': outline,
    'disabled': disabled,
  };
}
