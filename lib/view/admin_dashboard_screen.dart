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
  void _approveAchievement(String id) {
    // Implementation for approving achievement
  }

  void _rejectAchievement(String id) {
    // Implementation for rejecting achievement
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'جميع الإنجازات',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _achievements.length,
          itemBuilder: (context, index) {
            final achievement = _achievements[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: successColor.withOpacity(0.1),
                  child: Icon(Icons.emoji_events, color: successColor),
                ),
                title: Text(achievement.topic),
                subtitle: Text(achievement.goal),
                trailing: Text(
                  achievement.status,
                  style: TextStyle(
                    color: achievement.status == 'approved'
                        ? successColor
                        : errorColor,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
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
