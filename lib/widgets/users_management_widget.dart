import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/user_management_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'enhanced_add_user_dialog.dart';
import 'enhanced_edit_user_dialog.dart';

class UsersManagementWidget extends StatefulWidget {
  const UsersManagementWidget({super.key});

  @override
  State<UsersManagementWidget> createState() => _UsersManagementWidgetState();
}

class _UsersManagementWidgetState extends State<UsersManagementWidget> {
  final UserManagementService _userService = UserManagementService();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String _selectedRole = 'all';
  String _selectedStatus = 'all';
  String _selectedDepartment = 'all';

  final List<String> _roles = ['all', 'user', 'admin', 'manager', 'supervisor'];
  final List<String> _statuses = ['all', 'active', 'inactive'];
  final List<String> _departments = [
    'all',
    'الإدارة العامة',
    'الموارد البشرية',
    'التقنية',
    'المالية',
    'الطبية',
    'التمريض',
    'الصيدلة',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        _buildHeader(),
        const SizedBox(height: 24),

        // Statistics Cards
        _buildStatisticsCards(),
        const SizedBox(height: 24),

        // Search and Filters
        _buildSearchAndFilters(),
        const SizedBox(height: 24),

        // Users List
        _buildUsersList(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'إدارة المستخدمين',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'إدارة حسابات المستخدمين وصلاحياتهم',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => _showAddUserDialog(),
          icon: const Icon(Icons.person_add),
          label: const Text('إضافة مستخدم'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryDark,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsCards() {
    return FutureBuilder<Map<String, int>>(
      future: _userService.getUsersStatistics(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final stats =
            snapshot.data ??
            {'total': 0, 'active': 0, 'inactive': 0, 'admins': 0};

        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'إجمالي المستخدمين',
                '${stats['total']}',
                Icons.people,
                AppColors.primaryDark,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'المستخدمين النشطين',
                '${stats['active']}',
                Icons.people_alt,
                Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'المستخدمين المعطلين',
                '${stats['inactive']}',
                Icons.people_outline,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'المديرين',
                '${stats['admins']}',
                Icons.admin_panel_settings,
                AppColors.primaryMedium,
              ),
            ),
          ],
        );
      },
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
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
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

  Widget _buildSearchAndFilters() {
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
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText:
                  'البحث عن مستخدم (البريد الإلكتروني، الاسم، رقم الموظف)',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primaryDark),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 16),

          // Filters
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown(
                  'الدور',
                  _selectedRole,
                  _roles,
                  (value) => setState(() => _selectedRole = value!),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFilterDropdown(
                  'الحالة',
                  _selectedStatus,
                  _statuses,
                  (value) => setState(() => _selectedStatus = value!),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFilterDropdown(
                  'القسم',
                  _selectedDepartment,
                  _departments,
                  (value) => setState(() => _selectedDepartment = value!),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((item) {
            String displayText = item;
            if (item == 'all')
              displayText = 'الكل';
            else if (item == 'active')
              displayText = 'نشط';
            else if (item == 'inactive')
              displayText = 'معطل';
            else if (item == 'user')
              displayText = 'مستخدم';
            else if (item == 'admin')
              displayText = 'مدير';
            else if (item == 'manager')
              displayText = 'مدير قسم';
            else if (item == 'supervisor')
              displayText = 'مشرف';

            return DropdownMenuItem(value: item, child: Text(displayText));
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primaryDark),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUsersList() {
    return Container(
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
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryDark.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Expanded(
                  flex: 3,
                  child: Text(
                    'المستخدم',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const Expanded(
                  flex: 2,
                  child: Text(
                    'القسم',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const Expanded(
                  flex: 2,
                  child: Text(
                    'الدور',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const Expanded(
                  flex: 1,
                  child: Text(
                    'الحالة',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const Expanded(
                  flex: 2,
                  child: Text(
                    'تاريخ الإنشاء',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const Expanded(
                  flex: 1,
                  child: Text(
                    'إجراءات',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          // Users List
          StreamBuilder<List<AppUser>>(
            stream: _getFilteredUsers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      'خطأ في تحميل المستخدمين: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                );
              }

              final users = snapshot.data ?? [];

              if (users.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: Text('لا توجد مستخدمين')),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return _buildUserRow(user);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUserRow(AppUser user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          // User Info
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primaryLight.withOpacity(0.2),
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'م',
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
                        user.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        user.email,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      if (user.employeeId != null)
                        Text(
                          'رقم الموظف: ${user.employeeId}',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Department
          Expanded(
            flex: 2,
            child: Text(
              user.department ?? 'غير محدد',
              style: const TextStyle(fontSize: 13),
            ),
          ),

          // Roles
          Expanded(
            flex: 2,
            child: Wrap(
              spacing: 4,
              children: user.roles.map((role) {
                Color roleColor = AppColors.primaryLight;
                String roleText = role;

                switch (role) {
                  case 'admin':
                    roleColor = Colors.red;
                    roleText = 'مدير';
                    break;
                  case 'manager':
                    roleColor = Colors.orange;
                    roleText = 'مدير قسم';
                    break;
                  case 'supervisor':
                    roleColor = Colors.blue;
                    roleText = 'مشرف';
                    break;
                  case 'user':
                    roleColor = Colors.green;
                    roleText = 'مستخدم';
                    break;
                }

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: roleColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: roleColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    roleText,
                    style: TextStyle(
                      color: roleColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Status
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: user.isActive
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                user.isActive ? 'نشط' : 'معطل',
                style: TextStyle(
                  color: user.isActive ? Colors.green : Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Created Date
          Expanded(
            flex: 2,
            child: Text(
              _formatDate(user.createdAt),
              style: const TextStyle(fontSize: 12),
            ),
          ),

          // Actions
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 20),
                  onSelected: (value) => _handleUserAction(value, user),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 16),
                          SizedBox(width: 8),
                          Text('تعديل'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: user.isActive ? 'deactivate' : 'activate',
                      child: Row(
                        children: [
                          Icon(
                            user.isActive ? Icons.block : Icons.check_circle,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(user.isActive ? 'إلغاء التفعيل' : 'تفعيل'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'reset_password',
                      child: Row(
                        children: [
                          Icon(Icons.lock_reset, size: 16),
                          SizedBox(width: 8),
                          Text('إعادة تعيين كلمة المرور'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 16, color: Colors.red),
                          SizedBox(width: 8),
                          Text('حذف', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Stream<List<AppUser>> _getFilteredUsers() {
    Stream<List<AppUser>> stream = _userService.getAllUsers();

    // Apply role filter
    if (_selectedRole != 'all') {
      stream = _userService.getUsersByRole(_selectedRole);
    }

    // Apply status filter
    if (_selectedStatus != 'all') {
      stream = _userService.getUsersByStatus(_selectedStatus == 'active');
    }

    // Apply department filter
    if (_selectedDepartment != 'all') {
      stream = _userService.getUsersByDepartment(_selectedDepartment);
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      stream = _userService.searchUsers(_searchQuery);
    }

    return stream;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _handleUserAction(String action, AppUser user) {
    switch (action) {
      case 'edit':
        _showEditUserDialog(user);
        break;
      case 'activate':
      case 'deactivate':
        _toggleUserStatus(user);
        break;
      case 'reset_password':
        _resetUserPassword(user);
        break;
      case 'delete':
        _deleteUser(user);
        break;
    }
  }

  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (context) => const EnhancedAddUserDialog(),
    );
  }

  void _showEditUserDialog(AppUser user) {
    showDialog(
      context: context,
      builder: (context) => EnhancedEditUserDialog(user: user),
    );
  }

  void _toggleUserStatus(AppUser user) async {
    try {
      await _userService.updateUserStatus(user.id, !user.isActive);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              user.isActive ? 'تم إلغاء تفعيل المستخدم' : 'تم تفعيل المستخدم',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحديث حالة المستخدم: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _resetUserPassword(AppUser user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إعادة تعيين كلمة المرور'),
        content: Text(
          'هل تريد إرسال رابط إعادة تعيين كلمة المرور إلى ${user.email}؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('إرسال'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _userService.resetUserPassword(user.email);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إرسال رابط إعادة تعيين كلمة المرور'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('خطأ في إرسال رابط إعادة التعيين: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _deleteUser(AppUser user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المستخدم'),
        content: Text(
          'هل أنت متأكد من حذف المستخدم ${user.name}؟\nهذا الإجراء لا يمكن التراجع عنه.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _userService.deleteUser(user.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حذف المستخدم بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('خطأ في حذف المستخدم: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
