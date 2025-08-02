import 'package:achgate/services/auth_service.dart';
import 'package:achgate/services/admin_auth_service.dart';
import 'package:achgate/theme/app_theme.dart';
import 'package:achgate/core/app_router.dart';
import 'package:achgate/view/admin_dashboard_screen.dart';
import 'package:achgate/view/enhanced_admin_dashboard.dart';
import 'package:flutter/material.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _adminAuthService = AdminAuthService();
  final _authService =
      AuthService(); // للاستخدام في التحقق من البريد الإلكتروني وإعادة تعيين كلمة المرور
  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkExistingAdminSession();
  }

  /// التحقق من وجود جلسة أدمن نشطة
  Future<void> _checkExistingAdminSession() async {
    try {
      final isLoggedIn = await _adminAuthService.isAdminLoggedIn();
      if (isLoggedIn && mounted) {
        // المستخدم مسجل دخول بالفعل كأدمن، انقله مباشرة للوحة التحكم
        AppRouter.navigateToAdmin(context);
      }
    } catch (e) {
      // تجاهل الخطأ واستمر في عرض صفحة تسجيل الدخول
      print('Error checking admin session: $e');
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleAdminLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final email = _usernameController.text.trim();
        final password = _passwordController.text;

        // تسجيل الدخول باستخدام خدمة الأدمن المخصصة
        final result = await _adminAuthService.signInAsAdmin(
          email: email,
          password: password,
        );

        if (!result.isSuccess) {  
          throw result.errorMessage ?? 'حدث خطأ أثناء تسجيل الدخول';
        }

        // إظهار رسالة نجاح
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تسجيل الدخول بنجاح - مرحباً بك في لوحة التحكم'),
              backgroundColor: Color(0xFF15508A),
              duration: Duration(seconds: 2),
            ),
          );
        }

        // التوجه إلى لوحة التحكم الإدارية
        if (mounted) {
          AppRouter.navigateToAdmin(context);
          // Navigator.pushAndRemoveUntil(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => const AdminDashboardScreen(),
          //   ),
          //   (route) => false,
          // );
        }
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_errorMessage!),
              backgroundColor: Colors.red.shade600,
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
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

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 1024;
    final isTablet = screenSize.width > 768 && screenSize.width <= 1024;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (isDesktop) {
            return _buildDesktopLayout(constraints);
          } else if (isTablet) {
            return _buildTabletLayout(constraints);
          } else {
            return _buildMobileLayout(constraints);
          }
        },
      ),
    );
  }

  Widget _buildHeader() {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 1024;
    final isTablet = screenSize.width > 768 && screenSize.width <= 1024;

    final logoSize = isDesktop ? 100.0 : (isTablet ? 80.0 : 60.0);
    final titleFontSize = isDesktop ? 32.0 : (isTablet ? 28.0 : 24.0);
    final subtitleFontSize = isDesktop ? 18.0 : (isTablet ? 16.0 : 14.0);

    return Column(
      children: [
        // Admin icon with special styling
        Container(
          width: logoSize,
          height: logoSize,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF15508A), Color(0xFF1691D0), Color(0xFF2CAAE2)],
            ),
            borderRadius: BorderRadius.circular(logoSize / 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF15508A).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            Icons.admin_panel_settings,
            size: logoSize * 0.5,
            color: Colors.white,
          ),
        ),

        SizedBox(height: isDesktop ? 24 : (isTablet ? 20 : 16)),

        // Main title for admin
        Text(
          'لوحة التحكم الإدارية',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF15508A),
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: isDesktop ? 8 : 6),

        // Subtitle
        Text(
          'تجمع جدة الصحي الثاني',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: subtitleFontSize,
            color: const Color(0xFFA09EA4),
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: isDesktop ? 8 : 6),

        // Admin specific subtitle
        Text(
          'للمشرفين والإداريين المخولين فقط',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: subtitleFontSize - 2,
            color: const Color(0xFFFF6B6B),
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Container(
      padding: EdgeInsets.all(
        MediaQuery.of(context).size.width > 768 ? 32 : 24,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF15508A).withOpacity(0.1),
          width: 2,
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Admin login header
            Row(
              children: [
                Icon(
                  Icons.admin_panel_settings,
                  color: const Color(0xFF15508A),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'دخول المشرفين',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFF15508A),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Username field
            _buildInputField(
              controller: _usernameController,
              label: 'البريد الإلكتروني الإداري',
              hint: 'أدخل البريد الإلكتروني للحساب الإداري',
              icon: Icons.admin_panel_settings_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى إدخال البريد الإلكتروني';
                }
                if (!_authService.isEmailValid(value.trim())) {
                  return 'يرجى إدخال بريد إلكتروني صحيح';
                }
                return null;
              },
            ),

            SizedBox(height: MediaQuery.of(context).size.width > 768 ? 24 : 20),

            // Password field
            _buildInputField(
              controller: _passwordController,
              label: 'كلمة المرور',
              hint: 'أدخل كلمة المرور',
              icon: Icons.lock_outline,
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  color: const Color(0xFFA09EA4),
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى إدخال كلمة المرور';
                }
                if (value.length < 6) {
                  return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                }
                return null;
              },
            ),

            SizedBox(height: MediaQuery.of(context).size.width > 768 ? 20 : 16),

            // Remember me and forgot password
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (value) {
                          setState(() {
                            _rememberMe = value ?? false;
                          });
                        },
                        activeColor: const Color(0xFF15508A),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'تذكرني',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _showForgotPasswordDialog();
                  },
                  child: Text(
                    'هل نسيت كلمة المرور؟',
                    style: TextStyle(
                      color: const Color(0xFF1691D0),
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: MediaQuery.of(context).size.width > 768 ? 32 : 24),

            // Admin Login button
            SizedBox(
              height: MediaQuery.of(context).size.width > 768 ? 56 : 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleAdminLogin,
                style:
                    ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF15508A),
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shadowColor: const Color(0xFF15508A).withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ).copyWith(
                      overlayColor: MaterialStateProperty.resolveWith<Color?>((
                        Set<MaterialState> states,
                      ) {
                        if (states.contains(MaterialState.hovered)) {
                          return const Color(0xFF1691D0).withOpacity(0.1);
                        }
                        if (states.contains(MaterialState.pressed)) {
                          return const Color(0xFF1691D0).withOpacity(0.2);
                        }
                        return null;
                      }),
                    ),
                child: _isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.admin_panel_settings, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'دخول لوحة التحكم',
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width > 768
                                  ? 18
                                  : 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // Link to regular login
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'مستخدم عادي؟ ',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFFA09EA4),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    AppRouter.navigateToLogin(context);
                  },
                  child: Text(
                    'سجل دخول هنا',
                    style: TextStyle(
                      color: const Color(0xFF1691D0),
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),

            // Admin Setup Link
            const SizedBox(height: 24),
            Center(
              child: TextButton(
                onPressed: () {
                  AppRouter.navigateToAdminSetup(context);
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.orange.shade700,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'إعداد صلاحيات الأدمين',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    final isDesktop = MediaQuery.of(context).size.width > 768;
    final fontSize = isDesktop ? 16.0 : 14.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF15508A),
            fontSize: fontSize,
          ),
        ),
        SizedBox(height: isDesktop ? 8 : 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
          validator: validator,
          style: TextStyle(fontSize: fontSize),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: const Color(0xFFA09EA4),
              fontSize: fontSize,
            ),
            prefixIcon: Icon(
              icon,
              color: const Color(0xFF15508A),
              size: isDesktop ? 24 : 20,
            ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF15508A), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: const Color(0xFF15508A).withOpacity(0.3),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF15508A), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: isDesktop ? 16 : 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSupportContact() {
    return Text(
      'للدعم الفني الإداري، يرجى التواصل مع قسم تقنية المعلومات',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        fontSize: 14,
        color: const Color(0xFFA09EA4),
      ),
      textAlign: TextAlign.center,
    );
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.admin_panel_settings,
                    color: const Color(0xFF15508A),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'استعادة كلمة المرور الإدارية',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Color(0xFF15508A),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'أدخل بريدك الإلكتروني الإداري وسنرسل لك رابط لاستعادة كلمة المرور.',
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: emailController,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    decoration: InputDecoration(
                      hintText: 'البريد الإلكتروني الإداري',
                      hintStyle: const TextStyle(color: Color(0xFFA09EA4)),
                      prefixIcon: const Icon(
                        Icons.admin_panel_settings_outlined,
                        color: Color(0xFF15508A),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8F9FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF15508A),
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFE9ECEF),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF15508A),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: const Text(
                    'إلغاء',
                    style: TextStyle(color: Color(0xFFA09EA4)),
                  ),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          final email = emailController.text.trim();

                          if (email.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('يرجى إدخال البريد الإلكتروني'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          if (!_authService.isEmailValid(email)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('يرجى إدخال بريد إلكتروني صحيح'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          setState(() {
                            isLoading = true;
                          });

                          try {
                            await _authService.sendPasswordResetEmail(
                              email: email,
                            );
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'تم إرسال رابط استعادة كلمة المرور إلى بريدك الإلكتروني',
                                ),
                                backgroundColor: Color(0xFF15508A),
                                duration: Duration(seconds: 4),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(e.toString()),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 4),
                              ),
                            );
                          } finally {
                            setState(() {
                              isLoading = false;
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF15508A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'إرسال',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Desktop Layout (> 1024px)
  Widget _buildDesktopLayout(BoxConstraints constraints) {
    return Container(
      height: constraints.maxHeight,
      child: Row(
        children: [
          // Left side - Admin branding and background
          Expanded(
            flex: 5,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF15508A),
                    const Color(0xFF1691D0),
                    const Color(0xFF2CAAE2),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Decorative elements
                  Positioned(
                    top: 50,
                    left: 50,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 100,
                    right: 80,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(75),
                      ),
                    ),
                  ),

                  // Main admin branding content
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(60),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Large admin icon
                          Container(
                            padding: const EdgeInsets.all(30),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 3,
                              ),
                            ),
                            child: Icon(
                              Icons.admin_panel_settings,
                              size: 80,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 40),

                          Text(
                            'نظام إدارة متقدم للمشرفين والإداريين',
                            style: AppTheme.lightTheme.textTheme.headlineMedium
                                ?.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.bold,
                                ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 80),

                          Image.asset(
                            'assets/images/clustring_logo_white.png',
                            fit: BoxFit.cover,
                            height: MediaQuery.of(context).size.width > 1024
                                ? 120
                                : 100,
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Right side - Admin Login form
          Expanded(
            flex: 4,
            child: Container(
              color: Colors.white,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(60),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Admin login header
                        _buildHeader(),

                        const SizedBox(height: 40),

                        // Admin login form
                        _buildLoginForm(),

                        const SizedBox(height: 40),

                        // Support contact
                        _buildSupportContact(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tablet Layout (768px - 1024px)
  Widget _buildTabletLayout(BoxConstraints constraints) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Stack(
            children: [
              // Background gradient
              Container(
                height: constraints.maxHeight * 0.4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [const Color(0xFF15508A), const Color(0xFF1691D0)],
                  ),
                ),
              ),

              // Decorative wave
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: CustomPaint(
                  size: Size(constraints.maxWidth, 150),
                  painter: WavePatternPainter(),
                ),
              ),

              // Main content
              Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    const SizedBox(height: 40),

                    // Header with admin logo
                    _buildHeader(),

                    const SizedBox(height: 60),

                    // Admin login form container
                    Center(
                      child: Container(width: 500, child: _buildLoginForm()),
                    ),

                    const SizedBox(height: 40),

                    // Support contact
                    _buildSupportContact(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Mobile Layout (<= 768px)
  Widget _buildMobileLayout(BoxConstraints constraints) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Stack(
            children: [
              // Background decorative wave pattern
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: CustomPaint(
                  size: Size(constraints.maxWidth, 120),
                  painter: WavePatternPainter(),
                ),
              ),

              // Main content
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 40),

                    // Logo and header section
                    _buildHeader(),

                    const SizedBox(height: 40),

                    // Admin login form container
                    _buildLoginForm(),

                    const SizedBox(height: 30),

                    // Support contact
                    _buildSupportContact(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Wave pattern painter for decorative background
class WavePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF15508A).withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.8);

    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.6,
      size.width * 0.5,
      size.height * 0.8,
    );

    path.quadraticBezierTo(
      size.width * 0.75,
      size.height,
      size.width,
      size.height * 0.8,
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
