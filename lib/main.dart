import 'package:achgate/core/app_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Configure Google Fonts to use local assets as fallback
  GoogleFonts.config.allowRuntimeFetching = true;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'تجمع جدة الصحي الثاني',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
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
  }
}
