import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';

/// Global Theme Manager - إدارة مركزية للمظاهر مع دعم الويب
class GlobalThemeManager {
  static final GlobalThemeManager _instance = GlobalThemeManager._internal();
  factory GlobalThemeManager() => _instance;
  GlobalThemeManager._internal();

  // مفتاح حفظ إعدادات الثيم
  static const String _themeKey = 'app_theme_mode';

  // إشعار للتحديثات
  static final ValueNotifier<ThemeMode> _themeModeNotifier =
      ValueNotifier<ThemeMode>(ThemeMode.system);

  // الحصول على ValueNotifier للاستماع للتغييرات
  static ValueNotifier<ThemeMode> get notifier => _themeModeNotifier;

  // الحصول على حالة المظهر الحالية
  static ThemeMode get themeMode => _themeModeNotifier.value;

  // تحديد ما إذا كان المظهر داكن
  static bool get isDarkMode {
    if (_themeModeNotifier.value == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;
    }
    return _themeModeNotifier.value == ThemeMode.dark;
  }

  // ============ THEME-AWARE COLOR GETTERS ============

  /// الحصول على اللون الأساسي حسب الثيم
  static Color get primaryColor {
    return isDarkMode ? DarkColors.primaryLight : AppColors.primaryDark;
  }

  /// الحصول على لون السطح حسب الثيم
  static Color get surfaceColor {
    return isDarkMode ? DarkColors.surface : AppColors.surfaceLight;
  }

  /// الحصول على لون الخلفية حسب الثيم
  static Color get backgroundColor {
    return isDarkMode ? DarkColors.background : AppColors.background;
  }

  /// الحصول على لون النص حسب الثيم
  static Color get textColor {
    return isDarkMode ? DarkColors.onSurface : AppColors.onSurface;
  }

  /// الحصول على gradient أساسي حسب الثيم
  static LinearGradient get primaryGradient {
    return ThemeGradients.getPrimaryGradient(isDarkMode);
  }

  /// الحصول على gradient خفيف حسب الثيم
  static LinearGradient get subtleGradient {
    return ThemeGradients.getSubtleGradient(isDarkMode);
  }

  /// الحصول على gradient للـ headers
  static LinearGradient get headerGradient {
    return ThemeGradients.getHeaderGradient(isDarkMode);
  }

  /// الحصول على gradient للبطاقات
  static LinearGradient get cardGradient {
    return ThemeGradients.getCardGradient(isDarkMode);
  }

  // ============ INITIALIZATION & PERSISTENCE ============

  /// تهيئة Theme Manager
  static Future<void> initialize() async {
    await loadTheme();
  }

  /// تحميل إعدادات الـ Theme من التخزين المحلي
  static Future<void> loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(_themeKey) ?? 'system';

      // تطبيق الثيم المحفوظ
      ThemeMode themeMode;
      switch (savedTheme) {
        case 'light':
          themeMode = ThemeMode.light;
          break;
        case 'dark':
          themeMode = ThemeMode.dark;
          break;
        case 'system':
        default:
          themeMode = ThemeMode.system;
          break;
      }

      _themeModeNotifier.value = themeMode;
      debugPrint('🎨 Theme loaded: $savedTheme');
    } catch (e) {
      debugPrint('❌ Error loading theme: $e');
      // في حالة الخطأ، استخدم الثيم الافتراضي
      _themeModeNotifier.value = ThemeMode.system;
    }
  }

  /// حفظ إعدادات الـ Theme في التخزين المحلي
  static Future<void> _saveTheme(String theme) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, theme);
      debugPrint('💾 Theme saved: $theme');
    } catch (e) {
      debugPrint('❌ Error saving theme: $e');
    }
  }

  /// تغيير إلى المظهر الفاتح
  static Future<void> setLightMode() async {
    _themeModeNotifier.value = ThemeMode.light;
    await _saveTheme('light');
    debugPrint('☀️ Theme changed to: Light Mode');
  }

  /// تغيير إلى المظهر الداكن
  static Future<void> setDarkMode() async {
    _themeModeNotifier.value = ThemeMode.dark;
    await _saveTheme('dark');
    debugPrint('🌙 Theme changed to: Dark Mode');
  }

  /// تغيير إلى وضع النظام
  static Future<void> setSystemMode() async {
    _themeModeNotifier.value = ThemeMode.system;
    await _saveTheme('system');
    debugPrint('🔄 Theme changed to: System Mode');
  }

  /// تبديل بين المظاهر
  static Future<void> toggleTheme() async {
    if (isDarkMode) {
      await setLightMode();
    } else {
      await setDarkMode();
    }
  }

  /// تعيين المظهر بالنص
  static Future<void> setThemeMode(String mode) async {
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

  /// الحصول على نص المظهر الحالي
  static String get currentThemeString {
    switch (_themeModeNotifier.value) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  /// الحصول على اسم المظهر بالعربية
  static String get currentThemeDisplayName {
    switch (_themeModeNotifier.value) {
      case ThemeMode.light:
        return 'فاتح';
      case ThemeMode.dark:
        return 'داكن';
      case ThemeMode.system:
        return 'تلقائي';
    }
  }

  /// إضافة مستمع للتغييرات
  static void addListener(VoidCallback listener) {
    _themeModeNotifier.addListener(listener);
  }

  /// إزالة مستمع
  static void removeListener(VoidCallback listener) {
    _themeModeNotifier.removeListener(listener);
  }

  /// تنظيف الموارد
  static void dispose() {
    _themeModeNotifier.dispose();
  }
}

/// Widget للاستماع لتغييرات الـ Theme
class ThemeListener extends StatefulWidget {
  final Widget child;
  final VoidCallback? onThemeChanged;

  const ThemeListener({
    super.key,
    required this.child,
    this.onThemeChanged,
  });

  @override
  State<ThemeListener> createState() => _ThemeListenerState();
}

class _ThemeListenerState extends State<ThemeListener> {
  @override
  void initState() {
    super.initState();
    GlobalThemeManager.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    GlobalThemeManager.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    if (mounted) {
      setState(() {});
      widget.onThemeChanged?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
