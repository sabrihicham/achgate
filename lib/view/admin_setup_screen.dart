import 'package:flutter/material.dart';
import '../services/admin_setup_service.dart';
import '../services/auth_service.dart';
import '../core/app_router.dart';

class AdminSetupScreen extends StatefulWidget {
  const AdminSetupScreen({super.key});

  @override
  State<AdminSetupScreen> createState() => _AdminSetupScreenState();
}

class _AdminSetupScreenState extends State<AdminSetupScreen> {
  final _emailController = TextEditingController();
  final _userIdController = TextEditingController();
  final _adminSetupService = AdminSetupService();
  final _authService = AuthService();

  bool _isLoading = false;
  String? _message;
  bool _isError = false;

  @override
  void dispose() {
    _emailController.dispose();
    _userIdController.dispose();
    super.dispose();
  }

  void _showMessage(String message, {bool isError = false}) {
    setState(() {
      _message = message;
      _isError = isError;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  void _showPermissionErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'خطأ في الصلاحيات',
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                errorMessage,
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
              ),
              const SizedBox(height: 16),
              const Text(
                'لمزيد من التفاصيل، راجع ملف ADMIN_PERMISSIONS_FIX.md',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('حسناً', style: TextStyle(fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }

  Future<void> _makeCurrentUserAdmin() async {
    if (_authService.currentUser == null) {
      _showMessage('يجب تسجيل الدخول أولاً', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _adminSetupService.makeCurrentUserAdmin();
      _showMessage('تم إضافة صلاحيات الأدمين للمستخدم الحالي بنجاح');
      // Navigate to admin dashboard after success
      Future.delayed(const Duration(seconds: 2), () {
        AppRouter.navigateToAdmin(context);
      });
    } catch (e) {
      // Show detailed error message with instructions
      _showDetailedErrorDialog(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showDetailedErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'خطأ في الصلاحيات',
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'لإضافة المدير الأول، يرجى اتباع إحدى الطريقتين:',
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
              ),
              const SizedBox(height: 16),
              const Text(
                'الطريقة الأولى - عبر Firebase Console:',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '1. اذهب إلى Firebase Console\n'
                '2. افتح Firestore Database\n'
                '3. أنشئ collection باسم "admin_users"\n'
                '4. أضف document بـ ID: ${_authService.currentUser!.uid}\n'
                '5. أضف field: isActive = true',
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 12),
              ),
              const SizedBox(height: 16),
              const Text(
                'الطريقة الثانية - تحديث قواعد Firestore:',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'راجع ملف ADMIN_PERMISSIONS_FIX.md للتفاصيل',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('موافق', style: TextStyle(fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }

  Future<void> _addAdminByEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showMessage('يرجى إدخال البريد الإلكتروني', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await _adminSetupService.addAdminByEmail(email);
      if (success) {
        _showMessage('تم إضافة المستخدم كأدمين بنجاح');
        _emailController.clear();
      } else {
        _showMessage('فشل في إضافة المستخدم كأدمين', isError: true);
      }
    } catch (e) {
      // Check if it's a permission error
      if (e.toString().contains('خطأ في الصلاحيات') ||
          e.toString().contains('Missing or insufficient permissions')) {
        _showPermissionErrorDialog(e.toString());
      } else {
        _showMessage('خطأ: $e', isError: true);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addAdminByUserId() async {
    final userId = _userIdController.text.trim();
    if (userId.isEmpty) {
      _showMessage('يرجى إدخال معرف المستخدم', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await _adminSetupService.addAdminByUserId(userId);
      if (success) {
        _showMessage('تم إضافة المستخدم كأدمين بنجاح');
        _userIdController.clear();
      } else {
        _showMessage('فشل في إضافة المستخدم كأدمين', isError: true);
      }
    } catch (e) {
      // Check if it's a permission error
      if (e.toString().contains('خطأ في الصلاحيات') ||
          e.toString().contains('Missing or insufficient permissions')) {
        _showPermissionErrorDialog(e.toString());
      } else {
        _showMessage('خطأ: $e', isError: true);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'إعداد صلاحيات الأدمين',
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF15508A),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info Card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'معلومات الإعداد',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'هذه الصفحة لإعداد صلاحيات المديرين للمرة الأولى.\n'
                      'إذا ظهرت رسالة "خطأ في الصلاحيات"، يمكنك إضافة المدير الأول يدوياً عبر Firebase Console.\n'
                      'راجع ملف ADMIN_PERMISSIONS_FIX.md للتفاصيل.',
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Current User Section
            if (_authService.currentUser != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'المستخدم الحالي',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'البريد الإلكتروني: ${_authService.currentUser!.email}',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'معرف المستخدم: ${_authService.currentUser!.uid}',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _makeCurrentUserAdmin,
                          icon: const Icon(Icons.admin_panel_settings),
                          label: const Text(
                            'إضافة صلاحيات الأدمين للمستخدم الحالي',
                            style: TextStyle(fontFamily: 'Cairo'),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF15508A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],

            // Add Admin by Email Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'إضافة أدمين بالبريد الإلكتروني',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.warning,
                          color: Colors.orange.shade600,
                          size: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Text(
                        'ملاحظة: بسبب قيود الصلاحيات، يمكن فقط إضافة البريد الإلكتروني للمستخدم الحالي. '
                        'لإضافة مستخدمين آخرين، استخدم معرف المستخدم في القسم التالي.',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'البريد الإلكتروني',
                        hintText: 'أدخل البريد الإلكتروني للمستخدم الحالي فقط',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _addAdminByEmail,
                        icon: const Icon(Icons.person_add),
                        label: const Text(
                          'إضافة كأدمين',
                          style: TextStyle(fontFamily: 'Cairo'),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Add Admin by User ID Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'إضافة أدمين بمعرف المستخدم',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'كيفية الحصول على معرف المستخدم:',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '1. في Firebase Console → Authentication → Users\n'
                            '2. ابحث عن المستخدم بالبريد الإلكتروني\n'
                            '3. انسخ User UID من العمود الأول',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              color: Colors.blue.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _userIdController,
                      decoration: const InputDecoration(
                        labelText: 'معرف المستخدم (User ID)',
                        hintText: 'أدخل معرف المستخدم (28 حرف تقريباً)',
                        prefixIcon: Icon(Icons.fingerprint),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _addAdminByUserId,
                        icon: const Icon(Icons.person_add),
                        label: const Text(
                          'إضافة كأدمين',
                          style: TextStyle(fontFamily: 'Cairo'),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Loading Indicator
            if (_isLoading) const Center(child: CircularProgressIndicator()),

            // Message Display
            if (_message != null)
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isError ? Colors.red.shade50 : Colors.green.shade50,
                  border: Border.all(
                    color: _isError ? Colors.red : Colors.green,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _message!,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: _isError
                        ? Colors.red.shade700
                        : Colors.green.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
