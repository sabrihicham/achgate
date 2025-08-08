import 'package:flutter/material.dart';

/// Theme Manager لإدارة الـ Dark Mode والـ Light Mode
class ThemeManager extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  /// تحميل إعدادات الـ Theme من التخزين المحلي
  Future<void> loadTheme() async {
    try {
      // في المستقبل يمكن استخدام SharedPreferences هنا
      // للآن نستخدم الوضع الافتراضي
      _themeMode = ThemeMode.system;
    } catch (e) {
      _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  /// حفظ إعدادات الـ Theme في التخزين المحلي
  Future<void> _saveTheme(String theme) async {
    try {
      // في المستقبل يمكن حفظ الإعدادات هنا
      debugPrint('Theme saved: $theme');
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }

  /// تغيير إلى الوضع الفاتح
  Future<void> setLightMode() async {
    _themeMode = ThemeMode.light;
    await _saveTheme('light');
    notifyListeners();
  }

  /// تغيير إلى الوضع الداكن
  Future<void> setDarkMode() async {
    _themeMode = ThemeMode.dark;
    await _saveTheme('dark');
    notifyListeners();
  }

  /// تغيير إلى وضع النظام (تلقائي)
  Future<void> setSystemMode() async {
    _themeMode = ThemeMode.system;
    await _saveTheme('system');
    notifyListeners();
  }

  /// تبديل بين الوضع الفاتح والداكن
  Future<void> toggleTheme() async {
    if (isDarkMode) {
      await setLightMode();
    } else {
      await setDarkMode();
    }
  }

  /// تحديد الوضع بناءً على النص
  Future<void> setThemeMode(String mode) async {
    switch (mode.toLowerCase()) {
      case 'light':
        await setLightMode();
        break;
      case 'dark':
        await setDarkMode();
        break;
      case 'system':
      case 'auto':
        await setSystemMode();
        break;
      default:
        await setSystemMode();
        break;
    }
  }

  /// الحصول على النص المقابل لوضع الـ Theme الحالي
  String get currentThemeString {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  /// الحصول على النص العربي لوضع الـ Theme الحالي
  String get currentThemeDisplayName {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'فاتح';
      case ThemeMode.dark:
        return 'داكن';
      case ThemeMode.system:
        return 'تلقائي';
    }
  }
}
