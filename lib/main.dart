import 'package:achgate/core/app_router.dart';
import 'package:achgate/services/global_theme_manager.dart';
import 'package:achgate/services/language_manager.dart';
import 'package:achgate/generated/l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // تهيئة Theme Manager
  await GlobalThemeManager.initialize();

  // تهيئة Language Manager
  await LanguageManager.initialize();

  // Configure Google Fonts to use local assets as fallback
  GoogleFonts.config.allowRuntimeFetching = true;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // استخدام ValueListenableBuilder للاستماع لتغييرات المظهر واللغة
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: GlobalThemeManager.notifier,
      builder: (context, themeMode, _) {
        return ValueListenableBuilder<Locale>(
          valueListenable: LanguageManager.localeNotifier,
          builder: (context, locale, child) {
            return MaterialApp(
              title: 'تجمع جدة الصحي الثاني',
              debugShowCheckedModeBanner: false,

              // إعدادات التوطين
              locale: locale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: LanguageManager.supportedLocales,

              // استخدام الـ themes الجديدة
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,

              initialRoute: AppRouter.splash,
              onGenerateRoute: AppRouter.generateRoute,

              onUnknownRoute: (settings) {
                // Handle unknown routes more intelligently
                print('🔍 Unknown route: ${settings.name}');

                // If it's an admin route or admin-related, redirect to splash with admin context
                if (settings.name?.contains('admin') == true) {
                  return AppRouter.generateRoute(
                    const RouteSettings(name: AppRouter.splash),
                  );
                }

                // Otherwise redirect to splash
                return AppRouter.generateRoute(
                  const RouteSettings(name: AppRouter.splash),
                );
              },
            );
          },
        );
      },
    );
  }
}
