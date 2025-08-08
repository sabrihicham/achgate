import 'package:flutter/material.dart';
import '../services/language_manager.dart';
import '../theme/app_colors.dart';

/// ودجة تبديل اللغات مع واجهة مستخدم أنيقة
class LanguageToggleWidget extends StatelessWidget {
  final bool showLabel;
  final bool isCompact;
  final EdgeInsetsGeometry? padding;
  final Function(Locale)? onLanguageChanged;

  const LanguageToggleWidget({
    super.key,
    this.showLabel = true,
    this.isCompact = false,
    this.padding,
    this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: LanguageManager.localeNotifier,
      builder: (context, currentLocale, child) {
        return Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primaryLight.withValues(alpha: 0.3),
            ),
          ),
          child: isCompact
              ? _buildCompactView(context, currentLocale)
              : _buildFullView(context, currentLocale),
        );
      },
    );
  }

  Widget _buildFullView(BuildContext context, Locale currentLocale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel) ...[
          Row(
            children: [
              Icon(
                Icons.language,
                color: AppColors.primaryDark,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                LanguageManager.isArabic ? 'اللغة' : 'Language',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryDark,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        Row(
          children: LanguageManager.supportedLocales.map((locale) {
            final isSelected = locale == currentLocale;
            final isArabic = locale.languageCode == 'ar';

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right:
                      locale == LanguageManager.supportedLocales.last ? 0 : 8,
                ),
                child: _buildLanguageOption(
                  context,
                  locale: locale,
                  flag: LanguageManager.getLanguageFlag(locale),
                  name: isArabic ? 'العربية' : 'English',
                  code: locale.languageCode.toUpperCase(),
                  isSelected: isSelected,
                  onTap: () => _changeLanguage(locale),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCompactView(BuildContext context, Locale currentLocale) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabel) ...[
          Icon(
            Icons.language,
            color: AppColors.primaryDark,
            size: 18,
          ),
          const SizedBox(width: 8),
        ],
        GestureDetector(
          onTap: () => _changeLanguage(LanguageManager.isArabic
              ? const Locale('en', 'US')
              : const Locale('ar', 'SA')),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.primaryLight.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  LanguageManager.getLanguageFlag(currentLocale),
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 4),
                Text(
                  currentLocale.languageCode.toUpperCase(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDark,
                      ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.swap_horiz,
                  size: 16,
                  color: AppColors.primaryDark,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageOption(
    BuildContext context, {
    required Locale locale,
    required String flag,
    required String name,
    required String code,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryDark : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryDark
                : AppColors.primaryLight.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              flag,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isSelected ? Colors.white : AppColors.primaryDark,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              code,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.8)
                        : AppColors.primaryDark.withValues(alpha: 0.6),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _changeLanguage(Locale locale) async {
    await LanguageManager.setLocale(locale);
    onLanguageChanged?.call(locale);
  }
}

/// قائمة منسدلة لتغيير اللغة
class LanguageDropdown extends StatelessWidget {
  final Function(Locale)? onLanguageChanged;
  final bool showFlags;

  const LanguageDropdown({
    super.key,
    this.onLanguageChanged,
    this.showFlags = true,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: LanguageManager.localeNotifier,
      builder: (context, currentLocale, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.primaryLight.withValues(alpha: 0.3),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<Locale>(
            value: currentLocale,
            underline: const SizedBox.shrink(),
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.primaryDark,
            ),
            items: LanguageManager.supportedLocales.map((locale) {
              final isArabic = locale.languageCode == 'ar';
              return DropdownMenuItem<Locale>(
                value: locale,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showFlags) ...[
                      Text(
                        LanguageManager.getLanguageFlag(locale),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      isArabic ? 'العربية' : 'English',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (Locale? newLocale) async {
              if (newLocale != null) {
                await LanguageManager.setLocale(newLocale);
                onLanguageChanged?.call(newLocale);
              }
            },
          ),
        );
      },
    );
  }
}

/// زر سريع لتبديل اللغة
class QuickLanguageSwitch extends StatelessWidget {
  final Function(Locale)? onLanguageChanged;

  const QuickLanguageSwitch({
    super.key,
    this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: LanguageManager.localeNotifier,
      builder: (context, currentLocale, child) {
        final nextLocale = LanguageManager.isArabic
            ? const Locale('en', 'US')
            : const Locale('ar', 'SA');

        return Tooltip(
          message: LanguageManager.isArabic
              ? 'تغيير إلى الإنجليزية'
              : 'Change to Arabic',
          child: InkWell(
            onTap: () async {
              await LanguageManager.toggleLanguage();
              onLanguageChanged?.call(nextLocale);
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    LanguageManager.getLanguageFlag(currentLocale),
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.swap_horiz,
                    size: 16,
                    color: AppColors.primaryDark,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    LanguageManager.getLanguageFlag(nextLocale),
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// مؤشر اللغة الحالية فقط للعرض
class LanguageIndicator extends StatelessWidget {
  final bool showName;
  final bool showFlag;
  final double? iconSize;

  const LanguageIndicator({
    super.key,
    this.showName = true,
    this.showFlag = true,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: LanguageManager.localeNotifier,
      builder: (context, currentLocale, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showFlag) ...[
              Text(
                LanguageManager.getLanguageFlag(currentLocale),
                style: TextStyle(fontSize: iconSize ?? 16),
              ),
              if (showName) const SizedBox(width: 4),
            ],
            if (showName)
              Text(
                LanguageManager.isArabic ? 'العربية' : 'English',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w500,
                    ),
              ),
          ],
        );
      },
    );
  }
}
