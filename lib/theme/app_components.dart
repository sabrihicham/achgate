import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Component styles for Jeddah Health Cluster II (تجمع جدة الصحي الثاني)
/// 
/// This class provides pre-built styled components that follow the design system
/// and can be used throughout the application for consistency.
class AppComponents {
  // Prevent instantiation
  AppComponents._();

  // ============ BUTTON COMPONENTS ============
  
  /// Primary button widget
  static Widget primaryButton({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    bool isFullWidth = false,
    IconData? icon,
    double? width,
    double? height,
  }) {
    return SizedBox(
      width: isFullWidth ? double.infinity : width,
      height: height ?? AppSpacing.buttonMinHeight,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading 
          ? const SizedBox(
              width: AppSpacing.iconSm,
              height: AppSpacing.iconSm,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.onPrimary),
              ),
            )
          : (icon != null ? Icon(icon, size: AppSpacing.iconSm) : const SizedBox.shrink()),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: AppColors.onPrimary,
          elevation: AppSpacing.elevation2,
          padding: AppSpacing.buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          textStyle: AppTypography.button,
        ),
      ),
    );
  }

  /// Secondary button widget
  static Widget secondaryButton({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    bool isFullWidth = false,
    IconData? icon,
    double? width,
    double? height,
  }) {
    return SizedBox(
      width: isFullWidth ? double.infinity : width,
      height: height ?? AppSpacing.buttonMinHeight,
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading 
          ? const SizedBox(
              width: AppSpacing.iconSm,
              height: AppSpacing.iconSm,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryDark),
              ),
            )
          : (icon != null ? Icon(icon, size: AppSpacing.iconSm) : const SizedBox.shrink()),
        label: Text(text),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryDark,
          padding: AppSpacing.buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          side: const BorderSide(
            color: AppColors.primaryDark,
            width: 1.5,
          ),
          textStyle: AppTypography.button.copyWith(
            color: AppColors.primaryDark,
          ),
        ),
      ),
    );
  }

  // ============ INPUT COMPONENTS ============
  
  /// Standard text input field
  static Widget textField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? prefixIcon,
    Widget? suffixIcon,
    bool obscureText = false,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool enabled = true,
    int? maxLines = 1,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.textTheme.labelLarge!.copyWith(
            color: enabled ? AppColors.onSurface : AppColors.disabled,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          keyboardType: keyboardType,
          enabled: enabled,
          maxLines: maxLines,
          maxLength: maxLength,
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
          style: AppTypography.textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null 
              ? Icon(prefixIcon, color: AppColors.onSurfaceVariant)
              : null,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: enabled ? AppColors.surfaceLight : AppColors.disabled.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: const BorderSide(color: AppColors.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: const BorderSide(color: AppColors.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: const BorderSide(
                color: AppColors.primaryMedium,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            contentPadding: AppSpacing.formFieldPadding,
          ),
        ),
      ],
    );
  }

  // ============ CARD COMPONENTS ============
  
  /// Standard card container
  static Widget card({
    required Widget child,
    EdgeInsets? padding,
    Color? backgroundColor,
    double? elevation,
    BorderRadius? borderRadius,
  }) {
    return Card(
      color: backgroundColor ?? Colors.white,
      elevation: elevation ?? AppSpacing.elevation1,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Padding(
        padding: padding ?? AppSpacing.cardPaddingAll,
        child: child,
      ),
    );
  }

  /// Patient information card
  static Widget patientCard({
    required String patientName,
    required String medicalRecordNumber,
    required String status,
    String? lastVisit,
    VoidCallback? onTap,
  }) {
    return card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    patientName,
                    style: AppTypography.patientName,
                    textAlign: TextAlign.right,
                  ),
                ),
                statusBadge(status),
              ],
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'رقم الملف الطبي: $medicalRecordNumber',
              style: AppTypography.medicalRecordNumber,
              textAlign: TextAlign.right,
            ),
            if (lastVisit != null) ...[
              SizedBox(height: AppSpacing.xs),
              Text(
                'آخر زيارة: $lastVisit',
                style: AppTypography.textTheme.bodySmall,
                textAlign: TextAlign.right,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============ STATUS COMPONENTS ============
  
  /// Status badge widget
  static Widget statusBadge(String status) {
    Color backgroundColor;
    Color textColor = AppColors.onPrimary;
    
    switch (status.toLowerCase()) {
      case 'نشط':
      case 'active':
        backgroundColor = AppColors.success;
        break;
      case 'معلق':
      case 'pending':
        backgroundColor = AppColors.warning;
        break;
      case 'منتهي':
      case 'inactive':
        backgroundColor = AppColors.error;
        break;
      default:
        backgroundColor = AppColors.primaryMedium;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(
        status,
        style: AppTypography.statusBadge.copyWith(color: textColor),
      ),
    );
  }

  // ============ LOADING COMPONENTS ============
  
  /// Standard loading indicator
  static Widget loadingIndicator({
    String? message,
    Color? color,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? AppColors.primaryMedium,
            ),
          ),
          if (message != null) ...[
            SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: AppTypography.textTheme.bodyMedium!.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  /// Page loading overlay
  static Widget loadingOverlay({
    required bool isLoading,
    required Widget child,
    String? message,
  }) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: loadingIndicator(message: message),
          ),
      ],
    );
  }

  // ============ MESSAGE COMPONENTS ============
  
  /// Error message widget
  static Widget errorMessage({
    required String message,
    VoidCallback? onRetry,
  }) {
    return card(
      backgroundColor: AppColors.error.withOpacity(0.1),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: AppSpacing.iconLg,
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            message,
            style: AppTypography.errorMessage,
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            SizedBox(height: AppSpacing.md),
            secondaryButton(
              text: 'إعادة المحاولة',
              onPressed: onRetry,
            ),
          ],
        ],
      ),
    );
  }

  /// Success message widget
  static Widget successMessage(String message) {
    return card(
      backgroundColor: AppColors.success.withOpacity(0.1),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: AppColors.success,
            size: AppSpacing.iconMd,
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTypography.successMessage,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  // ============ DIALOG COMPONENTS ============
  
  /// Standard confirmation dialog
  static Future<bool?> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'تأكيد',
    String cancelText = 'إلغاء',
  }) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: AppTypography.textTheme.headlineSmall!.copyWith(
              color: AppColors.primaryDark,
            ),
            textAlign: TextAlign.right,
          ),
          content: Text(
            message,
            style: AppTypography.textTheme.bodyMedium,
            textAlign: TextAlign.right,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(cancelText),
            ),
            primaryButton(
              text: confirmText,
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
        );
      },
    );
  }

  // ============ NAVIGATION COMPONENTS ============
  
  /// App bar with consistent styling
  static PreferredSizeWidget appBar({
    required String title,
    List<Widget>? actions,
    Widget? leading,
    bool automaticallyImplyLeading = true,
  }) {
    return AppBar(
      title: Text(
        title,
        style: AppTypography.textTheme.headlineSmall!.copyWith(
          color: AppColors.onPrimary,
        ),
      ),
      backgroundColor: AppColors.primaryDark,
      foregroundColor: AppColors.onPrimary,
      elevation: 0,
      centerTitle: true,
      actions: actions,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
    );
  }

  // ============ LAYOUT COMPONENTS ============
  
  /// Responsive container with proper spacing
  static Widget responsiveContainer({
    required Widget child,
    required double screenWidth,
    EdgeInsets? padding,
  }) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        maxWidth: AppSpacing.containerMaxWidth,
      ),
      padding: padding ?? EdgeInsets.all(
        AppSpacing.getPageMargin(screenWidth),
      ),
      child: child,
    );
  }

  /// Section divider with proper spacing
  static Widget sectionDivider({String? title}) {
    return Column(
      children: [
        SizedBox(height: AppSpacing.sectionSpacing),
        if (title != null) ...[
          Text(
            title,
            style: AppTypography.textTheme.titleMedium,
            textAlign: TextAlign.right,
          ),
          SizedBox(height: AppSpacing.md),
        ],
        const Divider(
          color: AppColors.outline,
          thickness: 1,
        ),
        SizedBox(height: AppSpacing.sectionSpacing),
      ],
    );
  }
}
