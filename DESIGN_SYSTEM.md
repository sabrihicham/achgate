# Design System Documentation
## تجمع جدة الصحي الثاني (Jeddah Health Cluster II)

This document outlines the complete design system for the healthcare platform, ensuring visual consistency and brand alignment across all components.

## 🎨 Color Palette

### Primary Colors
- **Primary Dark** (`#15508A`): Main brand color for primary buttons, headers, navigation
- **Primary Medium** (`#1691D0`): Interactive elements, links, focus states
- **Primary Light** (`#2CAAE2`): Decorative elements, subtle backgrounds, gradients

### Neutral Colors
- **Secondary Gray** (`#A09EA4`): Secondary text, borders, placeholders
- **Dark Text** (`#333333`): Primary content text
- **Light Surface** (`#F8F9FA`): Input field backgrounds, subtle containers
- **Pure Background** (`#FFFFFF`): Main page backgrounds, card backgrounds

### State Colors
- **Success** (`#10B981`): Success messages, positive status indicators
- **Error** (`#EF4444`): Error messages, validation alerts
- **Warning** (`#F59E0B`): Warning messages, caution alerts
- **Info** (`#3B82F6`): Information messages, tips

### Utility Colors
- **Outline** (`#E9ECEF`): Borders, dividers
- **Disabled** (`#D1D5DB`): Disabled state elements
- **Surface Variant** (`#F1F3F4`): Alternative container backgrounds

## 📝 Typography

### Font Families
- **Primary**: Inter (Latin text)
- **Arabic**: Noto Sans Arabic (Arabic text optimization)

### Text Styles

#### Display Styles
- **Display Large**: 57px, Bold - Hero sections
- **Display Medium**: 45px, Bold - Main page titles
- **Display Small**: 36px, Bold - Section headers

#### Headlines
- **Headline Large**: 32px, Bold - Page titles
- **Headline Medium**: 28px, SemiBold - Major section titles
- **Headline Small**: 24px, SemiBold - Minor section titles

#### Titles
- **Title Large**: 22px, Medium - Card titles
- **Title Medium**: 18px, Medium - List item titles
- **Title Small**: 16px, Medium - Small component titles

#### Body Text
- **Body Large**: 18px, Regular - Important body text
- **Body Medium**: 16px, Regular - Standard body text
- **Body Small**: 14px, Regular - Secondary text, captions

#### Labels
- **Label Large**: 16px, Medium - Form labels
- **Label Medium**: 14px, Medium - Button text
- **Label Small**: 12px, Medium - Small labels, tags

### Specialized Styles
- **Button Text**: 16px, SemiBold - All button text
- **Medical Record Number**: 14px, Bold, Monospace - Patient IDs
- **Patient Name**: 18px, SemiBold - Patient identification
- **Status Badge**: 12px, Bold - Status indicators
- **Error Message**: 14px, Medium, Red - Validation errors
- **Success Message**: 14px, Medium, Green - Success feedback

## 📏 Spacing System

Based on 8px grid system:

### Scale
- **XS**: 4px (0.5× base)
- **SM**: 8px (1× base)
- **MD**: 16px (2× base)
- **LG**: 24px (3× base)
- **XL**: 32px (4× base)
- **XXL**: 48px (6× base)
- **XXXL**: 64px (8× base)

### Component Spacing
- **Button Padding**: 24px horizontal, 16px vertical
- **Input Padding**: 16px horizontal, 16px vertical
- **Card Padding**: 24px all sides
- **Screen Padding**: 24px all sides
- **Form Field Spacing**: 24px between fields
- **Section Spacing**: 48px between major sections

### Responsive Spacing
- **Desktop**: 1.0× base spacing
- **Tablet**: 0.875× base spacing
- **Mobile**: 0.75× base spacing

## 🔄 Border Radius

- **XS**: 4px - Small elements
- **SM**: 8px - Buttons, small inputs
- **MD**: 12px - Standard components (default)
- **LG**: 16px - Cards, modals
- **XL**: 24px - Large containers
- **Round**: 50% - Circular elements

## 🌊 Elevation System

- **Level 0**: 0dp - Flat elements
- **Level 1**: 1dp - Subtle lift
- **Level 2**: 2dp - Standard buttons
- **Level 3**: 4dp - Cards, menus
- **Level 4**: 8dp - Navigation drawer
- **Level 5**: 16dp - Modal dialogs

## 🔢 Icon Sizes

- **XS**: 16px - Small inline icons
- **SM**: 20px - Form field icons
- **MD**: 24px - Standard size (default)
- **LG**: 32px - Prominent icons
- **XL**: 48px - Feature icons
- **XXL**: 64px - Logo, large graphics

## 🎯 Component Specifications

### Buttons
- **Minimum Height**: 48px
- **Small Height**: 36px
- **Large Height**: 56px
- **Minimum Width**: 120px
- **Padding**: 24px horizontal, 16px vertical

### Form Fields
- **Standard Height**: 48px
- **Small Height**: 36px
- **Large Height**: 56px
- **Textarea Min Height**: 96px

### Layout
- **Container Max Width**: 1200px
- **Sidebar Width**: 280px
- **Navigation Bar Height**: 64px

## 🏥 Healthcare-Specific Elements

### Patient Information
- **Section Spacing**: 32px between patient info sections
- **Medical Form Groups**: 24px spacing
- **Medication Items**: 8px spacing
- **Emergency Info**: 24px padding around alerts

### Status Indicators
- **Active/نشط**: Success green background
- **Pending/معلق**: Warning orange background  
- **Inactive/منتهي**: Error red background
- **Default**: Primary medium blue background

## 📱 Responsive Breakpoints

- **Mobile**: ≤ 768px
- **Tablet**: 769px - 1024px
- **Desktop**: > 1024px
- **Large Desktop**: > 1200px

### Responsive Adjustments
- **Font Scaling**: Mobile (0.9×), Tablet (0.95×), Desktop (1.0×)
- **Logo Sizes**: Mobile (80px), Tablet (100px), Desktop (120px)
- **Padding**: Reduces on smaller screens
- **Layout**: Single column on mobile, side-by-side on desktop

## ⚡ Animation Guidelines

- **Fast**: 150ms - Hover effects, button presses
- **Standard**: 250ms - Most transitions
- **Slow**: 400ms - Page transitions, complex animations

## ♿ Accessibility

### Color Contrast
- All text maintains WCAG AA compliance (4.5:1 contrast ratio minimum)
- Interactive elements have clear focus indicators
- Status colors work for colorblind users

### Typography
- Minimum font size: 14px for body text
- Clear hierarchy with sufficient size differences
- Good line spacing for readability (1.5× for body text)

### Touch Targets
- Minimum 48px touch target size
- Adequate spacing between interactive elements

## 🌐 RTL Support

- Full right-to-left text direction support
- Mirrored layouts for Arabic content
- Proper text alignment and spacing
- Cultural design considerations

## 🚀 Usage Examples

### CSS Variables (if using web)
```css
:root {
  --color-primary-dark: #15508A;
  --color-primary-medium: #1691D0;
  --color-primary-light: #2CAAE2;
  --spacing-sm: 8px;
  --spacing-md: 16px;
  --spacing-lg: 24px;
  --radius-md: 12px;
  --elevation-2: 0 2px 4px rgba(0,0,0,0.08);
}
```

### Flutter Implementation
```dart
// Use the AppTheme class
MaterialApp(
  theme: AppTheme.lightTheme,
  // ...
)

// Use predefined components
AppComponents.primaryButton(
  text: 'تسجيل الدخول',
  onPressed: () {},
)

// Use color constants
Container(
  color: AppColors.primaryDark,
  // ...
)
```

This design system ensures consistency, accessibility, and adherence to the تجمع جدة الصحي الثاني brand identity across all platform interfaces.
