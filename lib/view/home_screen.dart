import 'package:achgate/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:math' as math;
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'add_achievement_screen.dart';
import 'view_achievements_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> 
    with TickerProviderStateMixin {
  final _authService = AuthService();
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  
  int _selectedSidebarIndex = 0;
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  // Mock data for dashboard
  final Map<String, dynamic> _dashboardData = {
    'totalAchievements': 145,
    'monthlyAverage': 18,
    'dailyAverage': 4,
    'topCategory': 'الرعاية الأولية',
    'weeklyData': [12, 18, 23, 15, 28, 21, 25],
    'monthlyData': [145, 162, 138, 191, 158, 175],
    'categoryData': {
      'الرعاية الأولية': 45,
      'الإداري': 35,
      'التدريب': 30,
      'البحث والتطوير': 25,
      'أخرى': 10,
    },
    'recentAchievements': [
      {
        'date': '2025-01-13',
        'category': 'الرعاية الأولية',
        'description': 'تطوير برنامج الفحص الوقائي للمرضى المزمنين',
        'status': 'completed',
      },
      {
        'date': '2025-01-12',
        'category': 'التدريب',
        'description': 'إنجاز برنامج التدريب على تقنيات الذكاء الاصطناعي',
        'status': 'in_progress',
      },
      {
        'date': '2025-01-11',
        'category': 'البحث والتطوير',
        'description': 'نشر بحث حول تحسين جودة الخدمات الصحية',
        'status': 'completed',
      },
    ],
  };

  final List<Map<String, dynamic>> _sidebarItems = [
    {'icon': Icons.dashboard_outlined, 'activeIcon': Icons.dashboard, 'title': 'لوحة التحكم', 'index': 0},
    {'icon': Icons.add_circle_outline, 'activeIcon': Icons.add_circle, 'title': 'إضافة منجز', 'index': 1},
    {'icon': Icons.list_alt_outlined, 'activeIcon': Icons.list_alt, 'title': 'عرض المنجزات', 'index': 2},
    {'icon': Icons.analytics_outlined, 'activeIcon': Icons.analytics, 'title': 'التقارير', 'index': 3},
    {'icon': Icons.settings_outlined, 'activeIcon': Icons.settings, 'title': 'الإعدادات', 'index': 4},
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _scrollController.addListener(_onScroll);
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
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(_rotationController);

    // Start animations
    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
  }

  void _onScroll() {
    final isScrolled = _scrollController.offset > 50;
    if (isScrolled != _isScrolled) {
      setState(() {
        _isScrolled = isScrolled;
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _rotationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isWeb = kIsWeb;
    final isDesktop = screenSize.width > 1024;
    final isTablet = screenSize.width > 768 && screenSize.width <= 1024;

    if (isWeb && isDesktop) {
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
      body: Row(
        children: [
          // Sidebar Navigation
          _buildSidebar(),
          
          // Main Content Area
          Expanded(
            child: Column(
              children: [
                // Transparent App Bar
                _buildTransparentAppBar(),
                
                // Main Content
                Expanded(
                  child: _buildMainContent(),
                ),
              ],
            ),
          ),
        ],
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
                Expanded(
                  child: _buildSidebarNavigation(),
                ),
                
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
          AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationAnimation.value * 0.1,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.local_hospital,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'تجمع جدة الصحي الثاني',
            style: AppTypography.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'نظام إدارة المنجزات',
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
              position: Tween<Offset>(
                begin: Offset(-1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _slideController,
                curve: Interval(
                  index * 0.1, 
                  1.0, 
                  curve: Curves.easeOutCubic,
                ),
              )),
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
                              style: AppTypography.textTheme.bodyMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: isSelected 
                                  ? FontWeight.w600 
                                  : FontWeight.normal,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
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

  Widget _buildSidebarFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Divider(
            color: Colors.white24,
            thickness: 1,
          ),
          const SizedBox(height: 16),
          
          // User Info
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _authService.currentUser?.email?.split('@')[0] ?? 'مستخدم',
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'موظف',
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _handleLogout,
                icon: const Icon(
                  Icons.logout,
                  color: Colors.white,
                  size: 20,
                ),
                tooltip: 'تسجيل الخروج',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransparentAppBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 80,
      decoration: BoxDecoration(
        color: _isScrolled 
          ? Colors.white.withOpacity(0.95)
          : Colors.transparent,
        boxShadow: _isScrolled
          ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ]
          : null,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getSectionTitle(),
                    style: AppTypography.textTheme.headlineSmall?.copyWith(
                      color: _isScrolled ? AppColors.primaryDark : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _getSectionSubtitle(),
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: _isScrolled 
                        ? AppColors.secondaryGray 
                        : Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            
            // Action Buttons
            Row(
              children: [
                _buildAppBarButton(
                  icon: Icons.notifications_outlined,
                  onPressed: _showNotificationsDialog,
                  tooltip: 'الإشعارات',
                ),
                const SizedBox(width: 8),
                _buildAppBarButton(
                  icon: Icons.search,
                  onPressed: _showSearchDialog,
                  tooltip: 'البحث',
                ),
                const SizedBox(width: 8),
                _buildAppBarButton(
                  icon: Icons.fullscreen,
                  onPressed: _toggleFullscreen,
                  tooltip: 'ملء الشاشة',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBarButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (_isScrolled ? AppColors.primaryDark : Colors.white)
                .withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (_isScrolled ? AppColors.primaryDark : Colors.white)
                  .withOpacity(0.2),
              ),
            ),
            child: Icon(
              icon,
              color: _isScrolled ? AppColors.primaryDark : Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primaryLight.withOpacity(0.1),
            Colors.white,
          ],
        ),
      ),
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: _buildDashboardContent(),
            ),
          ),
        ],
      ),
    );
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
                // Welcome Section
                _buildWelcomeSection(),
                
                const SizedBox(height: 40),
                
                // KPI Cards
                _buildKPICardsGrid(),
                
                const SizedBox(height: 40),
                
                // Charts and Recent Activity
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Charts Section
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          _buildWeeklyChart(),
                          const SizedBox(height: 24),
                          _buildCategoryChart(),
                        ],
                      ),
                    ),
                    
                    const SizedBox(width: 24),
                    
                    // Recent Activities
                    Expanded(
                      flex: 1,
                      child: _buildRecentActivities(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeSection() {
    final currentHour = DateTime.now().hour;
    String greeting;
    IconData greetingIcon;
    
    if (currentHour < 12) {
      greeting = 'صباح الخير';
      greetingIcon = Icons.wb_sunny;
    } else if (currentHour < 17) {
      greeting = 'مساء الخير';
      greetingIcon = Icons.wb_sunny_outlined;
    } else {
      greeting = 'مساء الخير';
      greetingIcon = Icons.nights_stay;
    }

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryDark.withOpacity(0.1),
            AppColors.primaryLight.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primaryLight.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      greetingIcon,
                      color: AppColors.primaryDark,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      greeting,
                      style: AppTypography.textTheme.headlineMedium?.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'مرحباً بك في نظام إدارة المنجزات',
                  style: AppTypography.textTheme.titleMedium?.copyWith(
                    color: AppColors.secondaryGray,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'تتبع منجزاتك اليومية وساهم في تطوير الخدمات الصحية',
                  style: AppTypography.textTheme.bodyLarge?.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
          // Quick Action Button
          Container(
            margin: const EdgeInsets.only(left: 24),
            child: ElevatedButton.icon(
              onPressed: () => _onSidebarItemTap(1),
              icon: const Icon(Icons.add),
              label: const Text('إضافة منجز جديد'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                shadowColor: AppColors.primaryDark.withOpacity(0.3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKPICardsGrid() {
    final kpiData = [
      {
        'title': 'إجمالي المنجزات',
        'value': '${_dashboardData['totalAchievements']}',
        'icon': Icons.emoji_events,
        'color': AppColors.primaryDark,
        'trend': '+12%',
        'subtitle': 'هذا الشهر',
      },
      {
        'title': 'المتوسط الشهري',
        'value': '${_dashboardData['monthlyAverage']}',
        'icon': Icons.trending_up,
        'color': AppColors.success,
        'trend': '+8%',
        'subtitle': 'مقارنة بالشهر السابق',
      },
      {
        'title': 'المتوسط اليومي',
        'value': '${_dashboardData['dailyAverage']}',
        'icon': Icons.today,
        'color': AppColors.info,
        'trend': '+5%',
        'subtitle': 'هذا الأسبوع',
      },
      {
        'title': 'الفئة الأكثر نشاطاً',
        'value': _dashboardData['topCategory'],
        'icon': Icons.star,
        'color': AppColors.warning,
        'trend': '',
        'subtitle': 'القسم الرائد',
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 800 ? 4 : 2;
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 1.5,
          ),
          itemCount: kpiData.length,
          itemBuilder: (context, index) {
            return _buildKPICard(kpiData[index], index);
          },
        );
      },
    );
  }

  Widget _buildKPICard(Map<String, dynamic> data, int index) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return ScaleTransition(
          scale: Tween<double>(
            begin: 0.8,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: _scaleController,
            curve: Interval(
              index * 0.1,
              1.0,
              curve: Curves.elasticOut,
            ),
          )),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: data['color'].withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(
                color: data['color'].withOpacity(0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: data['color'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        data['icon'],
                        color: data['color'],
                        size: 24,
                      ),
                    ),
                    const Spacer(),
                    if (data['trend'].isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          data['trend'],
                          style: AppTypography.textTheme.bodySmall?.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  data['value'],
                  style: AppTypography.textTheme.headlineMedium?.copyWith(
                    color: data['color'],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                Text(
                  data['title'],
                  style: AppTypography.textTheme.titleSmall?.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                Text(
                  data['subtitle'],
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: AppColors.secondaryGray,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeeklyChart() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.bar_chart,
                color: AppColors.primaryDark,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'الأداء الأسبوعي',
                style: AppTypography.textTheme.titleLarge?.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.more_horiz),
                label: const Text('المزيد'),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Simple Bar Chart
          Container(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(
                _dashboardData['weeklyData'].length,
                (index) {
                  final value = _dashboardData['weeklyData'][index];
                  final maxValue = _dashboardData['weeklyData']
                      .reduce((a, b) => a > b ? a : b);
                  final height = (value / maxValue) * 160;
                  
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AnimatedContainer(
                            duration: Duration(milliseconds: 800 + index * 100),
                            height: height,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  AppColors.primaryDark,
                                  AppColors.primaryLight,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            ['ح', 'ن', 'ث', 'ر', 'خ', 'ج', 'س'][index],
                            style: AppTypography.textTheme.bodySmall?.copyWith(
                              color: AppColors.secondaryGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChart() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.pie_chart,
                color: AppColors.primaryDark,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'توزيع المنجزات حسب الفئة',
                style: AppTypography.textTheme.titleLarge?.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Category Bars
          ...(_dashboardData['categoryData'] as Map<String, int>)
              .entries
              .map((entry) => _buildCategoryBar(entry.key, entry.value))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildCategoryBar(String category, int value) {
    final maxValue = (_dashboardData['categoryData'] as Map<String, int>)
        .values
        .reduce((a, b) => a > b ? a : b);
    final percentage = (value / maxValue);
    
    final colors = [
      AppColors.primaryDark,
      AppColors.primaryMedium,
      AppColors.success,
      AppColors.warning,
      AppColors.info,
    ];
    
    final colorIndex = (_dashboardData['categoryData'] as Map<String, int>)
        .keys
        .toList()
        .indexOf(category) % colors.length;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  category,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                '$value',
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: colors[colorIndex],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: colors[colorIndex].withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 1000),
                decoration: BoxDecoration(
                  color: colors[colorIndex],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivities() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.history,
                color: AppColors.primaryDark,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'آخر الأنشطة',
                style: AppTypography.textTheme.titleLarge?.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          ...(_dashboardData['recentAchievements'] as List)
              .take(5)
              .map((achievement) => _buildActivityItem(achievement))
              .toList(),
          
          const SizedBox(height: 16),
          
          Center(
            child: TextButton(
              onPressed: () => _onSidebarItemTap(2),
              child: const Text('عرض جميع المنجزات'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> achievement) {
    final statusColor = achievement['status'] == 'completed' 
        ? AppColors.success 
        : AppColors.warning;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  achievement['category'],
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                achievement['date'].substring(5),
                style: AppTypography.textTheme.bodySmall?.copyWith(
                  color: AppColors.secondaryGray,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            achievement['description'],
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurface,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Tablet Layout
  Widget _buildTabletLayout() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('لوحة التحكم'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: _buildDashboardContent(),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  // Mobile Layout
  Widget _buildMobileLayout() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('لوحة التحكم'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: _buildDashboardContent(),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: _selectedSidebarIndex.clamp(0, 2),
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
          icon: Icon(Icons.add_circle_outline),
          activeIcon: Icon(Icons.add_circle),
          label: 'إضافة',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list_alt_outlined),
          activeIcon: Icon(Icons.list_alt),
          label: 'المنجزات',
        ),
      ],
    );
  }

  // Helper Methods
  String _getSectionTitle() {
    switch (_selectedSidebarIndex) {
      case 0:
        return 'لوحة التحكم';
      case 1:
        return 'إضافة منجز جديد';
      case 2:
        return 'عرض المنجزات';
      case 3:
        return 'التقارير والإحصائيات';
      case 4:
        return 'الإعدادات';
      default:
        return 'لوحة التحكم';
    }
  }

  String _getSectionSubtitle() {
    switch (_selectedSidebarIndex) {
      case 0:
        return 'نظرة عامة على أداءك وإحصائياتك';
      case 1:
        return 'سجل منجزاً جديداً في النظام';
      case 2:
        return 'تصفح وإدارة جميع منجزاتك';
      case 3:
        return 'تقارير مفصلة وتحليلات';
      case 4:
        return 'تخصيص إعدادات النظام';
      default:
        return 'مرحباً بك في نظام إدارة المنجزات';
    }
  }

  void _onSidebarItemTap(int index) {
    setState(() {
      _selectedSidebarIndex = index;
    });

    // Navigate to different screens based on selection
    switch (index) {
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AddAchievementScreen(),
          ),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ViewAchievementsScreen(),
          ),
        );
        break;
      case 3:
        // Navigate to reports screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('شاشة التقارير قيد التطوير'),
            backgroundColor: AppColors.info,
          ),
        );
        break;
      case 4:
        // Navigate to settings screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('شاشة الإعدادات قيد التطوير'),
            backgroundColor: AppColors.info,
          ),
        );
        break;
    }
  }

  void _showNotificationsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('الإشعارات'),
          content: const SizedBox(
            width: 300,
            height: 200,
            child: Center(
              child: Text('لا توجد إشعارات جديدة'),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إغلاق'),
            ),
          ],
        );
      },
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('البحث'),
          content: const SizedBox(
            width: 300,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'ابحث في المنجزات...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('بحث'),
            ),
          ],
        );
      },
    );
  }

  void _toggleFullscreen() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('وضع ملء الشاشة غير مدعوم في هذا المتصفح'),
        backgroundColor: AppColors.warning,
      ),
    );
  }

  Future<void> _handleLogout() async {
    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء تسجيل الخروج: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
