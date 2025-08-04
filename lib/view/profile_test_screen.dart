import 'package:flutter/material.dart';
import '../services/departments_service.dart';
import '../services/user_management_service.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';

class ProfileTestScreen extends StatefulWidget {
  const ProfileTestScreen({super.key});

  @override
  State<ProfileTestScreen> createState() => _ProfileTestScreenState();
}

class _ProfileTestScreenState extends State<ProfileTestScreen> {
  final DepartmentsService _departmentsService = DepartmentsService();
  final UserManagementService _userService = UserManagementService();
  final AuthService _authService = AuthService();

  bool _isLoading = true;
  String _status = 'جاري تحميل البيانات...';

  @override
  void initState() {
    super.initState();
    _testProfileSystem();
  }

  Future<void> _testProfileSystem() async {
    try {
      setState(() {
        _status = 'جاري تحميل الإدارات...';
      });

      await _departmentsService.loadDepartments();

      setState(() {
        _status = 'تم تحميل الإدارات بنجاح';
      });

      // Test current user loading
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        final userProfile = await _userService.getUserByEmail(
          currentUser.email!,
        );
        if (userProfile != null) {
          setState(() {
            _status = 'تم تحميل ملف المستخدم الحالي: ${userProfile.fullName}';
          });
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = 'خطأ في تحميل البيانات: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اختبار نظام الملف الشخصي'),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isLoading
                              ? Icons.hourglass_empty
                              : Icons.check_circle,
                          color: _isLoading
                              ? AppColors.primaryDark
                              : AppColors.success,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'حالة النظام',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(_status),
                    if (_isLoading) ...[
                      const SizedBox(height: 16),
                      const LinearProgressIndicator(),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Departments Info
            if (!_isLoading) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.business, color: AppColors.primaryDark),
                          const SizedBox(width: 8),
                          Text(
                            'معلومات الإدارات',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildDepartmentsInfo(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Test Actions
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.play_arrow, color: AppColors.primaryDark),
                          const SizedBox(width: 8),
                          Text(
                            'اختبارات النظام',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTestActions(),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDepartmentsInfo() {
    final executiveDeps = _departmentsService.getExecutiveDepartments();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('عدد الإدارات التنفيذية: ${executiveDeps.length}'),
        const SizedBox(height: 8),
        if (executiveDeps.isNotEmpty) ...[
          Text('الإدارات التنفيذية:'),
          const SizedBox(height: 8),
          ...executiveDeps.map((exec) {
            final mainDeps = _departmentsService.getMainDepartments(exec);
            return Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• $exec (${mainDeps.length} إدارة رئيسية)'),
                  if (mainDeps.isNotEmpty) ...[
                    ...mainDeps.take(2).map((main) {
                      final subDeps = _departmentsService.getSubDepartments(
                        exec,
                        main,
                      );
                      return Padding(
                        padding: const EdgeInsets.only(left: 32),
                        child: Text('  - $main (${subDeps.length} فرعية)'),
                      );
                    }),
                    if (mainDeps.length > 2)
                      Padding(
                        padding: const EdgeInsets.only(left: 32),
                        child: Text(
                          '  ... و ${mainDeps.length - 2} إدارات أخرى',
                        ),
                      ),
                  ],
                ],
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildTestActions() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pushNamed(context, '/profile');
          },
          icon: const Icon(Icons.person),
          label: const Text('الملف الشخصي'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pushNamed(context, '/profile-demo');
          },
          icon: const Icon(Icons.preview),
          label: const Text('عرض تجريبي'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pushNamed(context, '/admin');
          },
          icon: const Icon(Icons.admin_panel_settings),
          label: const Text('لوحة الإدمن'),
        ),
        ElevatedButton.icon(
          onPressed: _testDepartmentLoading,
          icon: const Icon(Icons.refresh),
          label: const Text('إعادة تحميل الإدارات'),
        ),
      ],
    );
  }

  Future<void> _testDepartmentLoading() async {
    setState(() {
      _isLoading = true;
      _status = 'جاري إعادة تحميل الإدارات...';
    });

    try {
      await _departmentsService.loadDepartments();
      setState(() {
        _status = 'تم إعادة تحميل الإدارات بنجاح';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = 'خطأ في إعادة تحميل الإدارات: $e';
        _isLoading = false;
      });
    }
  }
}
