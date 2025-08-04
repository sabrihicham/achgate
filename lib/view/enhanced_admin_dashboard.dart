// import 'package:flutter/material.dart';
// import '../theme/app_colors.dart';
// import '../theme/app_typography.dart';
// import '../theme/app_spacing.dart';
// import '../theme/app_components.dart';
// import '../widgets/admin_widgets.dart';
// import '../widgets/admin_notifications.dart';
// import '../services/admin_service.dart';
// import '../services/auth_service.dart';
// import '../models/achievement.dart';
// import '../core/app_router.dart';

// class EnhancedAdminDashboard extends StatefulWidget {
//   const EnhancedAdminDashboard({super.key});

//   @override
//   State<EnhancedAdminDashboard> createState() => _EnhancedAdminDashboardState();
// }

// class _EnhancedAdminDashboardState extends State<EnhancedAdminDashboard>
//     with TickerProviderStateMixin {
//   final AdminService _adminService = AdminService();
//   final AuthService _authService = AuthService();

//   late AnimationController _fadeController;
//   late Animation<double> _fadeAnimation;

//   int _selectedSidebarIndex = 0;
//   bool _isLoading = true;
//   bool _isAdmin = false;
//   Map<String, int> _statistics = {};
//   String _searchQuery = '';
//   String _selectedFilter = 'all';

//   final List<Map<String, dynamic>> _sidebarItems = [
//     {
//       'title': 'لوحة التحكم الرئيسية',
//       'icon': Icons.dashboard_outlined,
//       'selectedIcon': Icons.dashboard,
//       'badge': null,
//     },
//     {
//       'title': 'المراجعة السريعة',
//       'icon': Icons.pending_actions_outlined,
//       'selectedIcon': Icons.pending_actions,
//       'badge': 'pending',
//     },
//     {
//       'title': 'إدارة المنجزات',
//       'icon': Icons.assignment_outlined,
//       'selectedIcon': Icons.assignment,
//       'badge': null,
//     },
//     {
//       'title': 'إدارة المستخدمين',
//       'icon': Icons.people_outline,
//       'selectedIcon': Icons.people,
//       'badge': null,
//     },
//     {
//       'title': 'التقارير والتحليلات',
//       'icon': Icons.analytics_outlined,
//       'selectedIcon': Icons.analytics,
//       'badge': null,
//     },
//     {
//       'title': 'الإعدادات الإدارية',
//       'icon': Icons.settings_outlined,
//       'selectedIcon': Icons.settings,
//       'badge': null,
//     },
//   ];

//   final List<AdminFilterOption> _achievementFilters = [
//     const AdminFilterOption(label: 'الكل', value: 'all'),
//     const AdminFilterOption(label: 'معلقة', value: 'pending'),
//     const AdminFilterOption(label: 'مقبول', value: 'approved'),
//     const AdminFilterOption(label: 'مرفوض', value: 'rejected'),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _initializeAnimation();
//     _checkAdminAccess();
//   }

//   void _initializeAnimation() {
//     _fadeController = AnimationController(
//       duration: const Duration(milliseconds: 1000),
//       vsync: this,
//     );
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
//     );
//     _fadeController.forward();
//   }

//   Future<void> _checkAdminAccess() async {
//     try {
//       final isAdmin = await _adminService.isCurrentUserAdmin();
//       if (!isAdmin) {
//         if (mounted) {
//           AppRouter.navigateToAdminLogin(context);
//         }
//         return;
//       }

//       await _loadStatistics();
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       if (mounted) {
//         AdminNotificationService.showError(
//           context,
//           title: 'خطأ في التحقق من الصلاحيات',
//           message: e.toString(),
//         );
//       }
//     }
//   }

//   Future<void> _loadStatistics() async {
//     try {
//       final stats = await _adminService.getUsersStatistics();
//       setState(() {
//         _isAdmin = true;
//         _statistics = stats;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       if (mounted) {
//         AdminNotificationService.showError(
//           context,
//           title: 'خطأ في تحميل الإحصائيات',
//           message: e.toString(),
//         );
//       }
//     }
//   }

//   Future<void> _refreshData() async {
//     await _loadStatistics();
//     AdminNotificationService.showSuccess(
//       context,
//       title: 'تم تحديث البيانات',
//       message: 'تم تحديث جميع الإحصائيات بنجاح',
//     );
//   }

//   @override
//   void dispose() {
//     _fadeController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return Scaffold(
//         backgroundColor: AppColors.surfaceLight,
//         body: Center(
//           child: AppComponents.loadingIndicator(
//             message: 'جارٍ التحقق من الصلاحيات...',
//           ),
//         ),
//       );
//     }

//     if (!_isAdmin) {
//       return Scaffold(
//         backgroundColor: AppColors.surfaceLight,
//         body: Center(
//           child: AdminEmptyState(
//             title: 'غير مصرح بالوصول',
//             subtitle: 'ليس لديك صلاحيات للوصول إلى لوحة التحكم الإدارية',
//             icon: Icons.admin_panel_settings_outlined,
//             action: ElevatedButton(
//               onPressed: () => AppRouter.navigateToLogin(context),
//               child: const Text('تسجيل الدخول'),
//             ),
//           ),
//         ),
//       );
//     }

//     return Scaffold(
//       backgroundColor: AppColors.surfaceLight,
//       body: FadeTransition(
//         opacity: _fadeAnimation,
//         child: Row(
//           children: [
//             _buildEnhancedSidebar(),
//             Expanded(child: _buildMainContent()),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildEnhancedSidebar() {
//     return Container(
//       width: 300,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.08),
//             blurRadius: 20,
//             offset: const Offset(4, 0),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           _buildSidebarHeader(),
//           Expanded(child: _buildSidebarMenu()),
//           _buildSidebarFooter(),
//         ],
//       ),
//     );
//   }

//   Widget _buildSidebarHeader() {
//     return Container(
//       padding: const EdgeInsets.all(AppSpacing.lg),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             AppColors.primaryDark,
//             AppColors.primaryMedium,
//             AppColors.primaryLight,
//           ],
//         ),
//       ),
//       child: Column(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.2),
//               shape: BoxShape.circle,
//               border: Border.all(
//                 color: Colors.white.withOpacity(0.3),
//                 width: 2,
//               ),
//             ),
//             child: const Icon(
//               Icons.admin_panel_settings,
//               size: 40,
//               color: Colors.white,
//             ),
//           ),
//           const SizedBox(height: AppSpacing.md),
//           Text(
//             'لوحة التحكم الإدارية',
//             style: AppTypography.textTheme.headlineSmall?.copyWith(
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'نظام إدارة المنجزات المتطور',
//             style: AppTypography.textTheme.bodyMedium?.copyWith(
//               color: Colors.white.withOpacity(0.9),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSidebarMenu() {
//     return ListView.builder(
//       padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
//       itemCount: _sidebarItems.length,
//       itemBuilder: (context, index) {
//         final item = _sidebarItems[index];
//         final isSelected = _selectedSidebarIndex == index;
//         final badgeCount = item['badge'] != null
//             ? _getBadgeCount(item['badge'])
//             : 0;

//         return Container(
//           margin: const EdgeInsets.symmetric(
//             horizontal: AppSpacing.sm,
//             vertical: 2,
//           ),
//           child: Material(
//             color: isSelected
//                 ? AppColors.primaryLight.withOpacity(0.1)
//                 : Colors.transparent,
//             borderRadius: BorderRadius.circular(12),
//             child: InkWell(
//               onTap: () {
//                 setState(() {
//                   _selectedSidebarIndex = index;
//                 });
//               },
//               borderRadius: BorderRadius.circular(12),
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: AppSpacing.md,
//                   vertical: AppSpacing.md,
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(
//                       isSelected ? item['selectedIcon'] : item['icon'],
//                       color: isSelected
//                           ? AppColors.primaryDark
//                           : AppColors.onSurface.withOpacity(0.7),
//                       size: 24,
//                     ),
//                     const SizedBox(width: AppSpacing.md),
//                     Expanded(
//                       child: Text(
//                         item['title'],
//                         style: AppTypography.textTheme.bodyLarge?.copyWith(
//                           color: isSelected
//                               ? AppColors.primaryDark
//                               : AppColors.onSurface,
//                           fontWeight: isSelected
//                               ? FontWeight.bold
//                               : FontWeight.normal,
//                         ),
//                       ),
//                     ),
//                     if (badgeCount > 0)
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 8,
//                           vertical: 4,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.red,
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Text(
//                           badgeCount.toString(),
//                           style: AppTypography.textTheme.bodySmall?.copyWith(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   int _getBadgeCount(String type) {
//     switch (type) {
//       case 'pending':
//         return _statistics['pendingAchievements'] ?? 0;
//       default:
//         return 0;
//     }
//   }

//   Widget _buildSidebarFooter() {
//     return Container(
//       padding: const EdgeInsets.all(AppSpacing.lg),
//       child: Column(
//         children: [
//           const Divider(),
//           const SizedBox(height: AppSpacing.sm),
//           Material(
//             color: Colors.red.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(12),
//             child: InkWell(
//               onTap: _handleLogout,
//               borderRadius: BorderRadius.circular(12),
//               child: Container(
//                 padding: const EdgeInsets.all(AppSpacing.md),
//                 child: Row(
//                   children: [
//                     const Icon(Icons.logout, color: Colors.red),
//                     const SizedBox(width: AppSpacing.md),
//                     Text(
//                       'تسجيل الخروج',
//                       style: AppTypography.textTheme.bodyLarge?.copyWith(
//                         color: Colors.red,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMainContent() {
//     switch (_selectedSidebarIndex) {
//       case 0:
//         return _buildDashboard();
//       case 1:
//         return _buildQuickReview();
//       case 2:
//         return _buildAchievementsManagement();
//       case 3:
//         return _buildUsersManagement();
//       case 4:
//         return _buildAnalytics();
//       case 5:
//         return _buildAdminSettings();
//       default:
//         return _buildDashboard();
//     }
//   }

//   Widget _buildDashboard() {
//     return Container(
//       padding: const EdgeInsets.all(AppSpacing.lg),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           AdminHeader(
//             title: 'مرحباً بك في لوحة التحكم',
//             subtitle: 'نظرة شاملة على أداء النظام والإحصائيات الحالية',
//             onRefresh: _refreshData,
//           ),
//           const SizedBox(height: AppSpacing.lg),
//           _buildStatisticsGrid(),
//           const SizedBox(height: AppSpacing.lg),
//           Expanded(child: _buildRecentActivity()),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatisticsGrid() {
//     final stats = [
//       {
//         'title': 'إجمالي المستخدمين',
//         'value': _statistics['totalUsers']?.toString() ?? '0',
//         'icon': Icons.people,
//         'color': AppColors.primaryMedium,
//         'subtitle': 'مستخدم نشط',
//       },
//       {
//         'title': 'إجمالي المنجزات',
//         'value': _statistics['totalAchievements']?.toString() ?? '0',
//         'icon': Icons.assignment,
//         'color': AppColors.primaryDark,
//         'subtitle': 'منجز مسجل',
//       },
//       {
//         'title': 'في انتظار المراجعة',
//         'value': _statistics['pendingAchievements']?.toString() ?? '0',
//         'icon': Icons.pending_actions,
//         'color': Colors.orange,
//         'subtitle': 'يحتاج مراجعة',
//       },
//       {
//         'title': 'المنجزات المعتمدة',
//         'value': _statistics['approvedAchievements']?.toString() ?? '0',
//         'icon': Icons.check_circle,
//         'color': Colors.green,
//         'subtitle': 'معتمد ومقبول',
//       },
//     ];

//     return GridView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 4,
//         childAspectRatio: 1.3,
//         crossAxisSpacing: AppSpacing.md,
//         mainAxisSpacing: AppSpacing.md,
//       ),
//       itemCount: stats.length,
//       itemBuilder: (context, index) {
//         final stat = stats[index];
//         return AdminStatCard(
//           title: stat['title'] as String,
//           value: stat['value'] as String,
//           icon: stat['icon'] as IconData,
//           color: stat['color'] as Color,
//           subtitle: stat['subtitle'] as String,
//           isLoading: _isLoading,
//           onTap: () {
//             if (index == 2) {
//               // Pending achievements
//               setState(() {
//                 _selectedSidebarIndex = 1;
//               });
//             } else if (index == 1) {
//               // All achievements
//               setState(() {
//                 _selectedSidebarIndex = 2;
//               });
//             }
//           },
//         );
//       },
//     );
//   }

//   Widget _buildRecentActivity() {
//     return Container(
//       padding: const EdgeInsets.all(AppSpacing.lg),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 15,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               const Icon(
//                 Icons.timeline,
//                 color: AppColors.primaryMedium,
//                 size: 24,
//               ),
//               const SizedBox(width: AppSpacing.sm),
//               Text(
//                 'النشاط الأخير - المنجزات المعلقة',
//                 style: AppTypography.textTheme.titleLarge?.copyWith(
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: AppSpacing.lg),
//           Expanded(
//             child: StreamBuilder<List<Achievement>>(
//               stream: _adminService.getAchievementsByStatus('pending'),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return AppComponents.loadingIndicator();
//                 }

//                 if (snapshot.hasError) {
//                   return AdminEmptyState(
//                     title: 'خطأ في تحميل البيانات',
//                     subtitle: snapshot.error.toString(),
//                     icon: Icons.error_outline,
//                   );
//                 }

//                 final achievements = snapshot.data ?? [];
//                 if (achievements.isEmpty) {
//                   return const AdminEmptyState(
//                     title: 'لا توجد منجزات معلقة',
//                     subtitle: 'جميع المنجزات تمت مراجعتها',
//                     icon: Icons.check_circle_outline,
//                   );
//                 }

//                 return ListView.builder(
//                   itemCount: achievements.length,
//                   itemBuilder: (context, index) {
//                     final achievement = achievements[index];
//                     return _buildQuickAchievementItem(achievement);
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildQuickAchievementItem(Achievement achievement) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: AppSpacing.sm),
//       padding: const EdgeInsets.all(AppSpacing.md),
//       decoration: BoxDecoration(
//         color: AppColors.surfaceLight,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: AppColors.outline.withOpacity(0.2)),
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: Colors.orange.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: const Icon(
//               Icons.pending_actions,
//               color: Colors.orange,
//               size: 20,
//             ),
//           ),
//           const SizedBox(width: AppSpacing.md),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   achievement.topic,
//                   style: AppTypography.textTheme.titleMedium?.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   achievement.executiveDepartment,
//                   style: AppTypography.textTheme.bodyMedium?.copyWith(
//                     color: AppColors.onSurface.withOpacity(0.7),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               IconButton(
//                 onPressed: () => _approveAchievement(achievement),
//                 icon: const Icon(Icons.check, color: Colors.green),
//                 tooltip: 'قبول',
//               ),
//               IconButton(
//                 onPressed: () => _rejectAchievement(achievement),
//                 icon: const Icon(Icons.close, color: Colors.red),
//                 tooltip: 'رفض',
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildQuickReview() {
//     return Container(
//       padding: const EdgeInsets.all(AppSpacing.lg),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           AdminHeader(
//             title: 'المراجعة السريعة',
//             subtitle: 'راجع واعتمد المنجزات المعلقة بسرعة وسهولة',
//             onRefresh: _refreshData,
//           ),
//           const SizedBox(height: AppSpacing.lg),
//           Expanded(
//             child: StreamBuilder<List<Achievement>>(
//               stream: _adminService.getAchievementsByStatus('pending'),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return AppComponents.loadingIndicator();
//                 }

//                 if (snapshot.hasError) {
//                   return AdminEmptyState(
//                     title: 'خطأ في تحميل البيانات',
//                     subtitle: snapshot.error.toString(),
//                     icon: Icons.error_outline,
//                   );
//                 }

//                 final achievements = snapshot.data ?? [];
//                 if (achievements.isEmpty) {
//                   return const AdminEmptyState(
//                     title: 'ممتاز! لا توجد منجزات معلقة',
//                     subtitle: 'جميع المنجزات تمت مراجعتها واعتمادها',
//                     icon: Icons.check_circle_outline,
//                   );
//                 }

//                 return ListView.builder(
//                   itemCount: achievements.length,
//                   itemBuilder: (context, index) {
//                     final achievement = achievements[index];
//                     return _buildDetailedAchievementCard(achievement);
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDetailedAchievementCard(Achievement achievement) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: AppSpacing.lg),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 15,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(AppSpacing.lg),
//             decoration: BoxDecoration(
//               color: AppColors.primaryLight.withOpacity(0.1),
//               borderRadius: const BorderRadius.vertical(
//                 top: Radius.circular(16),
//               ),
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         achievement.topic,
//                         style: AppTypography.textTheme.titleLarge?.copyWith(
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         achievement.goal,
//                         style: AppTypography.textTheme.bodyLarge?.copyWith(
//                           color: AppColors.onSurface.withOpacity(0.8),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 AppComponents.statusBadge(achievement.status),
//               ],
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(AppSpacing.lg),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildDetailRow(
//                   'الإدارة التنفيذية',
//                   achievement.executiveDepartment,
//                 ),
//                 _buildDetailRow('الإدارة الرئيسية', achievement.mainDepartment),
//                 _buildDetailRow('القسم الفرعي', achievement.subDepartment),
//                 _buildDetailRow(
//                   'التاريخ',
//                   '${achievement.date.day}/${achievement.date.month}/${achievement.date.year}',
//                 ),
//                 _buildDetailRow('المكان', achievement.location),
//                 _buildDetailRow('المدة', achievement.duration),
//                 _buildDetailRow('الأثر', achievement.impact),
//                 const SizedBox(height: AppSpacing.lg),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: ElevatedButton.icon(
//                         onPressed: () => _approveAchievement(achievement),
//                         icon: const Icon(Icons.check),
//                         label: const Text('اعتماد المنجز'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.green,
//                           foregroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: AppSpacing.md),
//                     Expanded(
//                       child: OutlinedButton.icon(
//                         onPressed: () => _rejectAchievement(achievement),
//                         icon: const Icon(Icons.close),
//                         label: const Text('رفض المنجز'),
//                         style: OutlinedButton.styleFrom(
//                           foregroundColor: Colors.red,
//                           side: const BorderSide(color: Colors.red),
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: AppSpacing.md),
//                     IconButton(
//                       onPressed: () => _showAchievementDetails(achievement),
//                       icon: const Icon(Icons.visibility),
//                       tooltip: 'عرض التفاصيل',
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDetailRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 140,
//             child: Text(
//               '$label:',
//               style: AppTypography.textTheme.bodyMedium?.copyWith(
//                 fontWeight: FontWeight.bold,
//                 color: AppColors.onSurface.withOpacity(0.7),
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(value, style: AppTypography.textTheme.bodyMedium),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAchievementsManagement() {
//     return Container(
//       padding: const EdgeInsets.all(AppSpacing.lg),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           AdminHeader(
//             title: 'إدارة المنجزات',
//             subtitle: 'إدارة شاملة لجميع المنجزات في النظام',
//             onRefresh: _refreshData,
//           ),
//           const SizedBox(height: AppSpacing.lg),
//           Row(
//             children: [
//               Expanded(
//                 flex: 2,
//                 child: AdminSearchBar(
//                   hintText: 'البحث في المنجزات...',
//                   onSearch: (query) {
//                     setState(() {
//                       _searchQuery = query;
//                     });
//                   },
//                   onClear: () {
//                     setState(() {
//                       _searchQuery = '';
//                     });
//                   },
//                 ),
//               ),
//               const SizedBox(width: AppSpacing.md),
//               Expanded(
//                 child: Container(
//                   height: 56,
//                   child: AdminFilterChips(
//                     options: _achievementFilters,
//                     selectedValue: _selectedFilter,
//                     onSelected: (filter) {
//                       setState(() {
//                         _selectedFilter = filter;
//                       });
//                     },
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: AppSpacing.lg),
//           Expanded(child: _buildFilteredAchievementsList()),
//         ],
//       ),
//     );
//   }

//   Widget _buildFilteredAchievementsList() {
//     return StreamBuilder<List<Achievement>>(
//       stream: _selectedFilter == 'all'
//           ? _adminService.getAllAchievements()
//           : _adminService.getAchievementsByStatus(_selectedFilter),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return AppComponents.loadingIndicator();
//         }

//         if (snapshot.hasError) {
//           return AdminEmptyState(
//             title: 'خطأ في تحميل البيانات',
//             subtitle: snapshot.error.toString(),
//             icon: Icons.error_outline,
//           );
//         }

//         var achievements = snapshot.data ?? [];

//         // Apply search filter
//         if (_searchQuery.isNotEmpty) {
//           achievements = achievements.where((achievement) {
//             return achievement.topic.toLowerCase().contains(
//                   _searchQuery.toLowerCase(),
//                 ) ||
//                 achievement.goal.toLowerCase().contains(
//                   _searchQuery.toLowerCase(),
//                 ) ||
//                 achievement.executiveDepartment.toLowerCase().contains(
//                   _searchQuery.toLowerCase(),
//                 );
//           }).toList();
//         }

//         if (achievements.isEmpty) {
//           return AdminEmptyState(
//             title: _searchQuery.isNotEmpty
//                 ? 'لا توجد نتائج للبحث'
//                 : 'لا توجد منجزات',
//             subtitle: _searchQuery.isNotEmpty
//                 ? 'جرب كلمات بحث مختلفة'
//                 : 'لم يتم إضافة أي منجزات بعد',
//             icon: _searchQuery.isNotEmpty
//                 ? Icons.search_off
//                 : Icons.assignment_outlined,
//           );
//         }

//         return ListView.builder(
//           itemCount: achievements.length,
//           itemBuilder: (context, index) {
//             final achievement = achievements[index];
//             return _buildDetailedAchievementCard(achievement);
//           },
//         );
//       },
//     );
//   }

//   Widget _buildUsersManagement() {
//     return Container(
//       padding: const EdgeInsets.all(AppSpacing.lg),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           AdminHeader(
//             title: 'إدارة المستخدمين',
//             subtitle: 'إدارة وتفعيل حسابات المستخدمين',
//             onRefresh: _refreshData,
//           ),
//           const SizedBox(height: AppSpacing.lg),
//           AdminSearchBar(
//             hintText: 'البحث عن مستخدم...',
//             onSearch: (query) {
//               setState(() {
//                 _searchQuery = query;
//               });
//             },
//             onClear: () {
//               setState(() {
//                 _searchQuery = '';
//               });
//             },
//           ),
//           const SizedBox(height: AppSpacing.lg),
//           Expanded(
//             child: StreamBuilder<List<Map<String, dynamic>>>(
//               stream: _adminService.getAllUsers(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return AppComponents.loadingIndicator();
//                 }

//                 if (snapshot.hasError) {
//                   return AdminEmptyState(
//                     title: 'خطأ في تحميل البيانات',
//                     subtitle: snapshot.error.toString(),
//                     icon: Icons.error_outline,
//                   );
//                 }

//                 var users = snapshot.data ?? [];

//                 // Apply search filter
//                 if (_searchQuery.isNotEmpty) {
//                   users = users.where((user) {
//                     final name =
//                         user['displayName']?.toString().toLowerCase() ?? '';
//                     final email = user['email']?.toString().toLowerCase() ?? '';
//                     final query = _searchQuery.toLowerCase();
//                     return name.contains(query) || email.contains(query);
//                   }).toList();
//                 }

//                 if (users.isEmpty) {
//                   return AdminEmptyState(
//                     title: _searchQuery.isNotEmpty
//                         ? 'لا توجد نتائج للبحث'
//                         : 'لا توجد مستخدمين',
//                     subtitle: _searchQuery.isNotEmpty
//                         ? 'جرب كلمات بحث مختلفة'
//                         : 'لم يتم تسجيل أي مستخدمين بعد',
//                     icon: _searchQuery.isNotEmpty
//                         ? Icons.search_off
//                         : Icons.people_outline,
//                   );
//                 }

//                 return ListView.builder(
//                   itemCount: users.length,
//                   itemBuilder: (context, index) {
//                     final user = users[index];
//                     return _buildUserCard(user);
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildUserCard(Map<String, dynamic> user) {
//     final isActive = user['isActive'] ?? true;

//     return Container(
//       margin: const EdgeInsets.only(bottom: AppSpacing.md),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//         border: Border.all(
//           color: isActive
//               ? Colors.green.withOpacity(0.3)
//               : Colors.red.withOpacity(0.3),
//           width: 1,
//         ),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(AppSpacing.lg),
//         child: Row(
//           children: [
//             CircleAvatar(
//               radius: 30,
//               backgroundColor: AppColors.primaryLight.withOpacity(0.2),
//               child: Text(
//                 (user['displayName']?.toString().substring(0, 1) ?? 'م')
//                     .toUpperCase(),
//                 style: TextStyle(
//                   color: AppColors.primaryDark,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 20,
//                 ),
//               ),
//             ),
//             const SizedBox(width: AppSpacing.md),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     user['displayName'] ?? 'مستخدم غير محدد',
//                     style: AppTypography.textTheme.titleMedium?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     user['email'] ?? '',
//                     style: AppTypography.textTheme.bodyMedium?.copyWith(
//                       color: AppColors.secondaryGray,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 8,
//                       vertical: 4,
//                     ),
//                     decoration: BoxDecoration(
//                       color: isActive
//                           ? Colors.green.withOpacity(0.1)
//                           : Colors.red.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Text(
//                       isActive ? 'نشط' : 'معطل',
//                       style: AppTypography.textTheme.bodySmall?.copyWith(
//                         color: isActive ? Colors.green : Colors.red,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Switch(
//               value: isActive,
//               onChanged: (value) => _updateUserStatus(user['id'], value),
//               activeColor: Colors.green,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildAnalytics() {
//     return Container(
//       padding: const EdgeInsets.all(AppSpacing.lg),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           AdminHeader(
//             title: 'التقارير والتحليلات',
//             subtitle: 'تحليلات مفصلة وإحصائيات متقدمة',
//             onRefresh: _refreshData,
//           ),
//           const SizedBox(height: AppSpacing.lg),
//           const Expanded(
//             child: AdminEmptyState(
//               title: 'قريباً...',
//               subtitle: 'ستكون التحليلات والتقارير المتقدمة متاحة قريباً',
//               icon: Icons.analytics_outlined,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAdminSettings() {
//     return Container(
//       padding: const EdgeInsets.all(AppSpacing.lg),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           AdminHeader(
//             title: 'الإعدادات الإدارية',
//             subtitle: 'إعدادات النظام والتحكم في الصلاحيات',
//             onRefresh: _refreshData,
//           ),
//           const SizedBox(height: AppSpacing.lg),
//           const Expanded(
//             child: AdminEmptyState(
//               title: 'قريباً...',
//               subtitle: 'ستكون الإعدادات الإدارية المتقدمة متاحة قريباً',
//               icon: Icons.settings_outlined,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showAchievementDetails(Achievement achievement) {
//     showDialog(
//       context: context,
//       builder: (context) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         child: Container(
//           constraints: const BoxConstraints(maxWidth: 600),
//           padding: const EdgeInsets.all(AppSpacing.lg),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Expanded(
//                     child: Text(
//                       achievement.topic,
//                       style: AppTypography.textTheme.headlineSmall?.copyWith(
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                   IconButton(
//                     onPressed: () => Navigator.of(context).pop(),
//                     icon: const Icon(Icons.close),
//                   ),
//                 ],
//               ),
//               const Divider(),
//               const SizedBox(height: AppSpacing.md),
//               SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _buildDetailRow('الهدف', achievement.goal),
//                     _buildDetailRow(
//                       'الإدارة التنفيذية',
//                       achievement.executiveDepartment,
//                     ),
//                     _buildDetailRow(
//                       'الإدارة الرئيسية',
//                       achievement.mainDepartment,
//                     ),
//                     _buildDetailRow('القسم الفرعي', achievement.subDepartment),
//                     _buildDetailRow(
//                       'التاريخ',
//                       '${achievement.date.day}/${achievement.date.month}/${achievement.date.year}',
//                     ),
//                     _buildDetailRow('المكان', achievement.location),
//                     _buildDetailRow('المدة', achievement.duration),
//                     _buildDetailRow('الأثر', achievement.impact),
//                     _buildDetailRow('الحالة', achievement.status),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: AppSpacing.lg),
//               if (achievement.status == 'pending')
//                 Row(
//                   children: [
//                     Expanded(
//                       child: ElevatedButton(
//                         onPressed: () {
//                           Navigator.of(context).pop();
//                           _approveAchievement(achievement);
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.green,
//                           foregroundColor: Colors.white,
//                         ),
//                         child: const Text('اعتماد'),
//                       ),
//                     ),
//                     const SizedBox(width: AppSpacing.md),
//                     Expanded(
//                       child: OutlinedButton(
//                         onPressed: () {
//                           Navigator.of(context).pop();
//                           _rejectAchievement(achievement);
//                         },
//                         style: OutlinedButton.styleFrom(
//                           foregroundColor: Colors.red,
//                           side: const BorderSide(color: Colors.red),
//                         ),
//                         child: const Text('رفض'),
//                       ),
//                     ),
//                   ],
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> _approveAchievement(Achievement achievement) async {
//     try {
//       AdminLoadingDialog.show(context, 'جارٍ اعتماد المنجز...');

//       await _adminService.updateAchievementStatus(achievement.id!, 'approved');

//       if (mounted) {
//         AdminLoadingDialog.hide(context);
//         AdminNotificationService.showSuccess(
//           context,
//           title: 'تم اعتماد المنجز',
//           message: 'تم اعتماد "${achievement.topic}" بنجاح',
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         AdminLoadingDialog.hide(context);
//         AdminNotificationService.showError(
//           context,
//           title: 'خطأ في اعتماد المنجز',
//           message: e.toString(),
//         );
//       }
//     }
//   }

//   Future<void> _rejectAchievement(Achievement achievement) async {
//     final confirmed = await AdminConfirmationDialog.show(
//       context,
//       title: 'رفض المنجز',
//       content:
//           'هل أنت متأكد من رفض هذا المنجز؟ لا يمكن التراجع عن هذا الإجراء.',
//       confirmText: 'رفض',
//       icon: Icons.cancel,
//       iconColor: Colors.red,
//     );

//     if (confirmed == true) {
//       try {
//         AdminLoadingDialog.show(context, 'جارٍ رفض المنجز...');

//         await _adminService.updateAchievementStatus(
//           achievement.id!,
//           'rejected',
//         );

//         if (mounted) {
//           AdminLoadingDialog.hide(context);
//           AdminNotificationService.showWarning(
//             context,
//             title: 'تم رفض المنجز',
//             message: 'تم رفض "${achievement.topic}"',
//           );
//         }
//       } catch (e) {
//         if (mounted) {
//           AdminLoadingDialog.hide(context);
//           AdminNotificationService.showError(
//             context,
//             title: 'خطأ في رفض المنجز',
//             message: e.toString(),
//           );
//         }
//       }
//     }
//   }

//   Future<void> _updateUserStatus(String userId, bool isActive) async {
//     try {
//       AdminLoadingDialog.show(context, 'جارٍ تحديث حالة المستخدم...');

//       await _adminService.updateUserStatus(userId, isActive);

//       if (mounted) {
//         AdminLoadingDialog.hide(context);
//         AdminNotificationService.showSuccess(
//           context,
//           title: 'تم تحديث حالة المستخدم',
//           message: isActive ? 'تم تفعيل المستخدم' : 'تم إلغاء تفعيل المستخدم',
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         AdminLoadingDialog.hide(context);
//         AdminNotificationService.showError(
//           context,
//           title: 'خطأ في تحديث المستخدم',
//           message: e.toString(),
//         );
//       }
//     }
//   }

//   Future<void> _handleLogout() async {
//     final confirmed = await AdminConfirmationDialog.show(
//       context,
//       title: 'تسجيل الخروج',
//       content: 'هل أنت متأكد من تسجيل الخروج من لوحة التحكم؟',
//       confirmText: 'تسجيل الخروج',
//       icon: Icons.logout,
//       iconColor: Colors.red,
//     );

//     if (confirmed == true) {
//       try {
//         await _authService.signOut();
//         if (mounted) {
//           AppRouter.navigateToLogin(context);
//         }
//       } catch (e) {
//         if (mounted) {
//           AdminNotificationService.showError(
//             context,
//             title: 'خطأ في تسجيل الخروج',
//             message: e.toString(),
//           );
//         }
//       }
//     }
//   }
// }
