import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';
import '../theme/app_components.dart';
import '../services/departments_service.dart';
import '../services/achievement_service.dart';
import '../models/achievement.dart';

class EditAchievementScreen extends StatefulWidget {
  final Achievement achievement;

  const EditAchievementScreen({super.key, required this.achievement});

  @override
  State<EditAchievementScreen> createState() => _EditAchievementScreenState();
}

class _EditAchievementScreenState extends State<EditAchievementScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Form controllers
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

  // Form state
  String? _selectedParticipationType;
  String? _selectedExecutiveDepartment;
  String? _selectedMainDepartment;
  String? _selectedSubDepartment;
  DateTime? _selectedDate;
  List<String> _selectedFiles = [];
  bool _isLoading = false;

  // Services
  final DepartmentsService _departmentsService = DepartmentsService();
  final AchievementService _achievementService = AchievementService();

  // Departments data structure
  Map<String, Map<String, List<String>>> _departmentsData = {};

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

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadDepartmentsData();
    _populateFormWithAchievementData();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      _fadeController.forward();
    });
  }

  Future<void> _loadDepartmentsData() async {
    try {
      _departmentsData = await _departmentsService.loadDepartments();
      setState(() {});
    } catch (e) {
      debugPrint('Error loading departments data: $e');
    }
  }

  void _populateFormWithAchievementData() {
    final achievement = widget.achievement;

    // Populate form fields
    _selectedParticipationType = achievement.participationType;
    _selectedExecutiveDepartment = achievement.executiveDepartment;
    _selectedMainDepartment = achievement.mainDepartment;
    _selectedSubDepartment = achievement.subDepartment;
    _selectedDate = achievement.date;
    _selectedFiles = List.from(achievement.attachments);

    // Populate controllers
    _participationTypeController.text = achievement.participationType;
    _executiveDepartmentController.text = achievement.executiveDepartment;
    _mainDepartmentController.text = achievement.mainDepartment;
    _subDepartmentController.text = achievement.subDepartment;
    _topicController.text = achievement.topic;
    _goalController.text = achievement.goal;
    _dateController.text =
        '${achievement.date.day}/${achievement.date.month}/${achievement.date.year}';
    _locationController.text = achievement.location;
    _durationController.text = achievement.duration;
    _impactController.text = achievement.impact;
  }

  @override
  void dispose() {
    _fadeController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppComponents.appBar(
        title: 'تعديل المنجز',
        showBackButton: true,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => Navigator.of(context).pop(),
            color: Colors.white,
            splashRadius: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    _buildWarningCard(),
                    SizedBox(height: AppSpacing.lg),
                    _buildFormCard(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWarningCard() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.warning, size: 24),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تعديل المنجز',
                  style: AppTypography.textTheme.labelLarge!.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  'يمكنك تعديل المنجز فقط إذا كان في حالة "معلقة". بعد الاعتماد أو الرفض لا يمكن التعديل.',
                  style: AppTypography.textTheme.bodySmall!.copyWith(
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
              'تعديل تفاصيل المنجز',
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
    return Column(
      children: [
        // Participation Type
        _buildParticipationTypeField(),
        SizedBox(height: AppSpacing.lg),

        // Executive Department
        _buildExecutiveDepartmentField(),
        SizedBox(height: AppSpacing.lg),

        // Main Department
        _buildMainDepartmentField(),
        SizedBox(height: AppSpacing.lg),

        // Sub Department
        _buildSubDepartmentField(),
        SizedBox(height: AppSpacing.lg),

        // Date
        _buildDateField(),
        SizedBox(height: AppSpacing.lg),

        // Location
        _buildLocationField(),
        SizedBox(height: AppSpacing.lg),

        // Duration
        _buildDurationField(),
        SizedBox(height: AppSpacing.lg),

        // Topic
        _buildTopicField(),
        SizedBox(height: AppSpacing.lg),

        // Goal
        _buildGoalField(),
        SizedBox(height: AppSpacing.lg),

        // Impact
        _buildImpactField(),
        SizedBox(height: AppSpacing.lg),

        // Attachments
        _buildAttachmentsField(),
      ],
    );
  }

  Widget _buildParticipationTypeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'نوع المشاركة *',
          style: AppTypography.textTheme.labelLarge!.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        DropdownButtonFormField<String>(
          value: _selectedParticipationType,
          decoration: _getInputDecoration('اختر نوع المشاركة'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'نوع المشاركة مطلوب';
            }
            return null;
          },
          items: _participationTypes.map((type) {
            return DropdownMenuItem<String>(
              value: type,
              child: Text(type, style: AppTypography.textTheme.bodyMedium),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedParticipationType = value;
              _participationTypeController.text = value ?? '';
            });
          },
          icon: const Icon(Icons.keyboard_arrow_down),
          isExpanded: true,
          style: AppTypography.textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildExecutiveDepartmentField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الإدارة التنفيذية *',
          style: AppTypography.textTheme.labelLarge!.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        DropdownButtonFormField<String>(
          value: _selectedExecutiveDepartment,
          decoration: _getInputDecoration('اختر الإدارة التنفيذية'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'الإدارة التنفيذية مطلوبة';
            }
            return null;
          },
          items: _departmentsData.keys.map((department) {
            return DropdownMenuItem<String>(
              value: department,
              child: Text(
                department,
                style: AppTypography.textTheme.bodyMedium,
              ),
            );
          }).toList(),
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
          icon: const Icon(Icons.keyboard_arrow_down),
          isExpanded: true,
          style: AppTypography.textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildMainDepartmentField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الإدارة الرئيسية *',
          style: AppTypography.textTheme.labelLarge!.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        DropdownButtonFormField<String>(
          value: _selectedMainDepartment,
          decoration: _getInputDecoration(
            _selectedExecutiveDepartment == null
                ? 'اختر الإدارة التنفيذية أولاً'
                : 'اختر الإدارة الرئيسية',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'الإدارة الرئيسية مطلوبة';
            }
            return null;
          },
          items: _availableMainDepartments.map((department) {
            return DropdownMenuItem<String>(
              value: department,
              child: Text(
                department,
                style: AppTypography.textTheme.bodyMedium,
              ),
            );
          }).toList(),
          onChanged: _selectedExecutiveDepartment == null
              ? null
              : (value) {
                  setState(() {
                    _selectedMainDepartment = value;
                    _selectedSubDepartment = null;
                    _mainDepartmentController.text = value ?? '';
                    _subDepartmentController.clear();
                  });
                },
          icon: const Icon(Icons.keyboard_arrow_down),
          isExpanded: true,
          style: AppTypography.textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildSubDepartmentField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الإدارة الفرعية *',
          style: AppTypography.textTheme.labelLarge!.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        DropdownButtonFormField<String>(
          value: _selectedSubDepartment,
          decoration: _getInputDecoration(
            _selectedMainDepartment == null
                ? 'اختر الإدارة الرئيسية أولاً'
                : 'اختر الإدارة الفرعية',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'الإدارة الفرعية مطلوبة';
            }
            return null;
          },
          items: _availableSubDepartments.map((department) {
            return DropdownMenuItem<String>(
              value: department,
              child: Text(
                department,
                style: AppTypography.textTheme.bodyMedium,
              ),
            );
          }).toList(),
          onChanged: _selectedMainDepartment == null
              ? null
              : (value) {
                  setState(() {
                    _selectedSubDepartment = value;
                    _subDepartmentController.text = value ?? '';
                  });
                },
          icon: const Icon(Icons.keyboard_arrow_down),
          isExpanded: true,
          style: AppTypography.textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تاريخ عمل المشاركة *',
          style: AppTypography.textTheme.labelLarge!.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        TextFormField(
          controller: _dateController,
          decoration: _getInputDecoration(
            'اختر التاريخ',
          ).copyWith(suffixIcon: const Icon(Icons.calendar_today)),
          readOnly: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'تاريخ المشاركة مطلوب';
            }
            return null;
          },
          onTap: () async {
            final pickedDate = await showDatePicker(
              context: context,
              initialDate: _selectedDate ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              locale: const Locale('ar'),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: Theme.of(
                      context,
                    ).colorScheme.copyWith(primary: AppColors.primaryMedium),
                  ),
                  child: child!,
                );
              },
            );

            if (pickedDate != null) {
              setState(() {
                _selectedDate = pickedDate;
                _dateController.text =
                    '${pickedDate.day}/${pickedDate.month}/${pickedDate.year}';
              });
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
            border: Border.all(color: AppColors.outline),
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
                    'اضغط لاختيار الملفات',
                    style: AppTypography.textTheme.bodyMedium!.copyWith(
                      color: AppColors.primaryMedium,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (_selectedFiles.isNotEmpty) ...[
                    SizedBox(height: AppSpacing.md),
                    ..._selectedFiles
                        .map(
                          (file) => Container(
                            margin: EdgeInsets.only(bottom: AppSpacing.xs),
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusSm,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.attach_file,
                                  size: 16,
                                  color: AppColors.primaryMedium,
                                ),
                                SizedBox(width: AppSpacing.xs),
                                Expanded(
                                  child: Text(
                                    file,
                                    style: AppTypography.textTheme.bodySmall,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: AppColors.error,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _selectedFiles.remove(file);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
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
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
          style: AppTypography.textTheme.bodyMedium,
        ),
      ],
    );
  }

  InputDecoration _getInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.surfaceLight,
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: AppColors.outline, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: AppColors.outline, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: AppColors.primaryMedium, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      hintStyle: AppTypography.textTheme.bodyMedium!.copyWith(
        color: AppColors.onSurfaceVariant,
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: AppSpacing.buttonMinHeight + 8,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [AppColors.primaryDark, AppColors.primaryMedium],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _submitForm,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.save, color: Colors.white, size: 24),
                      SizedBox(width: AppSpacing.sm),
                      Text(
                        'حفظ التعديلات',
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
  }

  void _selectFiles() {
    // Mock file selection - In real app, use file_picker package
    setState(() {
      _selectedFiles.addAll(['ملف_جديد.pdf']);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم اختيار ${_selectedFiles.length} ملف'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      _showValidationError();
      return;
    }

    if (_selectedDate == null) {
      _showValidationError();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create updated achievement object
      final updatedAchievement = widget.achievement.copyWith(
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
        attachments: _selectedFiles,
      );

      // Update achievement in Firestore
      await _achievementService.updateAchievement(updatedAchievement);

      setState(() {
        _isLoading = false;
      });

      // Show success message and go back
      _showSuccessDialog();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

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
            Text('يرجى تعبئة جميع الحقول المطلوبة'),
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
        title: const Text('خطأ!'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('موافق'),
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
        content: const Text('تم تحديث المنجز بنجاح.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to achievements list
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryMedium,
              foregroundColor: Colors.white,
            ),
            child: const Text('العودة'),
          ),
        ],
      ),
    );
  }
}
