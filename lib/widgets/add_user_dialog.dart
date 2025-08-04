import 'package:flutter/material.dart';
import '../services/user_management_service.dart';
import '../theme/app_colors.dart';

class AddUserDialog extends StatefulWidget {
  const AddUserDialog({super.key});

  @override
  State<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final UserManagementService _userService = UserManagementService();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _jobTitleController = TextEditingController();

  String _selectedDepartment = '';
  List<String> _selectedRoles = ['user'];
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
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
                  Icon(
                    Icons.person_add,
                    color: AppColors.primaryDark,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'إضافة مستخدم جديد',
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
              const SizedBox(height: 24),

              // Form Fields
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Email
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'البريد الإلكتروني *',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'البريد الإلكتروني مطلوب';
                          }
                          if (!value.contains('@')) {
                            return 'البريد الإلكتروني غير صحيح';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'كلمة المرور *',
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'كلمة المرور مطلوبة';
                          }
                          if (value.length < 6) {
                            return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

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
                    onPressed: _isLoading ? null : _createUser,
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
                        : const Text('إنشاء المستخدم'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _createUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _userService.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
        phoneNumber: _phoneController.text.trim().isNotEmpty
            ? _phoneController.text.trim()
            : null,
        department: _selectedDepartment.isNotEmpty ? _selectedDepartment : null,
        jobTitle: _jobTitleController.text.trim().isNotEmpty
            ? _jobTitleController.text.trim()
            : null,
        employeeId: _employeeIdController.text.trim().isNotEmpty
            ? _employeeIdController.text.trim()
            : null,
        roles: _selectedRoles,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إنشاء المستخدم بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في إنشاء المستخدم: $e'),
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
