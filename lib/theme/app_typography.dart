import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography system for Jeddah Health Cluster II (تجمع جدة الصحي الثاني)
/// 
/// This class defines the complete typography scale optimized for Arabic and English text,
/// following Material Design 3 guidelines with healthcare-specific adaptations.
class AppTypography {
  // Prevent instantiation
  AppTypography._();

  // ============ FONT FAMILIES ============
  /// Primary font family - Cairo font optimized for Arabic and English text
  static const String primaryFontFamily = 'Cairo';
  
  /// Arabic font family - Cairo is excellent for Arabic rendering
  static const String arabicFontFamily = 'Cairo';

  // ============ FONT WEIGHTS ============
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  // ============ TEXT THEME GENERATOR ============
  /// Generate text theme with Cairo font
  static TextTheme get textTheme => GoogleFonts.cairoTextTheme(_baseTextTheme);

  // ============ BASE TEXT THEME ============
  static const TextTheme _baseTextTheme = TextTheme(
    // ========== DISPLAY STYLES ==========
    displayLarge: TextStyle(
      fontSize: 57,
      fontWeight: bold,
      letterSpacing: -0.25,
      color: AppColors.primaryDark,
      height: 1.12,
    ),
    displayMedium: TextStyle(
      fontSize: 45,
      fontWeight: bold,
      letterSpacing: 0,
      color: AppColors.primaryDark,
      height: 1.16,
    ),
    displaySmall: TextStyle(
      fontSize: 36,
      fontWeight: bold,
      letterSpacing: 0,
      color: AppColors.primaryDark,
      height: 1.22,
    ),

    // ========== HEADLINE STYLES ==========
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: bold,
      letterSpacing: 0,
      color: AppColors.primaryDark,
      height: 1.25,
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: semiBold,
      letterSpacing: 0,
      color: AppColors.primaryDark,
      height: 1.29,
    ),
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: semiBold,
      letterSpacing: 0,
      color: AppColors.primaryDark,
      height: 1.33,
    ),

    // ========== TITLE STYLES ==========
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: medium,
      letterSpacing: 0,
      color: AppColors.onSurface,
      height: 1.27,
    ),
    titleMedium: TextStyle(
      fontSize: 18,
      fontWeight: medium,
      letterSpacing: 0.15,
      color: AppColors.onSurface,
      height: 1.33,
    ),
    titleSmall: TextStyle(
      fontSize: 16,
      fontWeight: medium,
      letterSpacing: 0.1,
      color: AppColors.onSurface,
      height: 1.38,
    ),

    // ========== BODY STYLES ==========
    bodyLarge: TextStyle(
      fontSize: 18,
      fontWeight: regular,
      letterSpacing: 0.5,
      color: AppColors.onSurface,
      height: 1.44,
    ),
    bodyMedium: TextStyle(
      fontSize: 16,
      fontWeight: regular,
      letterSpacing: 0.25,
      color: AppColors.onSurface,
      height: 1.5,
    ),
    bodySmall: TextStyle(
      fontSize: 14,
      fontWeight: regular,
      letterSpacing: 0.4,
      color: AppColors.secondaryGray,
      height: 1.43,
    ),

    // ========== LABEL STYLES ==========
    labelLarge: TextStyle(
      fontSize: 16,
      fontWeight: medium,
      letterSpacing: 0.1,
      color: AppColors.onSurface,
      height: 1.25,
    ),
    labelMedium: TextStyle(
      fontSize: 14,
      fontWeight: medium,
      letterSpacing: 0.5,
      color: AppColors.onSurface,
      height: 1.14,
    ),
    labelSmall: TextStyle(
      fontSize: 12,
      fontWeight: medium,
      letterSpacing: 0.5,
      color: AppColors.secondaryGray,
      height: 1.17,
    ),
  );

  // ============ CUSTOM STYLES ============
  
  /// Button text style
  static TextStyle get button => GoogleFonts.cairo(
    fontSize: 16,
    fontWeight: semiBold,
    letterSpacing: 0.1,
    color: AppColors.onPrimary,
    height: 1.25,
  );

  /// Caption text style
  static TextStyle get caption => GoogleFonts.cairo(
    fontSize: 12,
    fontWeight: regular,
    letterSpacing: 0.4,
    color: AppColors.secondaryGray,
    height: 1.33,
  );

  /// Overline text style
  static TextStyle get overline => GoogleFonts.cairo(
    fontSize: 12,
    fontWeight: medium,
    letterSpacing: 1.5,
    color: AppColors.secondaryGray,
    height: 1.33,
  );

  // ============ RESPONSIVE STYLES ============
  
  /// Get responsive text style based on screen width
  static TextStyle getResponsiveStyle(TextStyle baseStyle, double screenWidth) {
    late double scaleFactor;
    
    if (screenWidth > 1200) {
      scaleFactor = 1.0; // Desktop
    } else if (screenWidth > 768) {
      scaleFactor = 0.95; // Tablet
    } else {
      scaleFactor = 0.9; // Mobile
    }
    
    return baseStyle.copyWith(
      fontSize: (baseStyle.fontSize ?? 16) * scaleFactor,
    );
  }

  // ============ ARABIC-SPECIFIC STYLES ============
  
  /// Arabic headline large
  static TextStyle get arabicHeadlineLarge => GoogleFonts.cairo(
    fontSize: 32,
    fontWeight: bold,
    letterSpacing: 0,
    color: AppColors.primaryDark,
    height: 1.4, // Increased for Arabic text
  );

  /// Arabic body text
  static TextStyle get arabicBodyMedium => GoogleFonts.cairo(
    fontSize: 16,
    fontWeight: regular,
    letterSpacing: 0,
    color: AppColors.onSurface,
    height: 1.6, // Increased for Arabic text
  );

  // ============ HEALTHCARE-SPECIFIC STYLES ============
  
  /// Medical record number style
  static const TextStyle medicalRecordNumber = TextStyle(
    fontSize: 14,
    fontWeight: bold,
    letterSpacing: 1.0,
    color: AppColors.primaryDark,
    fontFamily: 'monospace',
    height: 1.2,
  );

  /// Patient name style
  static TextStyle get patientName => GoogleFonts.cairo(
    fontSize: 18,
    fontWeight: semiBold,
    letterSpacing: 0.15,
    color: AppColors.onSurface,
    height: 1.33,
  );

  /// Status badge text style
  static TextStyle get statusBadge => GoogleFonts.cairo(
    fontSize: 12,
    fontWeight: bold,
    letterSpacing: 0.5,
    color: AppColors.onPrimary,
    height: 1.0,
  );

  /// Error message style
  static TextStyle get errorMessage => GoogleFonts.cairo(
    fontSize: 14,
    fontWeight: medium,
    letterSpacing: 0.25,
    color: AppColors.error,
    height: 1.43,
  );

  /// Success message style
  static TextStyle get successMessage => GoogleFonts.cairo(
    fontSize: 14,
    fontWeight: medium,
    letterSpacing: 0.25,
    color: AppColors.success,
    height: 1.43,
  );

  // ============ UTILITY METHODS ============
  
  /// Apply brand color to any text style
  static TextStyle withBrandColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Apply different font weight to text style
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  /// Apply different font size to text style
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }

  /// Create text style with custom properties using Cairo font
  static TextStyle custom({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.cairo(
      fontSize: fontSize ?? 16,
      fontWeight: fontWeight ?? regular,
      color: color ?? AppColors.onSurface,
      height: height ?? 1.5,
      letterSpacing: letterSpacing ?? 0.25,
    );
  }

  // ============ TEXT SCALE FACTORS ============
  
  /// Scale factors for different screen sizes
  static const Map<String, double> textScaleFactors = {
    'mobile': 0.9,
    'tablet': 0.95,
    'desktop': 1.0,
    'large': 1.1,
  };

  // ============ LINE HEIGHT PRESETS ============
  
  /// Standard line heights for different content types
  static const double tightLineHeight = 1.2;
  static const double normalLineHeight = 1.5;
  static const double relaxedLineHeight = 1.75;
  static const double arabicLineHeight = 1.6;
}
