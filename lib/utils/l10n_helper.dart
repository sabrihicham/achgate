import 'package:flutter/material.dart';

/// Extension لتسهيل الوصول للترجمات
extension BuildContextLocalization on BuildContext {
  /// الحصول على كائن الترجمات
  AppLocalizations get l10n => AppLocalizations.of(this)!;

  /// الحصول على اللغة الحالية
  Locale get locale => Localizations.localeOf(this);

  /// تحديد ما إذا كانت اللغة الحالية عربية
  bool get isArabic => locale.languageCode == 'ar';

  /// تحديد ما إذا كانت اللغة الحالية إنجليزية
  bool get isEnglish => locale.languageCode == 'en';

  /// تحديد اتجاه النص
  TextDirection get textDirection => Directionality.of(this);

  /// تحديد ما إذا كان الاتجاه RTL
  bool get isRTL => textDirection == TextDirection.rtl;

  /// تحديد ما إذا كان الاتجاه LTR
  bool get isLTR => textDirection == TextDirection.ltr;
}

/// كلاس مساعد للترجمات
class AppLocalizations extends StatelessWidget {
  const AppLocalizations({super.key});

  @override
  Widget build(BuildContext context) {
    // هذا مجرد placeholder، الكلاس الحقيقي سيتم توليده تلقائياً
    return const SizedBox.shrink();
  }

  /// الحصول على كائن الترجمات (سيتم استبداله بالكود المولد)
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }
}

/// مساعدات إضافية للترجمة
class L10nHelper {
  /// تنسيق الأرقام حسب اللغة
  static String formatNumber(BuildContext context, num number) {
    final locale = context.locale;
    if (locale.languageCode == 'ar') {
      // استخدام الأرقام العربية الهندية إذا رغبت
      return number.toString();
    }
    return number.toString();
  }

  /// تنسيق العملة
  static String formatCurrency(BuildContext context, double amount) {
    final locale = context.locale;
    if (locale.languageCode == 'ar') {
      return '${amount.toStringAsFixed(2)} ريال';
    } else {
      return 'SAR ${amount.toStringAsFixed(2)}';
    }
  }

  /// تنسيق التاريخ حسب اللغة
  static String formatDate(BuildContext context, DateTime date) {
    final locale = context.locale;
    if (locale.languageCode == 'ar') {
      return '${date.day}/${date.month}/${date.year}';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }

  /// تنسيق الوقت
  static String formatTime(BuildContext context, TimeOfDay time) {
    final locale = context.locale;
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am
        ? (locale.languageCode == 'ar' ? 'ص' : 'AM')
        : (locale.languageCode == 'ar' ? 'م' : 'PM');

    return '$hour:$minute $period';
  }

  /// الحصول على اسم الشهر
  static String getMonthName(BuildContext context, int month) {
    final locale = context.locale;

    final arabicMonths = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر'
    ];

    final englishMonths = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    if (month < 1 || month > 12) return '';

    return locale.languageCode == 'ar'
        ? arabicMonths[month - 1]
        : englishMonths[month - 1];
  }

  /// الحصول على اسم اليوم
  static String getDayName(BuildContext context, int weekday) {
    final locale = context.locale;

    final arabicDays = [
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد'
    ];

    final englishDays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    if (weekday < 1 || weekday > 7) return '';

    return locale.languageCode == 'ar'
        ? arabicDays[weekday - 1]
        : englishDays[weekday - 1];
  }

  /// تحويل الأرقام للعربية الهندية (اختياري)
  static String toArabicNumerals(String input) {
    const english = '0123456789';
    const arabic = '٠١٢٣٤٥٦٧٨٩';

    String output = input;
    for (int i = 0; i < english.length; i++) {
      output = output.replaceAll(english[i], arabic[i]);
    }
    return output;
  }

  /// تحويل الأرقام للإنجليزية
  static String toEnglishNumerals(String input) {
    const arabic = '٠١٢٣٤٥٦٧٨٩';
    const english = '0123456789';

    String output = input;
    for (int i = 0; i < arabic.length; i++) {
      output = output.replaceAll(arabic[i], english[i]);
    }
    return output;
  }
}
