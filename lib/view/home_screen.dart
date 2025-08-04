import 'package:achgate/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';
import '../theme/app_components.dart';
import 'login_screen.dart';
import '../services/achievement_service.dart';
import '../services/departments_service.dart';
import '../models/achievement.dart';
import 'edit_achievement_screen.dart';
import 'view_achievements_screen.dart';
import 'profile_demo_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final _authService = AuthService();
  final _achievementService = AchievementService();
  late AnimationController _fadeController;
  late AnimationController _slideController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int _selectedSidebarIndex = 0;
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  String _selectedAchievementsFilter = 'all';
  final TextEditingController _searchController = TextEditingController();

  // Form key and controllers for Add Achievement
  final _formKey = GlobalKey<FormState>();
  final _participationTypeController = TextEditingController();
  final _executiveDepartmentController = TextEditingController();
  final _mainDepartmentController = TextEditingController();
  final _subDepartmentController = TextEditingController();
  final _topicController = TextEditingController();
  final _goalController = TextEditingController();
  final _dateController = TextEditingController();
  final _locationController = TextEditingController();
  final _durationController = TextEditingController();
  final _impactController = TextEditingController();

  // Form state for Add Achievement
  String? _selectedParticipationType;
  String? _selectedExecutiveDepartment;
  String? _selectedMainDepartment;
  String? _selectedSubDepartment;
  DateTime? _selectedDate;
  List<PlatformFile> _selectedFiles = [];
  bool _isLoading = false;

  // Departments data structure - Three-tier hierarchy
  final DepartmentsService _departmentsService = DepartmentsService();

  // Get main departments list for selected executive department
  List<String> get _availableMainDepartments {
    if (_selectedExecutiveDepartment == null) return [];
    return _departmentsService.getMainDepartments(
      _selectedExecutiveDepartment!,
    );
  }

  // Get sub departments list for selected main department
  List<String> get _availableSubDepartments {
    if (_selectedExecutiveDepartment == null || _selectedMainDepartment == null)
      return [];
    return _departmentsService.getSubDepartments(
      _selectedExecutiveDepartment!,
      _selectedMainDepartment!,
    );
  }

  // Participation types
  final List<String> _participationTypes = [
    'مبادرة',
    'تدشين',
    'مشاركة',
    'فعالية',
    'حملة',
    'لقاء',
    'محاضرة',
    'دورة تدريبية',
    'اجتماع',
    'شراكة مجتمعية',
    'ورشة تدريبية',
    'معرض',
    'ملتقى',
    'نشاط',
    'لوحة بيانات',
    'تفعيل أيام عالمية',
    'تفعيل',
    'مؤتمر',
    'خبر',
    'اعتماد',
    'إصدار دليل',
    'تنفيذ برنامج',
    'ركن',
    'بروشور',
    'بوستر',
    'رول أب',
    'تغريدة X',
    'منشور سناب شات',
    'منشور تيك توك',
    'منشور إنستقرام',
    'خدمة جديدة',
    'جائزة',
    'تكريم',
    'مشروع',
    'مؤشر متميز',
    'قصة نجاح',
    'ابتكار',
    'أخرى',
  ];

  final List<Map<String, dynamic>> _achievementFilterOptions = [
    {'value': 'all', 'label': 'جميع المنجزات', 'icon': Icons.list_alt},
    {'value': 'pending', 'label': 'معلقة', 'icon': Icons.hourglass_empty},
    {'value': 'approved', 'label': 'معتمدة', 'icon': Icons.check_circle},
    {'value': 'rejected', 'label': 'مرفوضة', 'icon': Icons.cancel},
  ];

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
    {
      'icon': Icons.dashboard_outlined,
      'activeIcon': Icons.dashboard,
      'title': 'لوحة التحكم',
      'index': 0,
    },
    {
      'icon': Icons.add_circle_outline,
      'activeIcon': Icons.add_circle,
      'title': 'إضافة منجز',
      'index': 1,
    },
    {
      'icon': Icons.list_alt_outlined,
      'activeIcon': Icons.list_alt,
      'title': 'عرض المنجزات',
      'index': 2,
    },
    {
      'icon': Icons.analytics_outlined,
      'activeIcon': Icons.analytics,
      'title': 'التقارير',
      'index': 3,
    },
    {
      'icon': Icons.person_outline,
      'activeIcon': Icons.person,
      'title': 'الملف الشخصي',
      'index': 4,
    },
    {
      'icon': Icons.settings_outlined,
      'activeIcon': Icons.settings,
      'title': 'الإعدادات',
      'index': 5,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _scrollController.addListener(_onScroll);
    _loadDepartmentsData();
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

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    _participationTypeController.dispose();
    _executiveDepartmentController.dispose();
    _mainDepartmentController.dispose();
    _subDepartmentController.dispose();
    _topicController.dispose();
    _goalController.dispose();
    _dateController.dispose();
    _locationController.dispose();
    _durationController.dispose();
    _impactController.dispose();
    super.dispose();
  }

  // Function to load departments data
  Future<void> _loadDepartmentsData() async {
    try {
      // Load departments using the service
      await _departmentsService.loadDepartments();

      setState(() {
        // Update UI after loading
      });
    } catch (e) {
      // Handle error loading departments data
      debugPrint('Error loading departments data: $e');

      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'خطأ في تحميل بيانات الإدارات: $e',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
        );
      }
    }
  }

  // Helper method to format date in Arabic style
  String _formatDate(DateTime date) {
    // Format as DD/MM/YYYY with leading zeros
    String day = date.day.toString().padLeft(2, '0');
    String month = date.month.toString().padLeft(2, '0');
    String year = date.year.toString();
    return '$day/$month/$year';
  }

  // Helper method to get file icon based on file extension
  IconData _getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case '.pdf':
        return Icons.picture_as_pdf;
      case '.doc':
      case '.docx':
        return Icons.description;
      case '.jpg':
      case '.jpeg':
      case '.png':
      case '.gif':
        return Icons.image;
      case '.mp4':
      case '.mov':
      case '.avi':
        return Icons.video_file;
      case '.mp3':
      case '.wav':
      case '.m4a':
        return Icons.audio_file;
      case '.xlsx':
      case '.xls':
        return Icons.table_chart;
      case '.pptx':
      case '.ppt':
        return Icons.slideshow;
      default:
        return Icons.insert_drive_file;
    }
  }

  // Helper method to format file size
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // Helper method to build file item widget
  Widget _buildFileItem(PlatformFile file) {
    final extension = file.extension != null ? '.${file.extension}' : '';
    final fileIcon = _getFileIcon(extension);
    final fileSize = file.size > 0 ? _formatFileSize(file.size) : 'غير معروف';

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.xs),
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.outline.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
            ),
            child: Icon(fileIcon, size: 20, color: AppColors.primaryMedium),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  style: AppTypography.textTheme.bodySmall!.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  fileSize,
                  style: AppTypography.textTheme.bodySmall!.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: AppColors.error),
            tooltip: 'حذف الملف',
            onPressed: () {
              setState(() {
                _selectedFiles.remove(file);
              });
            },
          ),
        ],
      ),
    );
  }

  // Helper method to clear all selected files
  void _clearAllFiles() {
    setState(() {
      _selectedFiles.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'تم مسح جميع الملفات',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryMedium,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),
    );
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
                _buildtAppBar(),

                // Main Content
                Expanded(child: _buildMainContent()),
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
          SizedBox(
            child: Image.asset(
              'assets/images/portal_logo_white.png',
              fit: BoxFit.cover,
            ),
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
              position:
                  Tween<Offset>(
                    begin: Offset(-1.0, 0.0),
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
                              style: AppTypography.textTheme.bodyMedium
                                  ?.copyWith(
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
                      _authService.currentUser?.email?.split('@')[0] ??
                          'مستخدم',
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
                icon: const Icon(Icons.logout, color: Colors.white, size: 20),
                tooltip: 'تسجيل الخروج',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildtAppBar() {
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
          // Glassmorphism overlay
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: _isScrolled
                  ? [Colors.white.withOpacity(0.1), Colors.transparent]
                  : [
                      Colors.white.withOpacity(0.15),
                      Colors.white.withOpacity(0.05),
                      Colors.transparent,
                    ],
            ),
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color:
                              (_isScrolled
                                      ? AppColors.primaryLight
                                      : Colors.white)
                                  .withOpacity(0.15),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color:
                                (_isScrolled
                                        ? AppColors.primaryLight
                                        : Colors.white)
                                    .withOpacity(0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: _isScrolled
                                ? [
                                    AppColors.primaryDark,
                                    AppColors.primaryMedium,
                                  ]
                                : [
                                    Colors.white,
                                    Colors.white.withOpacity(0.95),
                                  ],
                          ).createShader(bounds),
                          child: Text(
                            _getSectionTitle(),
                            style: AppTypography.textTheme.headlineMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                  fontSize: 22,
                                  shadows: _isScrolled
                                      ? null
                                      : [
                                          Shadow(
                                            offset: const Offset(0, 3),
                                            blurRadius: 6,
                                            color: Colors.black.withOpacity(
                                              0.4,
                                            ),
                                          ),
                                        ],
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _getSectionSubtitle(),
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          color: _isScrolled
                              ? AppColors.secondaryGray
                              : Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // Action Buttons with enhanced design
                Row(
                  children: [
                    _buildModernAppBarButton(
                      icon: Icons.notifications_rounded,
                      onPressed: _showNotificationsDialog,
                      tooltip: 'الإشعارات',
                      hasNotification: true,
                    ),
                    const SizedBox(width: 10),
                    _buildModernAppBarButton(
                      icon: Icons.search_rounded,
                      onPressed: _showSearchDialog,
                      tooltip: 'البحث',
                    ),
                    const SizedBox(width: 10),
                    _buildModernAppBarButton(
                      icon: Icons.tune_rounded,
                      onPressed: _toggleFullscreen,
                      tooltip: 'الإعدادات',
                    ),
                    const SizedBox(width: 10),
                    _buildModernAppBarButton(
                      icon: Icons.logout_rounded,
                      onPressed: _handleLogout,
                      tooltip: 'تسجيل الخروج',
                      isDestructive: true,
                    ),
                  ],
                ),
              ],
            ),
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
    bool isDestructive = false,
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
                  gradient: LinearGradient(
                    colors: [
                      (_isScrolled ? AppColors.primaryLight : Colors.white)
                          .withOpacity(0.2),
                      (_isScrolled ? AppColors.primaryMedium : Colors.white)
                          .withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: (_isScrolled ? AppColors.primaryLight : Colors.white)
                        .withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          (_isScrolled ? AppColors.primaryDark : Colors.black)
                              .withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
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
        return _buildAddAchievementContent();
      case 2:
        return _buildViewAchievementsContent();
      case 3:
        return _buildReportsContent();
      case 4:
        return _buildProfileContent();
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
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white,
                    AppColors.primaryLight.withOpacity(0.02),
                    AppColors.primaryLight.withOpacity(0.05),
                  ],
                  stops: const [0.0, 0.7, 1.0],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Enhanced Welcome Section with Hero Animation
                  Hero(
                    tag: 'welcome_section',
                    child: Material(
                      color: Colors.transparent,
                      child: _buildEnhancedWelcomeSection(),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Quick Stats Section
                  _buildQuickStatsSection(),

                  const SizedBox(height: 32),

                  // Enhanced KPI Cards with Staggered Animation
                  _buildEnhancedKPICardsGrid(),

                  const SizedBox(height: 48),

                  // Charts and Analytics Section with Enhanced Layout
                  _buildAnalyticsSection(),

                  const SizedBox(height: 48),

                  // Bottom Actions Section
                  _buildBottomActionsSection(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedWelcomeSection() {
    final currentHour = DateTime.now().hour;
    String greeting;
    IconData greetingIcon;
    Color greetingColor;

    if (currentHour < 12) {
      greeting = 'صباح الخير';
      greetingIcon = Icons.wb_sunny;
      greetingColor = Colors.orange;
    } else if (currentHour < 17) {
      greeting = 'مساء الخير';
      greetingIcon = Icons.wb_sunny_outlined;
      greetingColor = Colors.amber;
    } else {
      greeting = 'مساء الخير';
      greetingIcon = Icons.nights_stay;
      greetingColor = Colors.indigo;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryDark.withOpacity(0.95),
            AppColors.primaryMedium.withOpacity(0.85),
            AppColors.primaryLight.withOpacity(0.75),
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
            spreadRadius: 5,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
      ),
      child: Stack(
        children: [
          // Background decoration
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Colors.white.withOpacity(0.1), Colors.transparent],
                ),
              ),
            ),
          ),

          // Main content
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting with animation
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 800),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: 0.8 + (0.2 * value),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: greetingColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: greetingColor.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  greetingIcon,
                                  color: greetingColor,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    greeting,
                                    style: AppTypography
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                  ),
                                  Text(
                                    _authService.currentUser?.email?.split(
                                          '@',
                                        )[0] ??
                                        'مستخدم',
                                    style: AppTypography.textTheme.titleMedium
                                        ?.copyWith(
                                          color: Colors.white.withOpacity(0.8),
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Welcome message with enhanced styling
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'مرحباً بك في نظام إدارة المنجزات',
                            style: AppTypography.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'تتبع منجزاتك اليومية وساهم في تطوير الخدمات الصحية',
                            style: AppTypography.textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 32),

              // Enhanced Action Buttons
              Column(
                children: [
                  _buildEnhancedActionButton(
                    icon: Icons.add_circle_rounded,
                    label: 'إضافة منجز جديد',
                    color: Colors.white,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    onPressed: () => _onSidebarItemTap(1),
                  ),
                  const SizedBox(height: 12),
                  _buildEnhancedActionButton(
                    icon: Icons.analytics_rounded,
                    label: 'عرض التقارير',
                    color: Colors.white.withOpacity(0.8),
                    backgroundColor: Colors.white.withOpacity(0.1),
                    onPressed: () => _onSidebarItemTap(3),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color backgroundColor,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStatsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildQuickStatCard(
              title: 'منجزات اليوم',
              value: '12',
              icon: Icons.today_rounded,
              color: AppColors.success,
              trend: '+3',
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildQuickStatCard(
              title: 'معلقة',
              value: '8',
              icon: Icons.pending_actions_rounded,
              color: AppColors.warning,
              trend: '+2',
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildQuickStatCard(
              title: 'معتمدة',
              value: '145',
              icon: Icons.check_circle_rounded,
              color: AppColors.primaryDark,
              trend: '+15',
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildQuickStatCard(
              title: 'هذا الأسبوع',
              value: '28',
              icon: Icons.calendar_view_week_rounded,
              color: AppColors.info,
              trend: '+8',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String trend,
  }) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, animationValue, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - animationValue)),
          child: Opacity(
            opacity: animationValue,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withOpacity(0.1), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: 2,
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
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: color, size: 20),
                      ),
                      const Spacer(),
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
                          trend,
                          style: AppTypography.textTheme.bodySmall?.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    value,
                    style: AppTypography.textTheme.headlineMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurface.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnalyticsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isLargeScreen = constraints.maxWidth > 1200;

          if (isLargeScreen) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left side - Charts
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

                // Right side - Recent Activities
                Expanded(flex: 1, child: _buildRecentActivities()),
              ],
            );
          } else {
            return Column(
              children: [
                _buildWeeklyChart(),
                const SizedBox(height: 24),
                _buildCategoryChart(),
                const SizedBox(height: 24),
                _buildRecentActivities(),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildEnhancedKPICardsGrid() {
    final kpiData = [
      {
        'title': 'إجمالي المنجزات',
        'value': '${_dashboardData['totalAchievements']}',
        'icon': Icons.emoji_events,
        'color': AppColors.primaryDark,
        'trend': '+12%',
        'subtitle': 'هذا الشهر',
        'bgGradient': [AppColors.primaryDark, AppColors.primaryLight],
      },
      {
        'title': 'المتوسط الشهري',
        'value': '${_dashboardData['monthlyAverage']}',
        'icon': Icons.trending_up,
        'color': AppColors.success,
        'trend': '+8%',
        'subtitle': 'مقارنة بالشهر السابق',
        'bgGradient': [AppColors.success, AppColors.success.withOpacity(0.6)],
      },
      {
        'title': 'المتوسط اليومي',
        'value': '${_dashboardData['dailyAverage']}',
        'icon': Icons.today,
        'color': AppColors.info,
        'trend': '+5%',
        'subtitle': 'هذا الأسبوع',
        'bgGradient': [AppColors.info, AppColors.info.withOpacity(0.6)],
      },
      {
        'title': 'الفئة الأكثر نشاطاً',
        'value': _dashboardData['topCategory'],
        'icon': Icons.star,
        'color': AppColors.warning,
        'trend': '',
        'subtitle': 'القسم الرائد',
        'bgGradient': [AppColors.warning, AppColors.warning.withOpacity(0.6)],
      },
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth > 800 ? 4 : 2;
          final itemAspectRatio = constraints.maxWidth > 800 ? 1.6 : 1.4;

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: itemAspectRatio,
            ),
            itemCount: kpiData.length,
            itemBuilder: (context, index) {
              return _buildEnhancedKPICard(kpiData[index], index);
            },
          );
        },
      ),
    );
  }

  Widget _buildEnhancedKPICard(Map<String, dynamic> data, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + (index * 150)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, animationValue, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - animationValue)),
          child: Transform.scale(
            scale: 0.9 + (0.1 * animationValue),
            child: Opacity(
              opacity: animationValue,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, data['color'].withOpacity(0.02)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: data['color'].withOpacity(0.15),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: data['color'].withOpacity(0.08),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                      spreadRadius: 3,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Background pattern
                    Positioned(
                      top: -20,
                      right: -20,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              data['color'].withOpacity(0.08),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Main content
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: data['bgGradient'],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: data['color'].withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  data['icon'],
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const Spacer(),
                              if (data['trend'].isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.success.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.trending_up,
                                        color: AppColors.success,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        data['trend'],
                                        style: AppTypography.textTheme.bodySmall
                                            ?.copyWith(
                                              color: AppColors.success,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          Text(
                            data['value'],
                            style: AppTypography.textTheme.headlineLarge
                                ?.copyWith(
                                  color: data['color'],
                                  fontWeight: FontWeight.bold,
                                  height: 1.0,
                                ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            data['title'],
                            style: AppTypography.textTheme.titleMedium
                                ?.copyWith(
                                  color: AppColors.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            data['subtitle'],
                            style: AppTypography.textTheme.bodySmall?.copyWith(
                              color: AppColors.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomActionsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryLight.withOpacity(0.1),
            AppColors.primaryMedium.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primaryLight.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Text(
            'إجراءات سريعة',
            style: AppTypography.textTheme.titleLarge?.copyWith(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.add_task_rounded,
                  title: 'إضافة منجز',
                  subtitle: 'أضف منجزاً جديداً',
                  color: AppColors.primaryDark,
                  onTap: () => _onSidebarItemTap(1),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.analytics_rounded,
                  title: 'التقارير',
                  subtitle: 'عرض الإحصائيات',
                  color: AppColors.success,
                  onTap: () => _onSidebarItemTap(3),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.settings_rounded,
                  title: 'الإعدادات',
                  subtitle: 'تخصيص النظام',
                  color: AppColors.info,
                  onTap: () => _onSidebarItemTap(4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.15), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTypography.textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
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
              Icon(Icons.bar_chart, color: AppColors.primaryDark, size: 24),
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
              children: List.generate(_dashboardData['weeklyData'].length, (
                index,
              ) {
                final value = _dashboardData['weeklyData'][index] as int;
                final maxValue = (_dashboardData['weeklyData'] as List<int>)
                    .reduce((int a, int b) => a > b ? a : b);
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
              }),
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
              Icon(Icons.pie_chart, color: AppColors.primaryDark, size: 24),
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
          ...(_dashboardData['categoryData'] as Map<String, int>).entries
              .map((entry) => _buildCategoryBar(entry.key, entry.value))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildCategoryBar(String category, int value) {
    final maxValue = (_dashboardData['categoryData'] as Map<String, int>).values
        .reduce((int a, int b) => a > b ? a : b);
    final percentage = (value / maxValue);

    final colors = [
      AppColors.primaryDark,
      AppColors.primaryMedium,
      AppColors.success,
      AppColors.warning,
      AppColors.info,
    ];

    final colorIndex =
        (_dashboardData['categoryData'] as Map<String, int>).keys
            .toList()
            .indexOf(category) %
        colors.length;

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
              Icon(Icons.history, color: AppColors.primaryDark, size: 24),
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
        border: Border.all(color: statusColor.withOpacity(0.2)),
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
      appBar: AppComponents.appBar(
        title: 'لوحة التحكم',
        automaticallyImplyLeading: false,
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_rounded),
              onPressed: _showNotificationsDialog,
              color: Colors.white,
              splashRadius: 20,
            ),
          ),
        ],
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
      appBar: AppComponents.appBar(
        title: 'لوحة التحكم',
        automaticallyImplyLeading: false,
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.menu_rounded),
              onPressed: () {
                // يمكن إضافة drawer أو side menu هنا
              },
              color: Colors.white,
              splashRadius: 20,
            ),
          ),
        ],
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

  // Content methods for different screens
  Widget _buildAddAchievementContent() {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 1024;
    final isTablet = screenSize.width > 768 && screenSize.width <= 1024;

    return Container(
      padding: const EdgeInsets.all(24),
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: _buildFormLayout(isDesktop, isTablet),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFormLayout(bool isDesktop, bool isTablet) {
    if (isDesktop) {
      return _buildDesktopFormLayout();
    } else if (isTablet) {
      return _buildTabletFormLayout();
    } else {
      return _buildMobileFormLayout();
    }
  }

  Widget _buildDesktopFormLayout() {
    return SingleChildScrollView(
      child: AppComponents.responsiveContainer(
        screenWidth: MediaQuery.of(context).size.width,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Form Section
            Expanded(flex: 7, child: _buildFormCard()),
            SizedBox(width: AppSpacing.xl),
            // Info Section
            Expanded(flex: 3, child: _buildInfoCard()),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletFormLayout() {
    return SingleChildScrollView(
      child: AppComponents.responsiveContainer(
        screenWidth: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            _buildInfoCard(),
            SizedBox(height: AppSpacing.xl),
            _buildFormCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileFormLayout() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          _buildInfoCard(),
          SizedBox(height: AppSpacing.lg),
          _buildFormCard(),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.95 + (0.05 * value),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  AppColors.primaryDark,
                  AppColors.primaryMedium,
                  AppColors.primaryLight.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryDark.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusLg,
                        ),
                      ),
                      child: const Icon(
                        Icons.add_task,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        'إضافة منجز جديد',
                        style: AppTypography.textTheme.headlineSmall!.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.lg),
                Text(
                  'قم بتعبئة جميع الحقول المطلوبة لإضافة منجز جديد إلى سجلك. تأكد من دقة المعلومات المدخلة.',
                  style: AppTypography.textTheme.bodyMedium!.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    height: 1.6,
                  ),
                ),
                SizedBox(height: AppSpacing.lg),
                _buildTipsList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTipsList() {
    final tips = [
      'تأكد من اختيار نوع المشاركة المناسب',
      'اختر الإدارة التنفيذية أولاً ثم الإدارة الفرعية',
      'أدخل تاريخ المشاركة الصحيح',
      'اكتب وصفاً واضحاً للموضوع والهدف',
      'أرفق الملفات الداعمة إن وجدت',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'نصائح لتعبئة الاستمارة:',
          style: AppTypography.textTheme.labelLarge!.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: AppSpacing.md),
        ...tips.asMap().entries.map((entry) {
          final index = entry.key;
          final tip = entry.value;
          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 400 + (index * 100)),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(20 * (1 - value), 0),
                child: Opacity(
                  opacity: value,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 4),
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            tip,
                            style: AppTypography.textTheme.bodySmall!.copyWith(
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }).toList(),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: EdgeInsets.all(AppSpacing.xl),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'بيانات المنجز',
              style: AppTypography.textTheme.headlineSmall!.copyWith(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSpacing.xl),
            _buildFormFields(),
            SizedBox(height: AppSpacing.xl),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildFormFields() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;

    return Column(
      children: [
        // Participation Type
        _buildAnimatedField(index: 0, child: _buildParticipationTypeField()),
        SizedBox(height: AppSpacing.lg),

        // Department Fields
        if (isDesktop) ...[
          Row(
            children: [
              Expanded(
                child: _buildAnimatedField(
                  index: 1,
                  child: _buildExecutiveDepartmentField(),
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildAnimatedField(
                  index: 2,
                  child: _buildMainDepartmentField(),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          _buildAnimatedField(index: 3, child: _buildSubDepartmentField()),
        ] else ...[
          _buildAnimatedField(
            index: 1,
            child: _buildExecutiveDepartmentField(),
          ),
          SizedBox(height: AppSpacing.lg),
          _buildAnimatedField(index: 2, child: _buildMainDepartmentField()),
          SizedBox(height: AppSpacing.lg),
          _buildAnimatedField(index: 3, child: _buildSubDepartmentField()),
        ],

        SizedBox(height: AppSpacing.lg),

        // Date and Location
        if (isDesktop) ...[
          Row(
            children: [
              Expanded(
                child: _buildAnimatedField(index: 4, child: _buildDateField()),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildAnimatedField(
                  index: 5,
                  child: _buildLocationField(),
                ),
              ),
            ],
          ),
        ] else ...[
          _buildAnimatedField(index: 4, child: _buildDateField()),
          SizedBox(height: AppSpacing.lg),
          _buildAnimatedField(index: 5, child: _buildLocationField()),
        ],

        SizedBox(height: AppSpacing.lg),
        _buildAnimatedField(index: 6, child: _buildDurationField()),
        SizedBox(height: AppSpacing.lg),

        // Topic and Goal
        _buildAnimatedField(index: 7, child: _buildTopicField()),
        SizedBox(height: AppSpacing.lg),
        _buildAnimatedField(index: 8, child: _buildGoalField()),
        SizedBox(height: AppSpacing.lg),
        _buildAnimatedField(index: 9, child: _buildImpactField()),
        SizedBox(height: AppSpacing.lg),

        // Attachments
        _buildAnimatedField(index: 10, child: _buildAttachmentsField()),
      ],
    );
  }

  Widget _buildAnimatedField({required Widget child, required int index}) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 200 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: child,
    );
  }

  Widget _buildParticipationTypeField() {
    return _buildDropdownField<String>(
      value: _selectedParticipationType,
      label: 'نوع المشاركة *',
      hint: 'اختر نوع المشاركة',
      items: _participationTypes,
      onChanged: (value) {
        setState(() {
          _selectedParticipationType = value;
          _participationTypeController.text = value ?? '';
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'نوع المشاركة مطلوب';
        }
        return null;
      },
    );
  }

  Widget _buildExecutiveDepartmentField() {
    return _buildDropdownField<String>(
      value: _selectedExecutiveDepartment,
      label: 'الإدارة التنفيذية *',
      hint: 'اختر الإدارة التنفيذية',
      items: _departmentsService.getExecutiveDepartments(),
      onChanged: (value) {
        setState(() {
          _selectedExecutiveDepartment = value;
          _selectedMainDepartment = null;
          _selectedSubDepartment = null;
          _executiveDepartmentController.text = value ?? '';
          _mainDepartmentController.clear();
          _subDepartmentController.clear();
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'الإدارة التنفيذية مطلوبة';
        }
        return null;
      },
    );
  }

  Widget _buildMainDepartmentField() {
    return _buildDropdownField<String>(
      value: _selectedMainDepartment,
      label: 'الإدارة الرئيسية *',
      hint: 'اختر الإدارة الرئيسية',
      items: _availableMainDepartments,
      enabled: _selectedExecutiveDepartment != null,
      onChanged: (value) {
        setState(() {
          _selectedMainDepartment = value;
          _selectedSubDepartment = null;
          _mainDepartmentController.text = value ?? '';
          _subDepartmentController.clear();
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'الإدارة الرئيسية مطلوبة';
        }
        return null;
      },
    );
  }

  Widget _buildSubDepartmentField() {
    return _buildDropdownField<String>(
      value: _selectedSubDepartment,
      label: 'الإدارة الفرعية *',
      hint: 'اختر الإدارة الفرعية',
      items: _availableSubDepartments,
      enabled: _selectedMainDepartment != null,
      onChanged: (value) {
        setState(() {
          _selectedSubDepartment = value;
          _subDepartmentController.text = value ?? '';
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'الإدارة الفرعية مطلوبة';
        }
        return null;
      },
    );
  }

  Widget _buildDropdownField<T>({
    required T? value,
    required String label,
    required String hint,
    required List<T> items,
    required void Function(T?) onChanged,
    String? Function(T?)? validator,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.textTheme.labelLarge!.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        DropdownButtonFormField<T>(
          value: value,
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(
                item.toString(),
                style: AppTypography.textTheme.bodyMedium,
              ),
            );
          }).toList(),
          onChanged: enabled ? onChanged : null,
          validator: validator,
          decoration: _getInputDecoration(hint),
          style: AppTypography.textTheme.bodyMedium!.copyWith(
            color: enabled ? AppColors.onSurface : AppColors.onSurfaceVariant,
          ),
          dropdownColor: Colors.white,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: enabled ? AppColors.onSurfaceVariant : AppColors.outline,
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تاريخ المشاركة *',
          style: AppTypography.textTheme.labelLarge!.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        TextFormField(
          controller: _dateController,
          decoration: _getInputDecoration('اختر تاريخ المشاركة').copyWith(
            suffixIcon: const Icon(
              Icons.calendar_today,
              color: AppColors.primaryMedium,
            ),
          ),
          readOnly: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'تاريخ المشاركة مطلوب';
            }
            return null;
          },
          onTap: () async {
            try {
              final DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: _selectedDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: Theme.of(context).colorScheme.copyWith(
                        primary: AppColors.primaryMedium,
                        onPrimary: Colors.white,
                        surface: Colors.white,
                        onSurface: AppColors.onSurface,
                      ),
                    ),
                    child: child!,
                  );
                },
              );

              if (pickedDate != null) {
                setState(() {
                  _selectedDate = pickedDate;
                  _dateController.text = _formatDate(pickedDate);
                });
              }
            } catch (e) {
              debugPrint('Error picking date: $e');
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'حدث خطأ أثناء اختيار التاريخ. يرجى المحاولة مرة أخرى.',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                  ),
                );
              }
            }
          },
        ),
      ],
    );
  }

  Widget _buildLocationField() {
    return _buildTextFormField(
      controller: _locationController,
      label: 'موقع المشاركة *',
      hint: 'أدخل موقع المشاركة',
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'موقع المشاركة مطلوب';
        }
        return null;
      },
    );
  }

  Widget _buildDurationField() {
    return _buildTextFormField(
      controller: _durationController,
      label: 'مدة التنفيذ *',
      hint: 'مثال: 3 أيام، أسبوعين',
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'مدة التنفيذ مطلوبة';
        }
        return null;
      },
    );
  }

  Widget _buildTopicField() {
    return _buildTextFormField(
      controller: _topicController,
      label: 'موضوع المشاركة *',
      hint: 'اكتب وصفاً تفصيلياً لموضوع المشاركة',
      maxLines: 3,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'موضوع المشاركة مطلوب';
        }
        return null;
      },
    );
  }

  Widget _buildGoalField() {
    return _buildTextFormField(
      controller: _goalController,
      label: 'الهدف من المشاركة *',
      hint: 'اكتب الهدف أو الغاية من المشاركة',
      maxLines: 3,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'الهدف من المشاركة مطلوب';
        }
        return null;
      },
    );
  }

  Widget _buildImpactField() {
    return _buildTextFormField(
      controller: _impactController,
      label: 'الأثر أو الفائدة *',
      hint: 'اكتب الأثر المحقق أو الفائدة من المشاركة',
      maxLines: 3,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'الأثر أو الفائدة مطلوبة';
        }
        return null;
      },
    );
  }

  Widget _buildAttachmentsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'المرفقات (اختياري)',
          style: AppTypography.textTheme.labelLarge!.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.outline,
              style: BorderStyle.solid,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            color: AppColors.surfaceLight,
          ),
          child: InkWell(
            onTap: _selectFiles,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 48,
                    color: AppColors.primaryMedium,
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    _selectedFiles.isEmpty
                        ? 'اضغط لاختيار الملفات'
                        : 'اضغط لإضافة المزيد من الملفات',
                    style: AppTypography.textTheme.bodyMedium!.copyWith(
                      color: AppColors.primaryMedium,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    'أنواع الملفات المدعومة: PDF, DOC, DOCX, JPG, PNG, MP4, MP3 (حد أقصى 10MB لكل ملف)',
                    style: AppTypography.textTheme.bodySmall!.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (_selectedFiles.isNotEmpty) ...[
                    SizedBox(height: AppSpacing.lg),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSm,
                        ),
                        border: Border.all(
                          color: AppColors.primaryLight.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.attach_file,
                                size: 16,
                                color: AppColors.primaryMedium,
                              ),
                              SizedBox(width: AppSpacing.xs),
                              Text(
                                'الملفات المحددة (${_selectedFiles.length})',
                                style: AppTypography.textTheme.bodySmall!
                                    .copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryMedium,
                                    ),
                              ),
                              const Spacer(),
                              if (_selectedFiles.isNotEmpty)
                                TextButton.icon(
                                  onPressed: _clearAllFiles,
                                  icon: const Icon(Icons.clear_all, size: 16),
                                  label: const Text('مسح الكل'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.error,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: AppSpacing.sm,
                                      vertical: AppSpacing.xs,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: AppSpacing.sm),
                          ..._selectedFiles.map((file) => _buildFileItem(file)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.textTheme.labelLarge!.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        TextFormField(
          controller: controller,
          decoration: _getInputDecoration(hint),
          validator: validator,
          maxLines: maxLines,
          textDirection: TextDirection.rtl,
          style: AppTypography.textTheme.bodyMedium,
        ),
      ],
    );
  }

  InputDecoration _getInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTypography.textTheme.bodyMedium!.copyWith(
        color: AppColors.onSurfaceVariant,
      ),
      filled: true,
      fillColor: AppColors.surfaceLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: BorderSide(color: AppColors.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: BorderSide(color: AppColors.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: BorderSide(color: AppColors.primaryMedium, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: BorderSide(color: AppColors.error, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
    );
  }

  Widget _buildSubmitButton() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Opacity(
            opacity: value,
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryMedium,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  elevation: 8,
                  shadowColor: AppColors.primaryMedium.withOpacity(0.3),
                ),
                child: _isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: AppSpacing.sm),
                          Text(
                            'جاري الإرسال...',
                            style: AppTypography.textTheme.labelLarge!.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.send, color: Colors.white),
                          SizedBox(width: AppSpacing.sm),
                          Text(
                            'إرسال المنجز',
                            style: AppTypography.textTheme.labelLarge!.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _selectFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf', 'doc', 'docx', 'txt', // Documents
          'jpg', 'jpeg', 'png', 'gif', 'bmp', // Images
          'mp4', 'mov', 'avi', 'mkv', 'webm', // Videos
          'mp3', 'wav', 'm4a', 'aac', 'ogg', // Audio
          'xlsx', 'xls', 'csv', // Spreadsheets
          'pptx', 'ppt', // Presentations
          'zip', 'rar', '7z', // Archives
        ],
        allowMultiple: true,
        withData: true, // Required for web platform
        withReadStream: false, // Not needed for simple file upload
      );

      if (result != null && result.files.isNotEmpty) {
        // Check file size limit (10MB per file) - especially important for web
        const int maxFileSize = 10 * 1024 * 1024; // 10MB in bytes
        List<PlatformFile> validFiles = [];
        List<String> oversizedFiles = [];
        List<String> duplicateFiles = [];

        for (PlatformFile file in result.files) {
          // Check file size
          if (file.size > maxFileSize) {
            oversizedFiles.add(file.name);
            continue;
          }

          // Check for duplicates
          bool alreadyExists = _selectedFiles.any(
            (existingFile) =>
                existingFile.name == file.name &&
                existingFile.size == file.size,
          );

          if (alreadyExists) {
            duplicateFiles.add(file.name);
            continue;
          }

          validFiles.add(file);
        }

        // Add valid files to the list
        if (validFiles.isNotEmpty) {
          setState(() {
            _selectedFiles.addAll(validFiles);
          });

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'تم اختيار ${validFiles.length} ملف بنجاح',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
          );
        }

        // Show warnings for invalid files
        if (oversizedFiles.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'الملفات التالية تتجاوز الحد الأقصى للحجم (10MB): ${oversizedFiles.join(', ')}',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
          );
        }

        if (duplicateFiles.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'الملفات التالية موجودة مسبقاً: ${duplicateFiles.join(', ')}',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: AppColors.primaryMedium,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error picking files: $e');

      // Show user-friendly error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'حدث خطأ أثناء اختيار الملفات. يرجى المحاولة مرة أخرى.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      _showValidationError();
      return;
    }

    // Additional validation
    if (_selectedDate == null) {
      _showValidationError();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create Achievement object
      final achievement = Achievement(
        participationType: _selectedParticipationType!,
        executiveDepartment: _selectedExecutiveDepartment!,
        mainDepartment: _selectedMainDepartment!,
        subDepartment: _selectedSubDepartment!,
        topic: _topicController.text.trim(),
        goal: _goalController.text.trim(),
        date: _selectedDate!,
        location: _locationController.text.trim(),
        duration: _durationController.text.trim(),
        impact: _impactController.text.trim(),
        attachments: _selectedFiles.map((file) => file.name).toList(),
        userId: '', // Will be set by the service
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Add achievement to Firestore
      final achievementId = await _achievementService.addAchievement(
        achievement,
      );

      debugPrint('Achievement added successfully with ID: $achievementId');

      setState(() {
        _isLoading = false;
      });

      // Show success message
      _showSuccessDialog();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      // Show error message
      _showErrorDialog(e.toString());
    }
  }

  void _showValidationError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'يرجى تعبئة جميع الحقول المطلوبة',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              child: const Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: 32,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Text(
              'خطأ!',
              style: AppTypography.textTheme.headlineSmall!.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(message, style: AppTypography.textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'موافق',
              style: AppTypography.textTheme.labelLarge!.copyWith(
                color: AppColors.primaryMedium,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 32,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Text(
              'تم بنجاح!',
              style: AppTypography.textTheme.headlineSmall!.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'تم إضافة المنجز بنجاح. سيتم مراجعته وإضافته إلى سجلك قريباً.',
          style: AppTypography.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              _onSidebarItemTap(0); // Go back to dashboard
            },
            child: Text(
              'العودة للوحة التحكم',
              style: AppTypography.textTheme.labelLarge!.copyWith(
                color: AppColors.primaryMedium,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              _resetForm(); // Reset form for new entry
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryMedium,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
            child: Text(
              'إضافة منجز آخر',
              style: AppTypography.textTheme.labelLarge!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    setState(() {
      _selectedParticipationType = null;
      _selectedExecutiveDepartment = null;
      _selectedMainDepartment = null;
      _selectedSubDepartment = null;
      _selectedDate = null;
      _selectedFiles.clear();
    });

    // Clear all controllers
    _participationTypeController.clear();
    _executiveDepartmentController.clear();
    _mainDepartmentController.clear();
    _subDepartmentController.clear();
    _topicController.clear();
    _goalController.clear();
    _dateController.clear();
    _locationController.clear();
    _durationController.clear();
    _impactController.clear();
  }

  Widget _buildViewAchievementsContent() {
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
          // Header
          Row(
            children: [
              Icon(Icons.list_alt, color: AppColors.primaryDark, size: 32),
              const SizedBox(width: 16),
              Text(
                'منجزاتي',
                style: AppTypography.textTheme.headlineSmall?.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ViewAchievementsScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.open_in_new),
                label: const Text('افتح في شاشة منفصلة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryMedium,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Filter Chips
          _buildAchievementsFilterChips(),
          const SizedBox(height: 16),

          // Achievements Count
          _buildAchievementsCount(),
          const SizedBox(height: 16),

          // Achievements List (Limited height for embedded view)
          Container(height: 400, child: _buildAchievementsList()),
        ],
      ),
    );
  }

  Widget _buildReportsContent() {
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
              Icon(Icons.analytics, color: AppColors.primaryDark, size: 32),
              const SizedBox(width: 16),
              Text(
                'التقارير والإحصائيات',
                style: AppTypography.textTheme.headlineSmall?.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Quick stats cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'إجمالي التقارير',
                  '12',
                  Icons.description,
                  AppColors.primaryMedium,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'تقارير هذا الشهر',
                  '3',
                  Icons.calendar_today,
                  AppColors.success,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'قيد الإعداد',
                  '2',
                  Icons.hourglass_empty,
                  AppColors.warning,
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          Center(
            child: Column(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  size: 120,
                  color: AppColors.primaryLight.withOpacity(0.5),
                ),
                const SizedBox(height: 24),
                Text(
                  'قريباً - شاشة التقارير التفصيلية',
                  style: AppTypography.textTheme.titleLarge?.copyWith(
                    color: AppColors.secondaryGray,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'ستتضمن تقارير شاملة وإحصائيات تفصيلية حول المنجزات',
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.secondaryGray,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsContent() {
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
              Icon(Icons.settings, color: AppColors.primaryDark, size: 32),
              const SizedBox(width: 16),
              Text(
                'الإعدادات',
                style: AppTypography.textTheme.headlineSmall?.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Settings options
          _buildSettingItem(
            'إعدادات الحساب',
            'تحديث المعلومات الشخصية',
            Icons.account_circle,
            () {},
          ),
          const SizedBox(height: 16),
          _buildSettingItem(
            'إعدادات الإشعارات',
            'تخصيص تفضيلات الإشعارات',
            Icons.notifications,
            () {},
          ),
          const SizedBox(height: 16),
          _buildSettingItem(
            'إعدادات العرض',
            'تخصيص مظهر التطبيق',
            Icons.palette,
            () {},
          ),
          const SizedBox(height: 16),
          _buildSettingItem(
            'إعدادات الأمان',
            'تغيير كلمة المرور والأمان',
            Icons.security,
            () {},
          ),
          const SizedBox(height: 32),

          // Logout button
          Container(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _handleLogout,
              icon: const Icon(Icons.logout),
              label: const Text('تسجيل الخروج'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
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
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTypography.textTheme.bodySmall?.copyWith(
              color: AppColors.secondaryGray,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.surfaceLight),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primaryMedium, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: AppColors.secondaryGray,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.secondaryGray,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent() {
    return const ProfileDemoScreen();
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
        return 'الملف الشخصي';
      case 5:
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
        return 'عرض وتحديث معلوماتك الشخصية';
      case 5:
        return 'تخصيص إعدادات النظام';
      default:
        return 'مرحباً بك في نظام إدارة المنجزات';
    }
  }

  void _onSidebarItemTap(int index) {
    setState(() {
      _selectedSidebarIndex = index;
    });
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
            child: Center(child: Text('لا توجد إشعارات جديدة')),
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

  // Achievements management functions
  Widget _buildAchievementsFilterChips() {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _achievementFilterOptions.length,
        itemBuilder: (context, index) {
          final option = _achievementFilterOptions[index];
          final isSelected = _selectedAchievementsFilter == option['value'];

          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedAchievementsFilter = option['value'];
                });
              },
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    option['icon'],
                    size: 18,
                    color: isSelected ? Colors.white : AppColors.primaryMedium,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    option['label'],
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : AppColors.primaryMedium,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.white,
              selectedColor: AppColors.primaryMedium,
              checkmarkColor: Colors.white,
              side: BorderSide(
                color: isSelected
                    ? AppColors.primaryMedium
                    : AppColors.onSurface.withOpacity(0.3),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAchievementsCount() {
    return FutureBuilder<Map<String, int>>(
      future: _achievementService.getUserAchievementsCount(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final counts = snapshot.data!;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryLight.withOpacity(0.1),
                AppColors.primaryMedium.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primaryLight.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCountItem('المجموع', counts['total']!, Icons.dashboard),
              _buildCountItem(
                'معلقة',
                counts['pending']!,
                Icons.hourglass_empty,
              ),
              _buildCountItem('معتمد', counts['approved']!, Icons.check_circle),
              _buildCountItem('مرفوض', counts['rejected']!, Icons.cancel),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCountItem(String label, int count, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primaryMedium, size: 24),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: AppTypography.textTheme.headlineSmall?.copyWith(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTypography.textTheme.bodySmall?.copyWith(
            color: AppColors.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsList() {
    return StreamBuilder<List<Achievement>>(
      stream: _getFilteredAchievements(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryMedium),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.error.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'خطأ في تحميل المنجزات',
                  style: AppTypography.textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.error,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }

        final achievements = snapshot.data ?? [];

        if (achievements.isEmpty) {
          return _buildAchievementsEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: achievements.length,
          itemBuilder: (context, index) {
            final achievement = achievements[index];
            return _buildAchievementCard(achievement, index);
          },
        );
      },
    );
  }

  Widget _buildAchievementsEmptyState() {
    String message;
    IconData icon;

    switch (_selectedAchievementsFilter) {
      case 'pending':
        message = 'لا توجد منجزات معلقة';
        icon = Icons.hourglass_empty;
        break;
      case 'approved':
        message = 'لا توجد منجزات معتمدة';
        icon = Icons.check_circle_outline;
        break;
      case 'rejected':
        message = 'لا توجد منجزات مرفوضة';
        icon = Icons.cancel_outlined;
        break;
      default:
        message = 'لم تقم بإضافة أي منجزات بعد';
        icon = Icons.inbox_outlined;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: AppColors.onSurface.withOpacity(0.5)),
          const SizedBox(height: 24),
          Text(
            message,
            style: AppTypography.textTheme.headlineSmall?.copyWith(
              color: AppColors.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          if (_selectedAchievementsFilter == 'all') ...[
            const SizedBox(height: 16),
            Text(
              'ابدأ بإضافة منجزك الأول',
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _onSidebarItemTap(1),
              icon: const Icon(Icons.add),
              label: const Text('إضافة منجز جديد'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryMedium,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: InkWell(
                onTap: () => _showAchievementDetails(achievement),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildStatusChip(achievement.status),
                          const Spacer(),
                          _buildAchievementMenu(achievement),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        achievement.participationType,
                        style: AppTypography.textTheme.labelLarge?.copyWith(
                          color: AppColors.primaryMedium,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        achievement.topic,
                        style: AppTypography.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.business,
                            size: 16,
                            color: AppColors.onSurface.withOpacity(0.7),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${achievement.executiveDepartment} - ${achievement.mainDepartment}',
                              style: AppTypography.textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppColors.onSurface.withOpacity(0.7),
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: AppColors.onSurface.withOpacity(0.7),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${achievement.date.day}/${achievement.date.month}/${achievement.date.year}',
                            style: AppTypography.textTheme.bodySmall?.copyWith(
                              color: AppColors.onSurface.withOpacity(0.7),
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: AppColors.onSurface.withOpacity(0.7),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            achievement.location,
                            style: AppTypography.textTheme.bodySmall?.copyWith(
                              color: AppColors.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
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
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    String label;
    IconData icon;

    switch (status) {
      case 'approved':
        backgroundColor = AppColors.success.withOpacity(0.1);
        textColor = AppColors.success;
        label = 'معتمد';
        icon = Icons.check_circle;
        break;
      case 'rejected':
        backgroundColor = AppColors.error.withOpacity(0.1);
        textColor = AppColors.error;
        label = 'مرفوض';
        icon = Icons.cancel;
        break;
      default:
        backgroundColor = AppColors.warning.withOpacity(0.1);
        textColor = AppColors.warning;
        label = 'معلقة';
        icon = Icons.hourglass_empty;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementMenu(Achievement achievement) {
    return PopupMenuButton<String>(
      onSelected: (value) => _handleAchievementMenuAction(value, achievement),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'view',
          child: Row(
            children: [
              Icon(Icons.visibility, size: 18),
              SizedBox(width: 8),
              Text('عرض التفاصيل'),
            ],
          ),
        ),
        if (achievement.status == 'pending')
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit, size: 18),
                SizedBox(width: 8),
                Text('تعديل'),
              ],
            ),
          ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 18, color: AppColors.error),
              SizedBox(width: 8),
              Text('حذف', style: TextStyle(color: AppColors.error)),
            ],
          ),
        ),
      ],
      child: const Icon(Icons.more_vert),
    );
  }

  Stream<List<Achievement>> _getFilteredAchievements() {
    if (_selectedAchievementsFilter == 'all') {
      return _achievementService.getUserAchievements();
    } else {
      return _achievementService.getUserAchievementsByStatus(
        _selectedAchievementsFilter,
      );
    }
  }

  void _handleAchievementMenuAction(String action, Achievement achievement) {
    switch (action) {
      case 'view':
        _showAchievementDetails(achievement);
        break;
      case 'edit':
        _editAchievement(achievement);
        break;
      case 'delete':
        _confirmDeleteAchievement(achievement);
        break;
    }
  }

  void _showAchievementDetails(Achievement achievement) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 1024;
    final isTablet = screenSize.width > 768 && screenSize.width <= 1024;
    final isMobile = screenSize.width <= 768;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Achievement Details',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Container();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
              .animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
          child: FadeTransition(
            opacity: animation,
            child: Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.symmetric(
                horizontal: isDesktop
                    ? 80
                    : isTablet
                    ? 40
                    : 16,
                vertical: isDesktop
                    ? 40
                    : isTablet
                    ? 60
                    : 20,
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: isDesktop ? 800 : double.infinity,
                  maxHeight: screenSize.height * 0.9,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Column(
                    children: [
                      // Header Section
                      _buildAchievementDetailsHeader(achievement, isMobile),

                      // Content Section
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(isMobile ? 16 : 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Status and Date Card
                              _buildStatusDateCard(achievement, isMobile),
                              SizedBox(height: isMobile ? 16 : 24),

                              // Departments Section
                              _buildDepartmentsSection(achievement, isMobile),
                              SizedBox(height: isMobile ? 16 : 24),

                              // Details Section
                              _buildDetailsSection(achievement, isMobile),
                              SizedBox(height: isMobile ? 16 : 24),

                              // Content Section
                              _buildContentSection(achievement, isMobile),

                              // Attachments Section
                              if (achievement.attachments.isNotEmpty) ...[
                                SizedBox(height: isMobile ? 16 : 24),
                                _buildAttachmentsSection(achievement, isMobile),
                              ],
                            ],
                          ),
                        ),
                      ),

                      // Action Buttons
                      _buildAchievementDetailsActions(achievement, isMobile),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAchievementDetailsHeader(
    Achievement achievement,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primaryMedium],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.star_rounded,
              color: Colors.white,
              size: isMobile ? 24 : 28,
            ),
          ),
          SizedBox(width: isMobile ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تفاصيل المنجز',
                  style: AppTypography.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 18 : 22,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  achievement.participationType,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: isMobile ? 14 : 16,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: isMobile ? 20 : 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDateCard(Achievement achievement, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  color: AppColors.primaryMedium,
                  size: isMobile ? 18 : 20,
                ),
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تاريخ المشاركة',
                      style: AppTypography.textTheme.labelSmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: isMobile ? 11 : 12,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '${achievement.date.day}/${achievement.date.month}/${achievement.date.year}',
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: isMobile ? 13 : 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 10 : 12,
              vertical: isMobile ? 6 : 8,
            ),
            decoration: BoxDecoration(
              color: _getStatusColor(achievement.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _getStatusColor(achievement.status).withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getStatusIcon(achievement.status),
                  size: isMobile ? 14 : 16,
                  color: _getStatusColor(achievement.status),
                ),
                SizedBox(width: 4),
                Text(
                  _getStatusLabel(achievement.status),
                  style: AppTypography.textTheme.labelSmall?.copyWith(
                    color: _getStatusColor(achievement.status),
                    fontWeight: FontWeight.w600,
                    fontSize: isMobile ? 11 : 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentsSection(Achievement achievement, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
              Icon(
                Icons.account_tree_rounded,
                color: AppColors.primaryMedium,
                size: isMobile ? 18 : 20,
              ),
              SizedBox(width: 8),
              Text(
                'الهيكل التنظيمي',
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                  fontSize: isMobile ? 16 : 18,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 12 : 16),
          _buildDepartmentHierarchy(achievement, isMobile),
        ],
      ),
    );
  }

  Widget _buildDepartmentHierarchy(Achievement achievement, bool isMobile) {
    final departments = [
      {
        'label': 'الإدارة التنفيذية',
        'value': achievement.executiveDepartment,
        'icon': Icons.business_center,
        'color': AppColors.primaryDark,
      },
      {
        'label': 'الإدارة الرئيسية',
        'value': achievement.mainDepartment,
        'icon': Icons.domain,
        'color': AppColors.primaryMedium,
      },
      {
        'label': 'الإدارة الفرعية',
        'value': achievement.subDepartment,
        'icon': Icons.group_work,
        'color': AppColors.primaryLight,
      },
    ];

    return Column(
      children: departments.asMap().entries.map((entry) {
        final index = entry.key;
        final dept = entry.value;
        final isLast = index == departments.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (dept['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: (dept['color'] as Color).withOpacity(0.3),
                    ),
                  ),
                  child: Icon(
                    dept['icon'] as IconData,
                    size: isMobile ? 16 : 18,
                    color: dept['color'] as Color,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: isMobile ? 20 : 24,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.outline.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
              ],
            ),
            SizedBox(width: isMobile ? 12 : 16),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  top: 6,
                  bottom: isLast ? 0 : (isMobile ? 16 : 20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dept['label'] as String,
                      style: AppTypography.textTheme.labelMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: isMobile ? 12 : 13,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      dept['value'] as String,
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: isMobile ? 14 : 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildDetailsSection(Achievement achievement, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
              Icon(
                Icons.info_outline_rounded,
                color: AppColors.info,
                size: isMobile ? 18 : 20,
              ),
              SizedBox(width: 8),
              Text(
                'تفاصيل إضافية',
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                  fontSize: isMobile ? 16 : 18,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  'الموقع',
                  achievement.location,
                  Icons.location_on_rounded,
                  AppColors.error,
                  isMobile,
                ),
              ),
              SizedBox(width: isMobile ? 12 : 16),
              Expanded(
                child: _buildDetailItem(
                  'المدة',
                  achievement.duration,
                  Icons.schedule_rounded,
                  AppColors.warning,
                  isMobile,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: isMobile ? 16 : 18, color: color),
              SizedBox(width: 6),
              Text(
                label,
                style: AppTypography.textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: isMobile ? 12 : 13,
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          Text(
            value,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: isMobile ? 13 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection(Achievement achievement, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
              Icon(
                Icons.description_rounded,
                color: AppColors.success,
                size: isMobile ? 18 : 20,
              ),
              SizedBox(width: 8),
              Text(
                'محتوى المنجز',
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                  fontSize: isMobile ? 16 : 18,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 16 : 20),
          _buildContentCard(
            'الموضوع',
            achievement.topic,
            Icons.topic_rounded,
            AppColors.primaryMedium,
            isMobile,
          ),
          SizedBox(height: isMobile ? 12 : 16),
          _buildContentCard(
            'الهدف',
            achievement.goal,
            Icons.flag_rounded,
            AppColors.info,
            isMobile,
          ),
          SizedBox(height: isMobile ? 12 : 16),
          _buildContentCard(
            'الأثر والفائدة',
            achievement.impact,
            Icons.trending_up_rounded,
            AppColors.success,
            isMobile,
          ),
        ],
      ),
    );
  }

  Widget _buildContentCard(
    String title,
    String content,
    IconData icon,
    Color color,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 18),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: isMobile ? 14 : 16, color: color),
              ),
              SizedBox(width: 8),
              Text(
                title,
                style: AppTypography.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: isMobile ? 13 : 14,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 8 : 10),
          Text(
            content,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              height: 1.5,
              fontSize: isMobile ? 14 : 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentsSection(Achievement achievement, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
              Icon(
                Icons.attach_file_rounded,
                color: AppColors.warning,
                size: isMobile ? 18 : 20,
              ),
              SizedBox(width: 8),
              Text(
                'المرفقات',
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                  fontSize: isMobile ? 16 : 18,
                ),
              ),
              SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${achievement.attachments.length}',
                  style: AppTypography.textTheme.labelSmall?.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 10 : 11,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: achievement.attachments.map((attachment) {
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 10 : 12,
                  vertical: isMobile ? 6 : 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.outline.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getFileIcon(
                        '.${attachment.split('.').last.toLowerCase()}',
                      ),
                      size: isMobile ? 14 : 16,
                      color: AppColors.onSurfaceVariant,
                    ),
                    SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        attachment,
                        style: AppTypography.textTheme.labelMedium?.copyWith(
                          fontSize: isMobile ? 12 : 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementDetailsActions(
    Achievement achievement,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        border: Border(
          top: BorderSide(color: AppColors.outline.withOpacity(0.1)),
        ),
      ),
      child: Row(
        children: [
          if (achievement.status == 'pending') ...[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  _editAchievement(achievement);
                },
                icon: Icon(Icons.edit_rounded, size: isMobile ? 16 : 18),
                label: Text(
                  'تعديل',
                  style: TextStyle(fontSize: isMobile ? 14 : 16),
                ),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 16),
                  side: BorderSide(color: AppColors.primaryMedium),
                  foregroundColor: AppColors.primaryMedium,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            SizedBox(width: isMobile ? 8 : 12),
          ],
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(Icons.check_rounded, size: isMobile ? 16 : 18),
              label: Text(
                'إغلاق',
                style: TextStyle(fontSize: isMobile ? 14 : 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryMedium,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'approved':
        return Icons.check_circle_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
      default:
        return Icons.hourglass_empty_rounded;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'approved':
        return 'معتمد';
      case 'rejected':
        return 'مرفوض';
      default:
        return 'معلقة';
    }
  }

  void _editAchievement(Achievement achievement) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditAchievementScreen(achievement: achievement),
      ),
    );
  }

  void _confirmDeleteAchievement(Achievement achievement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text(
          'هل أنت متأكد من حذف هذا المنجز؟ لا يمكن التراجع عن هذا الإجراء.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => _deleteAchievement(achievement),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAchievement(Achievement achievement) async {
    Navigator.of(context).pop(); // Close confirmation dialog

    try {
      await _achievementService.deleteAchievement(achievement.id!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف المنجز بنجاح'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في حذف المنجز: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
