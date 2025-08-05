import 'dart:math' as math;

import 'package:achgate/services/auth_service.dart';
import 'package:achgate/theme/app_theme.dart';
import 'package:achgate/view/home_screen.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final email = _usernameController.text.trim();
        final password = _passwordController.text;

        // Validate email format
        if (!_authService.isEmailValid(email)) {
          throw 'يرجى إدخال بريد إلكتروني صحيح';
        }

        // Sign in with Firebase Auth
        final userCredential = await _authService.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (userCredential != null && mounted) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تسجيل الدخول بنجاح'),
              backgroundColor: Color(0xFF15508A),
              duration: Duration(seconds: 2),
            ),
          );

          // Navigate to home screen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;
    final isTablet = screenWidth > 768 && screenWidth <= 1024;
    final logoSize = isDesktop ? 120.0 : (isTablet ? 100.0 : 80.0);
    final titleFontSize = isDesktop ? 32.0 : (isTablet ? 28.0 : 24.0);
    final subtitleFontSize = isDesktop ? 16.0 : (isTablet ? 15.0 : 14.0);

    return Column(
      children: [
        // Logo placeholder (you can replace with actual logo)
        Container(
          width: logoSize,
          height: logoSize,
          decoration: BoxDecoration(
            color: const Color(0xFF15508A),
            borderRadius: BorderRadius.circular(logoSize / 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF15508A).withValues(alpha: 0.2),
                blurRadius: isDesktop ? 20 : 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            Icons.local_hospital,
            size: logoSize * 0.5,
            color: Colors.white,
          ),
        ),

        SizedBox(height: isDesktop ? 24 : (isTablet ? 20 : 16)),

        // Main title
        Text(
          'تسجيل الدخول للإدارات',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
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
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Username field
            _buildInputField(
              controller: _usernameController,
              label: 'البريد الإلكتروني',
              hint: 'أدخل البريد الإلكتروني',
              icon: Icons.email_outlined,
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
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 350;

                if (isNarrow) {
                  // Stack vertically on very narrow screens
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                            activeColor: const Color(0xFF15508A),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'تذكرني',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
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
                      ),
                    ],
                  );
                } else {
                  // Side by side on wider screens
                  return Row(
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
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
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
                  );
                }
              },
            ),

            SizedBox(height: MediaQuery.of(context).size.width > 768 ? 32 : 24),

            // Login button
            SizedBox(
              height: MediaQuery.of(context).size.width > 768 ? 56 : 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style:
                    ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF15508A),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shadowColor: const Color(0xFF15508A).withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ).copyWith(
                      overlayColor: WidgetStateProperty.resolveWith<Color?>((
                        Set<WidgetState> states,
                      ) {
                        if (states.contains(WidgetState.hovered)) {
                          return const Color(0xFF1691D0).withValues(alpha: 0.1);
                        }
                        if (states.contains(WidgetState.pressed)) {
                          return const Color(0xFF1691D0).withValues(alpha: 0.2);
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
                    : Text(
                        'تسجيل الدخول',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width > 768
                              ? 18
                              : 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // Link to admin login
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'مشرف أو إداري؟ ',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFFA09EA4),
                    fontSize: 14,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/admin-login');
                  },
                  child: Text(
                    'دخول لوحة التحكم',
                    style: TextStyle(
                      color: const Color(0xFF1691D0),
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;
    final fontSize = isDesktop ? 16.0 : 14.0;
    final labelFontSize = isDesktop ? 16.0 : 14.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: const Color(0xFF333333),
            fontSize: labelFontSize,
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
              color: const Color(0xFFA09EA4),
              size: isDesktop ? 24 : 20,
            ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE9ECEF), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE9ECEF), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1691D0), width: 2),
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
              horizontal: isDesktop ? 16 : 14,
              vertical: isDesktop ? 16 : 14,
            ),
            errorStyle: TextStyle(
              fontSize: isDesktop ? 14 : 12,
              color: Colors.red.shade600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSupportContact() {
    return Text(
      'للدعم الفني، يرجى التواصل معنا',
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
              title: const Text(
                'استعادة كلمة المرور',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: Color(0xFF15508A),
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'أدخل بريدك الإلكتروني وسنرسل لك رابط لاستعادة كلمة المرور.',
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: emailController,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    decoration: InputDecoration(
                      hintText: 'البريد الإلكتروني',
                      hintStyle: const TextStyle(color: Color(0xFFA09EA4)),
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: Color(0xFFA09EA4),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8F9FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFE9ECEF),
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
                          color: Color(0xFF1691D0),
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
    return SizedBox(
      height: constraints.maxHeight,
      child: Row(
        children: [
          // Left side - Branding and background
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
                        color: Colors.white.withValues(alpha: 0.1),
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
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(75),
                      ),
                    ),
                  ),

                  // Main branding content
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(60),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Large logo
                          Image.asset(
                            'assets/images/portal_logo_white.png',
                            fit: BoxFit.cover,
                            height: MediaQuery.of(context).size.width > 1024
                                ? 120
                                : 100,
                          ),
                          const SizedBox(height: 40),

                          Text(
                            'نظام إدارة متقدم لادارة المنجزات الخاصة بتجمع جدة الصحي الثاني',
                            style: AppTheme.lightTheme.textTheme.headlineMedium
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontWeight: FontWeight.bold,
                                ),
                            textAlign: TextAlign.center,
                          ),

                          // // Welcome text
                          // Text(
                          //   'مرحباً بكم في',
                          //   style: TextStyle(
                          //     fontSize: 24,
                          //     color: Colors.white.withValues(alpha: 0.9),
                          //     fontWeight: FontWeight.w300,
                          //   ),
                          //   textAlign: TextAlign.center,
                          // ),

                          // const SizedBox(height: 16),
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

          // Right side - Login form
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
                        // Login header
                        Text(
                          'تسجيل الدخول',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF15508A),
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'للإدارات والموظفين المخولين',
                          style: TextStyle(
                            fontSize: 16,
                            color: const Color(0xFFA09EA4),
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 40),

                        // Login form
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

                    // Header with logo
                    _buildHeader(),

                    const SizedBox(height: 60),

                    // Login form container
                    Center(
                      child: SizedBox(width: 500, child: _buildLoginForm()),
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

                    // Login form container
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

class WavePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2CAAE2).withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final path = Path();

    // Create responsive wave pattern
    final waveHeight = size.height * 0.3;
    final waveFrequency = size.width / 100;

    // Create wave pattern
    path.moveTo(0, size.height * 0.5);

    for (double x = 0; x <= size.width; x += 5) {
      final y =
          size.height * 0.5 +
          waveHeight *
              math.sin(x / waveFrequency) *
              math.cos(x / (waveFrequency * 1.6));
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);

    // Add additional decorative elements for desktop
    if (size.width > 1024) {
      final decorativePaint = Paint()
        ..color = const Color(0xFF2CAAE2).withValues(alpha: 0.05)
        ..style = PaintingStyle.fill;

      // Add some circles
      canvas.drawCircle(
        Offset(size.width * 0.8, size.height * 0.3),
        30,
        decorativePaint,
      );

      canvas.drawCircle(
        Offset(size.width * 0.2, size.height * 0.7),
        20,
        decorativePaint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
