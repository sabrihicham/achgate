import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_components.dart';
import '../services/admin_service.dart';
import '../services/auth_service.dart';
import '../services/admin_auth_service.dart';
import '../services/global_theme_manager.dart';
import '../services/language_manager.dart';
import '../core/app_router.dart';
import '../models/achievement.dart';
import '../widgets/users_management_widget.dart';
import '../widgets/charts_widget.dart';
import '../widgets/language_widgets.dart';
import '../generated/l10n/app_localizations.dart';
import 'login_screen.dart';
import 'edit_achievement_screen.dart';
import 'profile_demo_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with TickerProviderStateMixin {
  final AdminService _adminService = AdminService();
  final AuthService _authService = AuthService();
  final AdminAuthService _adminAuthService = AdminAuthService();

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int _selectedSidebarIndex = 0;
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  bool _isLoading = true;
  bool _isAdmin = false;
  final List<Achievement> _achievements = [];
  final List<Achievement> _pendingAchievements = [];

  // Theme-aware color helpers - Legacy getters for backward compatibility
  Color get successColor =>
      GlobalThemeManager.isDarkMode ? DarkColors.success : AppColors.success;
  Color get warningColor =>
      GlobalThemeManager.isDarkMode ? DarkColors.warning : AppColors.warning;
  Color get errorColor =>
      GlobalThemeManager.isDarkMode ? DarkColors.error : AppColors.error;

  final List<Map<String, dynamic>> _sidebarItems = [
    {
      'icon': Icons.dashboard_outlined,
      'activeIcon': Icons.dashboard,
      'titleKey': 'mainDashboard',
      'index': 0,
    },
    {
      'icon': Icons.pending_actions_outlined,
      'activeIcon': Icons.pending_actions,
      'titleKey': 'quickReview',
      'index': 1,
    },
    {
      'icon': Icons.assignment_outlined,
      'activeIcon': Icons.assignment,
      'titleKey': 'achievementsManagement',
      'index': 2,
    },
    {
      'icon': Icons.people_outline,
      'activeIcon': Icons.people,
      'titleKey': 'usersManagement',
      'index': 3,
    },
    {
      'icon': Icons.analytics_outlined,
      'activeIcon': Icons.analytics,
      'titleKey': 'reportsAndAnalytics',
      'index': 4,
    },
    {
      'icon': Icons.settings_outlined,
      'activeIcon': Icons.settings,
      'titleKey': 'adminSettings',
      'index': 5,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeTheme();
    _setupThemeListener();
    // _scrollController.addListener(_onScroll);
    _checkAdminAccess();
  }

  void _setupThemeListener() {
    GlobalThemeManager.addListener(() {
      if (mounted) {
        setState(() {
          // تحديث الواجهة عند تغيير الثيم
        });
      }
    });
  }

  void _initializeTheme() async {
    await GlobalThemeManager.initialize();
    if (mounted) {
      setState(() {
        // تحديث الواجهة بعد تهيئة الثيم
      });
    }
  }

  /// تغيير الثيم مع تحديث فوري للواجهة
  Future<void> _changeTheme(String themeMode) async {
    try {
      // عرض مؤشر التحميل للويب
      if (!mounted) return;

      // تطبيق الثيم الجديد
      await GlobalThemeManager.setThemeMode(themeMode);

      // تحديث الواجهة فوراً
      if (mounted) {
        setState(() {
          // إعادة بناء الواجهة مع الثيم الجديد
        });

        // إظهار رسالة نجاح
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم تغيير المظهر إلى ${_getThemeDisplayName(themeMode)}',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تغيير المظهر: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// الحصول على اسم الثيم بالعربية
  String _getThemeDisplayName(String themeMode) {
    switch (themeMode) {
      case 'light':
        return 'الفاتح';
      case 'dark':
        return 'الداكن';
      case 'system':
        return 'التلقائي';
      default:
        return 'غير معروف';
    }
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    // Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  // void _onScroll() {
  //   final isScrolled = _scrollController.offset > 50;
  //   if (isScrolled != _isScrolled) {
  //     setState(() {
  //       _isScrolled = isScrolled;
  //     });
  //   }
  // }

  void _onSidebarItemTap(int index) {
    setState(() {
      _selectedSidebarIndex = index;
    });
  }

  Future<void> _checkAdminAccess() async {
    try {
      // Use AdminAuthService for more reliable admin checking
      final isAdmin = await _adminAuthService.isAdminLoggedIn();
      print('🔍 Admin check result: $isAdmin');

      if (!isAdmin) {
        print('❌ User is not admin, redirecting to admin login');
        if (mounted) {
          // Redirect to admin login instead of regular login
          AppRouter.navigateToAdminLogin(context);
        }
        return;
      }

      // User is admin, load admin data
      await _adminService.getUsersStatistics();
      setState(() {
        _isAdmin = true;
        _isLoading = false;
      });
      print('✅ Admin access confirmed, dashboard loaded');
    } catch (e) {
      print('❌ Error checking admin access: $e');
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        // On error, redirect to admin login
        AppRouter.navigateToAdminLogin(context);
      }
    }
  }

  // Helper methods for actions
  void _approveAchievement(String id) async {
    try {
      await _adminService.updateAchievementStatus(id, 'approved');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم اعتماد المنجز بنجاح'),
            backgroundColor: successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في اعتماد المنجز: $e'),
            backgroundColor: errorColor,
          ),
        );
      }
    }
  }

  void _rejectAchievement(String id) async {
    try {
      await _adminService.updateAchievementStatus(id, 'rejected');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم رفض المنجز'),
            backgroundColor: errorColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في رفض المنجز: $e'),
            backgroundColor: errorColor,
          ),
        );
      }
    }
  }

  void _deleteAchievement(String id) async {
    try {
      await _adminService.deleteAchievement(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم حذف المنجز بنجاح'),
            backgroundColor: successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في حذف المنجز: $e'),
            backgroundColor: errorColor,
          ),
        );
      }
    }
  }

  // Responsive design helpers
  bool _isDesktop() => MediaQuery.of(context).size.width > 1024;
  bool _isTablet() =>
      MediaQuery.of(context).size.width >= 768 &&
      MediaQuery.of(context).size.width <= 1024;

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 1024;
    final isTablet = screenSize.width > 768 && screenSize.width <= 1024;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: GlobalThemeManager.isDarkMode
            ? DarkColors.background
            : AppColors.surfaceLight,
        body: Center(
          child: AppComponents.loadingIndicator(
            message: 'جارٍ التحقق من الصلاحيات...',
          ),
        ),
      );
    }

    if (!_isAdmin) {
      return const Scaffold(
        body: Center(
          child: Text(
            'ليس لديك صلاحية للوصول إلى لوحة التحكم',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    if (isDesktop) {
      return _buildWebDesktopLayout();
    } else if (isTablet) {
      return _buildTabletLayout();
    } else {
      return _buildMobileLayout();
    }
  }

  Widget _buildWebDesktopLayout() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Row(
          children: [
            // Sidebar Navigation
            _buildSidebar(),
            // Main Content Area
            Expanded(
              child: Column(
                children: [
                  _buildAppBar(),
                  // Main Content
                  Expanded(child: _buildMainContent()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            width: 280,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: GlobalThemeManager.isDarkMode
                    ? [
                        DarkColors.primaryDark,
                        DarkColors.primaryMedium,
                        DarkColors.primaryLight.withValues(alpha: 0.8),
                      ]
                    : [
                        AppColors.primaryDark,
                        AppColors.primaryMedium,
                        AppColors.primaryLight.withValues(alpha: 0.8),
                      ],
              ),
              boxShadow: [
                BoxShadow(
                  color: (GlobalThemeManager.isDarkMode
                          ? DarkColors.primaryDark
                          : AppColors.primaryDark)
                      .withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                // Logo Section
                _buildSidebarHeader(),
                SizedBox(height: 40),
                // Navigation Items
                Expanded(child: _buildSidebarNavigation()),
                // User Profile Section
                _buildSidebarFooter(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSidebarHeader() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          // Animated Logo
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.admin_panel_settings,
              size: 40,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.portalAdministration,
            style: AppTypography.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.healthCluster,
            style: AppTypography.textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarNavigation() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _sidebarItems.length,
      itemBuilder: (context, index) {
        final item = _sidebarItems[index];
        final isSelected = _selectedSidebarIndex == index;

        return AnimatedBuilder(
          animation: _slideAnimation,
          builder: (context, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-1.0, 0.0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: _slideController,
                  curve: Interval(
                    index * 0.1,
                    1.0,
                    curve: Curves.easeOutCubic,
                  ),
                ),
              ),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _onSidebarItemTap(index),
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected
                            ? Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1,
                              )
                            : null,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected ? item['activeIcon'] : item['icon'],
                            color: Colors.white,
                            size: 24,
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              _getLocalizedTitle(item['titleKey']),
                              style:
                                  AppTypography.textTheme.bodyLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAppBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      height: MediaQuery.of(context).size.height * 0.2,
      decoration: BoxDecoration(
        gradient: _isScrolled
            ? LinearGradient(
                colors: GlobalThemeManager.isDarkMode
                    ? [
                        DarkColors.surface.withValues(alpha: 0.98),
                        DarkColors.surface.withValues(alpha: 0.95),
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.98),
                        Colors.white.withValues(alpha: 0.95),
                      ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: GlobalThemeManager.isDarkMode
                    ? [
                        DarkColors.primaryDark.withValues(alpha: 0.95),
                        DarkColors.primaryMedium.withValues(alpha: 0.90),
                        DarkColors.primaryLight.withValues(alpha: 0.85),
                      ]
                    : [
                        AppColors.primaryDark.withValues(alpha: 0.95),
                        AppColors.primaryMedium.withValues(alpha: 0.90),
                        AppColors.primaryLight.withValues(alpha: 0.85),
                      ],
                stops: const [0.0, 0.6, 1.0],
              ),
        boxShadow: _isScrolled
            ? [
                BoxShadow(
                  color: (GlobalThemeManager.isDarkMode
                          ? DarkColors.primaryDark
                          : AppColors.primaryDark)
                      .withValues(alpha: 0.15),
                  blurRadius: 25,
                  offset: const Offset(0, 8),
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: (GlobalThemeManager.isDarkMode
                          ? DarkColors.primaryDark
                          : AppColors.primaryDark)
                      .withValues(alpha: 0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                  spreadRadius: 3,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
        border: _isScrolled
            ? Border.all(
                color: (GlobalThemeManager.isDarkMode
                        ? DarkColors.primaryLight
                        : AppColors.primaryLight)
                    .withValues(alpha: 0.3),
                width: 1.5,
              )
            : Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _getPageTitle(),
                      style: AppTypography.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _isScrolled
                            ? (GlobalThemeManager.isDarkMode
                                ? DarkColors.onSurface
                                : AppColors.primaryDark)
                            : Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      _getPageSubtitle(),
                      style: AppTypography.textTheme.bodyLarge?.copyWith(
                        color: _isScrolled
                            ? (GlobalThemeManager.isDarkMode
                                ? DarkColors.onSurfaceVariant
                                : AppColors.primaryDark.withValues(alpha: 0.7))
                            : Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              // Action Buttons
              Row(
                children: [
                  _buildModernAppBarButton(
                    icon: Icons.refresh,
                    onPressed: () => _refreshData(),
                    tooltip: AppLocalizations.of(context)!.refreshData,
                  ),
                  SizedBox(width: 12),
                  // Language Switch Button
                  Tooltip(
                    message: LanguageManager.isArabic
                        ? 'تغيير إلى الإنجليزية'
                        : 'Change to Arabic',
                    child: QuickLanguageSwitch(
                      onLanguageChanged: (locale) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              LanguageManager.isArabic
                                  ? 'تم تغيير اللغة إلى ${LanguageManager.getLanguageNameInArabic(locale)}'
                                  : 'Language changed to ${LanguageManager.getLanguageNameInEnglish(locale)}',
                            ),
                            backgroundColor: AppColors.primaryDark,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 12),
                  _buildModernAppBarButton(
                    icon: Icons.notifications_outlined,
                    onPressed: () {},
                    tooltip: 'الإشعارات',
                    hasNotification: true,
                  ),
                  SizedBox(width: 12),
                  _buildModernAppBarButton(
                    icon: Icons.account_circle_outlined,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ProfileDemoScreen(),
                        ),
                      );
                    },
                    tooltip: 'الملف الشخصي',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernAppBarButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    bool hasNotification = false,
  }) {
    return Tooltip(
      message: tooltip,
      preferBelow: false,
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryDark.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(18),
              splashColor: _isScrolled
                  ? AppColors.primaryLight.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.3),
              hoverColor: _isScrolled
                  ? AppColors.primaryLight.withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: _isScrolled
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.white.withValues(alpha: 0.15),
                  border: Border.all(
                    color: _isScrolled
                        ? AppColors.primaryLight.withValues(alpha: 0.3)
                        : Colors.white.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  icon,
                  color: _isScrolled ? AppColors.primaryDark : Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
          // Notification badge if needed
          if (hasNotification)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getPageTitle() {
    final localizations = AppLocalizations.of(context)!;
    switch (_selectedSidebarIndex) {
      case 0:
        return localizations.mainDashboard;
      case 1:
        return localizations.quickReview;
      case 2:
        return localizations.achievementsManagement;
      case 3:
        return localizations.usersManagement;
      case 4:
        return localizations.reportsAndAnalytics;
      case 5:
        return localizations.adminSettings;
      default:
        return localizations.mainDashboard;
    }
  }

  String _getPageSubtitle() {
    switch (_selectedSidebarIndex) {
      case 0:
        return 'نظرة شاملة على أداء النظام والإحصائيات الحالية';
      case 1:
        return 'مراجعة سريعة للمنجزات المعلقة والمهام العاجلة';
      case 2:
        return 'إدارة شاملة لجميع المنجزات في النظام';
      case 3:
        return 'إدارة وتفعيل حسابات المستخدمين';
      case 4:
        return 'تحليلات مفصلة وإحصائيات متقدمة';
      case 5:
        return 'إعدادات النظام والتحكم في الصلاحيات';
      default:
        return 'نظرة شاملة على أداء النظام والإحصائيات الحالية';
    }
  }

  String _getLocalizedTitle(String titleKey) {
    final localizations = AppLocalizations.of(context)!;
    switch (titleKey) {
      case 'mainDashboard':
        return localizations.mainDashboard;
      case 'quickReview':
        return localizations.quickReview;
      case 'achievementsManagement':
        return localizations.achievementsManagement;
      case 'usersManagement':
        return localizations.usersManagement;
      case 'reportsAndAnalytics':
        return localizations.reportsAndAnalytics;
      case 'adminSettings':
        return localizations.adminSettings;
      default:
        return titleKey; // fallback to the key itself
    }
  }

  void _refreshData() {
    // Refresh data logic here
    setState(() {
      _isLoading = true;
    });

    // Simulate data refresh
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  Widget _buildTabletLayout() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppComponents.appBar(
        title: _getPageTitle(),
        automaticallyImplyLeading: false,
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () async {
                await _authService.signOut();
                if (mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.logout),
              splashRadius: 20,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(20),
          child: _buildSelectedContent(),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppComponents.appBar(
        title: _getPageTitle(),
        automaticallyImplyLeading: false,
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () async {
                await _authService.signOut();
                if (mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.logout),
              splashRadius: 20,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          child: _buildSelectedContent(),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: _selectedSidebarIndex.clamp(0, 4),
      onTap: _onSidebarItemTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primaryDark,
      unselectedItemColor: AppColors.secondaryGray,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'الرئيسية',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.pending_actions_outlined),
          activeIcon: Icon(Icons.pending_actions),
          label: 'المراجعة',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment_outlined),
          activeIcon: Icon(Icons.assignment),
          label: 'المنجزات',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_outline),
          activeIcon: Icon(Icons.people),
          label: 'المستخدمين',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics_outlined),
          activeIcon: Icon(Icons.analytics),
          label: 'التقارير',
        ),
      ],
    );
  }

  Widget _buildMainContent() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primaryLight.withValues(alpha: 0.1), Colors.white],
        ),
      ),
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: _buildSelectedContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedContent() {
    switch (_selectedSidebarIndex) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return _buildPendingAchievementsContent();
      case 2:
        return _buildAllAchievementsContent();
      case 3:
        return _buildUsersManagementContent();
      case 4:
        return _buildAnalyticsContent();
      case 5:
        return _buildSettingsContent();
      default:
        return _buildDashboardContent();
    }
  }

  Widget _buildDashboardContent() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section with Enhanced Design
                _buildEnhancedWelcomeSection(),
                SizedBox(height: 32),

                // Quick Stats Section
                _buildQuickStatsSection(),
                SizedBox(height: 32),

                // Enhanced KPI Cards Grid
                _buildEnhancedKPICardsGrid(),
                SizedBox(height: 32),

                // Analytics Section
                _buildAnalyticsSection(),
                SizedBox(height: 32),

                // Bottom Actions Section
                _buildBottomActionsSection(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primaryMedium],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.welcomeToDashboard,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.trackAchievementsEasily,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                ),
              ],
            ),
          ),
          const Icon(Icons.admin_panel_settings, color: Colors.white, size: 48),
        ],
      ),
    );
  }

  Widget _buildQuickStatsSection() {
    return Row(
      children: [
        Expanded(
          child: _buildQuickStatCard(
            AppLocalizations.of(context)!.pendingAchievements,
            '${_pendingAchievements.length}',
            Icons.pending_actions,
            warningColor,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildQuickStatCard(
            AppLocalizations.of(context)!.totalAchievements,
            '${_achievements.length}',
            Icons.emoji_events,
            successColor,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildQuickStatCard(
            AppLocalizations.of(context)!.activeUsers,
            '152',
            Icons.people,
            AppColors.primaryLight,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildQuickStatCard(
            'الإدارات',
            '12',
            Icons.business,
            AppColors.primaryMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedKPICardsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: _getGridColumns(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildKPICard(
          'معدل الموافقة',
          '87%',
          Icons.check_circle,
          successColor,
          '↑ 12% من الشهر الماضي',
        ),
        _buildKPICard(
          'متوسط وقت المراجعة',
          '2.3 يوم',
          Icons.schedule,
          warningColor,
          '↓ 0.5 يوم تحسن',
        ),
        _buildKPICard(
          'الإدارات النشطة',
          '8/12',
          Icons.business_center,
          AppColors.primaryDark,
          '66% من إجمالي الإدارات',
        ),
        _buildKPICard(
          'الإنجازات هذا الشهر',
          '47',
          Icons.trending_up,
          AppColors.primaryMedium,
          '↑ 23% من الشهر الماضي',
        ),
      ],
    );
  }

  int _getGridColumns() {
    if (_isDesktop()) return 4;
    if (_isTablet()) return 2;
    return 1;
  }

  Widget _buildKPICard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withValues(alpha: 0.7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.arrow_upward, color: color, size: 16),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
          ),
          SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'إحصائيات الأداء',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.analytics),
                label: Text('عرض التفاصيل'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'مخطط الإحصائيات\n(سيتم التطوير)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionsSection() {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            'إضافة إنجاز جديد',
            'إنشاء إنجاز جديد للموظفين',
            Icons.add_circle,
            AppColors.primaryDark,
            () {},
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildActionCard(
            'إدارة المستخدمين',
            'إضافة أو تعديل المستخدمين',
            Icons.people_alt,
            AppColors.primaryMedium,
            () {},
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildActionCard(
            'التقارير',
            'عرض وتصدير التقارير',
            Icons.assessment,
            successColor,
            () {},
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  // Content sections for different sidebar items
  Widget _buildPendingAchievementsContent() {
    return StreamBuilder<List<Achievement>>(
      stream: _adminService.getAchievementsByStatus('pending'),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorState(
            'حدث خطأ في تحميل المنجزات المعلقة: ${snapshot.error}',
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final pendingAchievements = snapshot.data ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            _buildQuickReviewHeader(pendingAchievements.length),
            SizedBox(height: 24),

            // Quick Stats Section
            _buildQuickReviewStats(pendingAchievements),
            SizedBox(height: 24),

            // Filter and Sort Options
            _buildQuickReviewFilters(),
            SizedBox(height: 24),

            // Pending Achievements Content
            if (pendingAchievements.isEmpty)
              _buildEmptyPendingState()
            else
              _buildPendingAchievementsList(pendingAchievements),
          ],
        );
      },
    );
  }

  Widget _buildQuickReviewHeader(int pendingCount) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [warningColor, warningColor.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: warningColor.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'المراجعة السريعة',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: 8),
                Text(
                  'مراجعة سريعة للمنجزات المعلقة ($pendingCount منجز)',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.pending_actions,
                  color: Colors.white,
                  size: 28,
                ),
                if (pendingCount > 0) ...[
                  SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$pendingCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickReviewStats(List<Achievement> pendingAchievements) {
    final today = DateTime.now();
    final urgent = pendingAchievements.where((a) {
      final daysDiff = today.difference(a.createdAt).inDays;
      return daysDiff >= 3; // اعتبر المنجز عاجل إذا مر عليه 3 أيام أو أكثر
    }).length;

    final thisWeek = pendingAchievements.where((a) {
      final daysDiff = today.difference(a.createdAt).inDays;
      return daysDiff <= 7;
    }).length;

    final departments =
        pendingAchievements.map((a) => a.executiveDepartment).toSet().length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 1024;
        final isTablet = constraints.maxWidth > 768;

        if (isDesktop) {
          return Row(
            children: [
              Expanded(
                child: _buildQuickStatCard(
                  'عاجل',
                  '$urgent',
                  Icons.priority_high,
                  Colors.red,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildQuickStatCard(
                  'هذا الأسبوع',
                  '$thisWeek',
                  Icons.today,
                  warningColor,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildQuickStatCard(
                  'الإدارات',
                  '$departments',
                  Icons.business,
                  AppColors.primaryMedium,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildQuickStatCard(
                  'الإجمالي',
                  '${pendingAchievements.length}',
                  Icons.pending,
                  AppColors.primaryDark,
                ),
              ),
            ],
          );
        } else if (isTablet) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildQuickStatCard(
                      'عاجل',
                      '$urgent',
                      Icons.priority_high,
                      Colors.red,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildQuickStatCard(
                      'هذا الأسبوع',
                      '$thisWeek',
                      Icons.today,
                      warningColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickStatCard(
                      'الإدارات',
                      '$departments',
                      Icons.business,
                      AppColors.primaryMedium,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildQuickStatCard(
                      'الإجمالي',
                      '${pendingAchievements.length}',
                      Icons.pending,
                      AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
            ],
          );
        } else {
          return Column(
            children: [
              _buildQuickStatCard(
                'عاجل',
                '$urgent',
                Icons.priority_high,
                Colors.red,
              ),
              SizedBox(height: 12),
              _buildQuickStatCard(
                'هذا الأسبوع',
                '$thisWeek',
                Icons.today,
                warningColor,
              ),
              SizedBox(height: 12),
              _buildQuickStatCard(
                'الإدارات',
                '$departments',
                Icons.business,
                AppColors.primaryMedium,
              ),
              SizedBox(height: 12),
              _buildQuickStatCard(
                'الإجمالي',
                '${pendingAchievements.length}',
                Icons.pending,
                AppColors.primaryDark,
              ),
            ],
          );
        }
      },
    );
  }

  String _quickReviewSortBy = 'date';
  bool _showUrgentOnly = false;

  // Analytics variables
  String _selectedReportPeriod = 'weekly';
  bool _isAnalyticsLoading = false;
  Map<String, dynamic>? _currentAnalyticsData;

  // Settings variables
  String _selectedSettingsTab = 'general';
  bool _emailNotificationsEnabled = true;
  bool _pushNotificationsEnabled = true;
  bool _achievementAutoApproval = false;
  bool _maintenanceModeEnabled = false;
  bool _backupEnabled = true;
  String _backupFrequency = 'daily';
  int _maxFileSize = 10; // MB
  int _sessionTimeout = 30; // minutes
  bool _twoFactorEnabled = false;
  bool _auditLogEnabled = true;
  String _defaultUserRole = 'user';
  Map<String, bool> _modulePermissions = {
    'achievements': true,
    'users': true,
    'analytics': true,
    'reports': true,
    'settings': true,
  };

  Widget _buildQuickReviewFilters() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 768) {
            return Row(
              children: [
                const Icon(Icons.tune, color: AppColors.primaryDark),
                SizedBox(width: 12),
                Text(
                  'فلترة سريعة',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                Row(
                  children: [
                    _buildFilterChipWidget('الكل', !_showUrgentOnly, () {
                      setState(() => _showUrgentOnly = false);
                    }),
                    SizedBox(width: 8),
                    _buildFilterChipWidget('العاجل فقط', _showUrgentOnly, () {
                      setState(() => _showUrgentOnly = true);
                    }),
                    SizedBox(width: 20),
                    SizedBox(
                      width: 150,
                      child: DropdownButtonFormField<String>(
                        value: _quickReviewSortBy,
                        decoration: const InputDecoration(
                          labelText: 'ترتيب حسب',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'date',
                            child: Text('التاريخ'),
                          ),
                          DropdownMenuItem(
                            value: 'department',
                            child: Text('الإدارة'),
                          ),
                          DropdownMenuItem(
                            value: 'priority',
                            child: Text('الأولوية'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => _quickReviewSortBy = value ?? 'date');
                        },
                      ),
                    ),
                  ],
                ),
              ],
            );
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.tune, color: AppColors.primaryDark),
                    SizedBox(width: 12),
                    Text(
                      'فلترة سريعة',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    _buildFilterChipWidget('الكل', !_showUrgentOnly, () {
                      setState(() => _showUrgentOnly = false);
                    }),
                    SizedBox(width: 8),
                    _buildFilterChipWidget('العاجل فقط', _showUrgentOnly, () {
                      setState(() => _showUrgentOnly = true);
                    }),
                  ],
                ),
                SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: DropdownButtonFormField<String>(
                    value: _quickReviewSortBy,
                    decoration: const InputDecoration(
                      labelText: 'ترتيب حسب',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'date', child: Text('التاريخ')),
                      DropdownMenuItem(
                        value: 'department',
                        child: Text('الإدارة'),
                      ),
                      DropdownMenuItem(
                        value: 'priority',
                        child: Text('الأولوية'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => _quickReviewSortBy = value ?? 'date');
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildFilterChipWidget(
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryDark
              : AppColors.primaryLight.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryDark
                : AppColors.primaryLight.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.primaryDark,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyPendingState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: successColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_outline,
              size: 64,
              color: successColor,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'لا توجد منجزات معلقة!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 12),
          Text(
            'جميع المنجزات تم مراجعتها بنجاح',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => setState(() => _selectedSidebarIndex = 2),
            icon: const Icon(Icons.assignment),
            label: Text('عرض جميع المنجزات'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingAchievementsList(List<Achievement> achievements) {
    // تطبيق الفلاتر
    var filteredAchievements = achievements;

    if (_showUrgentOnly) {
      final today = DateTime.now();
      filteredAchievements = achievements.where((a) {
        final daysDiff = today.difference(a.createdAt).inDays;
        return daysDiff >= 3;
      }).toList();
    }

    // ترتيب المنجزات
    switch (_quickReviewSortBy) {
      case 'date':
        filteredAchievements.sort((a, b) {
          return b.createdAt.compareTo(a.createdAt);
        });
        break;
      case 'department':
        filteredAchievements.sort(
          (a, b) => a.executiveDepartment.compareTo(b.executiveDepartment),
        );
        break;
      case 'priority':
        final today = DateTime.now();
        filteredAchievements.sort((a, b) {
          final aDays = today.difference(a.createdAt).inDays;
          final bDays = today.difference(b.createdAt).inDays;
          return bDays.compareTo(aDays);
        });
        break;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1024) {
          // Desktop: Grid view
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
            ),
            itemCount: filteredAchievements.length,
            itemBuilder: (context, index) => _buildPendingAchievementCard(
              filteredAchievements[index],
              isDesktop: true,
            ),
          );
        } else if (constraints.maxWidth > 768) {
          // Tablet: Single column with larger cards
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredAchievements.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildPendingAchievementCard(
                filteredAchievements[index],
                isTablet: true,
              ),
            ),
          );
        } else {
          // Mobile: Compact list view
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredAchievements.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildPendingAchievementCard(
                filteredAchievements[index],
                isMobile: true,
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildPendingAchievementCard(
    Achievement achievement, {
    bool isDesktop = false,
    bool isTablet = false,
    bool isMobile = false,
  }) {
    final today = DateTime.now();
    final daysDiff = today.difference(achievement.createdAt).inDays;
    final isUrgent = daysDiff >= 3;
    final priorityColor = isUrgent
        ? Colors.red
        : daysDiff >= 1
            ? warningColor
            : successColor;

    if (isMobile) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: priorityColor.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: priorityColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isUrgent
                        ? 'عاجل'
                        : daysDiff >= 1
                            ? 'متوسط'
                            : 'جديد',
                    style: TextStyle(
                      color: priorityColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(achievement.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              achievement.topic,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8),
            Text(
              achievement.goal,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8),
            Text(
              achievement.executiveDepartment,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _approveAchievement(achievement.id ?? ''),
                    icon: const Icon(Icons.check, size: 18),
                    label: Text('موافق'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: successColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _rejectAchievement(achievement.id ?? ''),
                    icon: const Icon(Icons.close, size: 18),
                    label: Text('رفض'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: errorColor,
                      side: BorderSide(color: errorColor),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Desktop and Tablet view
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: priorityColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: priorityColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isUrgent ? Icons.priority_high : Icons.schedule,
                  color: priorityColor,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isUrgent
                          ? 'عاجل'
                          : daysDiff >= 1
                              ? 'متوسط الأولوية'
                              : 'جديد',
                      style: TextStyle(
                        color: priorityColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      daysDiff == 0
                          ? 'اليوم'
                          : '$daysDiff ${daysDiff == 1 ? 'يوم' : 'أيام'} مضت',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              Text(
                _formatDate(achievement.createdAt),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            achievement.topic,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8),
          Text(
            achievement.goal,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
            maxLines: isDesktop ? 3 : 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              achievement.executiveDepartment,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _approveAchievement(achievement.id ?? ''),
                  icon: const Icon(Icons.check),
                  label: Text('موافقة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: successColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _rejectAchievement(achievement.id ?? ''),
                  icon: const Icon(Icons.close),
                  label: Text('رفض'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: errorColor,
                    side: BorderSide(color: errorColor),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              if (isDesktop) ...[
                SizedBox(width: 12),
                IconButton(
                  onPressed: () => _showAchievementDetails(achievement),
                  icon: const Icon(Icons.info_outline),
                  tooltip: 'عرض التفاصيل',
                  style: IconButton.styleFrom(
                    backgroundColor:
                        AppColors.primaryLight.withValues(alpha: 0.1),
                    foregroundColor: AppColors.primaryDark,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'غير محدد';
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'اليوم';
    } else if (diff.inDays == 1) {
      return 'أمس';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} أيام مضت';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showAchievementDetails(Achievement achievement) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.7,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'تفاصيل المنجز',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              SizedBox(height: 16),
              _buildDetailRow('الموضوع:', achievement.topic),
              _buildDetailRow('الهدف:', achievement.goal),
              _buildDetailRow('الإدارة:', achievement.executiveDepartment),
              _buildDetailRow(
                'تاريخ الإنشاء:',
                _formatDate(achievement.createdAt),
              ),
              if (achievement.reviewNotes?.isNotEmpty == true)
                _buildDetailRow('ملاحظات المراجعة:', achievement.reviewNotes!),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _approveAchievement(achievement.id ?? '');
                      },
                      icon: const Icon(Icons.check),
                      label: Text('موافقة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: successColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _rejectAchievement(achievement.id ?? '');
                      },
                      icon: const Icon(Icons.close),
                      label: Text('رفض'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: errorColor,
                        side: BorderSide(color: errorColor),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildAllAchievementsContent() {
    return StreamBuilder<List<Achievement>>(
      stream: _adminService.getAllAchievements(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorState(
            'حدث خطأ في تحميل المنجزات: ${snapshot.error}',
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final achievements = snapshot.data ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section with Search and Filters
            _buildAchievementsHeader(achievements.length),
            SizedBox(height: 24),

            // Search and Filter Section
            _buildSearchAndFilterSection(),
            SizedBox(height: 24),

            // Statistics Cards
            _buildAchievementsStatistics(achievements),
            SizedBox(height: 24),

            // Achievements Table/Grid
            _buildAchievementsTable(achievements),
          ],
        );
      },
    );
  }

  Widget _buildAchievementsHeader(int totalCount) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primaryMedium],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إدارة المنجزات',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: 8),
                Text(
                  'إدارة شاملة لجميع المنجزات في النظام ($totalCount منجز)',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.assignment, color: Colors.white, size: 24),
                SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onSelected: (value) {
                    switch (value) {
                      case 'export_excel':
                        _exportToExcel();
                        break;
                      case 'export_csv':
                        _exportToCSV();
                        break;
                      case 'print_report':
                        _printReport();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'export_excel',
                      child: Row(
                        children: [
                          Icon(Icons.table_chart, color: AppColors.primaryDark),
                          SizedBox(width: 8),
                          Text('تصدير إلى Excel'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'export_csv',
                      child: Row(
                        children: [
                          Icon(Icons.description, color: AppColors.primaryDark),
                          SizedBox(width: 8),
                          Text('تصدير إلى CSV'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'print_report',
                      child: Row(
                        children: [
                          Icon(Icons.print, color: AppColors.primaryDark),
                          SizedBox(width: 8),
                          Text('طباعة التقرير'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _searchQuery = '';
  String _selectedStatusFilter = 'all';
  String _selectedDepartmentFilter = 'all';
  DateTime? _startDate;
  DateTime? _endDate;

  Widget _buildSearchAndFilterSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.search, color: AppColors.primaryDark),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'البحث والفلترة المتقدمة',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              // Quick actions
              Row(
                children: [
                  _buildQuickFilterChip(
                    'الكل',
                    _selectedStatusFilter == 'all',
                    () {
                      setState(() => _selectedStatusFilter = 'all');
                    },
                  ),
                  SizedBox(width: 8),
                  _buildQuickFilterChip(
                    'معلقة',
                    _selectedStatusFilter == 'pending',
                    () {
                      setState(() => _selectedStatusFilter = 'pending');
                    },
                  ),
                  SizedBox(width: 8),
                  _buildQuickFilterChip(
                    'معتمدة',
                    _selectedStatusFilter == 'approved',
                    () {
                      setState(() => _selectedStatusFilter = 'approved');
                    },
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),

          // Search Bar with advanced options
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'البحث في الموضوع، الهدف، الإدارة...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primaryLight),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primaryLight.withValues(alpha: 0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primaryDark),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => _showAdvancedFilters(),
                icon: const Icon(Icons.tune),
                label: Text('فلاتر متقدمة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Filter Row
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              // Status Filter
              SizedBox(
                width: 200,
                child: DropdownButtonFormField<String>(
                  value: _selectedStatusFilter,
                  decoration: InputDecoration(
                    labelText: 'فلترة بالحالة',
                    prefixIcon: const Icon(Icons.flag, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('جميع الحالات')),
                    DropdownMenuItem(value: 'pending', child: Text('معلقة')),
                    DropdownMenuItem(value: 'approved', child: Text('معتمد')),
                    DropdownMenuItem(value: 'rejected', child: Text('مرفوض')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedStatusFilter = value ?? 'all';
                    });
                  },
                ),
              ),

              // Department Filter
              SizedBox(
                width: 200,
                child: DropdownButtonFormField<String>(
                  value: _selectedDepartmentFilter,
                  decoration: InputDecoration(
                    labelText: 'فلترة بالإدارة',
                    prefixIcon: const Icon(Icons.business, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'all',
                      child: Text('جميع الإدارات'),
                    ),
                    DropdownMenuItem(
                      value: 'hr',
                      child: Text('الموارد البشرية'),
                    ),
                    DropdownMenuItem(
                      value: 'it',
                      child: Text('تقنية المعلومات'),
                    ),
                    DropdownMenuItem(value: 'finance', child: Text('المالية')),
                    DropdownMenuItem(value: 'medical', child: Text('الطبية')),
                    DropdownMenuItem(value: 'admin', child: Text('الإدارية')),
                    DropdownMenuItem(value: 'nursing', child: Text('التمريض')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedDepartmentFilter = value ?? 'all';
                    });
                  },
                ),
              ),

              // Date Range Buttons
              ElevatedButton.icon(
                onPressed: () => _selectDateRange(),
                icon: const Icon(Icons.date_range),
                label: Text(_getDateRangeText()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryLight,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              // Clear Filters
              if (_hasActiveFilters())
                OutlinedButton.icon(
                  onPressed: () => _clearFilters(),
                  icon: const Icon(Icons.clear_all),
                  label: Text('مسح جميع الفلاتر'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: errorColor,
                    side: BorderSide(color: errorColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
            ],
          ),

          // Active filters display
          if (_hasActiveFilters()) ...[
            SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _buildActiveFilterChips(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickFilterChip(
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryDark
              : AppColors.primaryLight.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryDark
                : AppColors.primaryLight.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.primaryDark,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  bool _hasActiveFilters() {
    return _searchQuery.isNotEmpty ||
        _selectedStatusFilter != 'all' ||
        _selectedDepartmentFilter != 'all' ||
        (_startDate != null && _endDate != null);
  }

  List<Widget> _buildActiveFilterChips() {
    final chips = <Widget>[];

    if (_searchQuery.isNotEmpty) {
      chips.add(
        _buildFilterChip('البحث: $_searchQuery', () {
          setState(() => _searchQuery = '');
        }),
      );
    }

    if (_selectedStatusFilter != 'all') {
      chips.add(
        _buildFilterChip(
          'الحالة: ${_getStatusFilterText(_selectedStatusFilter)}',
          () {
            setState(() => _selectedStatusFilter = 'all');
          },
        ),
      );
    }

    if (_selectedDepartmentFilter != 'all') {
      chips.add(
        _buildFilterChip(
          'الإدارة: ${_getDepartmentFilterText(_selectedDepartmentFilter)}',
          () {
            setState(() => _selectedDepartmentFilter = 'all');
          },
        ),
      );
    }

    if (_startDate != null && _endDate != null) {
      chips.add(
        _buildFilterChip('التاريخ: ${_getDateRangeText()}', () {
          setState(() {
            _startDate = null;
            _endDate = null;
          });
        }),
      );
    }

    return chips;
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: AppColors.primaryLight.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.primaryDark, fontSize: 12),
          ),
          SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close,
              size: 16,
              color: AppColors.primaryDark.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusFilterText(String value) {
    switch (value) {
      case 'pending':
        return 'معلقة';
      case 'approved':
        return 'معتمد';
      case 'rejected':
        return 'مرفوض';
      default:
        return 'جميع الحالات';
    }
  }

  String _getDepartmentFilterText(String value) {
    switch (value) {
      case 'hr':
        return 'الموارد البشرية';
      case 'it':
        return 'تقنية المعلومات';
      case 'finance':
        return 'المالية';
      case 'medical':
        return 'الطبية';
      case 'admin':
        return 'الإدارية';
      case 'nursing':
        return 'التمريض';
      default:
        return 'جميع الإدارات';
    }
  }

  void _showAdvancedFilters() {
    showDialog(
      context: context,
      builder: (context) => _buildAdvancedFiltersDialog(),
    );
  }

  Widget _buildAdvancedFiltersDialog() {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.tune, color: AppColors.primaryDark),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'الفلاتر المتقدمة',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),
            SizedBox(height: 16),
            Text(
              'فلترة حسب نوع المشاركة:',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                'مبادرة',
                'تدشين',
                'مشاركة',
                'فعالية',
                'حملة',
                'لقاء',
                'محاضرة',
                'دورة تدريبية',
                'اجتماع',
              ]
                  .map(
                    (type) => FilterChip(
                      label: Text(type),
                      selected: false, // You can implement this logic
                      onSelected: (selected) {
                        // Implement participation type filtering
                      },
                    ),
                  )
                  .toList(),
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('إلغاء'),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Apply advanced filters
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                    ),
                    child: Text(
                      'تطبيق',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsStatistics(List<Achievement> achievements) {
    final pending = achievements.where((a) => a.status == 'pending').length;
    final approved = achievements.where((a) => a.status == 'approved').length;
    final rejected = achievements.where((a) => a.status == 'rejected').length;
    final total = achievements.length;

    return Column(
      children: [
        // Main statistics row
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'إجمالي المنجزات',
                total.toString(),
                Icons.emoji_events,
                AppColors.primaryDark,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'معلقة',
                pending.toString(),
                Icons.pending_actions,
                warningColor,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'معتمد',
                approved.toString(),
                Icons.check_circle,
                successColor,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'مرفوض',
                rejected.toString(),
                Icons.cancel,
                errorColor,
              ),
            ),
          ],
        ),
        SizedBox(height: 20),

        // Additional analytics row
        if (_isDesktop()) ...[
          Row(
            children: [
              Expanded(
                child: _buildProgressCard(
                  'معدل الموافقة',
                  total > 0
                      ? '${(approved / total * 100).toStringAsFixed(1)}%'
                      : '0%',
                  total > 0 ? approved / total : 0.0,
                  successColor,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildProgressCard(
                  'معدل الرفض',
                  total > 0
                      ? '${(rejected / total * 100).toStringAsFixed(1)}%'
                      : '0%',
                  total > 0 ? rejected / total : 0.0,
                  errorColor,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildProgressCard(
                  'معلقة',
                  total > 0
                      ? '${(pending / total * 100).toStringAsFixed(1)}%'
                      : '0%',
                  total > 0 ? pending / total : 0.0,
                  warningColor,
                ),
              ),
              SizedBox(width: 16),
              Expanded(child: _buildDepartmentStatsCard(achievements)),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildProgressCard(
    String title,
    String percentage,
    double progress,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: color, size: 20),
              SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            percentage,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentStatsCard(List<Achievement> achievements) {
    final departmentCounts = <String, int>{};
    for (final achievement in achievements) {
      final dept = achievement.executiveDepartment;
      departmentCounts[dept] = (departmentCounts[dept] ?? 0) + 1;
    }

    final topDepartments = departmentCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppColors.primaryLight.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.business, color: AppColors.primaryDark, size: 20),
              SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.mostActiveDepartments,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          SizedBox(height: 12),
          if (topDepartments.isNotEmpty) ...[
            ...topDepartments.take(3).map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: AppColors.primaryDark,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entry.key,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.onSurface),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                AppColors.primaryLight.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            entry.value.toString(),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.primaryDark,
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ] else ...[
            Text(
              'لا توجد بيانات',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsTable(List<Achievement> allAchievements) {
    // Filter achievements based on search and filters
    final filteredAchievements = _filterAchievements(allAchievements);

    if (filteredAchievements.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Bulk actions toolbar
          if (_selectedAchievements.isNotEmpty) _buildBulkActionsToolbar(),

          // Table Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(
                  _selectedAchievements.isNotEmpty ? 0 : 16,
                ),
                topRight: Radius.circular(
                  _selectedAchievements.isNotEmpty ? 0 : 16,
                ),
              ),
            ),
            child: Row(
              children: [
                // Select all checkbox
                Checkbox(
                  value: _selectedAchievements.length ==
                          filteredAchievements.length &&
                      filteredAchievements.isNotEmpty,
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedAchievements = Set.from(
                          filteredAchievements
                              .map((a) => a.id)
                              .where((id) => id != null),
                        );
                      } else {
                        _selectedAchievements.clear();
                      }
                    });
                  },
                  activeColor: AppColors.primaryDark,
                ),
                SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: Text(
                    'الموضوع',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'الإدارة',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'التاريخ',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'الحالة',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'الإجراءات',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          // Table Body
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredAchievements.length,
            itemBuilder: (context, index) {
              final achievement = filteredAchievements[index];
              return _buildAchievementRow(achievement, index);
            },
          ),
        ],
      ),
    );
  }

  Set<String> _selectedAchievements = {};

  Widget _buildBulkActionsToolbar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryDark.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.primaryDark, size: 20),
          SizedBox(width: 8),
          Text(
            'تم تحديد ${_selectedAchievements.length} منجز',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const Spacer(),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () => _bulkApprove(),
                icon: const Icon(Icons.check, size: 16),
                label: Text('اعتماد الكل'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: successColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 32),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                ),
              ),
              SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _bulkReject(),
                icon: const Icon(Icons.close, size: 16),
                label: Text('رفض الكل'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: errorColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 32),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                ),
              ),
              SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _bulkDelete(),
                icon: const Icon(Icons.delete, size: 16),
                label: Text('حذف الكل'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 32),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                ),
              ),
              SizedBox(width: 12),
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _selectedAchievements.clear();
                  });
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryDark,
                  side: BorderSide(color: AppColors.primaryDark),
                  minimumSize: const Size(0, 32),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                ),
                child: Text('إلغاء التحديد'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementRow(Achievement achievement, int index) {
    final isEven = index % 2 == 0;
    final isSelected = _selectedAchievements.contains(achievement.id);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primaryLight.withValues(alpha: 0.1)
            : (isEven ? Colors.grey.withValues(alpha: 0.02) : Colors.white),
      ),
      child: Row(
        children: [
          // Selection checkbox
          Checkbox(
            value: isSelected,
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  _selectedAchievements.add(achievement.id!);
                } else {
                  _selectedAchievements.remove(achievement.id);
                }
              });
            },
            activeColor: AppColors.primaryDark,
          ),
          SizedBox(width: 8),

          // Topic
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.topic,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  achievement.goal,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Department
          Expanded(
            flex: 2,
            child: Text(
              achievement.executiveDepartment,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.onSurface),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Date
          Expanded(
            flex: 2,
            child: Text(
              _formatArabicDate(achievement.date),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.onSurface),
            ),
          ),

          // Status
          Expanded(
            flex: 1,
            child: Center(child: _buildStatusChip(achievement.status)),
          ),

          // Actions
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (achievement.status == 'pending') ...[
                  _buildActionButton(
                    icon: Icons.check,
                    color: successColor,
                    tooltip: 'اعتماد',
                    onPressed: () =>
                        _approveAchievementWithConfirmation(achievement),
                  ),
                  SizedBox(width: 8),
                  _buildActionButton(
                    icon: Icons.close,
                    color: errorColor,
                    tooltip: 'رفض',
                    onPressed: () =>
                        _rejectAchievementWithConfirmation(achievement),
                  ),
                  SizedBox(width: 8),
                ],
                _buildActionButton(
                  icon: Icons.visibility,
                  color: AppColors.primaryDark,
                  tooltip: 'عرض',
                  onPressed: () => _viewAchievementDetails(achievement),
                ),
                SizedBox(width: 8),
                _buildActionButton(
                  icon: Icons.edit,
                  color: AppColors.primaryMedium,
                  tooltip: 'تعديل',
                  onPressed: () => _editAchievement(achievement),
                ),
                SizedBox(width: 8),
                _buildActionButton(
                  icon: Icons.delete,
                  color: errorColor,
                  tooltip: 'حذف',
                  onPressed: () =>
                      _deleteAchievementWithConfirmation(achievement),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Bulk action methods
  void _bulkApprove() {
    if (_selectedAchievements.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تأكيد الاعتماد المجمع'),
        content: Text(
          'هل أنت متأكد من اعتماد ${_selectedAchievements.length} منجز؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performBulkAction('approved');
            },
            style: ElevatedButton.styleFrom(backgroundColor: successColor),
            child: Text(
              'اعتماد الكل',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _bulkReject() {
    if (_selectedAchievements.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تأكيد الرفض المجمع'),
        content: Text(
          'هل أنت متأكد من رفض ${_selectedAchievements.length} منجز؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performBulkAction('rejected');
            },
            style: ElevatedButton.styleFrom(backgroundColor: errorColor),
            child: Text(
              'رفض الكل',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _bulkDelete() {
    if (_selectedAchievements.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تأكيد الحذف المجمع'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('هل أنت متأكد من حذف ${_selectedAchievements.length} منجز؟'),
            SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: errorColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: errorColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: errorColor, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'تحذير: هذا الإجراء لا يمكن التراجع عنه',
                      style: TextStyle(
                        color: errorColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performBulkDelete();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
            child: Text(
              'حذف نهائياً',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performBulkAction(String status) async {
    final selectedIds = List<String>.from(_selectedAchievements);
    int successCount = 0;
    int errorCount = 0;

    for (final id in selectedIds) {
      try {
        await _adminService.updateAchievementStatus(id, status);
        successCount++;
      } catch (e) {
        errorCount++;
        print('Error updating achievement $id: $e');
      }
    }

    setState(() {
      _selectedAchievements.clear();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorCount == 0
                ? 'تم ${status == 'approved' ? 'اعتماد' : 'رفض'} $successCount منجز بنجاح'
                : 'تم ${status == 'approved' ? 'اعتماد' : 'رفض'} $successCount منجز، فشل في $errorCount منجز',
          ),
          backgroundColor: errorCount == 0 ? successColor : warningColor,
        ),
      );
    }
  }

  Future<void> _performBulkDelete() async {
    final selectedIds = List<String>.from(_selectedAchievements);
    int successCount = 0;
    int errorCount = 0;

    for (final id in selectedIds) {
      try {
        await _adminService.deleteAchievement(id);
        successCount++;
      } catch (e) {
        errorCount++;
        print('Error deleting achievement $id: $e');
      }
    }

    setState(() {
      _selectedAchievements.clear();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorCount == 0
                ? 'تم حذف $successCount منجز بنجاح'
                : 'تم حذف $successCount منجز، فشل في حذف $errorCount منجز',
          ),
          backgroundColor: errorCount == 0 ? successColor : warningColor,
        ),
      );
    }
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case 'pending':
        color = warningColor;
        label = 'معلقة';
        icon = Icons.pending;
        break;
      case 'approved':
        color = successColor;
        label = 'معتمد';
        icon = Icons.check_circle;
        break;
      case 'rejected':
        color = errorColor;
        label = 'مرفوض';
        icon = Icons.cancel;
        break;
      default:
        color = AppColors.primaryLight;
        label = 'غير محدد';
        icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          SizedBox(height: 16),
          Text(
            'لا توجد منجزات تطابق البحث',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: AppColors.onSurfaceVariant),
          ),
          SizedBox(height: 8),
          Text(
            'جرب تغيير معايير البحث أو الفلترة',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: errorColor.withValues(alpha: 0.7),
          ),
          SizedBox(height: 16),
          Text(
            'حدث خطأ',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: errorColor),
          ),
          SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => setState(() {}),
            icon: const Icon(Icons.refresh),
            label: Text('إعادة المحاولة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for filtering and actions
  List<Achievement> _filterAchievements(List<Achievement> achievements) {
    return achievements.where((achievement) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final searchLower = _searchQuery.toLowerCase();
        if (!achievement.topic.toLowerCase().contains(searchLower) &&
            !achievement.goal.toLowerCase().contains(searchLower) &&
            !achievement.executiveDepartment.toLowerCase().contains(
                  searchLower,
                )) {
          return false;
        }
      }

      // Status filter
      if (_selectedStatusFilter != 'all' &&
          achievement.status != _selectedStatusFilter) {
        return false;
      }

      // Department filter (simplified for demo)
      if (_selectedDepartmentFilter != 'all') {
        // You can implement more sophisticated department filtering here
      }

      // Date range filter
      if (_startDate != null && _endDate != null) {
        if (achievement.date.isBefore(_startDate!) ||
            achievement.date.isAfter(_endDate!)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  String _formatArabicDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getDateRangeText() {
    if (_startDate != null && _endDate != null) {
      return '${_formatArabicDate(_startDate!)} - ${_formatArabicDate(_endDate!)}';
    }
    return 'اختيار فترة زمنية';
  }

  void _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _selectedStatusFilter = 'all';
      _selectedDepartmentFilter = 'all';
      _startDate = null;
      _endDate = null;
    });
  }

  // Action methods
  void _approveAchievementWithConfirmation(Achievement achievement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تأكيد الاعتماد'),
        content: Text('هل أنت متأكد من اعتماد منجز "${achievement.topic}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _approveAchievement(achievement.id!);
            },
            style: ElevatedButton.styleFrom(backgroundColor: successColor),
            child: Text('اعتماد', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _rejectAchievementWithConfirmation(Achievement achievement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تأكيد الرفض'),
        content: Text('هل أنت متأكد من رفض منجز "${achievement.topic}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _rejectAchievement(achievement.id!);
            },
            style: ElevatedButton.styleFrom(backgroundColor: errorColor),
            child: Text('رفض', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _deleteAchievementWithConfirmation(Achievement achievement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تأكيد الحذف'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('هل أنت متأكد من حذف منجز "${achievement.topic}"؟'),
            SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: errorColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: errorColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: errorColor, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'تحذير: هذا الإجراء لا يمكن التراجع عنه',
                      style: TextStyle(
                        color: errorColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAchievement(achievement.id!);
            },
            style: ElevatedButton.styleFrom(backgroundColor: errorColor),
            child: Text(
              'حذف نهائياً',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _viewAchievementDetails(Achievement achievement) {
    showDialog(
      context: context,
      builder: (context) => _buildAchievementDetailsDialog(achievement),
    );
  }

  void _editAchievement(Achievement achievement) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditAchievementScreen(achievement: achievement),
      ),
    );
  }

  Widget _buildAchievementDetailsDialog(Achievement achievement) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'تفاصيل المنجز',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryDark,
                              ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              SizedBox(height: 16),
              _buildDetailRow('الموضوع:', achievement.topic),
              _buildDetailRow('الهدف:', achievement.goal),
              _buildDetailRow('نوع المشاركة:', achievement.participationType),
              _buildDetailRow(
                'الإدارة التنفيذية:',
                achievement.executiveDepartment,
              ),
              _buildDetailRow('الإدارة الرئيسية:', achievement.mainDepartment),
              _buildDetailRow('الإدارة الفرعية:', achievement.subDepartment),
              _buildDetailRow('التاريخ:', _formatArabicDate(achievement.date)),
              _buildDetailRow('المكان:', achievement.location),
              _buildDetailRow('المدة:', achievement.duration),
              _buildDetailRow('الأثر:', achievement.impact),
              _buildDetailRow('الحالة:', _getStatusText(achievement.status)),
              SizedBox(height: 24),
              Row(
                children: [
                  if (achievement.status == 'pending') ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _approveAchievementWithConfirmation(achievement);
                        },
                        icon: const Icon(Icons.check),
                        label: Text('اعتماد'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: successColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _rejectAchievementWithConfirmation(achievement);
                        },
                        icon: const Icon(Icons.close),
                        label: Text('رفض'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: errorColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _editAchievement(achievement);
                        },
                        icon: const Icon(Icons.edit),
                        label: Text('تعديل'),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'معلقة';
      case 'approved':
        return 'معتمد';
      case 'rejected':
        return 'مرفوض';
      default:
        return 'غير محدد';
    }
  }

  // Export functions
  void _exportToExcel() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('جارٍ تصدير البيانات إلى Excel...'),
        backgroundColor: AppColors.primaryDark,
      ),
    );
    // TODO: Implement Excel export functionality
  }

  void _exportToCSV() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('جارٍ تصدير البيانات إلى CSV...'),
        backgroundColor: AppColors.primaryDark,
      ),
    );
    // TODO: Implement CSV export functionality
  }

  void _printReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('جارٍ تحضير التقرير للطباعة...'),
        backgroundColor: AppColors.primaryDark,
      ),
    );
    // TODO: Implement print functionality
  }

  Widget _buildUsersManagementContent() {
    return const UsersManagementWidget();
  }

  Widget _buildAnalyticsContent() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                _buildAnalyticsHeader(),
                SizedBox(height: 24),

                // Period Selection Tabs
                _buildPeriodSelector(),
                SizedBox(height: 24),

                // Analytics Content
                _isAnalyticsLoading
                    ? _buildLoadingAnalytics()
                    : _buildAnalyticsData(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnalyticsHeader() {
    return Container(
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
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'التقارير والتحليلات',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: 8),
                Text(
                  'تحليلات شاملة ومفصلة لأداء النظام',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.analytics,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.date_range, color: AppColors.primaryDark),
              SizedBox(width: 12),
              Text(
                'اختر فترة التقرير',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              _buildExportButton(),
            ],
          ),
          SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 768) {
                return Row(
                  children: [
                    Expanded(
                        child: _buildPeriodTab('weekly', 'التقرير الأسبوعي')),
                    SizedBox(width: 16),
                    Expanded(
                        child: _buildPeriodTab('monthly', 'التقرير الشهري')),
                    SizedBox(width: 16),
                    Expanded(
                        child: _buildPeriodTab('yearly', 'التقرير السنوي')),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildPeriodTab('weekly', 'التقرير الأسبوعي'),
                    SizedBox(height: 12),
                    _buildPeriodTab('monthly', 'التقرير الشهري'),
                    SizedBox(height: 12),
                    _buildPeriodTab('yearly', 'التقرير السنوي'),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodTab(String period, String title) {
    final isSelected = _selectedReportPeriod == period;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onPeriodSelected(period),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryDark
                  : AppColors.primaryLight.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isSelected ? Colors.white : AppColors.onSurface,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExportButton() {
    return ElevatedButton.icon(
      onPressed: _currentAnalyticsData != null ? _exportReport : null,
      icon: const Icon(Icons.download),
      label: Text('تصدير التقرير'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildLoadingAnalytics() {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'جارٍ تحميل التحليلات...',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsData() {
    if (_currentAnalyticsData == null) {
      return _buildEmptyAnalyticsState();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1024) {
          return _buildDesktopAnalytics();
        } else if (constraints.maxWidth > 768) {
          return _buildTabletAnalytics();
        } else {
          return _buildMobileAnalytics();
        }
      },
    );
  }

  Widget _buildEmptyAnalyticsState() {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.analytics_outlined,
              size: 64,
              color: AppColors.primaryDark,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'اختر فترة التقرير لعرض التحليلات',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 12),
          Text(
            'حدد الفترة الزمنية المطلوبة من الأعلى لعرض التحليلات والإحصائيات المفصلة',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopAnalytics() {
    return Column(
      children: [
        // Summary Cards Row
        _buildSummaryCards(),
        SizedBox(height: 24),

        // Primary Analytics Section - Line Chart and Pie Chart
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column - Line Chart (main trend)
            Expanded(
              flex: 1,
              child: _buildLineChartSection(),
            ),
            SizedBox(width: 24),
            // Right Column - Pie Chart (status distribution)
            Expanded(
              flex: 1,
              child: _buildPieChartSection(),
            ),
          ],
        ),
        SizedBox(height: 24),

        // Secondary Charts Section
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column - Area Chart and Bar Chart
            Expanded(
              child: Column(
                children: [
                  _buildAreaChartSection(),
                  SizedBox(height: 24),
                  _buildBarChartSection(),
                ],
              ),
            ),
            SizedBox(width: 24),
            // Right Column - Radar Chart and Scatter Plot
            Expanded(
              child: Column(
                children: [
                  _buildRadarChartSection(),
                  SizedBox(height: 24),
                  _buildScatterPlotSection(),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 24),

        // Advanced Analytics Section
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column - Heat Map
            Expanded(
              child: _buildHeatMapSection(),
            ),
            SizedBox(width: 24),
            // Right Column - Radial Progress
            Expanded(
              child: _buildRadialProgressSection(),
            ),
          ],
        ),
        SizedBox(height: 24),

        // Performance Metrics Section
        _buildPerformanceMetricsSection(),
        SizedBox(height: 24),

        // Detailed Stats Section
        _buildDetailedStats(),
      ],
    );
  }

  Widget _buildTabletAnalytics() {
    return Column(
      children: [
        _buildSummaryCards(),
        SizedBox(height: 24),

        // Primary Charts Row - Most Important
        Row(
          children: [
            Expanded(child: _buildLineChartSection()),
            SizedBox(width: 16),
            Expanded(child: _buildPieChartSection()),
          ],
        ),
        SizedBox(height: 24),

        // Secondary Charts
        _buildAreaChartSection(),
        SizedBox(height: 24),

        Row(
          children: [
            Expanded(child: _buildBarChartSection()),
            SizedBox(width: 16),
            Expanded(child: _buildRadarChartSection()),
          ],
        ),
        SizedBox(height: 24),

        Row(
          children: [
            Expanded(child: _buildScatterPlotSection()),
            SizedBox(width: 16),
            Expanded(child: _buildHeatMapSection()),
          ],
        ),
        SizedBox(height: 24),

        _buildRadialProgressSection(),
        SizedBox(height: 24),
        _buildPerformanceMetricsSection(),
        SizedBox(height: 24),
        _buildDetailedStats(),
      ],
    );
  }

  Widget _buildMobileAnalytics() {
    return Column(
      children: [
        _buildSummaryCards(),
        SizedBox(height: 24),

        // Primary Analytics - Most Important First
        _buildLineChartSection(),
        SizedBox(height: 24),
        _buildPieChartSection(), // Status distribution - high priority
        SizedBox(height: 24),

        // Secondary Analytics
        _buildAreaChartSection(),
        SizedBox(height: 24),
        _buildBarChartSection(),
        SizedBox(height: 24),
        _buildRadarChartSection(),
        SizedBox(height: 24),

        // Advanced Analytics
        _buildScatterPlotSection(),
        SizedBox(height: 24),
        _buildHeatMapSection(),
        SizedBox(height: 24),
        _buildRadialProgressSection(),
        SizedBox(height: 24),
        _buildPerformanceMetricsSection(),
        SizedBox(height: 24),
        _buildDetailedStats(),
      ],
    );
  }

  Widget _buildSummaryCards() {
    final data = _currentAnalyticsData!;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 768) {
          return Row(
            children: [
              Expanded(
                  child: _buildSummaryCard(
                      'إجمالي المنجزات',
                      '${data['totalAchievements']}',
                      Icons.assignment,
                      AppColors.primaryDark)),
              SizedBox(width: 16),
              Expanded(
                  child: _buildSummaryCard('المعتمد', '${data['approved']}',
                      Icons.check_circle, const Color(0xFF4CAF50))),
              SizedBox(width: 16),
              Expanded(
                  child: _buildSummaryCard('المعلق', '${data['pending']}',
                      Icons.pending, const Color(0xFFFF9800))),
              SizedBox(width: 16),
              Expanded(
                  child: _buildSummaryCard('المرفوض', '${data['rejected']}',
                      Icons.cancel, const Color(0xFFF44336))),
            ],
          );
        } else {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                      child: _buildSummaryCard(
                          'إجمالي المنجزات',
                          '${data['totalAchievements']}',
                          Icons.assignment,
                          AppColors.primaryDark)),
                  SizedBox(width: 16),
                  Expanded(
                      child: _buildSummaryCard('المعتمد', '${data['approved']}',
                          Icons.check_circle, const Color(0xFF4CAF50))),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                      child: _buildSummaryCard('المعلق', '${data['pending']}',
                          Icons.pending, const Color(0xFFFF9800))),
                  SizedBox(width: 16),
                  Expanded(
                      child: _buildSummaryCard('المرفوض', '${data['rejected']}',
                          Icons.cancel, const Color(0xFFF44336))),
                ],
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const Spacer(),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChartSection() {
    return ChartsWidget.buildLineChart(
      data: _currentAnalyticsData!,
      title: 'اتجاه المنجزات - ${_currentAnalyticsData!['period']}',
      primaryColor: AppColors.primaryDark,
      height: 350,
    );
  }

  Widget _buildPieChartSection() {
    return ChartsWidget.buildPieChart(
      data: _currentAnalyticsData!,
      title: 'توزيع حالات المنجزات',
      height: 350,
    );
  }

  Widget _buildBarChartSection() {
    return ChartsWidget.buildBarChart(
      data: _currentAnalyticsData!,
      title: 'المنجزات حسب الإدارة',
      primaryColor: AppColors.primaryMedium,
      height: 350,
    );
  }

  // رسم بياني منطقة (Area Chart)
  Widget _buildAreaChartSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.area_chart,
                  color: AppColors.primaryLight,
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'منحنى تراكمي للمنجزات',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'تراكمي',
                  style: TextStyle(
                    color: AppColors.primaryLight,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          SizedBox(
            height: 280,
            child: CustomPaint(
              painter: AreaChartPainter(_currentAnalyticsData!),
              child: Container(),
            ),
          ),
        ],
      ),
    );
  }

  // رسم بياني رادار (Radar Chart)
  Widget _buildRadarChartSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.radar,
                  color: Colors.blue,
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'أداء الإدارات',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'رادار',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          SizedBox(
            height: 280,
            child: CustomPaint(
              painter: RadarChartPainter(_currentAnalyticsData!),
              child: Container(),
            ),
          ),
        ],
      ),
    );
  }

  // رسم بياني التشتت (Scatter Plot)
  Widget _buildScatterPlotSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.scatter_plot,
                  color: Colors.orange,
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'العلاقة بين الوقت والمنجزات',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'تشتت',
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          SizedBox(
            height: 280,
            child: CustomPaint(
              painter: ScatterPlotPainter(_currentAnalyticsData!),
              child: Container(),
            ),
          ),
        ],
      ),
    );
  }

  // خريطة حرارية (Heat Map)
  Widget _buildHeatMapSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.thermostat,
                  color: Colors.red,
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'خريطة حرارية للنشاط',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'حراري',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          SizedBox(
            height: 280,
            child: _buildActivityHeatMap(),
          ),
        ],
      ),
    );
  }

  // تقدم دائري (Radial Progress)
  Widget _buildRadialProgressSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.donut_small,
                  color: Colors.purple,
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'مؤشرات الأداء الرئيسية',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'KPI',
                  style: TextStyle(
                    color: Colors.purple,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          SizedBox(
            height: 280,
            child: _buildRadialProgressIndicators(),
          ),
        ],
      ),
    );
  }

  // قسم مقاييس الأداء
  Widget _buildPerformanceMetricsSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.speed,
                  color: Colors.teal,
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'مقاييس الأداء المتقدمة',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          _buildPerformanceMetricsGrid(),
        ],
      ),
    );
  }

  Widget _buildDetailedStats() {
    final data = _currentAnalyticsData!;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إحصائيات تفصيلية',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 20),
          if (_selectedReportPeriod == 'monthly' &&
              data['approvalRate'] != null)
            _buildStatRow(
                'معدل الاعتماد', '${data['approvalRate'].toStringAsFixed(1)}%'),
          if (_selectedReportPeriod == 'yearly' && data['growthRate'] != null)
            _buildStatRow('معدل النمو السنوي',
                '${data['growthRate'].toStringAsFixed(1)}%'),
          if (data['totalUsers'] != null)
            _buildStatRow('إجمالي المستخدمين', '${data['totalUsers']}'),
          if (data['activeUsers'] != null)
            _buildStatRow(AppLocalizations.of(context)!.activeUsers,
                '${data['activeUsers']}'),
          _buildStatRow('الفترة الزمنية', data['period'] ?? ''),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  void _onPeriodSelected(String period) {
    setState(() {
      _selectedReportPeriod = period;
      _isAnalyticsLoading = true;
      _currentAnalyticsData = null;
    });

    _loadAnalyticsData(period);
  }

  Future<void> _loadAnalyticsData(String period) async {
    try {
      Map<String, dynamic> data;

      switch (period) {
        case 'weekly':
          data = await _adminService.getWeeklyAnalytics();
          break;
        case 'monthly':
          data = await _adminService.getMonthlyAnalytics();
          break;
        case 'yearly':
          data = await _adminService.getYearlyAnalytics();
          break;
        default:
          data = await _adminService.getWeeklyAnalytics();
      }

      if (mounted) {
        setState(() {
          _currentAnalyticsData = data;
          _isAnalyticsLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyticsLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحميل التحليلات: $e'),
            backgroundColor: errorColor,
          ),
        );
      }
    }
  }

  void _exportReport() {
    if (_currentAnalyticsData == null) return;

    // في التطبيق الحقيقي، ستقوم بتصدير البيانات إلى Excel أو PDF
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('سيتم إضافة ميزة تصدير التقارير قريباً'),
        backgroundColor: AppColors.primaryDark,
      ),
    );
  }

  // Settings Functions
  void _saveAllSettings() {
    // في التطبيق الحقيقي، ستقوم بحفظ الإعدادات في قاعدة البيانات
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم حفظ الإعدادات بنجاح'),
        backgroundColor: successColor,
      ),
    );
  }

  Widget _buildGeneralSettings() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الإعدادات العامة',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 24),

          // Language Setting
          _buildSettingItem(
            title: 'اللغة',
            subtitle: 'اختر لغة واجهة النظام',
            icon: Icons.language,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 200),
              child: const LanguageDropdown(
                showFlags: true,
              ),
            ),
          ),

          const Divider(height: 32),

          // Theme Setting
          _buildSettingItem(
            title: 'المظهر',
            subtitle: 'اختر نمط المظهر (يُطبق فوراً)',
            icon: Icons.palette,
            child: DropdownButton<String>(
              value: GlobalThemeManager.currentThemeString,
              onChanged: (value) async {
                if (value != null) {
                  await _changeTheme(value);
                }
              },
              items: const [
                DropdownMenuItem(value: 'light', child: Text('فاتح')),
                DropdownMenuItem(value: 'dark', child: Text('داكن')),
                DropdownMenuItem(value: 'system', child: Text('تلقائي')),
              ],
            ),
          ),

          const Divider(height: 32),

          // Session Timeout
          _buildSettingItem(
            title: 'مهلة انتهاء الجلسة',
            subtitle: 'مدة البقاء في النظام بدون نشاط (بالدقائق)',
            icon: Icons.timer,
            child: SizedBox(
              width: 100,
              child: TextFormField(
                initialValue: _sessionTimeout.toString(),
                keyboardType: TextInputType.number,
                onChanged: (value) =>
                    _sessionTimeout = int.tryParse(value) ?? 30,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
          ),

          const Divider(height: 32),

          // Default User Role
          _buildSettingItem(
            title: 'الدور الافتراضي للمستخدمين الجدد',
            subtitle: 'الدور الذي يُعطى للمستخدمين الجدد تلقائياً',
            icon: Icons.person_add,
            child: DropdownButton<String>(
              value: _defaultUserRole,
              onChanged: (value) => setState(() => _defaultUserRole = value!),
              items: const [
                DropdownMenuItem(value: 'user', child: Text('مستخدم عادي')),
                DropdownMenuItem(value: 'moderator', child: Text('مراقب')),
                DropdownMenuItem(value: 'admin', child: Text('مدير')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceSettings() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'المظهر والواجهة',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 24),

          // Theme Selection
          _buildSettingItem(
            title: 'نمط المظهر',
            subtitle: 'اختر نمط العرض المفضل (يُطبق فوراً)',
            icon: Icons.brightness_6,
            child: DropdownButton<String>(
              value: GlobalThemeManager.currentThemeString,
              onChanged: (value) async {
                if (value != null) {
                  await _changeTheme(value);
                }
              },
              items: const [
                DropdownMenuItem(value: 'light', child: Text('فاتح')),
                DropdownMenuItem(value: 'dark', child: Text('داكن')),
                DropdownMenuItem(value: 'system', child: Text('تلقائي')),
              ],
            ),
          ),

          const Divider(height: 32),

          // Dark Mode Toggle
          _buildSettingItem(
            title: 'الوضع الليلي',
            subtitle: 'تفعيل/إلغاء المظهر الداكن (تبديل سريع)',
            icon: GlobalThemeManager.isDarkMode
                ? Icons.dark_mode
                : Icons.light_mode,
            child: Switch(
              value: GlobalThemeManager.isDarkMode,
              onChanged: (value) async {
                await _changeTheme(value ? 'dark' : 'light');
              },
              activeColor: Theme.of(context).colorScheme.primary,
            ),
          ),

          const Divider(height: 32),

          // Language Section
          Text(
            'إعدادات اللغة',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDark,
                ),
          ),
          const SizedBox(height: 16),

          // Language Toggle Widget
          const LanguageToggleWidget(
            showLabel: false,
            padding: EdgeInsets.all(16),
          ),

          const Divider(height: 32),

          // Current Theme Info
          _buildSettingItem(
            title: 'المظهر الحالي',
            subtitle: 'النمط المُطبق حالياً',
            icon: Icons.info_outline,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                GlobalThemeManager.currentThemeDisplayName,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const Divider(height: 32),

          // Theme Colors Preview
          _buildSettingItem(
            title: 'ألوان النظام',
            subtitle: 'معاينة الألوان المستخدمة في النظام',
            icon: Icons.color_lens,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('الألوان الأساسية:',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                SizedBox(height: 8),
                Row(
                  children: [
                    _buildColorPreview(
                        GlobalThemeManager.isDarkMode
                            ? DarkColors.primaryDark
                            : AppColors.primaryDark,
                        'الأساسي'),
                    SizedBox(width: 12),
                    _buildColorPreview(
                        GlobalThemeManager.isDarkMode
                            ? DarkColors.primaryMedium
                            : AppColors.primaryMedium,
                        'المتوسط'),
                    SizedBox(width: 12),
                    _buildColorPreview(
                        GlobalThemeManager.isDarkMode
                            ? DarkColors.primaryLight
                            : AppColors.primaryLight,
                        'الفاتح'),
                  ],
                ),
                SizedBox(height: 16),
                Text('ألوان السطح:',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                SizedBox(height: 8),
                Row(
                  children: [
                    _buildColorPreview(
                        Theme.of(context).scaffoldBackgroundColor, 'الخلفية'),
                    SizedBox(width: 12),
                    _buildColorPreview(Theme.of(context).cardColor, 'البطاقات'),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 32),

          // Font Settings
          _buildSettingItem(
            title: 'حجم الخط',
            subtitle: 'تخصيص حجم الخط في النظام',
            icon: Icons.text_fields,
            child: DropdownButton<String>(
              value: 'medium',
              onChanged: (value) {
                // يمكن إضافة وظيفة تغيير حجم الخط هنا
              },
              items: const [
                DropdownMenuItem(value: 'small', child: Text('صغير')),
                DropdownMenuItem(value: 'medium', child: Text('متوسط')),
                DropdownMenuItem(value: 'large', child: Text('كبير')),
              ],
            ),
          ),

          const Divider(height: 32),

          // Quick Theme Actions
          Text(
            'تغيير سريع للمظهر',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await _changeTheme('light');
                  },
                  icon: const Icon(Icons.light_mode),
                  label: Text('فاتح'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: !GlobalThemeManager.isDarkMode &&
                            GlobalThemeManager.currentThemeString == 'light'
                        ? Theme.of(context).colorScheme.primary
                        : null,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await _changeTheme('dark');
                  },
                  icon: const Icon(Icons.dark_mode),
                  label: Text('داكن'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GlobalThemeManager.isDarkMode &&
                            GlobalThemeManager.currentThemeString == 'dark'
                        ? Theme.of(context).colorScheme.primary
                        : null,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await _changeTheme('system');
                  },
                  icon: const Icon(Icons.auto_mode),
                  label: Text('تلقائي'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        GlobalThemeManager.currentThemeString == 'system'
                            ? Theme.of(context).colorScheme.primary
                            : null,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إعدادات الإشعارات',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 24),

          // Email Notifications
          _buildSettingItem(
            title: 'الإشعارات عبر البريد الإلكتروني',
            subtitle: 'استقبال الإشعارات المهمة عبر البريد الإلكتروني',
            icon: Icons.email,
            child: Switch(
              value: _emailNotificationsEnabled,
              onChanged: (value) =>
                  setState(() => _emailNotificationsEnabled = value),
              activeColor: AppColors.primaryDark,
            ),
          ),

          const Divider(height: 32),

          // Push Notifications
          _buildSettingItem(
            title: 'الإشعارات الفورية',
            subtitle: 'تلقي إشعارات فورية عند حدوث أحداث مهمة',
            icon: Icons.notifications,
            child: Switch(
              value: _pushNotificationsEnabled,
              onChanged: (value) =>
                  setState(() => _pushNotificationsEnabled = value),
              activeColor: AppColors.primaryDark,
            ),
          ),

          const Divider(height: 32),

          // Notification Types
          Text(
            'أنواع الإشعارات',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 16),

          _buildNotificationTypeItem('منجز جديد', true),
          _buildNotificationTypeItem('تحديث حالة المنجز', true),
          _buildNotificationTypeItem('مستخدم جديد', false),
          _buildNotificationTypeItem('تقرير شهري', true),
        ],
      ),
    );
  }

  Widget _buildSecuritySettings() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الأمان والحماية',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 24),

          // Two Factor Authentication
          _buildSettingItem(
            title: 'المصادقة الثنائية',
            subtitle: 'تفعيل المصادقة الثنائية لحماية إضافية',
            icon: Icons.security,
            child: Switch(
              value: _twoFactorEnabled,
              onChanged: (value) => setState(() => _twoFactorEnabled = value),
              activeColor: AppColors.primaryDark,
            ),
          ),

          const Divider(height: 32),

          // Audit Log
          _buildSettingItem(
            title: 'سجل العمليات',
            subtitle: 'تسجيل جميع العمليات المهمة في النظام',
            icon: Icons.history,
            child: Switch(
              value: _auditLogEnabled,
              onChanged: (value) => setState(() => _auditLogEnabled = value),
              activeColor: AppColors.primaryDark,
            ),
          ),

          const Divider(height: 32),

          // Password Policy
          _buildPasswordPolicySection(),

          const Divider(height: 32),

          // Security Actions
          Text(
            'إجراءات الأمان',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () =>
                      _showSecurityDialog('إعادة تعيين كلمات المرور'),
                  icon: const Icon(Icons.lock_reset),
                  label: Text('إعادة تعيين كلمات المرور'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: warningColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showSecurityDialog('إنهاء جميع الجلسات'),
                  icon: const Icon(Icons.logout),
                  label: Text('إنهاء جميع الجلسات'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: errorColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserSettings() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إدارة المستخدمين والأدوار',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 24),

          // Auto Achievement Approval
          _buildSettingItem(
            title: 'الاعتماد التلقائي للمنجزات',
            subtitle: 'اعتماد المنجزات تلقائياً بدون مراجعة',
            icon: Icons.auto_awesome,
            child: Switch(
              value: _achievementAutoApproval,
              onChanged: (value) =>
                  setState(() => _achievementAutoApproval = value),
              activeColor: AppColors.primaryDark,
            ),
          ),

          const Divider(height: 32),

          // Module Permissions
          Text(
            'صلاحيات الوحدات',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 16),

          ..._modulePermissions.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(_getModuleIcon(entry.key), color: AppColors.primaryDark),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(_getModuleName(entry.key)),
                  ),
                  Switch(
                    value: entry.value,
                    onChanged: (value) {
                      setState(() {
                        _modulePermissions[entry.key] = value;
                      });
                    },
                    activeColor: AppColors.primaryDark,
                  ),
                ],
              ),
            );
          }).toList(),

          const Divider(height: 32),

          // User Management Actions
          Text(
            'إجراءات إدارة المستخدمين',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _navigateToUserManagement(),
                  icon: const Icon(Icons.people),
                  label: Text('إدارة المستخدمين'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _exportUserReport(),
                  icon: const Icon(Icons.download),
                  label: Text('تصدير قائمة المستخدمين'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: successColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSystemSettings() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إعدادات النظام والصيانة',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 24),

          // Maintenance Mode
          _buildSettingItem(
            title: 'وضع الصيانة',
            subtitle: 'تفعيل وضع الصيانة لمنع وصول المستخدمين',
            icon: Icons.build,
            child: Switch(
              value: _maintenanceModeEnabled,
              onChanged: (value) =>
                  setState(() => _maintenanceModeEnabled = value),
              activeColor: AppColors.primaryDark,
            ),
          ),

          const Divider(height: 32),

          // Backup Settings
          _buildSettingItem(
            title: 'النسخ الاحتياطي التلقائي',
            subtitle: 'تفعيل النسخ الاحتياطي التلقائي للبيانات',
            icon: Icons.backup,
            child: Switch(
              value: _backupEnabled,
              onChanged: (value) => setState(() => _backupEnabled = value),
              activeColor: AppColors.primaryDark,
            ),
          ),

          if (_backupEnabled) ...[
            SizedBox(height: 16),
            _buildSettingItem(
              title: 'تكرار النسخ الاحتياطي',
              subtitle: 'تحديد معدل إنشاء النسخ الاحتياطية',
              icon: Icons.schedule,
              child: DropdownButton<String>(
                value: _backupFrequency,
                onChanged: (value) => setState(() => _backupFrequency = value!),
                items: const [
                  DropdownMenuItem(value: 'hourly', child: Text('كل ساعة')),
                  DropdownMenuItem(value: 'daily', child: Text('يومياً')),
                  DropdownMenuItem(value: 'weekly', child: Text('أسبوعياً')),
                  DropdownMenuItem(value: 'monthly', child: Text('شهرياً')),
                ],
              ),
            ),
          ],

          const Divider(height: 32),

          // File Upload Settings
          _buildSettingItem(
            title: 'حد حجم الملف الأقصى',
            subtitle: 'أقصى حجم للملفات المرفوعة (بالميجابايت)',
            icon: Icons.file_upload,
            child: SizedBox(
              width: 100,
              child: TextFormField(
                initialValue: _maxFileSize.toString(),
                keyboardType: TextInputType.number,
                onChanged: (value) => _maxFileSize = int.tryParse(value) ?? 10,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                  suffixText: 'MB',
                ),
              ),
            ),
          ),

          const Divider(height: 32),

          // System Actions
          Text(
            'إجراءات النظام',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 16),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ElevatedButton.icon(
                onPressed: () => _createBackup(),
                icon: const Icon(Icons.backup),
                label: Text('إنشاء نسخة احتياطية'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _clearCache(),
                icon: const Icon(Icons.clear),
                label: Text('مسح التخزين المؤقت'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: warningColor,
                  foregroundColor: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showSystemInfo(),
                icon: const Icon(Icons.info),
                label: Text('معلومات النظام'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: successColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIntegrationSettings() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'التكامل والAPI',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 24),

          // API Settings
          _buildSettingItem(
            title: 'API Token',
            subtitle: 'مفتاح API للتكامل مع الأنظمة الخارجية',
            icon: Icons.key,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppColors.primaryLight.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      'sk-1234567890abcdef...',
                      style: TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  onPressed: () => _regenerateApiToken(),
                  icon: const Icon(Icons.refresh),
                  tooltip: 'إعادة إنشاء المفتاح',
                ),
              ],
            ),
          ),

          const Divider(height: 32),

          // External Integrations
          Text(
            'التكاملات الخارجية',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 16),

          _buildIntegrationItem(
            'Microsoft Office 365',
            'تكامل مع حزمة مايكروسوفت أوفيس',
            Icons.business,
            true,
          ),
          _buildIntegrationItem(
            'Google Workspace',
            'تكامل مع خدمات جوجل للعمل',
            Icons.work,
            false,
          ),
          _buildIntegrationItem(
            'Slack',
            'إرسال الإشعارات عبر Slack',
            Icons.chat,
            false,
          ),

          const Divider(height: 32),

          // Webhook Settings
          Text(
            'إعدادات Webhooks',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 16),

          ElevatedButton.icon(
            onPressed: () => _manageWebhooks(),
            icon: const Icon(Icons.webhook),
            label: Text('إدارة Webhooks'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widgets for Settings
  Widget _buildSettingItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primaryDark),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
        child,
      ],
    );
  }

  Widget _buildColorPreview(Color color, String label) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildNotificationTypeItem(String title, bool enabled) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            enabled ? Icons.notifications_active : Icons.notifications_off,
            color: enabled ? AppColors.primaryDark : AppColors.onSurfaceVariant,
            size: 20,
          ),
          SizedBox(width: 12),
          Expanded(child: Text(title)),
          Switch(
            value: enabled,
            onChanged: (value) {},
            activeColor: AppColors.primaryDark,
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordPolicySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'سياسة كلمات المرور',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        SizedBox(height: 12),
        _buildPolicyItem('الحد الأدنى 8 أحرف', true),
        _buildPolicyItem('يجب أن تحتوي على أرقام', true),
        _buildPolicyItem('يجب أن تحتوي على رموز خاصة', true),
        _buildPolicyItem('يجب أن تحتوي على أحرف كبيرة وصغيرة', false),
      ],
    );
  }

  Widget _buildPolicyItem(String text, bool enabled) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            enabled ? Icons.check_circle : Icons.radio_button_unchecked,
            color: enabled ? successColor : AppColors.onSurfaceVariant,
            size: 16,
          ),
          SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: enabled ? AppColors.onSurface : AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntegrationItem(
      String title, String subtitle, IconData icon, bool enabled) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border:
              Border.all(color: AppColors.primaryLight.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: enabled
                    ? AppColors.primaryDark
                    : AppColors.onSurfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            Switch(
              value: enabled,
              onChanged: (value) {},
              activeColor: AppColors.primaryDark,
            ),
          ],
        ),
      ),
    );
  }

  // Helper Methods for Settings
  IconData _getModuleIcon(String module) {
    switch (module) {
      case 'achievements':
        return Icons.emoji_events;
      case 'users':
        return Icons.people;
      case 'analytics':
        return Icons.analytics;
      case 'reports':
        return Icons.assessment;
      case 'settings':
        return Icons.settings;
      default:
        return Icons.help;
    }
  }

  String _getModuleName(String module) {
    switch (module) {
      case 'achievements':
        return 'إدارة المنجزات';
      case 'users':
        return 'إدارة المستخدمين';
      case 'analytics':
        return 'التحليلات';
      case 'reports':
        return 'التقارير';
      case 'settings':
        return 'الإعدادات';
      default:
        return 'غير محدد';
    }
  }

  // Action Methods for Settings
  void _showSecurityDialog(String action) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(action),
        content: Text('هل أنت متأكد من تنفيذ $action؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('تم تنفيذ $action بنجاح')),
              );
            },
            child: Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  void _navigateToUserManagement() {
    setState(() => _selectedSidebarIndex = 3);
  }

  void _exportUserReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('جاري تصدير قائمة المستخدمين...'),
        backgroundColor: AppColors.primaryDark,
      ),
    );
  }

  void _createBackup() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('جاري إنشاء نسخة احتياطية...'),
        backgroundColor: successColor,
      ),
    );
  }

  void _clearCache() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم مسح التخزين المؤقت بنجاح'),
        backgroundColor: warningColor,
      ),
    );
  }

  void _showSystemInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('معلومات النظام'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الإصدار: 1.0.0'),
            Text('آخر تحديث: 2025-08-07'),
            Text('قاعدة البيانات: Firebase'),
            Text('الخادم: Google Cloud'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _regenerateApiToken() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('إعادة إنشاء مفتاح API'),
        content: Text('سيؤدي هذا إلى إبطال المفتاح الحالي. هل تريد المتابعة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم إنشاء مفتاح API جديد')),
              );
            },
            child: Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  void _manageWebhooks() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('صفحة إدارة Webhooks قيد التطوير'),
        backgroundColor: AppColors.primaryDark,
      ),
    );
  }

  Widget _buildSettingsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        _buildSettingsHeader(),
        SizedBox(height: 32),

        // Content based on layout
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 1024) {
              return _buildDesktopSettingsLayout();
            } else if (constraints.maxWidth > 768) {
              return _buildTabletSettingsLayout();
            } else {
              return _buildMobileSettingsLayout();
            }
          },
        ),
      ],
    );
  }

  Widget _buildSettingsHeader() {
    return Container(
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
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.settings,
              color: Colors.white,
              size: 32,
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إعدادات النظام',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: 8),
                Text(
                  'إدارة إعدادات المنصة والتحكم في الخصائص المتقدمة',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                      ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: _saveAllSettings,
            icon: const Icon(Icons.save),
            label: Text('حفظ التغييرات'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primaryDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopSettingsLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Settings Navigation Sidebar
        SizedBox(
          width: 280,
          child: _buildSettingsNavigation(),
        ),
        SizedBox(width: 24),
        // Settings Content
        Expanded(
          child: _buildSettingsPanel(),
        ),
      ],
    );
  }

  Widget _buildTabletSettingsLayout() {
    return Column(
      children: [
        // Horizontal Navigation Tabs
        _buildHorizontalSettingsNavigation(),
        SizedBox(height: 24),
        // Settings Content
        _buildSettingsPanel(),
      ],
    );
  }

  Widget _buildMobileSettingsLayout() {
    return Column(
      children: [
        // Compact Navigation
        _buildCompactSettingsNavigation(),
        SizedBox(height: 20),
        // Settings Content
        _buildSettingsPanel(),
      ],
    );
  }

  Widget _buildSettingsNavigation() {
    final settingsCategories = [
      {
        'id': 'general',
        'title': 'الإعدادات العامة',
        'icon': Icons.settings_outlined,
        'description': 'إعدادات أساسية للنظام',
      },
      {
        'id': 'appearance',
        'title': 'المظهر والواجهة',
        'icon': Icons.palette_outlined,
        'description': 'تخصيص شكل ومظهر النظام',
      },
      {
        'id': 'notifications',
        'title': 'الإشعارات',
        'icon': Icons.notifications_outlined,
        'description': 'إدارة الإشعارات والتنبيهات',
      },
      {
        'id': 'security',
        'title': 'الأمان والحماية',
        'icon': Icons.security_outlined,
        'description': 'إعدادات الأمان المتقدمة',
      },
      {
        'id': 'users',
        'title': 'المستخدمين والأدوار',
        'icon': Icons.people_outline,
        'description': 'إدارة المستخدمين والصلاحيات',
      },
      {
        'id': 'system',
        'title': 'النظام والصيانة',
        'icon': Icons.memory_outlined,
        'description': 'إعدادات النظام والنسخ الاحتياطية',
      },
      {
        'id': 'integration',
        'title': 'التكامل والAPI',
        'icon': Icons.api_outlined,
        'description': 'إعدادات التكامل مع الأنظمة الخارجية',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'أقسام الإعدادات',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 16),
          ...settingsCategories.map((category) {
            final isSelected = _selectedSettingsTab == category['id'];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => setState(
                      () => _selectedSettingsTab = category['id'] as String),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryDark.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(color: AppColors.primaryDark, width: 2)
                          : null,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryDark
                                : AppColors.primaryLight.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            category['icon'] as IconData,
                            color: isSelected
                                ? Colors.white
                                : AppColors.primaryDark,
                            size: 20,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                category['title'] as String,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? AppColors.primaryDark
                                          : AppColors.onSurface,
                                    ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                category['description'] as String,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.keyboard_arrow_left,
                            color: AppColors.primaryDark,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildHorizontalSettingsNavigation() {
    final settingsCategories = [
      {'id': 'general', 'title': 'عام', 'icon': Icons.settings_outlined},
      {'id': 'appearance', 'title': 'المظهر', 'icon': Icons.palette_outlined},
      {
        'id': 'notifications',
        'title': 'الإشعارات',
        'icon': Icons.notifications_outlined
      },
      {'id': 'security', 'title': 'الأمان', 'icon': Icons.security_outlined},
      {'id': 'users', 'title': 'المستخدمين', 'icon': Icons.people_outline},
      {'id': 'system', 'title': 'النظام', 'icon': Icons.memory_outlined},
      {'id': 'integration', 'title': 'التكامل', 'icon': Icons.api_outlined},
    ];

    return Container(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: settingsCategories.length,
        itemBuilder: (context, index) {
          final category = settingsCategories[index];
          final isSelected = _selectedSettingsTab == category['id'];

          return Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => setState(
                    () => _selectedSettingsTab = category['id'] as String),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 120,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryDark : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryDark
                          : AppColors.primaryLight.withValues(alpha: 0.3),
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        category['icon'] as IconData,
                        color:
                            isSelected ? Colors.white : AppColors.primaryDark,
                        size: 24,
                      ),
                      SizedBox(height: 8),
                      Text(
                        category['title'] as String,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.onSurface,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCompactSettingsNavigation() {
    final settingsCategories = [
      {'id': 'general', 'title': 'عام', 'icon': Icons.settings_outlined},
      {'id': 'appearance', 'title': 'المظهر', 'icon': Icons.palette_outlined},
      {
        'id': 'notifications',
        'title': 'الإشعارات',
        'icon': Icons.notifications_outlined
      },
      {'id': 'security', 'title': 'الأمان', 'icon': Icons.security_outlined},
      {'id': 'users', 'title': 'المستخدمين', 'icon': Icons.people_outline},
      {'id': 'system', 'title': 'النظام', 'icon': Icons.memory_outlined},
      {'id': 'integration', 'title': 'التكامل', 'icon': Icons.api_outlined},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: _selectedSettingsTab,
            onChanged: (value) => setState(() => _selectedSettingsTab = value!),
            decoration: InputDecoration(
              labelText: 'اختر قسم الإعدادات',
              prefixIcon: Icon(
                settingsCategories.firstWhere(
                        (cat) => cat['id'] == _selectedSettingsTab)['icon']
                    as IconData,
                color: AppColors.primaryDark,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: AppColors.primaryLight.withValues(alpha: 0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primaryDark),
              ),
            ),
            items: settingsCategories.map((category) {
              return DropdownMenuItem<String>(
                value: category['id'] as String,
                child: Row(
                  children: [
                    Icon(
                      category['icon'] as IconData,
                      color: AppColors.primaryDark,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Text(category['title'] as String),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsPanel() {
    switch (_selectedSettingsTab) {
      case 'general':
        return _buildGeneralSettings();
      case 'appearance':
        return _buildAppearanceSettings();
      case 'notifications':
        return _buildNotificationSettings();
      case 'security':
        return _buildSecuritySettings();
      case 'users':
        return _buildUserSettings();
      case 'system':
        return _buildSystemSettings();
      case 'integration':
        return _buildIntegrationSettings();
      default:
        return _buildGeneralSettings();
    }
  }

  Widget _buildSidebarFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Theme Toggle Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  GlobalThemeManager.isDarkMode
                      ? Icons.dark_mode
                      : Icons.light_mode,
                  color: Colors.white70,
                  size: 18,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'المظهر: ${GlobalThemeManager.currentThemeDisplayName}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    await GlobalThemeManager.toggleTheme();

                    // تحديث الواجهة
                    if (mounted) {
                      setState(() {
                        // إعادة بناء الواجهة مع الثيم الجديد
                      });

                      // إظهار رسالة تأكيد
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'تم التبديل إلى المظهر ${GlobalThemeManager.currentThemeDisplayName}'),
                          duration: const Duration(seconds: 2),
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.brightness_6,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16),
          const Divider(color: Colors.white24, thickness: 1),
          SizedBox(height: 16),

          // User Info
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                child: const Icon(Icons.person, color: Colors.white, size: 20),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مدير النظام',
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'admin@jchc.gov.sa',
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () async {
                  await _authService.signOut();
                  if (mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.logout, color: Colors.white70),
                tooltip: 'تسجيل الخروج',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // دوال مساعدة للرسومات البيانية الجديدة

  Widget _buildActivityHeatMap() {
    final data = _currentAnalyticsData!;
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.0,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: 28, // 4 weeks
      itemBuilder: (context, index) {
        final intensity = (data['heatmapData']?[index] ?? 0) / 10.0;
        return Container(
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: intensity.clamp(0.1, 1.0)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: TextStyle(
                color: intensity > 0.5 ? Colors.white : Colors.black87,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRadialProgressIndicators() {
    final data = _currentAnalyticsData!;

    final metrics = [
      {
        'title': 'معدل الاعتماد',
        'value': data['approvalRate'] ?? 85.0,
        'color': Colors.green,
        'icon': Icons.check_circle,
      },
      {
        'title': 'معدل الاستجابة',
        'value': data['responseRate'] ?? 92.0,
        'color': Colors.blue,
        'icon': Icons.speed,
      },
      {
        'title': 'رضا المستخدمين',
        'value': data['satisfactionRate'] ?? 78.0,
        'color': Colors.orange,
        'icon': Icons.sentiment_satisfied,
      },
      {
        'title': 'الكفاءة',
        'value': data['efficiencyRate'] ?? 88.0,
        'color': Colors.purple,
        'icon': Icons.trending_up,
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: constraints.maxWidth > 400 ? 2 : 1,
            childAspectRatio: 1.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: metrics.length,
          itemBuilder: (context, index) {
            final metric = metrics[index];
            return _buildRadialProgressCard(
              title: metric['title'] as String,
              value: metric['value'] as double,
              color: metric['color'] as Color,
              icon: metric['icon'] as IconData,
            );
          },
        );
      },
    );
  }

  Widget _buildRadialProgressCard({
    required String title,
    required double value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: value / 100,
                  strokeWidth: 6,
                  backgroundColor: color.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: color, size: 20),
                  SizedBox(height: 4),
                  Text(
                    '${value.round()}%',
                    style: TextStyle(
                      color: color,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetricsGrid() {
    final data = _currentAnalyticsData!;

    final metrics = [
      {
        'title': 'متوسط وقت المراجعة',
        'value': '${data['avgReviewTime'] ?? 2.5} يوم',
        'trend': '+5%',
        'isPositive': true,
        'icon': Icons.timer,
        'color': Colors.blue,
      },
      {
        'title': 'معدل الإنجاز الشهري',
        'value': '${data['monthlyCompletion'] ?? 87}%',
        'trend': '+12%',
        'isPositive': true,
        'icon': Icons.trending_up,
        'color': Colors.green,
      },
      {
        'title': 'المنجزات المتأخرة',
        'value': '${data['overdueAchievements'] ?? 3}',
        'trend': '-8%',
        'isPositive': true,
        'icon': Icons.warning,
        'color': Colors.orange,
      },
      {
        'title': 'مستوى الجودة',
        'value': '${data['qualityScore'] ?? 4.2}/5',
        'trend': '+3%',
        'isPositive': true,
        'icon': Icons.star,
        'color': Colors.purple,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.0,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: metrics.length,
      itemBuilder: (context, index) {
        final metric = metrics[index];
        return _buildMetricCard(
          title: metric['title'] as String,
          value: metric['value'] as String,
          trend: metric['trend'] as String,
          isPositive: metric['isPositive'] as bool,
          icon: metric['icon'] as IconData,
          color: metric['color'] as Color,
        );
      },
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String trend,
    required bool isPositive,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (isPositive ? Colors.green : Colors.red)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  trend,
                  style: TextStyle(
                    color: isPositive ? Colors.green : Colors.red,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

// Custom Painters للرسومات البيانية المتقدمة

class AreaChartPainter extends CustomPainter {
  final Map<String, dynamic> data;

  AreaChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppColors.primaryLight.withValues(alpha: 0.8),
          AppColors.primaryLight.withValues(alpha: 0.2),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = AppColors.primaryDark
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final values =
        List<double>.from(data['weeklyData'] ?? [10, 15, 12, 18, 22, 20, 25]);
    final path = Path();
    final linePath = Path();

    if (values.isNotEmpty) {
      final maxValue = values.reduce((a, b) => a > b ? a : b);
      final stepX = size.width / (values.length - 1);

      // إنشاء المسار للمنطقة المملوءة
      path.moveTo(0, size.height);
      linePath.moveTo(0, size.height - (values[0] / maxValue * size.height));

      for (int i = 0; i < values.length; i++) {
        final x = i * stepX;
        final y = size.height - (values[i] / maxValue * size.height);

        path.lineTo(x, y);
        if (i == 0) {
          linePath.moveTo(x, y);
        } else {
          linePath.lineTo(x, y);
        }
      }

      path.lineTo(size.width, size.height);
      path.close();

      canvas.drawPath(path, paint);
      canvas.drawPath(linePath, linePaint);

      // رسم النقاط
      final pointPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      final pointBorderPaint = Paint()
        ..color = AppColors.primaryDark
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      for (int i = 0; i < values.length; i++) {
        final x = i * stepX;
        final y = size.height - (values[i] / maxValue * size.height);

        canvas.drawCircle(Offset(x, y), 6, pointPaint);
        canvas.drawCircle(Offset(x, y), 6, pointBorderPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class RadarChartPainter extends CustomPainter {
  final Map<String, dynamic> data;

  RadarChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 40;

    final gridPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final dataPaint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final dataStrokePaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final departments =
        data['departmentPerformance'] as Map<String, dynamic>? ?? {};
    final labels = departments.keys.toList();
    final values = departments.values.cast<double>().toList();

    if (labels.isNotEmpty) {
      final maxValue =
          values.isNotEmpty ? values.reduce((a, b) => a > b ? a : b) : 100.0;
      final angleStep = 2 * math.pi / labels.length;

      // رسم الشبكة
      for (int i = 1; i <= 5; i++) {
        final r = radius * i / 5;
        canvas.drawCircle(center, r, gridPaint);
      }

      // رسم الخطوط الشعاعية
      for (int i = 0; i < labels.length; i++) {
        final angle = i * angleStep - math.pi / 2;
        final endPoint = Offset(
          center.dx + radius * math.cos(angle),
          center.dy + radius * math.sin(angle),
        );
        canvas.drawLine(center, endPoint, gridPaint);
      }

      // رسم البيانات
      final dataPath = Path();
      for (int i = 0; i < values.length; i++) {
        final angle = i * angleStep - math.pi / 2;
        final value = values[i] / maxValue;
        final dataRadius = radius * value;
        final point = Offset(
          center.dx + dataRadius * math.cos(angle),
          center.dy + dataRadius * math.sin(angle),
        );

        if (i == 0) {
          dataPath.moveTo(point.dx, point.dy);
        } else {
          dataPath.lineTo(point.dx, point.dy);
        }
      }
      dataPath.close();

      canvas.drawPath(dataPath, dataPaint);
      canvas.drawPath(dataPath, dataStrokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ScatterPlotPainter extends CustomPainter {
  final Map<String, dynamic> data;

  ScatterPlotPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final axisPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.5)
      ..strokeWidth = 1;

    final pointPaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.fill;

    // رسم المحاور
    canvas.drawLine(
      Offset(40, size.height - 40),
      Offset(size.width - 20, size.height - 40),
      axisPaint,
    );
    canvas.drawLine(
      Offset(40, size.height - 40),
      Offset(40, 20),
      axisPaint,
    );

    // رسم النقاط المبعثرة
    final scatterData = data['scatterData'] as List? ?? [];
    final plotWidth = size.width - 60;
    final plotHeight = size.height - 60;

    for (var point in scatterData) {
      final x = 40.0 + (point['x'] / 100) * plotWidth;
      final y = size.height - 40.0 - (point['y'] / 100) * plotHeight;

      canvas.drawCircle(Offset(x, y), 4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
