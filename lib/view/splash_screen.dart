import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/app_router.dart';
import '../services/admin_auth_service.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;

  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Initialize animations
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );



    // Start animations
    _startAnimations();

    // Navigate after splash
    _navigateAfterSplash();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _fadeController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    _scaleController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    _slideController.forward();
  }

  void _navigateAfterSplash() async {
    await Future.delayed(const Duration(milliseconds: 3000));

    if (mounted) {
      // Get the current route from ModalRoute
      final currentRoute = ModalRoute.of(context)?.settings.name;
      final user = FirebaseAuth.instance.currentUser;
      final adminAuthService = AdminAuthService();

      print('🔍 Current route: $currentRoute');
      print('🔍 User authenticated: ${user != null}');

      // Check if user is trying to access admin route
      if (currentRoute == '/admin' || currentRoute == AppRouter.admin) {
        print('🔍 Admin route detected');
        // For admin route, check if user is authenticated and has admin privileges
        if (user != null) {
          // Check if user has admin privileges
          final isAdmin = await adminAuthService.isAdminLoggedIn();
          print('🔍 Is admin logged in: $isAdmin');
          
          if (isAdmin) {
            // User is authenticated admin, navigate to admin dashboard
            Navigator.of(context).pushReplacementNamed(AppRouter.admin);
          } else {
            // User is authenticated but not admin, redirect to admin login
            Navigator.of(context).pushReplacementNamed(AppRouter.adminLogin);
          }
        } else {
          // Not authenticated, redirect to admin login
          Navigator.of(context).pushReplacementNamed(AppRouter.adminLogin);
        }
      } else {
        // Regular navigation logic - but first check if user is admin and should go to admin dashboard
        if (user != null) {
          // Check if this user is an admin
          final isAdmin = await adminAuthService.isAdminLoggedIn();
          print('🔍 Regular route but user is admin: $isAdmin');
          
          if (isAdmin) {
            // Admin user accessing regular route, keep them in admin dashboard
            Navigator.of(context).pushReplacementNamed(AppRouter.admin);
          } else {
            // Regular user, go to home
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) {
                  return const HomeScreen();
                },
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
                transitionDuration: const Duration(milliseconds: 300),
              ),
            );
          }
        } else {
          // Not authenticated, go to login
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) {
                return const LoginScreen();
              },
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 300),
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isWeb = screenSize.width > 600;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF15508A), // Primary dark
              Color(0xFF2E7CC4), // Primary medium
              Color(0xFF6BB6FF), // Primary light
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top spacer
              const Spacer(flex: 2),

              // Main content
              Expanded(
                flex: 6,
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isWeb ? 400 : screenSize.width * 0.8,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Portal Logo (Platform logo)
                        Image.asset(
                          'assets/images/portal_logo_white.png',
                          // width: isWeb ? 120 : screenSize.width * 0.9,
                          // height: isWeb ? 120 : screenSize.width * 0.9,
                          fit: BoxFit.cover,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Loading indicator
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 40),
                      child: Column(
                        children: [
                          const SizedBox(
                            width: 30,
                            height: 30,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'جاري التحميل...',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // Clustering Logo (Jeddah Health Cluster logo)
              Image.asset(
                'assets/images/clustring_logo_white.png',
                width: isWeb ? 200 : screenSize.width * 0.5,
                height: isWeb ? 80 : screenSize.width * 0.2,
                fit: BoxFit.contain,
              ),

              // Bottom spacer
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
