import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_components.dart';
import '../services/admin_service.dart';
import '../services/auth_service.dart';
import '../services/admin_auth_service.dart';
import '../core/app_router.dart';
import '../models/achievement.dart';
import 'login_screen.dart';
import 'edit_achievement_screen.dart';

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
  List<Achievement> _achievements = [];
  List<Achievement> _pendingAchievements = [];

  // Success and warning colors for the theme
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color errorColor = Color(0xFFF44336);

  final List<Map<String, dynamic>> _sidebarItems = [
    {
      'icon': Icons.dashboard_outlined,
      'activeIcon': Icons.dashboard,
      'title': 'لوحة التحكم الرئيسية',
      'index': 0,
    },
    {
      'icon': Icons.pending_actions_outlined,
      'activeIcon': Icons.pending_actions,
      'title': 'المراجعة السريعة',
      'index': 1,
    },
    {
      'icon': Icons.assignment_outlined,
      'activeIcon': Icons.assignment,
      'title': 'إدارة المنجزات',
      'index': 2,
    },
    {
      'icon': Icons.people_outline,
      'activeIcon': Icons.people,
      'title': 'إدارة المستخدمين',
      'index': 3,
    },
    {
      'icon': Icons.analytics_outlined,
      'activeIcon': Icons.analytics,
      'title': 'التقارير والتحليلات',
      'index': 4,
    },
    {
      'icon': Icons.settings_outlined,
      'activeIcon': Icons.settings,
      'title': 'الإعدادات الإدارية',
      'index': 5,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _scrollController.addListener(_onScroll);
    _checkAdminAccess();
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

  void _onScroll() {
    final isScrolled = _scrollController.offset > 50;
    if (isScrolled != _isScrolled) {
      setState(() {
        _isScrolled = isScrolled;
      });
    }
  }

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
          const SnackBar(
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
          const SnackBar(
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
          const SnackBar(
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
        backgroundColor: AppColors.surfaceLight,
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
                colors: [
                  AppColors.primaryDark,
                  AppColors.primaryMedium,
                  AppColors.primaryLight.withOpacity(0.8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryDark.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                // Logo Section
                _buildSidebarHeader(),
                const SizedBox(height: 40),
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
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.admin_panel_settings,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'لوحة التحكم الإدارية',
            style: AppTypography.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'تجمع جدة الصحي الثاني',
            style: AppTypography.textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.8),
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
              position:
                  Tween<Offset>(
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
                            ? Colors.white.withOpacity(0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected
                            ? Border.all(
                                color: Colors.white.withOpacity(0.3),
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
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              item['title'],
                              style: AppTypography.textTheme.bodyLarge
                                  ?.copyWith(
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
                colors: [
                  Colors.white.withOpacity(0.98),
                  Colors.white.withOpacity(0.95),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryDark.withOpacity(0.95),
                  AppColors.primaryMedium.withOpacity(0.90),
                  AppColors.primaryLight.withOpacity(0.85),
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
        boxShadow: _isScrolled
            ? [
                BoxShadow(
                  color: AppColors.primaryDark.withOpacity(0.15),
                  blurRadius: 25,
                  offset: const Offset(0, 8),
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: AppColors.primaryDark.withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                  spreadRadius: 3,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
        border: _isScrolled
            ? Border.all(
                color: AppColors.primaryLight.withOpacity(0.3),
                width: 1.5,
              )
            : Border.all(color: Colors.white.withOpacity(0.2), width: 1),
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
                            ? AppColors.primaryDark
                            : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getPageSubtitle(),
                      style: AppTypography.textTheme.bodyLarge?.copyWith(
                        color: _isScrolled
                            ? AppColors.primaryDark.withOpacity(0.7)
                            : Colors.white.withOpacity(0.9),
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
                    tooltip: 'تحديث البيانات',
                  ),
                  const SizedBox(width: 12),
                  _buildModernAppBarButton(
                    icon: Icons.notifications_outlined,
                    onPressed: () {},
                    tooltip: 'الإشعارات',
                    hasNotification: true,
                  ),
                  const SizedBox(width: 12),
                  _buildModernAppBarButton(
                    icon: Icons.account_circle_outlined,
                    onPressed: () {},
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
        color: AppColors.primaryDark.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
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
                  ? AppColors.primaryLight.withOpacity(0.3)
                  : Colors.white.withOpacity(0.3),
              hoverColor: _isScrolled
                  ? AppColors.primaryLight.withOpacity(0.1)
                  : Colors.white.withOpacity(0.1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: _isScrolled
                      ? Colors.white.withOpacity(0.1)
                      : Colors.white.withOpacity(0.15),
                  border: Border.all(
                    color: _isScrolled
                        ? AppColors.primaryLight.withOpacity(0.3)
                        : Colors.white.withOpacity(0.3),
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
    switch (_selectedSidebarIndex) {
      case 0:
        return 'لوحة التحكم الرئيسية';
      case 1:
        return 'المراجعة السريعة';
      case 2:
        return 'إدارة المنجزات';
      case 3:
        return 'إدارة المستخدمين';
      case 4:
        return 'التقارير والتحليلات';
      case 5:
        return 'الإعدادات الإدارية';
      default:
        return 'لوحة التحكم الرئيسية';
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
              color: AppColors.primaryLight.withOpacity(0.1),
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
              color: AppColors.primaryLight.withOpacity(0.1),
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
          colors: [AppColors.primaryLight.withOpacity(0.1), Colors.white],
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
                const SizedBox(height: 32),

                // Quick Stats Section
                _buildQuickStatsSection(),
                const SizedBox(height: 32),

                // Enhanced KPI Cards Grid
                _buildEnhancedKPICardsGrid(),
                const SizedBox(height: 32),

                // Analytics Section
                _buildAnalyticsSection(),
                const SizedBox(height: 32),

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
            color: AppColors.primaryDark.withOpacity(0.3),
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
                  'مرحباً بك في لوحة التحكم',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'تتبع الإنجازات وإدارة النظام بسهولة',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withOpacity(0.9),
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
            'الإنجازات المعلقة',
            '${_pendingAchievements.length}',
            Icons.pending_actions,
            warningColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildQuickStatCard(
            'إجمالي الإنجازات',
            '${_achievements.length}',
            Icons.emoji_events,
            successColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildQuickStatCard(
            'المستخدمين النشطين',
            '152',
            Icons.people,
            AppColors.primaryLight,
          ),
        ),
        const SizedBox(width: 16),
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
            color: Colors.grey.withOpacity(0.1),
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
                  color: color.withOpacity(0.1),
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
          const SizedBox(height: 12),
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
            color: Colors.grey.withOpacity(0.08),
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
                    colors: [color, color.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.arrow_upward, color: color, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
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
            color: Colors.grey.withOpacity(0.1),
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
                label: const Text('عرض التفاصيل'),
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
          const SizedBox(height: 20),
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
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionCard(
            'إدارة المستخدمين',
            'إضافة أو تعديل المستخدمين',
            Icons.people_alt,
            AppColors.primaryMedium,
            () {},
          ),
        ),
        const SizedBox(width: 16),
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
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
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
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الإنجازات المعلقة',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _pendingAchievements.length,
          itemBuilder: (context, index) {
            final achievement = _pendingAchievements[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: warningColor.withOpacity(0.1),
                  child: Icon(Icons.pending, color: warningColor),
                ),
                title: Text(achievement.topic),
                subtitle: Text(achievement.goal),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () =>
                          _approveAchievement(achievement.id ?? ''),
                      icon: Icon(Icons.check, color: successColor),
                    ),
                    IconButton(
                      onPressed: () => _rejectAchievement(achievement.id ?? ''),
                      icon: Icon(Icons.close, color: errorColor),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
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
            const SizedBox(height: 24),

            // Search and Filter Section
            _buildSearchAndFilterSection(),
            const SizedBox(height: 24),

            // Statistics Cards
            _buildAchievementsStatistics(achievements),
            const SizedBox(height: 24),

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
            color: AppColors.primaryDark.withOpacity(0.3),
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
                const SizedBox(height: 8),
                Text(
                  'إدارة شاملة لجميع المنجزات في النظام ($totalCount منجز)',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.assignment, color: Colors.white, size: 24),
                const SizedBox(width: 8),
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
            color: Colors.grey.withOpacity(0.1),
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
              const SizedBox(width: 8),
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
                  const SizedBox(width: 8),
                  _buildQuickFilterChip(
                    'معلقة',
                    _selectedStatusFilter == 'pending',
                    () {
                      setState(() => _selectedStatusFilter = 'pending');
                    },
                  ),
                  const SizedBox(width: 8),
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
          const SizedBox(height: 20),

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
                        color: AppColors.primaryLight.withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primaryDark),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => _showAdvancedFilters(),
                icon: const Icon(Icons.tune),
                label: const Text('فلاتر متقدمة'),
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
          const SizedBox(height: 16),

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
                    DropdownMenuItem(
                      value: 'pending',
                      child: Text('قيد المراجعة'),
                    ),
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
                  label: const Text('مسح جميع الفلاتر'),
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
            const SizedBox(height: 16),
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
              : AppColors.primaryLight.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryDark
                : AppColors.primaryLight.withOpacity(0.3),
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
        color: AppColors.primaryLight.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryLight.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.primaryDark, fontSize: 12),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close,
              size: 16,
              color: AppColors.primaryDark.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusFilterText(String value) {
    switch (value) {
      case 'pending':
        return 'قيد المراجعة';
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
                const SizedBox(width: 8),
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
            const SizedBox(height: 16),

            Text(
              'فلترة حسب نوع المشاركة:',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  [
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

            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('إلغاء'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Apply advanced filters
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                    ),
                    child: const Text(
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
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'قيد المراجعة',
                pending.toString(),
                Icons.pending_actions,
                warningColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'معتمد',
                approved.toString(),
                Icons.check_circle,
                successColor,
              ),
            ),
            const SizedBox(width: 16),
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
        const SizedBox(height: 20),

        // Additional analytics row
        if (_isDesktop()) ...[
          Row(
            children: [
              Expanded(
                child: _buildProgressCard(
                  'معدل الموافقة',
                  total > 0
                      ? (approved / total * 100).toStringAsFixed(1) + '%'
                      : '0%',
                  total > 0 ? approved / total : 0.0,
                  successColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildProgressCard(
                  'معدل الرفض',
                  total > 0
                      ? (rejected / total * 100).toStringAsFixed(1) + '%'
                      : '0%',
                  total > 0 ? rejected / total : 0.0,
                  errorColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildProgressCard(
                  'قيد المراجعة',
                  total > 0
                      ? (pending / total * 100).toStringAsFixed(1) + '%'
                      : '0%',
                  total > 0 ? pending / total : 0.0,
                  warningColor,
                ),
              ),
              const SizedBox(width: 16),
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
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
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
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            percentage,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withOpacity(0.1),
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
        border: Border.all(color: AppColors.primaryLight.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
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
              const SizedBox(width: 8),
              Text(
                'الإدارات الأكثر نشاطاً',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (topDepartments.isNotEmpty) ...[
            ...topDepartments
                .take(3)
                .map(
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
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entry.key,
                            style: Theme.of(context).textTheme.bodySmall
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
                            color: AppColors.primaryLight.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            entry.value.toString(),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
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
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
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
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
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
            color: Colors.grey.withOpacity(0.1),
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
              color: AppColors.primaryLight.withOpacity(0.1),
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
                  value:
                      _selectedAchievements.length ==
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
                const SizedBox(width: 8),
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
        color: AppColors.primaryDark.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.primaryDark, size: 20),
          const SizedBox(width: 8),
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
                label: const Text('اعتماد الكل'),
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
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _bulkReject(),
                icon: const Icon(Icons.close, size: 16),
                label: const Text('رفض الكل'),
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
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _bulkDelete(),
                icon: const Icon(Icons.delete, size: 16),
                label: const Text('حذف الكل'),
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
              const SizedBox(width: 12),
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
                child: const Text('إلغاء التحديد'),
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
            ? AppColors.primaryLight.withOpacity(0.1)
            : (isEven ? Colors.grey.withOpacity(0.02) : Colors.white),
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
          const SizedBox(width: 8),

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
                const SizedBox(height: 4),
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
                  const SizedBox(width: 8),
                  _buildActionButton(
                    icon: Icons.close,
                    color: errorColor,
                    tooltip: 'رفض',
                    onPressed: () =>
                        _rejectAchievementWithConfirmation(achievement),
                  ),
                  const SizedBox(width: 8),
                ],
                _buildActionButton(
                  icon: Icons.visibility,
                  color: AppColors.primaryDark,
                  tooltip: 'عرض',
                  onPressed: () => _viewAchievementDetails(achievement),
                ),
                const SizedBox(width: 8),
                _buildActionButton(
                  icon: Icons.edit,
                  color: AppColors.primaryMedium,
                  tooltip: 'تعديل',
                  onPressed: () => _editAchievement(achievement),
                ),
                const SizedBox(width: 8),
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
        title: const Text('تأكيد الاعتماد المجمع'),
        content: Text(
          'هل أنت متأكد من اعتماد ${_selectedAchievements.length} منجز؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performBulkAction('approved');
            },
            style: ElevatedButton.styleFrom(backgroundColor: successColor),
            child: const Text(
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
        title: const Text('تأكيد الرفض المجمع'),
        content: Text(
          'هل أنت متأكد من رفض ${_selectedAchievements.length} منجز؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performBulkAction('rejected');
            },
            style: ElevatedButton.styleFrom(backgroundColor: errorColor),
            child: const Text(
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
        title: const Text('تأكيد الحذف المجمع'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('هل أنت متأكد من حذف ${_selectedAchievements.length} منجز؟'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: errorColor.withOpacity(0.3)),
              ),
              child: const Row(
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
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performBulkDelete();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
            child: const Text(
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
        label = 'قيد المراجعة';
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
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
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
              color: color.withOpacity(0.1),
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
            color: Colors.grey.withOpacity(0.1),
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
            color: AppColors.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد منجزات تطابق البحث',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Text(
            'جرب تغيير معايير البحث أو الفلترة',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceVariant.withOpacity(0.7),
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
            color: Colors.grey.withOpacity(0.1),
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
            color: errorColor.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          Text(
            'حدث خطأ',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: errorColor),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => setState(() {}),
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاولة'),
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
        title: const Text('تأكيد الاعتماد'),
        content: Text('هل أنت متأكد من اعتماد منجز "${achievement.topic}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _approveAchievement(achievement.id!);
            },
            style: ElevatedButton.styleFrom(backgroundColor: successColor),
            child: const Text('اعتماد', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _rejectAchievementWithConfirmation(Achievement achievement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الرفض'),
        content: Text('هل أنت متأكد من رفض منجز "${achievement.topic}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _rejectAchievement(achievement.id!);
            },
            style: ElevatedButton.styleFrom(backgroundColor: errorColor),
            child: const Text('رفض', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _deleteAchievementWithConfirmation(Achievement achievement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('هل أنت متأكد من حذف منجز "${achievement.topic}"؟'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: errorColor.withOpacity(0.3)),
              ),
              child: const Row(
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
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAchievement(achievement.id!);
            },
            style: ElevatedButton.styleFrom(backgroundColor: errorColor),
            child: const Text(
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
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
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
              const SizedBox(height: 16),

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

              const SizedBox(height: 24),
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
                        label: const Text('اعتماد'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: successColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _rejectAchievementWithConfirmation(achievement);
                        },
                        icon: const Icon(Icons.close),
                        label: const Text('رفض'),
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
                        label: const Text('تعديل'),
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
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDark,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.onSurface),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'قيد المراجعة';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إدارة المستخدمين',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        const Center(
          child: Text(
            'قسم إدارة المستخدمين\n(قيد التطوير)',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: AppColors.onSurfaceVariant),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'التحليلات والإحصائيات',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        const Center(
          child: Text(
            'قسم التحليلات والإحصائيات\n(قيد التطوير)',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: AppColors.onSurfaceVariant),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الإعدادات',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        const Center(
          child: Text(
            'قسم الإعدادات\n(قيد التطوير)',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: AppColors.onSurfaceVariant),
          ),
        ),
      ],
    );
  }

  Widget _buildSidebarFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Divider(color: Colors.white24, thickness: 1),
          const SizedBox(height: 16),
          // User Info
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: const Icon(Icons.person, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
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
}
