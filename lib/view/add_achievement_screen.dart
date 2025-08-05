// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:file_picker/file_picker.dart';
// import '../theme/app_colors.dart';
// import '../theme/app_typography.dart';
// import '../theme/app_spacing.dart';
// import '../theme/app_components.dart';
// import '../services/departments_service.dart';
// import '../services/achievement_service.dart';
// import '../models/achievement.dart';

// class AddAchievementScreen extends StatefulWidget {
//   const AddAchievementScreen({super.key});

//   @override
//   State<AddAchievementScreen> createState() => _AddAchievementScreenState();
// }

// class _AddAchievementScreenState extends State<AddAchievementScreen>
//     with TickerProviderStateMixin {
//   final _formKey = GlobalKey<FormState>();
//   late AnimationController _fadeController;
//   late AnimationController _slideController;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;

//   // Form controllers
//   final _participationTypeController = TextEditingController();
//   final _executiveDepartmentController = TextEditingController();
//   final _mainDepartmentController = TextEditingController();
//   final _subDepartmentController = TextEditingController();
//   final _topicController = TextEditingController();
//   final _goalController = TextEditingController();
//   final _dateController = TextEditingController();
//   final _locationController = TextEditingController();
//   final _durationController = TextEditingController();
//   final _impactController = TextEditingController();

//   // Form state
//   String? _selectedParticipationType;
//   String? _selectedExecutiveDepartment;
//   String? _selectedMainDepartment;
//   String? _selectedSubDepartment;
//   DateTime? _selectedDate;
//   List<PlatformFile> _selectedFiles = [];
//   bool _isLoading = false;

//   // Departments data structure - Three-tier hierarchy
//   Map<String, Map<String, List<String>>> _departmentsData = {};
//   final DepartmentsService _departmentsService = DepartmentsService();
//   final AchievementService _achievementService = AchievementService();

//   // Get main departments list for selected executive department
//   List<String> get _availableMainDepartments {
//     if (_selectedExecutiveDepartment == null) return [];
//     return _departmentsService.getMainDepartments(
//       _selectedExecutiveDepartment!,
//     );
//   }

//   // Get sub departments list for selected main department
//   List<String> get _availableSubDepartments {
//     if (_selectedExecutiveDepartment == null || _selectedMainDepartment == null)
//       return [];
//     return _departmentsService.getSubDepartments(
//       _selectedExecutiveDepartment!,
//       _selectedMainDepartment!,
//     );
//   }

//   // Participation types
//   final List<String> _participationTypes = [
//     'مبادرة',
//     'تدشين',
//     'مشاركة',
//     'فعالية',
//     'حملة',
//     'لقاء',
//     'محاضرة',
//     'دورة تدريبية',
//     'اجتماع',
//     'شراكة مجتمعية',
//     'ورشة تدريبية',
//     'معرض',
//     'ملتقى',
//     'نشاط',
//     'لوحة بيانات',
//     'تفعيل أيام عالمية',
//     'تفعيل',
//     'مؤتمر',
//     'خبر',
//     'اعتماد',
//     'إصدار دليل',
//     'تنفيذ برنامج',
//     'ركن',
//     'بروشور',
//     'بوستر',
//     'رول أب',
//     'تغريدة X',
//     'منشور سناب شات',
//     'منشور تيك توك',
//     'منشور إنستقرام',
//     'خدمة جديدة',
//     'جائزة',
//     'تكريم',
//     'مشروع',
//     'مؤشر متميز',
//     'قصة نجاح',
//     'ابتكار',
//     'أخرى',
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _initializeAnimations();
//     _loadDepartmentsData();
//   }

//   void _initializeAnimations() {
//     _fadeController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );

//     _slideController = AnimationController(
//       duration: const Duration(milliseconds: 600),
//       vsync: this,
//     );

//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
//     );

//     _slideAnimation =
//         Tween<Offset>(begin: const Offset(0.0, 0.3), end: Offset.zero).animate(
//           CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
//         );

//     // Start animations
//     Future.delayed(const Duration(milliseconds: 100), () {
//       _fadeController.forward();
//       _slideController.forward();
//     });
//   }

//   // Function to load departments data from Excel file
//   // In a real app, this would read from the actual Excel file
//   Future<void> _loadDepartmentsData() async {
//     try {
//       // Load departments using the service
//       _departmentsData = await _departmentsService.loadDepartments();

//       setState(() {
//         // Update UI after loading
//       });
//     } catch (e) {
//       // Handle error loading departments data
//       debugPrint('Error loading departments data: $e');

//       // Show error to user
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               'خطأ في تحميل بيانات الإدارات: $e',
//               style: const TextStyle(color: Colors.white),
//             ),
//             backgroundColor: AppColors.error,
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
//             ),
//           ),
//         );
//       }
//     }
//   }

//   // Helper method to format date in Arabic style
//   String _formatDate(DateTime date) {
//     // Format as DD/MM/YYYY with leading zeros
//     String day = date.day.toString().padLeft(2, '0');
//     String month = date.month.toString().padLeft(2, '0');
//     String year = date.year.toString();
//     return '$day/$month/$year';
//   }

//   // Helper method to get file icon based on file extension
//   IconData _getFileIcon(String extension) {
//     switch (extension.toLowerCase()) {
//       case '.pdf':
//         return Icons.picture_as_pdf;
//       case '.doc':
//       case '.docx':
//         return Icons.description;
//       case '.jpg':
//       case '.jpeg':
//       case '.png':
//       case '.gif':
//         return Icons.image;
//       case '.mp4':
//       case '.mov':
//       case '.avi':
//         return Icons.video_file;
//       case '.mp3':
//       case '.wav':
//       case '.m4a':
//         return Icons.audio_file;
//       case '.xlsx':
//       case '.xls':
//         return Icons.table_chart;
//       case '.pptx':
//       case '.ppt':
//         return Icons.slideshow;
//       default:
//         return Icons.insert_drive_file;
//     }
//   }

//   // Helper method to format file size for web
//   String _formatFileSize(int bytes) {
//     if (bytes < 1024) return '$bytes B';
//     if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
//     if (bytes < 1024 * 1024 * 1024)
//       return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
//     return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
//   }

//   // Helper method to build file item widget for web
//   Widget _buildFileItem(PlatformFile file) {
//     final extension = file.extension != null ? '.${file.extension}' : '';
//     final fileIcon = _getFileIcon(extension);
//     final fileSize = file.size > 0 ? _formatFileSize(file.size) : 'غير معروف';

//     return Container(
//       margin: EdgeInsets.only(bottom: AppSpacing.xs),
//       padding: EdgeInsets.all(AppSpacing.sm),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
//         border: Border.all(color: AppColors.outline.withValues(alpha: 0.3)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.05),
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: EdgeInsets.all(AppSpacing.xs),
//             decoration: BoxDecoration(
//               color: AppColors.primaryLight.withValues(alpha: 0.1),
//               borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
//             ),
//             child: Icon(fileIcon, size: 20, color: AppColors.primaryMedium),
//           ),
//           SizedBox(width: AppSpacing.sm),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   file.name,
//                   style: AppTypography.textTheme.bodySmall!.copyWith(
//                     fontWeight: FontWeight.w500,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 if (file.size > 0) ...[
//                   SizedBox(height: 2),
//                   Text(
//                     fileSize,
//                     style: AppTypography.textTheme.bodySmall!.copyWith(
//                       color: AppColors.onSurfaceVariant,
//                       fontSize: 11,
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//           IconButton(
//             icon: const Icon(Icons.close, size: 18, color: AppColors.error),
//             onPressed: () {
//               setState(() {
//                 _selectedFiles.remove(file);
//               });
//             },
//             tooltip: 'حذف الملف',
//           ),
//         ],
//       ),
//     );
//   }

//   // Helper method to clear all selected files
//   void _clearAllFiles() {
//     setState(() {
//       _selectedFiles.clear();
//     });

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: const Text(
//           'تم مسح جميع الملفات',
//           style: TextStyle(color: Colors.white),
//         ),
//         backgroundColor: AppColors.primaryMedium,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _fadeController.dispose();
//     _slideController.dispose();
//     _participationTypeController.dispose();
//     _executiveDepartmentController.dispose();
//     _mainDepartmentController.dispose();
//     _subDepartmentController.dispose();
//     _topicController.dispose();
//     _goalController.dispose();
//     _dateController.dispose();
//     _locationController.dispose();
//     _durationController.dispose();
//     _impactController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenSize = MediaQuery.of(context).size;
//     final isDesktop = screenSize.width > 1024;
//     final isTablet = screenSize.width > 768 && screenSize.width <= 1024;

//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppComponents.appBar(
//         title: 'إضافة منجز جديد',
//         showBackButton: true,
//         leading: Container(
//           margin: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: Colors.white.withValues(alpha: 0.2),
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
//           ),
//           child: IconButton(
//             icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
//             onPressed: () => Navigator.of(context).pop(),
//             color: Colors.white,
//             splashRadius: 20,
//           ),
//         ),
//       ),
//       body: SafeArea(
//         child: AnimatedBuilder(
//           animation: _fadeAnimation,
//           builder: (context, child) {
//             return Opacity(
//               opacity: _fadeAnimation.value,
//               child: SlideTransition(
//                 position: _slideAnimation,
//                 child: _buildFormLayout(context, isDesktop, isTablet),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildFormLayout(BuildContext context, bool isDesktop, bool isTablet) {
//     if (isDesktop) {
//       return _buildDesktopLayout();
//     } else if (isTablet) {
//       return _buildTabletLayout();
//     } else {
//       return _buildMobileLayout();
//     }
//   }

//   Widget _buildDesktopLayout() {
//     return SingleChildScrollView(
//       child: AppComponents.responsiveContainer(
//         screenWidth: MediaQuery.of(context).size.width,
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Form Section
//             Expanded(flex: 7, child: _buildFormCard()),
//             SizedBox(width: AppSpacing.xl),
//             // Info Section
//             Expanded(flex: 3, child: _buildInfoCard()),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTabletLayout() {
//     return SingleChildScrollView(
//       child: AppComponents.responsiveContainer(
//         screenWidth: MediaQuery.of(context).size.width,
//         child: Column(
//           children: [
//             _buildInfoCard(),
//             SizedBox(height: AppSpacing.xl),
//             _buildFormCard(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMobileLayout() {
//     return SingleChildScrollView(
//       padding: EdgeInsets.all(AppSpacing.md),
//       child: Column(
//         children: [
//           _buildInfoCard(),
//           SizedBox(height: AppSpacing.lg),
//           _buildFormCard(),
//         ],
//       ),
//     );
//   }

//   Widget _buildInfoCard() {
//     return TweenAnimationBuilder<double>(
//       duration: const Duration(milliseconds: 600),
//       tween: Tween(begin: 0.0, end: 1.0),
//       builder: (context, value, child) {
//         return Transform.scale(
//           scale: 0.95 + (0.05 * value),
//           child: Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topRight,
//                 end: Alignment.bottomLeft,
//                 colors: [
//                   AppColors.primaryDark,
//                   AppColors.primaryMedium,
//                   AppColors.primaryLight.withValues(alpha: 0.8),
//                 ],
//               ),
//               borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
//               boxShadow: [
//                 BoxShadow(
//                   color: AppColors.primaryDark.withValues(alpha: 0.15),
//                   blurRadius: 20,
//                   offset: const Offset(0, 8),
//                 ),
//               ],
//             ),
//             padding: EdgeInsets.all(AppSpacing.xl),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Container(
//                       padding: EdgeInsets.all(AppSpacing.md),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withValues(alpha: 0.2),
//                         borderRadius: BorderRadius.circular(
//                           AppSpacing.radiusLg,
//                         ),
//                       ),
//                       child: const Icon(
//                         Icons.add_task,
//                         color: Colors.white,
//                         size: 32,
//                       ),
//                     ),
//                     SizedBox(width: AppSpacing.md),
//                     Expanded(
//                       child: Text(
//                         'إضافة منجز جديد',
//                         style: AppTypography.textTheme.headlineSmall!.copyWith(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: AppSpacing.lg),
//                 Text(
//                   'قم بتعبئة جميع الحقول المطلوبة لإضافة منجز جديد إلى سجلك. تأكد من دقة المعلومات المدخلة.',
//                   style: AppTypography.textTheme.bodyMedium!.copyWith(
//                     color: Colors.white.withValues(alpha: 0.9),
//                     height: 1.6,
//                   ),
//                 ),
//                 SizedBox(height: AppSpacing.lg),
//                 _buildTipsList(),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildTipsList() {
//     final tips = [
//       'تأكد من اختيار نوع المشاركة المناسب',
//       'اختر الإدارة التنفيذية أولاً ثم الإدارة الفرعية',
//       'أدخل تاريخ المشاركة الصحيح',
//       'اكتب وصفاً واضحاً للموضوع والهدف',
//       'أرفق الملفات الداعمة إن وجدت',
//     ];

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'نصائح لتعبئة الاستمارة:',
//           style: AppTypography.textTheme.labelLarge!.copyWith(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         SizedBox(height: AppSpacing.md),
//         ...tips.asMap().entries.map((entry) {
//           final index = entry.key;
//           final tip = entry.value;
//           return TweenAnimationBuilder<double>(
//             duration: Duration(milliseconds: 400 + (index * 100)),
//             tween: Tween(begin: 0.0, end: 1.0),
//             builder: (context, value, child) {
//               return Transform.translate(
//                 offset: Offset(20 * (1 - value), 0),
//                 child: Opacity(
//                   opacity: value,
//                   child: Padding(
//                     padding: EdgeInsets.only(bottom: AppSpacing.sm),
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Container(
//                           margin: EdgeInsets.only(top: 4),
//                           width: 6,
//                           height: 6,
//                           decoration: const BoxDecoration(
//                             color: Colors.white,
//                             shape: BoxShape.circle,
//                           ),
//                         ),
//                         SizedBox(width: AppSpacing.sm),
//                         Expanded(
//                           child: Text(
//                             tip,
//                             style: AppTypography.textTheme.bodySmall!.copyWith(
//                               color: Colors.white.withValues(alpha: 0.8),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           );
//         }).toList(),
//       ],
//     );
//   }

//   Widget _buildFormCard() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.08),
//             blurRadius: 20,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       padding: EdgeInsets.all(AppSpacing.xl),
//       child: Form(
//         key: _formKey,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'تفاصيل المنجز',
//               style: AppTypography.textTheme.headlineSmall!.copyWith(
//                 color: AppColors.primaryDark,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: AppSpacing.xl),
//             _buildFormFields(),
//             SizedBox(height: AppSpacing.xl),
//             _buildSubmitButton(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildFormFields() {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final isDesktop = screenWidth > 1024;

//     return Column(
//       children: [
//         // Participation Type and Executive Department
//         if (isDesktop)
//           Row(
//             children: [
//               Expanded(child: _buildParticipationTypeField()),
//               SizedBox(width: AppSpacing.lg),
//               Expanded(child: _buildExecutiveDepartmentField()),
//             ],
//           )
//         else ...[
//           _buildParticipationTypeField(),
//           SizedBox(height: AppSpacing.lg),
//           _buildExecutiveDepartmentField(),
//         ],

//         SizedBox(height: AppSpacing.lg),

//         // Departments - Executive, Main, and Sub
//         if (isDesktop)
//           Row(
//             children: [
//               Expanded(child: _buildMainDepartmentField()),
//               SizedBox(width: AppSpacing.lg),
//               Expanded(child: _buildSubDepartmentField()),
//             ],
//           )
//         else ...[
//           _buildMainDepartmentField(),
//           SizedBox(height: AppSpacing.lg),
//           _buildSubDepartmentField(),
//         ],

//         SizedBox(height: AppSpacing.lg),

//         // Date field
//         _buildDateField(),

//         SizedBox(height: AppSpacing.lg),

//         // Location and Duration
//         if (isDesktop)
//           Row(
//             children: [
//               Expanded(child: _buildLocationField()),
//               SizedBox(width: AppSpacing.lg),
//               Expanded(child: _buildDurationField()),
//             ],
//           )
//         else ...[
//           _buildLocationField(),
//           SizedBox(height: AppSpacing.lg),
//           _buildDurationField(),
//         ],

//         SizedBox(height: AppSpacing.lg),

//         // Topic (Full width)
//         _buildTopicField(),
//         SizedBox(height: AppSpacing.lg),

//         // Goal (Full width)
//         _buildGoalField(),
//         SizedBox(height: AppSpacing.lg),

//         // Impact (Full width)
//         _buildImpactField(),
//         SizedBox(height: AppSpacing.lg),

//         // Attachments
//         _buildAttachmentsField(),
//       ],
//     );
//   }

//   Widget _buildAnimatedField({required Widget child, required int index}) {
//     return TweenAnimationBuilder<double>(
//       duration: Duration(milliseconds: 300 + (index * 50)),
//       tween: Tween(begin: 0.0, end: 1.0),
//       builder: (context, value, _) {
//         return Transform.translate(
//           offset: Offset(0, 20 * (1 - value)),
//           child: Opacity(opacity: value, child: child),
//         );
//       },
//     );
//   }

//   Widget _buildParticipationTypeField() {
//     return _buildAnimatedField(
//       index: 0,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'نوع المشاركة *',
//             style: AppTypography.textTheme.labelLarge!.copyWith(
//               color: AppColors.onSurface,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           SizedBox(height: AppSpacing.xs),
//           DropdownButtonFormField<String>(
//             value: _selectedParticipationType,
//             decoration: _getInputDecoration('اختر نوع المشاركة'),
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'نوع المشاركة مطلوب';
//               }
//               return null;
//             },
//             items: _participationTypes.map((type) {
//               return DropdownMenuItem<String>(
//                 value: type,
//                 child: Text(type, style: AppTypography.textTheme.bodyMedium),
//               );
//             }).toList(),
//             onChanged: (value) {
//               setState(() {
//                 _selectedParticipationType = value;
//                 _participationTypeController.text = value ?? '';
//               });
//             },
//             icon: const Icon(Icons.keyboard_arrow_down),
//             isExpanded: true,
//             style: AppTypography.textTheme.bodyMedium,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildExecutiveDepartmentField() {
//     return _buildAnimatedField(
//       index: 1,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'الإدارة التنفيذية *',
//             style: AppTypography.textTheme.labelLarge!.copyWith(
//               color: AppColors.onSurface,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           SizedBox(height: AppSpacing.xs),
//           DropdownButtonFormField<String>(
//             value: _selectedExecutiveDepartment,
//             decoration: _getInputDecoration('اختر الإدارة التنفيذية'),
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'الإدارة التنفيذية مطلوبة';
//               }
//               return null;
//             },
//             items: _departmentsData.keys.map((department) {
//               return DropdownMenuItem<String>(
//                 value: department,
//                 child: Text(
//                   department,
//                   style: AppTypography.textTheme.bodyMedium,
//                 ),
//               );
//             }).toList(),
//             onChanged: (value) {
//               setState(() {
//                 _selectedExecutiveDepartment = value;
//                 _selectedMainDepartment =
//                     null; // Reset main department selection
//                 _selectedSubDepartment = null; // Reset sub department selection
//                 _executiveDepartmentController.text = value ?? '';
//                 _mainDepartmentController
//                     .clear(); // Clear main department field
//                 _subDepartmentController.clear(); // Clear sub department field
//               });
//             },
//             icon: const Icon(Icons.keyboard_arrow_down),
//             isExpanded: true,
//             style: AppTypography.textTheme.bodyMedium,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMainDepartmentField() {
//     return _buildAnimatedField(
//       index: 2,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'الإدارة الرئيسية *',
//             style: AppTypography.textTheme.labelLarge!.copyWith(
//               color: AppColors.onSurface,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           SizedBox(height: AppSpacing.xs),
//           DropdownButtonFormField<String>(
//             value: _selectedMainDepartment,
//             decoration: _getInputDecoration(
//               _selectedExecutiveDepartment == null
//                   ? 'اختر الإدارة التنفيذية أولاً'
//                   : 'اختر الإدارة الرئيسية',
//             ),
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'الإدارة الرئيسية مطلوبة';
//               }
//               return null;
//             },
//             items: _availableMainDepartments.map((department) {
//               return DropdownMenuItem<String>(
//                 value: department,
//                 child: Text(
//                   department,
//                   style: AppTypography.textTheme.bodyMedium,
//                 ),
//               );
//             }).toList(),
//             onChanged: _selectedExecutiveDepartment == null
//                 ? null
//                 : (value) {
//                     setState(() {
//                       _selectedMainDepartment = value;
//                       _selectedSubDepartment =
//                           null; // Reset sub department selection
//                       _mainDepartmentController.text = value ?? '';
//                       _subDepartmentController
//                           .clear(); // Clear sub department field
//                     });
//                   },
//             icon: const Icon(Icons.keyboard_arrow_down),
//             isExpanded: true,
//             style: AppTypography.textTheme.bodyMedium,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSubDepartmentField() {
//     return _buildAnimatedField(
//       index: 3,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'الإدارة الفرعية *',
//             style: AppTypography.textTheme.labelLarge!.copyWith(
//               color: AppColors.onSurface,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           SizedBox(height: AppSpacing.xs),
//           DropdownButtonFormField<String>(
//             value: _selectedSubDepartment,
//             decoration: _getInputDecoration(
//               _selectedMainDepartment == null
//                   ? 'اختر الإدارة الرئيسية أولاً'
//                   : 'اختر الإدارة الفرعية',
//             ),
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'الإدارة الفرعية مطلوبة';
//               }
//               return null;
//             },
//             items: _availableSubDepartments.map((department) {
//               return DropdownMenuItem<String>(
//                 value: department,
//                 child: Text(
//                   department,
//                   style: AppTypography.textTheme.bodyMedium,
//                 ),
//               );
//             }).toList(),
//             onChanged: _selectedMainDepartment == null
//                 ? null
//                 : (value) {
//                     setState(() {
//                       _selectedSubDepartment = value;
//                       _subDepartmentController.text = value ?? '';
//                     });
//                   },
//             icon: const Icon(Icons.keyboard_arrow_down),
//             isExpanded: true,
//             style: AppTypography.textTheme.bodyMedium,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDateField() {
//     return _buildAnimatedField(
//       index: 3,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'تاريخ عمل المشاركة *',
//             style: AppTypography.textTheme.labelLarge!.copyWith(
//               color: AppColors.onSurface,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           SizedBox(height: AppSpacing.xs),
//           TextFormField(
//             controller: _dateController,
//             decoration: _getInputDecoration('اختر التاريخ').copyWith(
//               suffixIcon: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   if (_selectedDate != null)
//                     IconButton(
//                       icon: const Icon(Icons.clear, size: 20),
//                       onPressed: () {
//                         setState(() {
//                           _selectedDate = null;
//                           _dateController.clear();
//                         });
//                       },
//                       tooltip: 'مسح التاريخ',
//                     ),
//                   const Icon(Icons.calendar_today),
//                   SizedBox(width: AppSpacing.xs),
//                 ],
//               ),
//             ),
//             readOnly: true,
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'تاريخ المشاركة مطلوب';
//               }
//               return null;
//             },
//             onTap: () async {
//               try {
//                 final pickedDate = await showDatePicker(
//                   context: context,
//                   initialDate: _selectedDate ?? DateTime.now(),
//                   firstDate: DateTime(2020),
//                   lastDate: DateTime.now().add(const Duration(days: 365)),
//                   helpText: 'اختر التاريخ',
//                   cancelText: 'إلغاء',
//                   confirmText: 'موافق',
//                   fieldLabelText: 'أدخل التاريخ',
//                   fieldHintText: 'يوم/شهر/سنة',
//                   builder: (context, child) {
//                     return Directionality(
//                       textDirection: TextDirection.rtl,
//                       child: Theme(
//                         data: Theme.of(context).copyWith(
//                           colorScheme: Theme.of(context).colorScheme.copyWith(
//                             primary: AppColors.primaryMedium,
//                             onPrimary: Colors.white,
//                             surface: Colors.white,
//                             onSurface: AppColors.onSurface,
//                           ),
//                           dialogBackgroundColor: Colors.white,
//                           textButtonTheme: TextButtonThemeData(
//                             style: TextButton.styleFrom(
//                               foregroundColor: AppColors.primaryMedium,
//                             ),
//                           ),
//                         ),
//                         child: child!,
//                       ),
//                     );
//                   },
//                 );

//                 if (pickedDate != null) {
//                   setState(() {
//                     _selectedDate = pickedDate;
//                     // Format date in Arabic style: DD/MM/YYYY
//                     _dateController.text = _formatDate(pickedDate);
//                   });
//                 }
//               } catch (e) {
//                 // Handle any errors that might occur during date picking
//                 debugPrint('Error picking date: $e');
//                 if (mounted) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: const Text(
//                         'حدث خطأ أثناء اختيار التاريخ. يرجى المحاولة مرة أخرى.',
//                         style: TextStyle(color: Colors.white),
//                       ),
//                       backgroundColor: AppColors.error,
//                       behavior: SnackBarBehavior.floating,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(
//                           AppSpacing.radiusMd,
//                         ),
//                       ),
//                     ),
//                   );
//                 }
//               }
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildLocationField() {
//     return _buildAnimatedField(
//       index: 4,
//       child: _buildTextFormField(
//         controller: _locationController,
//         label: 'موقع المشاركة *',
//         hint: 'أدخل موقع المشاركة',
//         validator: (value) {
//           if (value == null || value.isEmpty) {
//             return 'موقع المشاركة مطلوب';
//           }
//           return null;
//         },
//       ),
//     );
//   }

//   Widget _buildDurationField() {
//     return _buildAnimatedField(
//       index: 5,
//       child: _buildTextFormField(
//         controller: _durationController,
//         label: 'مدة التنفيذ *',
//         hint: 'مثال: 3 أيام، أسبوعين',
//         validator: (value) {
//           if (value == null || value.isEmpty) {
//             return 'مدة التنفيذ مطلوبة';
//           }
//           return null;
//         },
//       ),
//     );
//   }

//   Widget _buildTopicField() {
//     return _buildAnimatedField(
//       index: 6,
//       child: _buildTextFormField(
//         controller: _topicController,
//         label: 'موضوع المشاركة *',
//         hint: 'اكتب وصفاً تفصيلياً لموضوع المشاركة',
//         maxLines: 3,
//         validator: (value) {
//           if (value == null || value.isEmpty) {
//             return 'موضوع المشاركة مطلوب';
//           }
//           return null;
//         },
//       ),
//     );
//   }

//   Widget _buildGoalField() {
//     return _buildAnimatedField(
//       index: 7,
//       child: _buildTextFormField(
//         controller: _goalController,
//         label: 'الهدف من المشاركة *',
//         hint: 'اكتب الهدف أو الغاية من المشاركة',
//         maxLines: 3,
//         validator: (value) {
//           if (value == null || value.isEmpty) {
//             return 'الهدف من المشاركة مطلوب';
//           }
//           return null;
//         },
//       ),
//     );
//   }

//   Widget _buildImpactField() {
//     return _buildAnimatedField(
//       index: 8,
//       child: _buildTextFormField(
//         controller: _impactController,
//         label: 'الأثر أو الفائدة *',
//         hint: 'اكتب الأثر المحقق أو الفائدة من المشاركة',
//         maxLines: 3,
//         validator: (value) {
//           if (value == null || value.isEmpty) {
//             return 'الأثر أو الفائدة مطلوبة';
//           }
//           return null;
//         },
//       ),
//     );
//   }

//   Widget _buildAttachmentsField() {
//     return _buildAnimatedField(
//       index: 9,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'المرفقات (اختياري)',
//             style: AppTypography.textTheme.labelLarge!.copyWith(
//               color: AppColors.onSurface,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           SizedBox(height: AppSpacing.xs),
//           Container(
//             width: double.infinity,
//             decoration: BoxDecoration(
//               border: Border.all(
//                 color: AppColors.outline,
//                 style: BorderStyle.solid,
//                 width: 1,
//               ),
//               borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
//               color: AppColors.surfaceLight,
//             ),
//             child: InkWell(
//               onTap: _selectFiles,
//               borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
//               child: Padding(
//                 padding: EdgeInsets.all(AppSpacing.lg),
//                 child: Column(
//                   children: [
//                     Icon(
//                       Icons.cloud_upload_outlined,
//                       size: 48,
//                       color: AppColors.primaryMedium,
//                     ),
//                     SizedBox(height: AppSpacing.sm),
//                     Text(
//                       _selectedFiles.isEmpty
//                           ? 'اضغط لاختيار الملفات'
//                           : 'اضغط لإضافة المزيد من الملفات',
//                       style: AppTypography.textTheme.bodyMedium!.copyWith(
//                         color: AppColors.primaryMedium,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     SizedBox(height: AppSpacing.xs),
//                     Text(
//                       'أنواع الملفات المدعومة: PDF, DOC, DOCX, JPG, PNG, MP4, MP3 (حد أقصى 10MB لكل ملف)',
//                       style: AppTypography.textTheme.bodySmall!.copyWith(
//                         color: AppColors.onSurfaceVariant,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                     if (_selectedFiles.isNotEmpty) ...[
//                       SizedBox(height: AppSpacing.lg),
//                       Container(
//                         width: double.infinity,
//                         padding: EdgeInsets.all(AppSpacing.md),
//                         decoration: BoxDecoration(
//                           color: AppColors.primaryLight.withValues(alpha: 0.05),
//                           borderRadius: BorderRadius.circular(
//                             AppSpacing.radiusSm,
//                           ),
//                           border: Border.all(
//                             color: AppColors.primaryLight.withValues(alpha: 0.2),
//                           ),
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               children: [
//                                 Icon(
//                                   Icons.attach_file,
//                                   size: 16,
//                                   color: AppColors.primaryMedium,
//                                 ),
//                                 SizedBox(width: AppSpacing.xs),
//                                 Text(
//                                   'الملفات المحددة (${_selectedFiles.length})',
//                                   style: AppTypography.textTheme.labelMedium!
//                                       .copyWith(
//                                         color: AppColors.primaryMedium,
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                                 ),
//                                 const Spacer(),
//                                 TextButton(
//                                   onPressed: _clearAllFiles,
//                                   child: Text(
//                                     'مسح الكل',
//                                     style: AppTypography.textTheme.bodySmall!
//                                         .copyWith(
//                                           color: AppColors.error,
//                                           fontWeight: FontWeight.w500,
//                                         ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             SizedBox(height: AppSpacing.sm),
//                             ..._selectedFiles
//                                 .map((file) => _buildFileItem(file))
//                                 .toList(),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTextFormField({
//     required TextEditingController controller,
//     required String label,
//     required String hint,
//     String? Function(String?)? validator,
//     int maxLines = 1,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: AppTypography.textTheme.labelLarge!.copyWith(
//             color: AppColors.onSurface,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         SizedBox(height: AppSpacing.xs),
//         Focus(
//           child: Builder(
//             builder: (context) {
//               final hasFocus = Focus.of(context).hasFocus;
//               return AnimatedContainer(
//                 duration: const Duration(milliseconds: 200),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
//                   boxShadow: hasFocus
//                       ? [
//                           BoxShadow(
//                             color: AppColors.primaryMedium.withValues(alpha: 0.15),
//                             blurRadius: 8,
//                             offset: const Offset(0, 2),
//                           ),
//                         ]
//                       : [],
//                 ),
//                 child: TextFormField(
//                   controller: controller,
//                   decoration: _getInputDecoration(hint),
//                   validator: validator,
//                   maxLines: maxLines,
//                   textAlign: TextAlign.right,
//                   textDirection: TextDirection.rtl,
//                   style: AppTypography.textTheme.bodyMedium,
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   InputDecoration _getInputDecoration(String hint) {
//     return InputDecoration(
//       hintText: hint,
//       filled: true,
//       fillColor: AppColors.surfaceLight,
//       contentPadding: EdgeInsets.symmetric(
//         horizontal: AppSpacing.md,
//         vertical: AppSpacing.md,
//       ),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
//         borderSide: const BorderSide(color: AppColors.outline, width: 1),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
//         borderSide: const BorderSide(color: AppColors.outline, width: 1),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
//         borderSide: const BorderSide(color: AppColors.primaryMedium, width: 2),
//       ),
//       errorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
//         borderSide: const BorderSide(color: AppColors.error, width: 1),
//       ),
//       focusedErrorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
//         borderSide: const BorderSide(color: AppColors.error, width: 2),
//       ),
//       hintStyle: AppTypography.textTheme.bodyMedium!.copyWith(
//         color: AppColors.onSurfaceVariant,
//       ),
//     );
//   }

//   Widget _buildSubmitButton() {
//     return TweenAnimationBuilder<double>(
//       duration: const Duration(milliseconds: 800),
//       tween: Tween(begin: 0.0, end: 1.0),
//       builder: (context, value, child) {
//         return Transform.scale(
//           scale: 0.9 + (0.1 * value),
//           child: Container(
//             width: double.infinity,
//             height: AppSpacing.buttonMinHeight + 8,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.centerRight,
//                 end: Alignment.centerLeft,
//                 colors: [AppColors.primaryDark, AppColors.primaryMedium],
//               ),
//               borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
//               boxShadow: [
//                 BoxShadow(
//                   color: AppColors.primaryDark.withValues(alpha: 0.3),
//                   blurRadius: 12,
//                   offset: const Offset(0, 6),
//                 ),
//               ],
//             ),
//             child: Material(
//               color: Colors.transparent,
//               child: InkWell(
//                 onTap: _isLoading ? null : _submitForm,
//                 borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
//                 child: Center(
//                   child: _isLoading
//                       ? const SizedBox(
//                           width: 24,
//                           height: 24,
//                           child: CircularProgressIndicator(
//                             color: Colors.white,
//                             strokeWidth: 2,
//                           ),
//                         )
//                       : Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             const Icon(
//                               Icons.add_task,
//                               color: Colors.white,
//                               size: 24,
//                             ),
//                             SizedBox(width: AppSpacing.sm),
//                             Text(
//                               'إضافة منجز',
//                               style: AppTypography.textTheme.labelLarge!
//                                   .copyWith(
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                             ),
//                           ],
//                         ),
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   void _selectFiles() async {
//     try {
//       FilePickerResult? result = await FilePicker.platform.pickFiles(
//         type: FileType.custom,
//         allowedExtensions: [
//           'pdf', 'doc', 'docx', 'txt', // Documents
//           'jpg', 'jpeg', 'png', 'gif', 'bmp', // Images
//           'mp4', 'mov', 'avi', 'mkv', 'webm', // Videos
//           'mp3', 'wav', 'm4a', 'aac', 'ogg', // Audio
//           'xlsx', 'xls', 'csv', // Spreadsheets
//           'pptx', 'ppt', // Presentations
//           'zip', 'rar', '7z', // Archives
//         ],
//         allowMultiple: true,
//         withData: true, // Required for web platform
//         withReadStream: false, // Not needed for simple file upload
//       );

//       if (result != null && result.files.isNotEmpty) {
//         // Check file size limit (10MB per file) - especially important for web
//         const int maxFileSize = 10 * 1024 * 1024; // 10MB in bytes
//         List<PlatformFile> validFiles = [];
//         List<String> oversizedFiles = [];
//         List<String> duplicateFiles = [];

//         for (PlatformFile file in result.files) {
//           // Check file size
//           if (file.size > maxFileSize) {
//             oversizedFiles.add(file.name);
//             continue;
//           }

//           // Check for duplicates
//           bool alreadyExists = _selectedFiles.any(
//             (existingFile) =>
//                 existingFile.name == file.name &&
//                 existingFile.size == file.size,
//           );

//           if (alreadyExists) {
//             duplicateFiles.add(file.name);
//             continue;
//           }

//           validFiles.add(file);
//         }

//         // Add valid files to the list
//         if (validFiles.isNotEmpty) {
//           setState(() {
//             _selectedFiles.addAll(validFiles);
//           });

//           // Show success message
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(
//                 'تم اختيار ${validFiles.length} ملف بنجاح',
//                 style: const TextStyle(color: Colors.white),
//               ),
//               backgroundColor: AppColors.success,
//               behavior: SnackBarBehavior.floating,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
//               ),
//             ),
//           );
//         }

//         // Show warnings for invalid files
//         if (oversizedFiles.isNotEmpty) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(
//                 'الملفات التالية تتجاوز الحد الأقصى للحجم (10MB): ${oversizedFiles.join(', ')}',
//                 style: const TextStyle(color: Colors.white),
//               ),
//               backgroundColor: AppColors.error,
//               behavior: SnackBarBehavior.floating,
//               duration: const Duration(seconds: 4),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
//               ),
//             ),
//           );
//         }

//         if (duplicateFiles.isNotEmpty) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(
//                 'الملفات التالية موجودة مسبقاً: ${duplicateFiles.join(', ')}',
//                 style: const TextStyle(color: Colors.white),
//               ),
//               backgroundColor: AppColors.primaryMedium,
//               behavior: SnackBarBehavior.floating,
//               duration: const Duration(seconds: 3),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
//               ),
//             ),
//           );
//         }
//       }
//     } catch (e) {
//       debugPrint('Error picking files: $e');

//       // Show user-friendly error message
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: const Text(
//               'حدث خطأ أثناء اختيار الملفات. يرجى المحاولة مرة أخرى.',
//               style: TextStyle(color: Colors.white),
//             ),
//             backgroundColor: AppColors.error,
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
//             ),
//           ),
//         );
//       }
//     }
//   }

//   Future<void> _submitForm() async {
//     if (!_formKey.currentState!.validate()) {
//       _showValidationError();
//       return;
//     }

//     // Additional validation
//     if (_selectedDate == null) {
//       _showValidationError();
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       // Create Achievement object
//       final achievement = Achievement(
//         participationType: _selectedParticipationType!,
//         executiveDepartment: _selectedExecutiveDepartment!,
//         mainDepartment: _selectedMainDepartment!,
//         subDepartment: _selectedSubDepartment!,
//         topic: _topicController.text.trim(),
//         goal: _goalController.text.trim(),
//         date: _selectedDate!,
//         location: _locationController.text.trim(),
//         duration: _durationController.text.trim(),
//         impact: _impactController.text.trim(),
//         attachments: _selectedFiles.map((file) => file.name).toList(),
//         userId: '', // Will be set by the service
//         createdAt: DateTime.now(),
//         updatedAt: DateTime.now(),
//       );

//       // Add achievement to Firestore
//       final achievementId = await _achievementService.addAchievement(
//         achievement,
//       );

//       debugPrint('Achievement added successfully with ID: $achievementId');

//       setState(() {
//         _isLoading = false;
//       });

//       // Show success message
//       _showSuccessDialog();
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });

//       // Show error message
//       _showErrorDialog(e.toString());
//     }
//   }

//   void _showValidationError() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: const Row(
//           children: [
//             Icon(Icons.error_outline, color: Colors.white),
//             SizedBox(width: 8),
//             Text(
//               'يرجى تعبئة جميع الحقول المطلوبة',
//               style: TextStyle(color: Colors.white),
//             ),
//           ],
//         ),
//         backgroundColor: AppColors.error,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
//         ),
//       ),
//     );
//   }

//   void _showErrorDialog(String message) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
//         ),
//         title: Row(
//           children: [
//             Container(
//               padding: EdgeInsets.all(AppSpacing.sm),
//               decoration: BoxDecoration(
//                 color: AppColors.error.withValues(alpha: 0.1),
//                 borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
//               ),
//               child: const Icon(
//                 Icons.error_outline,
//                 color: AppColors.error,
//                 size: 32,
//               ),
//             ),
//             SizedBox(width: AppSpacing.md),
//             Text(
//               'خطأ!',
//               style: AppTypography.textTheme.headlineSmall!.copyWith(
//                 color: AppColors.error,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//         content: Text(message, style: AppTypography.textTheme.bodyMedium),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: Text(
//               'موافق',
//               style: AppTypography.textTheme.labelLarge!.copyWith(
//                 color: AppColors.primaryMedium,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showSuccessDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
//         ),
//         title: Row(
//           children: [
//             Container(
//               padding: EdgeInsets.all(AppSpacing.sm),
//               decoration: BoxDecoration(
//                 color: AppColors.success.withValues(alpha: 0.1),
//                 borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
//               ),
//               child: const Icon(
//                 Icons.check_circle,
//                 color: AppColors.success,
//                 size: 32,
//               ),
//             ),
//             SizedBox(width: AppSpacing.md),
//             Text(
//               'تم بنجاح!',
//               style: AppTypography.textTheme.headlineSmall!.copyWith(
//                 color: AppColors.success,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//         content: Text(
//           'تم إضافة المنجز بنجاح. سيتم مراجعته وإضافته إلى سجلك قريباً.',
//           style: AppTypography.textTheme.bodyMedium,
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop(); // Close dialog
//               Navigator.of(context).pop(); // Go back to dashboard
//             },
//             child: Text(
//               'العودة للوحة التحكم',
//               style: AppTypography.textTheme.labelLarge!.copyWith(
//                 color: AppColors.primaryMedium,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.of(context).pop(); // Close dialog
//               _resetForm(); // Reset form for new entry
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.primaryMedium,
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
//               ),
//             ),
//             child: Text(
//               'إضافة منجز آخر',
//               style: AppTypography.textTheme.labelLarge!.copyWith(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _resetForm() {
//     _formKey.currentState!.reset();
//     setState(() {
//       _selectedParticipationType = null;
//       _selectedExecutiveDepartment = null;
//       _selectedMainDepartment = null;
//       _selectedSubDepartment = null;
//       _selectedDate = null;
//       _selectedFiles.clear(); // Clear the PlatformFile list
//     });

//     // Clear all controllers
//     _participationTypeController.clear();
//     _executiveDepartmentController.clear();
//     _mainDepartmentController.clear();
//     _subDepartmentController.clear();
//     _topicController.clear();
//     _goalController.clear();
//     _dateController.clear();
//     _locationController.clear();
//     _durationController.clear();
//     _impactController.clear();
//   }
// }
