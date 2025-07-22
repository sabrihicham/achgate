import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'حدث خطأ غير متوقع: ${e.toString()}';
    }
  }

  // Create user with email and password
  Future<UserCredential?> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'حدث خطأ غير متوقع: ${e.toString()}';
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'حدث خطأ غير متوقع: ${e.toString()}';
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw 'حدث خطأ أثناء تسجيل الخروج: ${e.toString()}';
    }
  }

  // Handle Firebase Auth exceptions and return Arabic error messages
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'المستخدم غير موجود. يرجى التحقق من البريد الإلكتروني.';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة. يرجى المحاولة مرة أخرى.';
      case 'email-already-in-use':
        return 'البريد الإلكتروني مستخدم بالفعل. يرجى استخدام بريد إلكتروني آخر.';
      case 'weak-password':
        return 'كلمة المرور ضعيفة. يرجى استخدام كلمة مرور أقوى.';
      case 'invalid-email':
        return 'عنوان البريد الإلكتروني غير صحيح.';
      case 'user-disabled':
        return 'تم تعطيل هذا الحساب. يرجى التواصل مع الدعم الفني.';
      case 'too-many-requests':
        return 'تم إجراء محاولات كثيرة. يرجى المحاولة لاحقاً.';
      case 'operation-not-allowed':
        return 'هذه العملية غير مسموحة. يرجى التواصل مع الدعم الفني.';
      case 'network-request-failed':
        return 'فشل في الاتصال بالشبكة. يرجى التحقق من اتصال الإنترنت.';
      case 'invalid-credential':
        return 'بيانات الاعتماد غير صحيحة. يرجى التحقق من البريد الإلكتروني وكلمة المرور.';
      case 'account-exists-with-different-credential':
        return 'يوجد حساب بنفس البريد الإلكتروني مع طريقة تسجيل دخول مختلفة.';
      case 'credential-already-in-use':
        return 'بيانات الاعتماد مستخدمة بالفعل مع حساب آخر.';
      case 'requires-recent-login':
        return 'تتطلب هذه العملية تسجيل دخول حديث. يرجى تسجيل الدخول مرة أخرى.';
      default:
        return 'حدث خطأ: ${e.message ?? 'خطأ غير معروف'}';
    }
  }

  // Check if email is valid
  bool isEmailValid(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  // Check if password is strong enough
  bool isPasswordStrong(String password) {
    // At least 8 characters, contains uppercase, lowercase, number, and special character
    return password.length >= 8 &&
        RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]').hasMatch(password);
  }

  // Get password strength message
  String getPasswordStrengthMessage(String password) {
    if (password.length < 8) {
      return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
    }
    if (!RegExp(r'(?=.*[a-z])').hasMatch(password)) {
      return 'كلمة المرور يجب أن تحتوي على حرف صغير على الأقل';
    }
    if (!RegExp(r'(?=.*[A-Z])').hasMatch(password)) {
      return 'كلمة المرور يجب أن تحتوي على حرف كبير على الأقل';
    }
    if (!RegExp(r'(?=.*\d)').hasMatch(password)) {
      return 'كلمة المرور يجب أن تحتوي على رقم على الأقل';
    }
    if (!RegExp(r'(?=.*[@$!%*?&])').hasMatch(password)) {
      return 'كلمة المرور يجب أن تحتوي على رمز خاص على الأقل (@\$!%*?&)';
    }
    return '';
  }
}
