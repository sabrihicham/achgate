import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/user_management_service.dart';
import '../services/departments_service.dart';
import '../theme/app_colors.dart';

class EnhancedEditUserDialog extends StatefulWidget {
  final AppUser user;

  const EnhancedEditUserDialog({super.key, required this.user});

  @override
  State<EnhancedEditUserDialog> createState() => _EnhancedEditUserDialogState();
}

class _EnhancedEditUserDialogState extends State<EnhancedEditUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final UserManagementService _userService = UserManagementService();
  final DepartmentsService _departmentsService = DepartmentsService();

  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _employeeIdController;
  late final TextEditingController _jobTitleController;

  String? _selectedExecutiveDepartment;
  String? _selectedMainDepartment;
  String? _selectedSubDepartment;
  late List<String> _selectedRoles;
  bool _isLoading = false;

  final List<String> _availableRoles = [
    'user',
    'supervisor',
    'manager',
    'admin',
  ];

  @override
  void initState() {
    super.initState();
    _loadDepartments();
    _initializeControllers();
  }

  Future<void> _loadDepartments() async {
    try {
      await _departmentsService.loadDepartments();
      setState(() {});
    } catch (e) {
      debugPrint('Error loading departments: $e');
    }
  }

  void _initializeControllers() {
    _fullNameController = TextEditingController(
      text: widget.user.fullName ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.user.phoneNumber ?? '',
    );
    _employeeIdController = TextEditingController(
      text: widget.user.employeeId ?? '',
    );
    _jobTitleController = TextEditingController(
      text: widget.user.jobTitle ?? '',
    );

    _selectedExecutiveDepartment = widget.user.department;
    _selectedMainDepartment = widget.user.mainDepartment;
    _selectedSubDepartment = widget.user.subDepartment;
    _selectedRoles = List.from(widget.user.roles);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _employeeIdController.dispose();
    _jobTitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 1024;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: isDesktop ? 600 : screenSize.width * 0.9,
        constraints: BoxConstraints(maxHeight: screenSize.height * 0.9),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.edit,
                    color: AppColors.primaryDark,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تعديل المستخدم',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDark,
                            ),
                      ),
                      Text(
                        widget.user.email,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Form
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Personal Information Section
                      _buildSectionHeader('المعلومات الشخصية', Icons.person),
                      const SizedBox(height: 16),

                      _buildFullNameField(),
                      const SizedBox(height: 16),

                      // Employee ID and Job Title Row
                      if (isDesktop) ...[
                        Row(
                          children: [
                            Expanded(child: _buildEmployeeIdField()),
                            const SizedBox(width: 16),
                            Expanded(child: _buildJobTitleField()),
                          ],
                        ),
                      ] else ...[
                        _buildEmployeeIdField(),
                        const SizedBox(height: 16),
                        _buildJobTitleField(),
                      ],
                      const SizedBox(height: 16),

                      _buildPhoneField(),
                      const SizedBox(height: 24),

                      // Department Information Section
                      _buildSectionHeader('معلومات الإدارة', Icons.business),
                      const SizedBox(height: 16),

                      _buildExecutiveDepartmentField(),
                      const SizedBox(height: 16),

                      _buildMainDepartmentField(),
                      const SizedBox(height: 16),

                      _buildSubDepartmentField(),
                      const SizedBox(height: 24),

                      // Roles Section
                      _buildSectionHeader(
                        'الأدوار والصلاحيات',
                        Icons.admin_panel_settings,
                      ),
                      const SizedBox(height: 16),

                      _buildRolesField(),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  child: const Text('إلغاء'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isLoading ? null : _updateUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('حفظ التغييرات'),
                ),
              ],
            ),
          ],
        ),
      ),
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
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryDark,
          ),
        ),
      ],
    );
  }

  Widget _buildFullNameField() {
    return TextFormField(
      controller: _fullNameController,
      decoration: InputDecoration(
        labelText: 'الاسم الكامل *',
        prefixIcon: const Icon(Icons.person_outline),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'الاسم الكامل مطلوب';
        }
        return null;
      },
    );
  }

  Widget _buildEmployeeIdField() {
    return TextFormField(
      controller: _employeeIdController,
      decoration: InputDecoration(
        labelText: 'رقم الموظف',
        prefixIcon: const Icon(Icons.badge_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildJobTitleField() {
    return TextFormField(
      controller: _jobTitleController,
      decoration: InputDecoration(
        labelText: 'المسمى الوظيفي',
        prefixIcon: const Icon(Icons.work_outline),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        labelText: 'رقم الهاتف',
        prefixIcon: const Icon(Icons.phone_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          if (!RegExp(r'^[0-9+\-\s()]+$').hasMatch(value)) {
            return 'يرجى إدخال رقم هاتف صحيح';
          }
        }
        return null;
      },
    );
  }

  Widget _buildExecutiveDepartmentField() {
    return DropdownButtonFormField<String>(
      value: _selectedExecutiveDepartment,
      decoration: InputDecoration(
        labelText: 'الإدارة التنفيذية',
        prefixIcon: const Icon(Icons.account_tree),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: _departmentsService.getExecutiveDepartments().map((dept) {
        return DropdownMenuItem(value: dept, child: Text(dept));
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedExecutiveDepartment = value;
          _selectedMainDepartment = null;
          _selectedSubDepartment = null;
        });
      },
    );
  }

  Widget _buildMainDepartmentField() {
    final mainDepartments = _selectedExecutiveDepartment != null
        ? _departmentsService.getMainDepartments(_selectedExecutiveDepartment!)
        : <String>[];

    return DropdownButtonFormField<String>(
      value: _selectedMainDepartment,
      decoration: InputDecoration(
        labelText: 'الإدارة الرئيسية',
        prefixIcon: const Icon(Icons.business_center),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: mainDepartments.map((dept) {
        return DropdownMenuItem(value: dept, child: Text(dept));
      }).toList(),
      onChanged: _selectedExecutiveDepartment != null
          ? (value) {
              setState(() {
                _selectedMainDepartment = value;
                _selectedSubDepartment = null;
              });
            }
          : null,
    );
  }

  Widget _buildSubDepartmentField() {
    final subDepartments = _selectedMainDepartment != null
        ? _departmentsService.getSubDepartments(
            _selectedExecutiveDepartment!,
            _selectedMainDepartment!,
          )
        : <String>[];

    return DropdownButtonFormField<String>(
      value: _selectedSubDepartment,
      decoration: InputDecoration(
        labelText: 'الإدارة الفرعية',
        prefixIcon: const Icon(Icons.apartment),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: subDepartments.map((dept) {
        return DropdownMenuItem(value: dept, child: Text(dept));
      }).toList(),
      onChanged: _selectedMainDepartment != null
          ? (value) {
              setState(() {
                _selectedSubDepartment = value;
              });
            }
          : null,
    );
  }

  Widget _buildRolesField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'اختر الأدوار',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: _availableRoles.map((role) {
              final isSelected = _selectedRoles.contains(role);
              String roleText = role;

              switch (role) {
                case 'user':
                  roleText = 'مستخدم';
                  break;
                case 'supervisor':
                  roleText = 'مشرف';
                  break;
                case 'manager':
                  roleText = 'مدير قسم';
                  break;
                case 'admin':
                  roleText = 'مدير';
                  break;
              }

              return FilterChip(
                label: Text(roleText),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedRoles.add(role);
                    } else {
                      _selectedRoles.remove(role);
                      // Ensure at least one role is selected
                      if (_selectedRoles.isEmpty) {
                        _selectedRoles.add('user');
                      }
                    }
                  });
                },
                backgroundColor: isSelected
                    ? AppColors.primaryLight.withValues(alpha: 0.2)
                    : null,
                selectedColor: AppColors.primaryLight.withValues(alpha: 0.4),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Future<void> _updateUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Update user profile
      await _userService.updateUserProfile(
        userId: widget.user.id,
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

      // Update user object for roles update
      final updatedUser = widget.user.copyWith(
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
        roles: _selectedRoles,
      );

      await _userService.updateUser(updatedUser);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'تم تحديث المستخدم بنجاح',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'المستخدم: ${_fullNameController.text}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحديث المستخدم: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
