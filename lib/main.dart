import 'package:achgate/view/add_achievement_screen.dart';
import 'package:achgate/view/view_achievements_screen.dart';
import 'package:achgate/view/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
      routes: {
        '/add-achievement': (context) => const AddAchievementScreen(),
        '/view-achievements': (context) => const ViewAchievementsScreen(),
      },
      home: const SplashScreen(),
    );
  }
}
