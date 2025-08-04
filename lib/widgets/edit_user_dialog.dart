import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/user_management_service.dart';
import '../theme/app_colors.dart';

class EditUserDialog extends StatefulWidget {
  final AppUser user;

  const EditUserDialog({super.key, required this.user});

  @override
  State<EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final UserManagementService _userService = UserManagementService();

  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _employeeIdController;
  late final TextEditingController _jobTitleController;

  late String _selectedDepartment;
  late String _selectedSubDepartment;
  late List<String> _selectedRoles;
  bool _isLoading = false;

  final List<String> _departments = [
    'الإدارة العامة',
    'الموارد البشرية',
    'التقنية',
    'المالية',
    'الطبية',
    'التمريض',
    'الصيدلة',
    'الجودة والسلامة',
    'التعليم الطبي',
    'الخدمات اللوجستية',
  ];

  final List<String> _availableRoles = [
    'user',
    'supervisor',
    'manager',
    'admin',
  ];

  @override
  void initState() {
    super.initState();
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

    _selectedDepartment = widget.user.department ?? '';
    _selectedSubDepartment = widget.user.subDepartment ?? '';
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
    return Dialog(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.edit, color: AppColors.primaryDark, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'تعديل المستخدم',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // User Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primaryLight.withOpacity(0.3),
                      child: Text(
                        widget.user.name.isNotEmpty
                            ? widget.user.name[0].toUpperCase()
                            : 'م',
                        style: TextStyle(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.user.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            widget.user.email,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Form Fields
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Full Name
                      TextFormField(
                        controller: _fullNameController,
                        decoration: const InputDecoration(
                          labelText: 'الاسم الكامل *',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الاسم الكامل مطلوب';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Phone
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'رقم الهاتف',
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),

                      // Employee ID
                      TextFormField(
                        controller: _employeeIdController,
                        decoration: const InputDecoration(
                          labelText: 'رقم الموظف',
                          prefixIcon: Icon(Icons.badge),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Job Title
                      TextFormField(
                        controller: _jobTitleController,
                        decoration: const InputDecoration(
                          labelText: 'المسمى الوظيفي',
                          prefixIcon: Icon(Icons.work),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Department
                      DropdownButtonFormField<String>(
                        value: _selectedDepartment.isEmpty
                            ? null
                            : _selectedDepartment,
                        decoration: const InputDecoration(
                          labelText: 'القسم',
                          prefixIcon: Icon(Icons.business),
                          border: OutlineInputBorder(),
                        ),
                        items: _departments.map((dept) {
                          return DropdownMenuItem(
                            value: dept,
                            child: Text(dept),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedDepartment = value ?? '';
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Sub Department
                      TextFormField(
                        initialValue: _selectedSubDepartment,
                        decoration: const InputDecoration(
                          labelText: 'القسم الفرعي',
                          prefixIcon: Icon(Icons.business_center),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          _selectedSubDepartment = value;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Roles
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'الأدوار',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Wrap(
                              spacing: 8,
                              children: _availableRoles.map((role) {
                                final isSelected = _selectedRoles.contains(
                                  role,
                                );
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
                                      ? AppColors.primaryLight.withOpacity(0.2)
                                      : null,
                                  selectedColor: AppColors.primaryLight
                                      .withOpacity(0.4),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Status Toggle
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              widget.user.isActive
                                  ? Icons.check_circle
                                  : Icons.block,
                              color: widget.user.isActive
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'حالة الحساب',
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    widget.user.isActive ? 'نشط' : 'معطل',
                                    style: TextStyle(
                                      color: widget.user.isActive
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
      ),
    );
  }

  void _updateUser() async {
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
        department: _selectedDepartment.isNotEmpty ? _selectedDepartment : null,
        subDepartment: _selectedSubDepartment.isNotEmpty
            ? _selectedSubDepartment
            : null,
        jobTitle: _jobTitleController.text.trim().isNotEmpty
            ? _jobTitleController.text.trim()
            : null,
        employeeId: _employeeIdController.text.trim().isNotEmpty
            ? _employeeIdController.text.trim()
            : null,
      );

      // Update roles if changed
      final currentRoles = widget.user.roles.toSet();
      final newRoles = _selectedRoles.toSet();

      if (!currentRoles.containsAll(newRoles) ||
          !newRoles.containsAll(currentRoles)) {
        final updatedUser = widget.user.copyWith(
          roles: _selectedRoles,
          updatedAt: DateTime.now(),
        );
        await _userService.updateUser(updatedUser);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تحديث المستخدم بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحديث المستخدم: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
