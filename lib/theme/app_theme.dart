import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_spacing.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      // Core configuration
      useMaterial3: true,
      visualDensity: VisualDensity.adaptivePlatformDensity,

      // Color scheme
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryDark,
        secondary: AppColors.primaryMedium,
        tertiary: AppColors.primaryLight,
        surface: AppColors.surfaceLight,
        onPrimary: AppColors.onPrimary,
        onSecondary: AppColors.onSecondary,
        onSurface: AppColors.onSurface,
        error: AppColors.error,
        onError: Colors.white,
        outline: AppColors.outline,
        surfaceContainerHighest: AppColors.surfaceVariant,
        onSurfaceVariant: AppColors.onSurfaceVariant,
      ),

      // Typography
      textTheme: AppTypography.textTheme,
      fontFamily: GoogleFonts.cairo()
          .fontFamily, // Set Cairo as the default font family
      // Component themes
      elevatedButtonTheme: _elevatedButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      textButtonTheme: _textButtonTheme,
      inputDecorationTheme: _inputDecorationTheme,
      cardTheme: _cardTheme,
      appBarTheme: _appBarTheme,
      checkboxTheme: _checkboxTheme,
      dialogTheme: _dialogTheme,
      snackBarTheme: _snackBarTheme,
      progressIndicatorTheme: _progressIndicatorTheme,
      dividerTheme: _dividerTheme,
      iconTheme: _iconTheme,

      // Scaffold and background
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
    );
  }

  // Elevated Button Theme
  static ElevatedButtonThemeData get _elevatedButtonTheme {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.onPrimary,
        elevation: AppSpacing.elevation2,
        shadowColor: AppColors.primaryDark.withValues(alpha: 0.3),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        textStyle: AppTypography.button,
        minimumSize: const Size(120, 48),
      ).copyWith(
        backgroundColor: WidgetStateProperty.resolveWith<Color?>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.hovered)) {
            return AppColors.primaryMedium;
          }
          if (states.contains(WidgetState.pressed)) {
            return AppColors.primaryDark.withValues(alpha: 0.9);
          }
          if (states.contains(WidgetState.disabled)) {
            return AppColors.disabled;
          }
          return AppColors.primaryDark;
        }),
        overlayColor: WidgetStateProperty.resolveWith<Color?>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.hovered)) {
            return AppColors.primaryLight.withValues(alpha: 0.1);
          }
          if (states.contains(WidgetState.pressed)) {
            return AppColors.primaryLight.withValues(alpha: 0.2);
          }
          return null;
        }),
      ),
    );
  }

  // Outlined Button Theme
  static OutlinedButtonThemeData get _outlinedButtonTheme {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryDark,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        side: const BorderSide(color: AppColors.primaryDark, width: 1.5),
        textStyle: AppTypography.button,
        minimumSize: const Size(120, 48),
      ).copyWith(
        side: WidgetStateProperty.resolveWith<BorderSide?>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.hovered)) {
            return const BorderSide(
              color: AppColors.primaryMedium,
              width: 2,
            );
          }
          if (states.contains(WidgetState.disabled)) {
            return const BorderSide(color: AppColors.disabled, width: 1);
          }
          return const BorderSide(color: AppColors.primaryDark, width: 1.5);
        }),
        textStyle: WidgetStateProperty.all(
          AppTypography.textTheme.labelLarge?.copyWith(
            color: AppColors.primaryDark,
          ),
        ),
      ),
    );
  }

  // Text Button Theme
  static TextButtonThemeData get _textButtonTheme {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryMedium,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        textStyle: AppTypography.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  // Input Decoration Theme
  static InputDecorationTheme get _inputDecorationTheme {
    return InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceLight,
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: AppColors.outline, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: AppColors.outline, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: AppColors.primaryMedium, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      labelStyle: AppTypography.textTheme.bodyMedium?.copyWith(
        color: AppColors.onSurfaceVariant,
      ),
      hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
        color: AppColors.onSurfaceVariant,
      ),
      errorStyle: AppTypography.textTheme.bodySmall?.copyWith(
        color: AppColors.error,
      ),
    );
  }

  // Card Theme
  static CardThemeData get _cardTheme {
    return CardThemeData(
      color: Colors.white,
      elevation: AppSpacing.elevation1,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      margin: EdgeInsets.all(AppSpacing.sm),
    );
  }

  // App Bar Theme
  static AppBarTheme get _appBarTheme {
    return AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.onPrimary,
      elevation: 0,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      scrolledUnderElevation: 0,
      titleTextStyle: AppTypography.textTheme.headlineMedium?.copyWith(
        color: AppColors.onPrimary,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        fontSize: 24,
        shadows: [
          Shadow(
            offset: const Offset(0, 2),
            blurRadius: 8,
            color: Colors.black.withValues(alpha: 0.3),
          ),
        ],
      ),
      iconTheme: const IconThemeData(color: AppColors.onPrimary, size: 24),
      actionsIconTheme: const IconThemeData(
        color: AppColors.onPrimary,
        size: 22,
      ),
      toolbarHeight: 85,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
    );
  }

  // Checkbox Theme
  static CheckboxThemeData get _checkboxTheme {
    return CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color?>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryDark;
        }
        return AppColors.surfaceLight;
      }),
      checkColor: WidgetStateProperty.all(AppColors.onPrimary),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
      ),
    );
  }

  // Dialog Theme
  static DialogThemeData get _dialogTheme {
    return DialogThemeData(
      backgroundColor: Colors.white,
      elevation: AppSpacing.elevation3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      titleTextStyle: AppTypography.textTheme.headlineSmall?.copyWith(
        color: AppColors.primaryDark,
        fontWeight: FontWeight.bold,
      ),
      contentTextStyle: AppTypography.textTheme.bodyMedium?.copyWith(
        color: AppColors.onSurface,
      ),
    );
  }

  // SnackBar Theme
  static SnackBarThemeData get _snackBarTheme {
    return SnackBarThemeData(
      backgroundColor: AppColors.primaryDark,
      contentTextStyle: AppTypography.textTheme.bodyMedium?.copyWith(
        color: AppColors.onPrimary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      behavior: SnackBarBehavior.floating,
    );
  }

  // Progress Indicator Theme
  static ProgressIndicatorThemeData get _progressIndicatorTheme {
    return const ProgressIndicatorThemeData(
      color: AppColors.primaryMedium,
      linearTrackColor: AppColors.surfaceVariant,
      circularTrackColor: AppColors.surfaceVariant,
    );
  }

  // Divider Theme
  static DividerThemeData get _dividerTheme {
    return const DividerThemeData(
      color: AppColors.outline,
      thickness: 1,
      space: 1,
    );
  }

  // Icon Theme
  static IconThemeData get _iconTheme {
    return const IconThemeData(color: AppColors.onSurfaceVariant, size: 24);
  }

  // DARK THEME
  static ThemeData get darkTheme {
    return ThemeData(
      // Core configuration
      useMaterial3: true,
      visualDensity: VisualDensity.adaptivePlatformDensity,

      // Color scheme
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryLight, // لون أساسي أفتح للداكن
        secondary: AppColors.primaryMedium,
        tertiary: AppColors.primaryDark, // ألوان داعمة
        surface: AppColors.surfaceDark,
        onPrimary: AppColors.onPrimaryDark,
        onSecondary: AppColors.onSecondaryDark,
        onSurface: AppColors.onSurfaceDark,
        error: AppColors.error,
        onError: Colors.white,
        outline: AppColors.outlineDark,
        surfaceContainerHighest: AppColors.surfaceVariantDark,
        onSurfaceVariant: AppColors.onSurfaceVariantDark,
      ),

      // Typography
      textTheme: AppTypography.textTheme,
      fontFamily: GoogleFonts.cairo().fontFamily,

      // Component themes
      elevatedButtonTheme: _elevatedButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      textButtonTheme: _textButtonTheme,
      inputDecorationTheme: _inputDecorationTheme,
      cardTheme: _cardTheme,
      appBarTheme: _appBarTheme.copyWith(
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.onSurfaceDark,
      ),
      checkboxTheme: _checkboxTheme,
      dialogTheme: _dialogTheme.copyWith(
        backgroundColor: AppColors.surfaceDark,
      ),
      snackBarTheme: _snackBarTheme,
      progressIndicatorTheme: _progressIndicatorTheme,
      dividerTheme: _dividerTheme,
      iconTheme: _iconTheme.copyWith(color: AppColors.onSurfaceDark),

      // Scaffold and background
      scaffoldBackgroundColor: AppColors.backgroundDark,
      canvasColor: AppColors.backgroundDark,
    );
  }

  // Dark Theme Components

  // Dark Elevated Button Theme
  static ElevatedButtonThemeData get _darkElevatedButtonTheme {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: DarkColors.primaryLight,
        foregroundColor: DarkColors.onPrimary,
        elevation: 3,
        shadowColor: Colors.black.withValues(alpha: 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        textStyle: const TextStyle(
          color: DarkColors.onPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Dark Outlined Button Theme
  static OutlinedButtonThemeData get _darkOutlinedButtonTheme {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: DarkColors.primaryLight,
        side: const BorderSide(color: DarkColors.primaryLight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
      ),
    );
  }

  // Dark Text Button Theme
  static TextButtonThemeData get _darkTextButtonTheme {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: DarkColors.primaryLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
    );
  }

  // Dark Input Decoration Theme
  static InputDecorationTheme get _darkInputDecorationTheme {
    return InputDecorationTheme(
      filled: true,
      fillColor: DarkColors.surfaceVariant,
      hintStyle: const TextStyle(
        color: DarkColors.onSurfaceVariant,
      ),
      labelStyle: const TextStyle(
        color: DarkColors.onSurfaceVariant,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide:
            BorderSide(color: DarkColors.primaryMedium.withValues(alpha: 0.5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide:
            BorderSide(color: DarkColors.primaryMedium.withValues(alpha: 0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: DarkColors.primaryLight, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: DarkColors.error),
      ),
    );
  }

  // Dark Card Theme
  static CardThemeData get _darkCardTheme {
    return CardThemeData(
      color: DarkColors.surface,
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      margin: const EdgeInsets.all(AppSpacing.sm),
    );
  }

  // Dark AppBar Theme
  static AppBarTheme get _darkAppBarTheme {
    return AppBarTheme(
      backgroundColor: DarkColors.surface,
      foregroundColor: DarkColors.onSurface,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: const TextStyle(
        color: DarkColors.onSurface,
        fontWeight: FontWeight.w600,
        fontSize: 20,
      ),
      iconTheme: const IconThemeData(
        color: DarkColors.onSurface,
      ),
    );
  }

  // Dark Checkbox Theme
  static CheckboxThemeData get _darkCheckboxTheme {
    return CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return DarkColors.primaryLight;
          }
          return Colors.transparent;
        },
      ),
      checkColor: WidgetStateProperty.all(DarkColors.onPrimary),
      side: const BorderSide(color: DarkColors.primaryMedium),
    );
  }

  // Dark Dialog Theme
  static DialogThemeData get _darkDialogTheme {
    return DialogThemeData(
      backgroundColor: DarkColors.surface,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      titleTextStyle: const TextStyle(
        color: DarkColors.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: const TextStyle(
        color: DarkColors.onSurface,
        fontSize: 16,
      ),
    );
  }

  // Dark SnackBar Theme
  static SnackBarThemeData get _darkSnackBarTheme {
    return SnackBarThemeData(
      backgroundColor: DarkColors.surfaceVariant,
      contentTextStyle: const TextStyle(
        color: DarkColors.onSurface,
        fontSize: 16,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      behavior: SnackBarBehavior.floating,
    );
  }

  // Dark Progress Indicator Theme
  static ProgressIndicatorThemeData get _darkProgressIndicatorTheme {
    return const ProgressIndicatorThemeData(
      color: DarkColors.primaryLight,
      linearTrackColor: DarkColors.surfaceVariant,
      circularTrackColor: DarkColors.surfaceVariant,
    );
  }

  // Dark Divider Theme
  static DividerThemeData get _darkDividerTheme {
    return const DividerThemeData(
      color: DarkColors.primaryMedium,
      thickness: 1,
      space: 1,
    );
  }

  // Dark Icon Theme
  static IconThemeData get _darkIconTheme {
    return const IconThemeData(color: DarkColors.onSurfaceVariant, size: 24);
  }

  // Dark Switch Theme
  static SwitchThemeData get _darkSwitchTheme {
    return SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return DarkColors.onPrimary;
          }
          return DarkColors.onSurfaceVariant;
        },
      ),
      trackColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return DarkColors.primaryLight;
          }
          return DarkColors.surfaceVariant;
        },
      ),
    );
  }
}
