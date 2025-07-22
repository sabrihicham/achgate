import 'package:flutter/material.dart';

/// Spacing system for Jeddah Health Cluster II (تجمع جدة الصحي الثاني)
/// 
/// This class defines a consistent spacing scale based on an 8px grid system
/// following Material Design guidelines with healthcare-specific adaptations.
class AppSpacing {
  // Prevent instantiation
  AppSpacing._();

  // ============ BASE SPACING UNIT ============
  /// Base spacing unit (8px) - All spacing should be multiples of this
  static const double baseUnit = 8.0;

  // ============ SPACING SCALE ============
  /// Extra small spacing (4px) - 0.5x base unit
  static const double xs = baseUnit * 0.5;

  /// Small spacing (8px) - 1x base unit
  static const double sm = baseUnit * 1.0;

  /// Medium spacing (16px) - 2x base unit
  static const double md = baseUnit * 2.0;

  /// Large spacing (24px) - 3x base unit
  static const double lg = baseUnit * 3.0;

  /// Extra large spacing (32px) - 4x base unit
  static const double xl = baseUnit * 4.0;

  /// Extra extra large spacing (48px) - 6x base unit
  static const double xxl = baseUnit * 6.0;

  /// Extra extra extra large spacing (64px) - 8x base unit
  static const double xxxl = baseUnit * 8.0;

  // ============ COMPONENT-SPECIFIC SPACING ============
  
  // Padding values for different components
  static const double buttonPaddingHorizontal = lg; // 24px
  static const double buttonPaddingVertical = md; // 16px
  static const double inputPaddingHorizontal = md; // 16px
  static const double inputPaddingVertical = md; // 16px
  static const double cardPadding = lg; // 24px
  static const double screenPadding = lg; // 24px
  static const double sectionSpacing = xl; // 32px

  // ============ LAYOUT SPACING ============
  
  /// Spacing between form fields
  static const double formFieldSpacing = lg; // 24px

  /// Spacing between sections
  static const double betweenSections = xxl; // 48px

  /// Spacing between related elements
  static const double betweenRelated = md; // 16px

  /// Spacing between unrelated elements
  static const double betweenUnrelated = xl; // 32px

  /// Page margins for different screen sizes
  static const double mobilePageMargin = md; // 16px
  static const double tabletPageMargin = xl; // 32px
  static const double desktopPageMargin = xxxl; // 64px

  // ============ BORDER RADIUS ============
  
  /// Extra small radius (4px) - For small elements
  static const double radiusXs = 4.0;

  /// Small radius (8px) - For buttons, inputs
  static const double radiusSm = 8.0;

  /// Medium radius (12px) - Default for most components
  static const double radiusMd = 12.0;

  /// Large radius (16px) - For cards, modals
  static const double radiusLg = 16.0;

  /// Extra large radius (24px) - For large containers
  static const double radiusXl = 24.0;

  /// Round radius (50%) - For circular elements
  static const double radiusRound = 9999.0;

  // ============ ELEVATION SYSTEM ============
  
  /// No elevation
  static const double elevation0 = 0.0;

  /// Level 1 elevation - Subtle lift
  static const double elevation1 = 1.0;

  /// Level 2 elevation - Standard buttons
  static const double elevation2 = 2.0;

  /// Level 3 elevation - Cards, menus
  static const double elevation3 = 4.0;

  /// Level 4 elevation - Navigation drawer
  static const double elevation4 = 8.0;

  /// Level 5 elevation - Modal dialogs
  static const double elevation5 = 16.0;

  // ============ ICON SIZES ============
  
  /// Extra small icon (16px)
  static const double iconXs = 16.0;

  /// Small icon (20px)
  static const double iconSm = 20.0;

  /// Medium icon (24px) - Default size
  static const double iconMd = 24.0;

  /// Large icon (32px)
  static const double iconLg = 32.0;

  /// Extra large icon (48px)
  static const double iconXl = 48.0;

  /// Extra extra large icon (64px)
  static const double iconXxl = 64.0;

  // ============ BUTTON DIMENSIONS ============
  
  /// Minimum button height
  static const double buttonMinHeight = 48.0;

  /// Small button height
  static const double buttonSmallHeight = 36.0;

  /// Large button height
  static const double buttonLargeHeight = 56.0;

  /// Minimum button width
  static const double buttonMinWidth = 120.0;

  // ============ FORM FIELD DIMENSIONS ============
  
  /// Standard input field height
  static const double inputHeight = 48.0;

  /// Small input field height
  static const double inputSmallHeight = 36.0;

  /// Large input field height
  static const double inputLargeHeight = 56.0;

  /// Textarea minimum height
  static const double textareaMinHeight = 96.0;

  // ============ RESPONSIVE SPACING ============
  
  /// Get responsive spacing based on screen width
  static double getResponsiveSpacing(double baseSpacing, double screenWidth) {
    if (screenWidth > 1200) {
      return baseSpacing * 1.0; // Desktop
    } else if (screenWidth > 768) {
      return baseSpacing * 0.875; // Tablet (7/8)
    } else {
      return baseSpacing * 0.75; // Mobile (3/4)
    }
  }

  /// Get responsive page margin
  static double getPageMargin(double screenWidth) {
    if (screenWidth > 1200) {
      return desktopPageMargin;
    } else if (screenWidth > 768) {
      return tabletPageMargin;
    } else {
      return mobilePageMargin;
    }
  }

  /// Get responsive card padding
  static double getCardPadding(double screenWidth) {
    if (screenWidth > 768) {
      return cardPadding; // 24px
    } else {
      return md; // 16px on mobile
    }
  }

  // ============ HEALTHCARE-SPECIFIC SPACING ============
  
  /// Spacing between patient information sections
  static const double patientSectionSpacing = xl; // 32px

  /// Spacing around medical alerts
  static const double alertSpacing = md; // 16px

  /// Spacing for form groups in medical forms
  static const double medicalFormGroupSpacing = lg; // 24px

  /// Spacing for medication list items
  static const double medicationItemSpacing = sm; // 8px

  /// Spacing around emergency information
  static const double emergencySpacing = lg; // 24px

  // ============ GRID SYSTEM ============
  
  /// Column gap in grid layouts
  static const double gridColumnGap = md; // 16px

  /// Row gap in grid layouts
  static const double gridRowGap = md; // 16px

  /// Container max width for content
  static const double containerMaxWidth = 1200.0;

  /// Sidebar width
  static const double sidebarWidth = 280.0;

  /// Navigation bar height
  static const double navigationBarHeight = 64.0;

  // ============ ANIMATION DURATIONS ============
  
  /// Fast animation duration (150ms)
  static const Duration fastAnimation = Duration(milliseconds: 150);

  /// Standard animation duration (250ms)
  static const Duration standardAnimation = Duration(milliseconds: 250);

  /// Slow animation duration (400ms)
  static const Duration slowAnimation = Duration(milliseconds: 400);

  // ============ UTILITY METHODS ============
  
  /// Convert spacing value to EdgeInsets
  static EdgeInsets allSpacing(double value) => EdgeInsets.all(value);
  
  /// Create symmetric horizontal spacing
  static EdgeInsets horizontalSpacing(double value) => 
    EdgeInsets.symmetric(horizontal: value);
  
  /// Create symmetric vertical spacing
  static EdgeInsets verticalSpacing(double value) => 
    EdgeInsets.symmetric(vertical: value);
  
  /// Create custom EdgeInsets
  static EdgeInsets customSpacing({
    double? top,
    double? right,
    double? bottom,
    double? left,
  }) => EdgeInsets.only(
    top: top ?? 0,
    right: right ?? 0,
    bottom: bottom ?? 0,
    left: left ?? 0,
  );

  // ============ SPACING PRESETS ============
  
  /// Common spacing combinations
  static const EdgeInsets formFieldPadding = EdgeInsets.symmetric(
    horizontal: inputPaddingHorizontal,
    vertical: inputPaddingVertical,
  );

  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: buttonPaddingHorizontal,
    vertical: buttonPaddingVertical,
  );

  static const EdgeInsets cardPaddingAll = EdgeInsets.all(cardPadding);

  static const EdgeInsets screenPaddingAll = EdgeInsets.all(screenPadding);

  static const EdgeInsets sectionPaddingVertical = EdgeInsets.symmetric(
    vertical: sectionSpacing,
  );
}
