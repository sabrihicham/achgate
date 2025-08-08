import 'package:flutter/material.dart';
import '../services/language_manager.dart';
import '../widgets/language_widgets.dart';
import '../theme/app_colors.dart';

/// مثال على شاشة إعدادات اللغة المستقلة
class LanguageSettingsScreen extends StatelessWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            LanguageManager.isArabic ? 'إعدادات اللغة' : 'Language Settings'),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        actions: [
          // Quick language indicator in app bar
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: LanguageIndicator(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryDark,
                    AppColors.primaryMedium,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.language,
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              LanguageManager.isArabic
                                  ? 'إعدادات اللغة'
                                  : 'Language Settings',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              LanguageManager.isArabic
                                  ? 'اختر اللغة المفضلة لواجهة التطبيق'
                                  : 'Choose your preferred interface language',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Current Language Info
            _buildInfoCard(
              context,
              title: LanguageManager.isArabic
                  ? 'اللغة الحالية'
                  : 'Current Language',
              child: ValueListenableBuilder<Locale>(
                valueListenable: LanguageManager.localeNotifier,
                builder: (context, locale, child) {
                  return Row(
                    children: [
                      Text(
                        LanguageManager.getLanguageFlag(locale),
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            LanguageManager.isArabic
                                ? LanguageManager.getLanguageNameInArabic(
                                    locale)
                                : LanguageManager.getLanguageNameInEnglish(
                                    locale),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          Text(
                            '${locale.languageCode.toUpperCase()} - ${locale.countryCode}',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Language Selection
            _buildInfoCard(
              context,
              title:
                  LanguageManager.isArabic ? 'اختر اللغة' : 'Select Language',
              child: const LanguageToggleWidget(
                showLabel: false,
                padding: EdgeInsets.zero,
              ),
            ),

            const SizedBox(height: 24),

            // Quick Actions
            _buildInfoCard(
              context,
              title:
                  LanguageManager.isArabic ? 'إجراءات سريعة' : 'Quick Actions',
              child: Column(
                children: [
                  ListTile(
                    leading:
                        Icon(Icons.swap_horiz, color: AppColors.primaryDark),
                    title: Text(
                      LanguageManager.isArabic
                          ? 'تبديل اللغة'
                          : 'Toggle Language',
                    ),
                    subtitle: Text(
                      LanguageManager.isArabic
                          ? 'تبديل بين العربية والإنجليزية'
                          : 'Switch between Arabic and English',
                    ),
                    trailing: QuickLanguageSwitch(
                      onLanguageChanged: (locale) {
                        _showLanguageChangedSnackBar(context, locale);
                      },
                    ),
                    onTap: () async {
                      await LanguageManager.toggleLanguage();
                      _showLanguageChangedSnackBar(
                          context, LanguageManager.currentLocale);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(Icons.refresh, color: AppColors.primaryDark),
                    title: Text(
                      LanguageManager.isArabic
                          ? 'إعادة تعيين'
                          : 'Reset to Default',
                    ),
                    subtitle: Text(
                      LanguageManager.isArabic
                          ? 'العودة إلى اللغة الافتراضية (العربية)'
                          : 'Return to default language (Arabic)',
                    ),
                    onTap: () async {
                      await LanguageManager.resetToDefault();
                      _showLanguageChangedSnackBar(
                          context, LanguageManager.currentLocale);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Language Info
            _buildInfoCard(
              context,
              title: LanguageManager.isArabic
                  ? 'معلومات اللغات المدعومة'
                  : 'Supported Languages Info',
              child: Column(
                children: LanguageManager.supportedLocales.map((locale) {
                  final info = LanguageManager.getLanguageInfo(locale);
                  final isCurrentLanguage =
                      locale == LanguageManager.currentLocale;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isCurrentLanguage
                          ? AppColors.primaryLight.withValues(alpha: 0.1)
                          : Colors.grey.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isCurrentLanguage
                            ? AppColors.primaryLight
                            : Colors.grey.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          info['flag']!,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                info['name']!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: isCurrentLanguage
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                              ),
                              Text(
                                '${info['code']!.toUpperCase()} - ${info['direction']!.toUpperCase()}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                              ),
                            ],
                          ),
                        ),
                        if (isCurrentLanguage)
                          Icon(
                            Icons.check_circle,
                            color: AppColors.primaryDark,
                            size: 20,
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context,
      {required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryLight.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDark,
                ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  void _showLanguageChangedSnackBar(BuildContext context, Locale locale) {
    final message = LanguageManager.isArabic
        ? 'تم تغيير اللغة إلى ${LanguageManager.getLanguageNameInArabic(locale)}'
        : 'Language changed to ${LanguageManager.getLanguageNameInEnglish(locale)}';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(LanguageManager.getLanguageFlag(locale)),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.primaryDark,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: LanguageManager.isArabic ? 'تراجع' : 'Undo',
          textColor: Colors.white,
          onPressed: () {
            LanguageManager.toggleLanguage();
          },
        ),
      ),
    );
  }
}

/// مثال على ودجة بسيطة تعرض اللغة الحالية
class LanguageDisplayWidget extends StatelessWidget {
  const LanguageDisplayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: LanguageManager.localeNotifier,
      builder: (context, locale, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primaryLight.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                LanguageManager.getLanguageFlag(locale),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 6),
              Text(
                locale.languageCode.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// مثال على كيفية استخدام اللغات في الودجات المخصصة
class CustomLanguageAwareWidget extends StatelessWidget {
  final String arabicText;
  final String englishText;
  final IconData? icon;

  const CustomLanguageAwareWidget({
    super.key,
    required this.arabicText,
    required this.englishText,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: LanguageManager.localeNotifier,
      builder: (context, locale, child) {
        final isArabic = LanguageManager.isArabic;
        final text = isArabic ? arabicText : englishText;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryLight.withValues(alpha: 0.1),
                AppColors.primaryMedium.withValues(alpha: 0.05),
              ],
              begin: isArabic ? Alignment.topRight : Alignment.topLeft,
              end: isArabic ? Alignment.bottomLeft : Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primaryLight.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            textDirection: LanguageManager.currentDirection,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: AppColors.primaryDark,
                  size: 20,
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  text,
                  textDirection: LanguageManager.currentDirection,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primaryDark,
                      ),
                ),
              ),
              const SizedBox(width: 8),
              LanguageIndicator(
                showName: false,
                iconSize: 14,
              ),
            ],
          ),
        );
      },
    );
  }
}
