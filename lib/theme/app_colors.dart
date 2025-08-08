import 'package:flutter/material.dart';

/// Brand Colors for Jeddah Health Cluster II (تجمع جدة الصحي الثاني)
///
/// This class defines the complete color palette for the healthcare platform
/// following the official brand guidelines.
class AppColors {
  // Prevent instantiation
  AppColors._();

  // ============ PRIMARY COLORS ============
  static const Color primaryDark = Color(0xFF15508A);
  static const Color primaryMedium = Color(0xFF1691D0);
  static const Color primaryLight = Color(0xFF2CAAE2);

  // ============ NEUTRAL COLORS (Light) ============
  static const Color secondaryGray = Color(0xFFA09EA4);
  static const Color onSurface = Color(0xFF333333);
  static const Color surfaceLight = Color(0xFFF8F9FA);
  static const Color background = Color(0xFFFFFFFF);

  // ============ NEUTRAL COLORS (Dark) ============
  static const Color onSurfaceDark = Color(0xFFE5E7EB);
  static const Color onSurfaceVariantDark = Color(0xFF9CA3AF);
  static const Color surfaceDark = Color(0xFF111827);
  static const Color surfaceVariantDark = Color(0xFF1F2937);
  static const Color backgroundDark = Color(0xFF0B1220);
  static const Color outlineDark = Color(0xFF374151);

  // ============ TEXT COLORS ============
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSurfaceVariant = Color(0xFFA09EA4);

  // Text on primary/secondary in Dark Mode
  static const Color onPrimaryDark = Color(0xFFFFFFFF);
  static const Color onSecondaryDark = Color(0xFFFFFFFF);

  // ============ STATE COLORS ============
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // ============ UTILITY COLORS ============
  static const Color outline = Color(0xFFE9ECEF);
  static const Color disabled = Color(0xFFD1D5DB);
  static const Color surfaceVariant = Color(0xFFF1F3F4);

  // ============ GRADIENT COLORS ============
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDark, primaryMedium, primaryLight],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient subtleGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [background, surfaceLight],
    stops: [0.0, 1.0],
  );

  // Dark mode gradients
  static const LinearGradient primaryGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primaryMedium, primaryDark],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient subtleGradientDark = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundDark, surfaceDark],
    stops: [0.0, 1.0],
  );

  // ============ OPACITY VARIANTS ============
  static Color get primaryLightOverlay => primaryLight.withValues(alpha: 0.1);
  static Color get primaryMediumOverlay => primaryMedium.withValues(alpha: 0.1);
  static Color get primaryDarkOverlay => primaryDark.withValues(alpha: 0.1);

  static Color get shadowColor => Colors.black.withValues(alpha: 0.08);
  static Color get shadowColorDark => Colors.black.withValues(alpha: 0.6);

  // ============ SEMANTIC COLOR METHODS ============
  static Color successWithOpacity(double opacity) =>
      success.withValues(alpha: opacity);
  static Color errorWithOpacity(double opacity) =>
      error.withValues(alpha: opacity);
  static Color warningWithOpacity(double opacity) =>
      warning.withValues(alpha: opacity);
  static Color infoWithOpacity(double opacity) =>
      info.withValues(alpha: opacity);

  // ============ ACCESSIBILITY HELPERS ============
  static bool hasGoodContrast(Color foreground, Color background) {
    final luminance1 = foreground.computeLuminance();
    final luminance2 = background.computeLuminance();
    final lightest = luminance1 > luminance2 ? luminance1 : luminance2;
    final darkest = luminance1 > luminance2 ? luminance2 : luminance1;
    final contrast = (lightest + 0.05) / (darkest + 0.05);
    return contrast >= 4.5; // WCAG AA standard
  }

  // ============ COLOR PALETTE MAP ============
  static const Map<String, Color> colorPalette = {
    // Light
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
    'surface-variant': surfaceVariant,

    // Dark
    'on-surface-dark': onSurfaceDark,
    'on-surface-variant-dark': onSurfaceVariantDark,
    'surface-dark': surfaceDark,
    'surface-variant-dark': surfaceVariantDark,
    'background-dark': backgroundDark,
    'outline-dark': outlineDark,
    'on-primary-dark': onPrimaryDark,
    'on-secondary-dark': onSecondaryDark,
  };
}

/// Dark Theme Colors for Enhanced User Experience
///
/// This class defines the color palette specifically optimized for dark mode
/// with proper contrast ratios and accessibility considerations.
class DarkColors {
  // Prevent instantiation
  DarkColors._();

  // ============ PRIMARY COLORS (Adjusted for Dark) ============
  static const Color primaryDark = Color(0xFF1E3A8A); // Darker blue
  static const Color primaryMedium = Color(0xFF3B82F6); // Standard blue
  static const Color primaryLight = Color(0xFF60A5FA); // Lighter blue

  // ============ SURFACE COLORS ============
  static const Color surface = Color(0xFF1F2937); // Dark gray
  static const Color surfaceVariant = Color(0xFF374151); // Lighter dark gray
  static const Color background = Color(0xFF111827); // Very dark background
  static const Color surfaceContainer = Color(0xFF1F2937);

  // ============ TEXT COLORS ============
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFFF9FAFB); // Very light text
  static const Color onSurfaceVariant = Color(0xFFD1D5DB);
  static const Color onBackground = Color(0xFFF9FAFB);

  // ============ OUTLINE & BORDERS ============
  static const Color outline = Color(0xFF4B5563); // Medium gray outline
  static const Color outlineVariant = Color(0xFF374151);

  // ============ STATE COLORS (Dark Optimized) ============
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFF87171);
  static const Color warning = Color(0xFFFBBF24);
  static const Color info = Color(0xFF60A5FA);

  // ============ GRADIENTS FOR DARK MODE ============
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primaryMedium, primaryDark],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [surface, background],
    stops: [0.0, 1.0],
  );

  static const LinearGradient subtleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1F2937),
      Color(0xFF111827),
    ],
    stops: [0.0, 1.0],
  );

  // ============ SHADOW COLORS ============
  static Color get shadowColor => Colors.black.withValues(alpha: 0.7);
  static Color get elevationShadow => Colors.black.withValues(alpha: 0.4);

  // ============ UTILITY METHODS ============
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }

  // ============ GRADIENT HELPERS ============
  static LinearGradient createCustomGradient({
    required List<Color> colors,
    Alignment begin = Alignment.topLeft,
    Alignment end = Alignment.bottomRight,
    List<double>? stops,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: colors,
      stops: stops,
    );
  }
}

/// Theme-aware Gradients Manager
///
/// Provides context-aware gradients that automatically adapt based on
/// current theme mode (light/dark). Essential for consistent UI appearance.
class ThemeGradients {
  // Prevent instantiation
  ThemeGradients._();

  /// Get primary gradient based on current theme
  static LinearGradient getPrimaryGradient(bool isDarkMode) {
    return isDarkMode ? DarkColors.primaryGradient : AppColors.primaryGradient;
  }

  /// Get subtle background gradient based on current theme
  static LinearGradient getSubtleGradient(bool isDarkMode) {
    return isDarkMode ? DarkColors.subtleGradient : AppColors.subtleGradient;
  }

  /// Get surface gradient for cards and containers
  static LinearGradient getSurfaceGradient(bool isDarkMode) {
    return isDarkMode ? DarkColors.surfaceGradient : AppColors.subtleGradient;
  }

  /// Get header gradient for app bars and headers
  static LinearGradient getHeaderGradient(bool isDarkMode) {
    if (isDarkMode) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          DarkColors.surface,
          DarkColors.surfaceVariant,
          DarkColors.background,
        ],
        stops: [0.0, 0.6, 1.0],
      );
    } else {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.primaryDark,
          AppColors.primaryMedium,
          AppColors.primaryLight,
        ],
        stops: [0.0, 0.6, 1.0],
      );
    }
  }

  /// Get card elevation gradient
  static LinearGradient getCardGradient(bool isDarkMode) {
    if (isDarkMode) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          DarkColors.surface,
          DarkColors.surfaceVariant.withValues(alpha: 0.8),
        ],
        stops: const [0.0, 1.0],
      );
    } else {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white,
          AppColors.surfaceLight.withValues(alpha: 0.8),
        ],
        stops: const [0.0, 1.0],
      );
    }
  }

  /// Create a custom themed gradient
  static LinearGradient createThemedGradient({
    required bool isDarkMode,
    required List<Color> lightColors,
    required List<Color> darkColors,
    Alignment begin = Alignment.topLeft,
    Alignment end = Alignment.bottomRight,
    List<double>? stops,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: isDarkMode ? darkColors : lightColors,
      stops: stops,
    );
  }
}
