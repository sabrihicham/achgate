import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// خدمة إدارة اللغات الشاملة للتطبيق
///
/// تدعم هذه الخدمة:
/// - العربية (افتراضية مع RTL)
/// - الإنجليزية (مع LTR)
/// - حفظ واسترداد اختيار المستخدم
/// - تحديث فوري للواجهة
/// - دعم جميع المنصات
class LanguageManager {
  static const String _languageKey = 'selected_language';
  static const String _directionKey = 'text_direction';

  // اللغات المدعومة
  static const List<Locale> supportedLocales = [
    Locale('ar', 'SA'), // العربية - السعودية
    Locale('en', 'US'), // الإنجليزية - أمريكا
  ];

  // اللغة الافتراضية
  static const Locale defaultLocale = Locale('ar', 'SA');

  // Notifiers للتحديث الفوري
  static final ValueNotifier<Locale> _localeNotifier =
      ValueNotifier<Locale>(defaultLocale);
  static final ValueNotifier<TextDirection> _directionNotifier =
      ValueNotifier<TextDirection>(TextDirection.rtl);

  // Getters للوصول للحالة الحالية
  static ValueNotifier<Locale> get localeNotifier => _localeNotifier;
  static ValueNotifier<TextDirection> get directionNotifier =>
      _directionNotifier;

  static Locale get currentLocale => _localeNotifier.value;
  static TextDirection get currentDirection => _directionNotifier.value;
  static bool get isArabic => currentLocale.languageCode == 'ar';
  static bool get isEnglish => currentLocale.languageCode == 'en';
  static bool get isRTL => currentDirection == TextDirection.rtl;
  static bool get isLTR => currentDirection == TextDirection.ltr;

  /// تهيئة مدير اللغات
  static Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // استرداد اللغة المحفوظة
      final savedLanguage = prefs.getString(_languageKey);
      final savedDirection = prefs.getString(_directionKey);

      if (savedLanguage != null) {
        final locale = _localeFromString(savedLanguage);
        _localeNotifier.value = locale;

        // تحديد الاتجاه المحفوظ أو الافتراضي
        if (savedDirection != null) {
          _directionNotifier.value =
              savedDirection == 'rtl' ? TextDirection.rtl : TextDirection.ltr;
        } else {
          _directionNotifier.value = _getDirectionForLocale(locale);
        }
      } else {
        // إذا لم تكن هناك لغة محفوظة، استخدم لغة النظام إن أمكن
        final systemLocale = _getSystemLocale();
        await setLocale(systemLocale);
      }

      debugPrint(
          '🌐 Language Manager initialized: ${currentLocale.toString()}');
      debugPrint('📄 Text Direction: ${currentDirection.name}');
    } catch (e) {
      debugPrint('❌ Error initializing Language Manager: $e');
      // في حالة الخطأ، استخدم الإعدادات الافتراضية
      _localeNotifier.value = defaultLocale;
      _directionNotifier.value = TextDirection.rtl;
    }
  }

  /// تغيير اللغة
  static Future<void> setLocale(Locale locale) async {
    try {
      if (!supportedLocales.contains(locale)) {
        debugPrint('⚠️ Unsupported locale: $locale, using default');
        locale = defaultLocale;
      }

      final prefs = await SharedPreferences.getInstance();
      final direction = _getDirectionForLocale(locale);

      // حفظ الإعدادات
      await prefs.setString(_languageKey, locale.toString());
      await prefs.setString(_directionKey, direction.name);

      // تحديث الحالة
      _localeNotifier.value = locale;
      _directionNotifier.value = direction;

      debugPrint('🌐 Language changed to: ${locale.toString()}');
      debugPrint('📄 Text Direction: ${direction.name}');
    } catch (e) {
      debugPrint('❌ Error setting locale: $e');
    }
  }

  /// تغيير إلى العربية
  static Future<void> setArabic() async {
    await setLocale(const Locale('ar', 'SA'));
  }

  /// تغيير إلى الإنجليزية
  static Future<void> setEnglish() async {
    await setLocale(const Locale('en', 'US'));
  }

  /// تبديل اللغة بين العربية والإنجليزية
  static Future<void> toggleLanguage() async {
    if (isArabic) {
      await setEnglish();
    } else {
      await setArabic();
    }
  }

  /// إعادة تعيين إلى اللغة الافتراضية
  static Future<void> resetToDefault() async {
    await setLocale(defaultLocale);
  }

  /// الحصول على اسم اللغة بالعربية
  static String getLanguageNameInArabic(Locale locale) {
    switch (locale.languageCode) {
      case 'ar':
        return 'العربية';
      case 'en':
        return 'الإنجليزية';
      default:
        return 'غير معروف';
    }
  }

  /// الحصول على اسم اللغة بالإنجليزية
  static String getLanguageNameInEnglish(Locale locale) {
    switch (locale.languageCode) {
      case 'ar':
        return 'Arabic';
      case 'en':
        return 'English';
      default:
        return 'Unknown';
    }
  }

  /// الحصول على اسم اللغة الحالية
  static String getCurrentLanguageName() {
    return isArabic
        ? getLanguageNameInArabic(currentLocale)
        : getLanguageNameInEnglish(currentLocale);
  }

  /// الحصول على رمز اللغة للعرض
  static String getLanguageFlag(Locale locale) {
    switch (locale.languageCode) {
      case 'ar':
        return '🇸🇦';
      case 'en':
        return '🇺🇸';
      default:
        return '🌐';
    }
  }

  /// إضافة مستمع للتغييرات
  static void addLocaleListener(VoidCallback listener) {
    _localeNotifier.addListener(listener);
  }

  /// إضافة مستمع لتغييرات الاتجاه
  static void addDirectionListener(VoidCallback listener) {
    _directionNotifier.addListener(listener);
  }

  /// إزالة مستمع اللغة
  static void removeLocaleListener(VoidCallback listener) {
    _localeNotifier.removeListener(listener);
  }

  /// إزالة مستمع الاتجاه
  static void removeDirectionListener(VoidCallback listener) {
    _directionNotifier.removeListener(listener);
  }

  /// تنظيف الموارد
  static void dispose() {
    _localeNotifier.dispose();
    _directionNotifier.dispose();
  }

  /// الحصول على اتجاه النص للغة
  static TextDirection _getDirectionForLocale(Locale locale) {
    switch (locale.languageCode) {
      case 'ar':
      case 'he':
      case 'fa':
      case 'ur':
        return TextDirection.rtl;
      default:
        return TextDirection.ltr;
    }
  }

  /// تحويل نص إلى Locale
  static Locale _localeFromString(String localeString) {
    final parts = localeString.split('_');
    if (parts.length >= 2) {
      return Locale(parts[0], parts[1]);
    } else {
      return Locale(parts[0]);
    }
  }

  /// الحصول على لغة النظام
  static Locale _getSystemLocale() {
    try {
      final systemLocale = PlatformDispatcher.instance.locale;

      // تحقق إذا كانت لغة النظام مدعومة
      final supported = supportedLocales.firstWhere(
        (locale) => locale.languageCode == systemLocale.languageCode,
        orElse: () => defaultLocale,
      );

      return supported;
    } catch (e) {
      debugPrint('⚠️ Could not get system locale: $e');
      return defaultLocale;
    }
  }

  /// الحصول على معلومات اللغة للعرض
  static Map<String, String> getLanguageInfo(Locale locale) {
    return {
      'code': locale.languageCode,
      'name': isArabic
          ? getLanguageNameInArabic(locale)
          : getLanguageNameInEnglish(locale),
      'nativeName': getLanguageNameInArabic(locale),
      'flag': getLanguageFlag(locale),
      'direction': _getDirectionForLocale(locale).name,
    };
  }

  /// الحصول على جميع اللغات المدعومة مع معلوماتها
  static List<Map<String, String>> getAllSupportedLanguages() {
    return supportedLocales.map((locale) => getLanguageInfo(locale)).toList();
  }

  /// تحديد ما إذا كانت اللغة تحتاج إلى خط خاص
  static bool needsSpecialFont(Locale locale) {
    switch (locale.languageCode) {
      case 'ar':
      case 'fa':
      case 'ur':
        return true;
      default:
        return false;
    }
  }

  /// الحصول على اسم الخط المناسب للغة
  static String getFontFamily(Locale locale) {
    if (needsSpecialFont(locale)) {
      return 'Cairo'; // خط Cairo للعربية
    } else {
      return 'Inter'; // خط Inter للإنجليزية
    }
  }
}
