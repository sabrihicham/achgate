import 'package:achgate/view/admin_dashboard_screen.dart';
import 'package:flutter/material.dart';
import '../view/splash_screen.dart';
import '../view/login_screen.dart';
import '../view/admin_login_screen.dart';
import '../view/home_screen.dart';
import '../view/view_achievements_screen.dart';
import '../view/admin_setup_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String adminLogin = '/admin-login';
  static const String home = '/home';
  static const String viewAchievements = '/view-achievements';
  static const String admin = '/admin';
  static const String adminSetup = '/admin-setup';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _createRoute(const SplashScreen(), settings);

      case login:
        return _createRoute(const LoginScreen(), settings);

      case adminLogin:
        return _createRoute(const AdminLoginScreen(), settings);

      case home:
        return _createRoute(const HomeScreen(), settings);

      case viewAchievements:
        return _createRoute(const ViewAchievementsScreen(), settings);

      case admin:
        return _createRoute(const AdminDashboardScreen(), settings);

      case adminSetup:
        return _createRoute(const AdminSetupScreen(), settings);

      default:
        return _createRoute(const SplashScreen(), settings);
    }
  }

  static PageRoute _createRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  static void navigateToAdmin(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(admin, (route) => false);
  }

  static void navigateToAdminLogin(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(adminLogin, (route) => false);
  }

  static void navigateToHome(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(home, (route) => false);
  }

  static void navigateToLogin(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(login, (route) => false);
  }

  static void navigateToAdminSetup(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(adminSetup, (route) => false);
  }

  // Helper method to check if route is admin route
  static bool isAdminRoute(String? routeName) {
    return routeName == admin;
  }

  // Helper method to get route title
  static String getRouteTitle(String? routeName) {
    switch (routeName) {
      case splash:
        return 'تجمع جدة الصحي الثاني';
      case login:
        return 'تسجيل الدخول';
      case adminLogin:
        return 'دخول لوحة التحكم';
      case home:
        return 'الصفحة الرئيسية';
      case viewAchievements:
        return 'عرض المنجزات';
      case admin:
        return 'لوحة التحكم الإدارية';
      case adminSetup:
        return 'إعداد صلاحيات الأدمين';
      default:
        return 'تجمع جدة الصحي الثاني';
    }
  }
}
