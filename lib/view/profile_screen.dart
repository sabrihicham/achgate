import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_components.dart';
import '../services/auth_service.dart';
import '../services/user_management_service.dart';
import '../services/departments_service.dart';
import '../models/user.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final UserManagementService _userService = UserManagementService();
  final DepartmentsService _departmentsService = DepartmentsService();

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _employeeIdController = TextEditingController();

  AppUser? _currentUser;
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;

  String? _selectedExecutiveDepartment;
  String? _selectedMainDepartment;
  String? _selectedSubDepartment;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadUserProfile();
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

    _fadeController.forward();
    _slideController.forward();
  }

  Future<void> _loadUserProfile() async {
    try {
      final userEmail = _authService.currentUser?.email;
      if (userEmail == null) {
        _navigateToLogin();
        return;
      }

      final user = await _userService.getUserByEmail(userEmail);
      if (user != null) {
        setState(() {
          _currentUser = user;
          _fullNameController.text = user.fullName ?? '';
          _phoneController.text = user.phoneNumber ?? '';
          _jobTitleController.text = user.jobTitle ?? '';
          _employeeIdController.text = user.employeeId ?? '';
          _selectedExecutiveDepartment = user.department;
          _selectedMainDepartment = user.mainDepartment;
          _selectedSubDepartment = user.subDepartment;
          _isLoading = false;
        });
      } else {
        _navigateToLogin();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('خطأ في تحميل المعلومات: $e');
    }
  }

  Future<void> _loadDepartmentsData() async {
    try {
      await _departmentsService.loadDepartments();
    } catch (e) {
      debugPrint('Error loading departments: $e');
    }
  }

  void _navigateToLogin() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.error),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.success),
      );
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _jobTitleController.dispose();
    _employeeIdController.dispose();
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
            message: 'جارٍ تحميل المعلومات...',
          ),
        ),
      );
    }

    if (_currentUser == null) {
      return Scaffold(
        backgroundColor: AppColors.surfaceLight,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                'لم يتم العثور على بيانات المستخدم',
                style: AppTypography.textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _navigateToLogin,
                child: const Text('تسجيل الدخول'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: _buildLayout(isDesktop, isTablet),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLayout(bool isDesktop, bool isTablet) {
    if (isDesktop) {
      return _buildDesktopLayout();
    } else if (isTablet) {
      return _buildTabletLayout();
    } else {
      return _buildMobileLayout();
    }
  }

  Widget _buildDesktopLayout() {
    return CustomScrollView(
      slivers: [
        _buildAppBar(),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Card
                Expanded(flex: 2, child: _buildProfileCard()),
                const SizedBox(width: 32),
                // Information Form
                Expanded(flex: 3, child: _buildInformationForm()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return CustomScrollView(
      slivers: [
        _buildAppBar(),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildProfileCard(),
                const SizedBox(height: 24),
                _buildInformationForm(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return CustomScrollView(
      slivers: [
        _buildAppBar(),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildProfileCard(),
                const SizedBox(height: 16),
                _buildInformationForm(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primaryDark,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'الملف الشخصي',
          style: AppTypography.textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryDark,
                AppColors.primaryMedium,
                AppColors.primaryLight,
              ],
            ),
          ),
          child: Center(
            child: Icon(
              Icons.person,
              size: 80,
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ),
        ),
      ),
      actions: [
        if (!_isEditing)
          IconButton(
            onPressed: () {
              setState(() {
                _isEditing = true;
              });
            },
            icon: const Icon(Icons.edit, color: Colors.white),
            tooltip: 'تعديل المعلومات',
          ),
        IconButton(
          onPressed: _signOut,
          icon: const Icon(Icons.logout, color: Colors.white),
          tooltip: 'تسجيل الخروج',
        ),
      ],
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Avatar
          Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: AppColors.primaryLight.withValues(alpha: 0.2),
                child: Text(
                  _currentUser!.name.isNotEmpty
                      ? _currentUser!.name[0].toUpperCase()
                      : 'م',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _currentUser!.isActive
                        ? AppColors.success
                        : AppColors.error,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(
                    _currentUser!.isActive ? Icons.check : Icons.close,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // User Name
          Text(
            _currentUser!.name,
            style: AppTypography.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Email
          Text(
            _currentUser!.email,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _currentUser!.isActive
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _currentUser!.isActive
                    ? AppColors.success
                    : AppColors.error,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _currentUser!.isActive ? Icons.check_circle : Icons.error,
                  size: 16,
                  color: _currentUser!.isActive
                      ? AppColors.success
                      : AppColors.error,
                ),
                const SizedBox(width: 8),
                Text(
                  _currentUser!.isActive ? 'نشط' : 'معطل',
                  style: TextStyle(
                    color: _currentUser!.isActive
                        ? AppColors.success
                        : AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Roles
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _currentUser!.roles.map((role) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getRoleColor(role).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _getRoleColor(role)),
                ),
                child: Text(
                  _getRoleText(role),
                  style: TextStyle(
                    color: _getRoleColor(role),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Account Stats
          _buildAccountStats(),
        ],
      ),
    );
  }

  Widget _buildAccountStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primaryDark, size: 20),
              const SizedBox(width: 8),
              Text(
                'معلومات الحساب',
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'تاريخ الإنشاء',
                style: AppTypography.textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              Text(
                _formatDate(_currentUser!.createdAt),
                style: AppTypography.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'آخر تحديث',
                style: AppTypography.textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              Text(
                _formatDate(_currentUser!.updatedAt),
                style: AppTypography.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (_currentUser!.lastLoginAt != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'آخر دخول',
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                Text(
                  _formatDate(_currentUser!.lastLoginAt!),
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInformationForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  _isEditing ? Icons.edit : Icons.info,
                  color: AppColors.primaryDark,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _isEditing
                        ? 'تعديل المعلومات الشخصية'
                        : 'المعلومات الشخصية',
                    style: AppTypography.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
                if (_isEditing) ...[
                  TextButton(
                    onPressed: _cancelEditing,
                    child: const Text('إلغاء'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      foregroundColor: Colors.white,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('حفظ'),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 32),

            // Personal Information Section
            _buildPersonalInfoSection(),
            const SizedBox(height: 24),

            // Department Information Section
            _buildDepartmentInfoSection(),
            const SizedBox(height: 24),

            // Contact Information Section
            _buildContactInfoSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('المعلومات الشخصية', Icons.person),
        const SizedBox(height: 16),

        // Full Name
        _buildTextField(
          controller: _fullNameController,
          label: 'الاسم الكامل',
          icon: Icons.person_outline,
          enabled: _isEditing,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'الاسم الكامل مطلوب';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Employee ID
        _buildTextField(
          controller: _employeeIdController,
          label: 'رقم الموظف',
          icon: Icons.badge_outlined,
          enabled: _isEditing,
        ),
        const SizedBox(height: 16),

        // Job Title
        _buildTextField(
          controller: _jobTitleController,
          label: 'المسمى الوظيفي',
          icon: Icons.work_outline,
          enabled: _isEditing,
        ),
      ],
    );
  }

  Widget _buildDepartmentInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('معلومات الإدارة', Icons.business),
        const SizedBox(height: 16),

        // Executive Department
        _buildDropdownField(
          label: 'الإدارة التنفيذية',
          value: _selectedExecutiveDepartment,
          items: _departmentsService.getExecutiveDepartments(),
          onChanged: _isEditing
              ? (value) {
                  setState(() {
                    _selectedExecutiveDepartment = value;
                    _selectedMainDepartment = null;
                    _selectedSubDepartment = null;
                  });
                }
              : null,
          icon: Icons.account_tree,
        ),
        const SizedBox(height: 16),

        // Main Department
        _buildDropdownField(
          label: 'الإدارة الرئيسية',
          value: _selectedMainDepartment,
          items: _selectedExecutiveDepartment != null
              ? _departmentsService.getMainDepartments(
                  _selectedExecutiveDepartment!,
                )
              : [],
          onChanged: _isEditing && _selectedExecutiveDepartment != null
              ? (value) {
                  setState(() {
                    _selectedMainDepartment = value;
                    _selectedSubDepartment = null;
                  });
                }
              : null,
          icon: Icons.business_center,
        ),
        const SizedBox(height: 16),

        // Sub Department
        _buildDropdownField(
          label: 'الإدارة الفرعية',
          value: _selectedSubDepartment,
          items: _selectedMainDepartment != null
              ? _departmentsService.getSubDepartments(
                  _selectedExecutiveDepartment!,
                  _selectedMainDepartment!,
                )
              : [],
          onChanged: _isEditing && _selectedMainDepartment != null
              ? (value) {
                  setState(() {
                    _selectedSubDepartment = value;
                  });
                }
              : null,
          icon: Icons.apartment,
        ),
      ],
    );
  }

  Widget _buildContactInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('معلومات الاتصال', Icons.contact_phone),
        const SizedBox(height: 16),

        // Email (Read Only)
        _buildTextField(
          controller: TextEditingController(text: _currentUser!.email),
          label: 'البريد الإلكتروني',
          icon: Icons.email_outlined,
          enabled: false,
        ),
        const SizedBox(height: 16),

        // Phone Number
        _buildTextField(
          controller: _phoneController,
          label: 'رقم الهاتف',
          icon: Icons.phone_outlined,
          enabled: _isEditing,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              if (!RegExp(r'^[0-9+\-\s()]+$').hasMatch(value)) {
                return 'يرجى إدخال رقم هاتف صحيح';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primaryDark, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: AppTypography.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryDark,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(
        color: enabled ? AppColors.onSurface : AppColors.onSurfaceVariant,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: enabled ? Colors.white : AppColors.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryDark, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.5)),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?>? onChanged,
    required IconData icon,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: onChanged != null ? Colors.white : AppColors.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryDark, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.5)),
        ),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(value: item, child: Text(item));
      }).toList(),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.red;
      case 'manager':
        return Colors.orange;
      case 'supervisor':
        return Colors.blue;
      case 'user':
      default:
        return AppColors.success;
    }
  }

  String _getRoleText(String role) {
    switch (role) {
      case 'admin':
        return 'مدير';
      case 'manager':
        return 'مدير قسم';
      case 'supervisor':
        return 'مشرف';
      case 'user':
      default:
        return 'مستخدم';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      // Reset form fields
      _fullNameController.text = _currentUser!.fullName ?? '';
      _phoneController.text = _currentUser!.phoneNumber ?? '';
      _jobTitleController.text = _currentUser!.jobTitle ?? '';
      _employeeIdController.text = _currentUser!.employeeId ?? '';
      _selectedExecutiveDepartment = _currentUser!.department;
      _selectedMainDepartment = _currentUser!.mainDepartment;
      _selectedSubDepartment = _currentUser!.subDepartment;
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _userService.updateUserProfile(
        userId: _currentUser!.id,
        fullName: _fullNameController.text.trim(),
        phoneNumber: _phoneController.text.trim().isNotEmpty
            ? _phoneController.text.trim()
            : null,
        department: _selectedExecutiveDepartment,
        mainDepartment: _selectedMainDepartment,
        subDepartment: _selectedSubDepartment,
        jobTitle: _jobTitleController.text.trim().isNotEmpty
            ? _jobTitleController.text.trim()
            : null,
        employeeId: _employeeIdController.text.trim().isNotEmpty
            ? _employeeIdController.text.trim()
            : null,
      );

      // Reload user profile to get updated data
      await _loadUserProfile();

      setState(() {
        _isEditing = false;
        _isSaving = false;
      });

      _showSuccessSnackBar('تم حفظ المعلومات بنجاح');
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      _showErrorSnackBar('خطأ في حفظ المعلومات: $e');
    }
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل تريد تسجيل الخروج من الحساب؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authService.signOut();
      _navigateToLogin();
    }
  }
}
