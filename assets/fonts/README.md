# Cairo Font Installation Guide

## Overview
This project uses the Cairo font family for optimal Arabic and English text rendering. Cairo is a modern, clean font that provides excellent readability for both languages.

## Required Font Files
You need to download the following Cairo font files and place them in the `assets/fonts/` directory:

### Download Source
- **Google Fonts**: https://fonts.google.com/specimen/Cairo
- **Direct Download**: Use Google Fonts to download the Cairo font family

### Required Font Weights
1. **Cairo-Light.ttf** (Weight: 300)
2. **Cairo-Regular.ttf** (Weight: 400) 
3. **Cairo-Medium.ttf** (Weight: 500)
4. **Cairo-SemiBold.ttf** (Weight: 600)
5. **Cairo-Bold.ttf** (Weight: 700)

## Installation Steps

### Step 1: Download Cairo Font
1. Visit [Google Fonts - Cairo](https://fonts.google.com/specimen/Cairo)
2. Click "Download family" to download the font files
3. Extract the downloaded ZIP file

### Step 2: Replace Placeholder Files
1. Navigate to `assets/fonts/` in your project
2. Replace the placeholder `.ttf` files with the actual Cairo font files:
   - Replace `Cairo-Light.ttf` with the actual Light weight file
   - Replace `Cairo-Regular.ttf` with the actual Regular weight file
   - Replace `Cairo-Medium.ttf` with the actual Medium weight file
   - Replace `Cairo-SemiBold.ttf` with the actual SemiBold weight file
   - Replace `Cairo-Bold.ttf` with the actual Bold weight file

### Step 3: Verify Installation
1. Run `flutter clean`
2. Run `flutter pub get`
3. Run your app to see the Cairo font in action

## Font Configuration
The Cairo font is configured in:
- `pubspec.yaml` - Font asset declarations
- `lib/theme/app_typography.dart` - Typography system
- `lib/theme/app_theme.dart` - Default font family setting

## Usage
The Cairo font will be used automatically throughout the app. No additional configuration is needed in individual widgets as it's set as the default font family in the app theme.

## Features
- ✅ Excellent Arabic text rendering
- ✅ Clean English text display
- ✅ Multiple font weights (Light, Regular, Medium, SemiBold, Bold)
- ✅ Optimized for healthcare/medical applications
- ✅ RTL (Right-to-Left) text support

## Troubleshooting
If fonts are not displaying correctly:
1. Ensure all font files are properly placed in `assets/fonts/`
2. Verify file names match exactly what's in `pubspec.yaml`
3. Run `flutter clean` and `flutter pub get`
4. Restart your development server

## Alternative: Using Google Fonts Package
If you prefer to use the Google Fonts package instead of local font files:
1. The project already includes `google_fonts: ^6.1.0` in dependencies
2. You can use `GoogleFonts.cairo()` in your text styles
3. This approach downloads fonts dynamically but requires internet connection
