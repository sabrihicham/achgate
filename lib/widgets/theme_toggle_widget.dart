import 'package:flutter/material.dart';
import '../services/global_theme_manager.dart';

/// Widget لتبديل الـ Theme في أي مكان في التطبيق
class ThemeToggleWidget extends StatefulWidget {
  final bool showLabel;
  final bool isCompact;
  final VoidCallback? onThemeChanged;

  const ThemeToggleWidget({
    super.key,
    this.showLabel = true,
    this.isCompact = false,
    this.onThemeChanged,
  });

  @override
  State<ThemeToggleWidget> createState() => _ThemeToggleWidgetState();
}

class _ThemeToggleWidgetState extends State<ThemeToggleWidget> {
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
    if (widget.isCompact) {
      return GestureDetector(
        onTap: () async {
          await GlobalThemeManager.toggleTheme();
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            border: Border.all(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Icon(
            GlobalThemeManager.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.all(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).cardColor,
        ),
        child: Row(
          children: [
            Icon(
              GlobalThemeManager.isDarkMode
                  ? Icons.dark_mode
                  : Icons.light_mode,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            if (widget.showLabel) ...[
              const SizedBox(width: 12),
              Text(
                GlobalThemeManager.currentThemeDisplayName,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
            const Spacer(),
            Switch(
              value: GlobalThemeManager.isDarkMode,
              onChanged: (_) async {
                await GlobalThemeManager.toggleTheme();
              },
              activeColor: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

/// Theme Selector Widget - اختيار متقدم للـ Theme
class ThemeSelector extends StatefulWidget {
  final VoidCallback? onThemeChanged;

  const ThemeSelector({
    super.key,
    this.onThemeChanged,
  });

  @override
  State<ThemeSelector> createState() => _ThemeSelectorState();
}

class _ThemeSelectorState extends State<ThemeSelector> {
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
    return Card(
      margin: const EdgeInsets.all(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.palette,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'نمط المظهر',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildThemeOption(
              ThemeMode.light,
              'المظهر الفاتح',
              'مناسب للاستخدام النهاري',
              Icons.light_mode,
            ),
            _buildThemeOption(
              ThemeMode.dark,
              'المظهر الداكن',
              'مريح للعين في الإضاءة المنخفضة',
              Icons.dark_mode,
            ),
            _buildThemeOption(
              ThemeMode.system,
              'تلقائي',
              'يتبع إعدادات النظام',
              Icons.brightness_auto,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    ThemeMode mode,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final isSelected = GlobalThemeManager.themeMode == mode;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        borderRadius: BorderRadius.circular(8),
        color: isSelected
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () async {
            switch (mode) {
              case ThemeMode.light:
                await GlobalThemeManager.setLightMode();
                break;
              case ThemeMode.dark:
                await GlobalThemeManager.setDarkMode();
                break;
              case ThemeMode.system:
                await GlobalThemeManager.setSystemMode();
                break;
            }
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: isSelected
                  ? Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    )
                  : Border.all(
                      color: Theme.of(context).dividerColor,
                    ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).iconTheme.color,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                            ),
                      ),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.color
                                  ?.withValues(alpha: 0.7),
                            ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Floating Theme Toggle - زر عائم للتبديل السريع
class FloatingThemeToggle extends StatefulWidget {
  final VoidCallback? onThemeChanged;

  const FloatingThemeToggle({
    super.key,
    this.onThemeChanged,
  });

  @override
  State<FloatingThemeToggle> createState() => _FloatingThemeToggleState();
}

class _FloatingThemeToggleState extends State<FloatingThemeToggle> {
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
    return FloatingActionButton(
      mini: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      foregroundColor: Theme.of(context).colorScheme.primary,
      onPressed: () => _showThemeBottomSheet(context),
      child: Icon(
        GlobalThemeManager.isDarkMode ? Icons.dark_mode : Icons.light_mode,
      ),
    );
  }

  void _showThemeBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'اختيار المظهر',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            ThemeSelector(onThemeChanged: widget.onThemeChanged),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
