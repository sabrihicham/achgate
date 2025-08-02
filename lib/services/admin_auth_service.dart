import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// خدمة المصادقة الإدارية
/// تتعامل مع تسجيل دخول المديرين والتحقق من صلاحياتهم
class AdminAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _adminUsersCollection = 'admin_users';

  /// نتيجة عملية المصادقة الإدارية
  AdminAuthResult? _lastAuthResult;

  /// الحصول على المستخدم الحالي
  User? get currentUser => _auth.currentUser;

  /// التحقق من تسجيل دخول المدير
  Future<bool> isAdminLoggedIn() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('❌ No user logged in');
        return false;
      }

      print('🔍 Checking admin status for user: ${user.uid}');

      // التحقق من وجود مستند المدير
      final adminDoc = await _firestore
          .collection(_adminUsersCollection)
          .doc(user.uid)
          .get();

      if (!adminDoc.exists) {
        print('❌ Admin document does not exist');
        return false;
      }

      final data = adminDoc.data()!;
      final isActive = data['isActive'];
      
      print('✅ Admin document found, isActive: $isActive');

      // التعامل مع القيم المختلفة لـ isActive
      if (isActive is bool) {
        return isActive;
      } else if (isActive is String) {
        return isActive.toLowerCase() == 'true';
      } else {
        return isActive == true;
      }
    } catch (e) {
      print('❌ Error checking admin login status: $e');
      return false;
    }
  }

  /// تسجيل دخول المدير
  Future<AdminAuthResult> signInAsAdmin({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 Attempting admin login for: $email');

      // تسجيل الدخول باستخدام Firebase Auth
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        return AdminAuthResult.failure('فشل في تسجيل الدخول');
      }

      print('✅ User authenticated: ${user.uid}');

      // التحقق من الصلاحيات الإدارية
      final isAdmin = await _checkAdminPermissions(user.uid);
      if (!isAdmin) {
        // تسجيل خروج المستخدم إذا لم يكن مديراً
        await _auth.signOut();
        return AdminAuthResult.failure(
          'هذا الحساب ليس لديه صلاحيات إدارية'
        );
      }

      print('✅ Admin permissions verified');

      // تحديث آخر تسجيل دخول
      await _updateLastLogin(user.uid);

      _lastAuthResult = AdminAuthResult.success(
        'تم تسجيل الدخول بنجاح',
        user,
      );

      return _lastAuthResult!;
    } on FirebaseAuthException catch (e) {
      print('❌ Firebase Auth Error: ${e.code} - ${e.message}');
      
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'لا يوجد حساب مرتبط بهذا البريد الإلكتروني';
          break;
        case 'wrong-password':
          errorMessage = 'كلمة المرور غير صحيحة';
          break;
        case 'invalid-email':
          errorMessage = 'البريد الإلكتروني غير صحيح';
          break;
        case 'user-disabled':
          errorMessage = 'هذا الحساب معطل';
          break;
        case 'too-many-requests':
          errorMessage = 'تم تجاوز عدد المحاولات المسموح. حاول مرة أخرى لاحقاً';
          break;
        case 'network-request-failed':
          errorMessage = 'خطأ في الاتصال بالإنترنت';
          break;
        default:
          errorMessage = 'حدث خطأ أثناء تسجيل الدخول: ${e.message}';
      }

      return AdminAuthResult.failure(errorMessage);
    } catch (e) {
      print('❌ Unexpected error during admin login: $e');
      return AdminAuthResult.failure('حدث خطأ غير متوقع: $e');
    }
  }

  /// تسجيل خروج المدير
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _lastAuthResult = null;
      print('✅ Admin signed out successfully');
    } catch (e) {
      print('❌ Error signing out: $e');
      throw Exception('فشل في تسجيل الخروج: $e');
    }
  }

  /// التحقق من الصلاحيات الإدارية
  Future<bool> _checkAdminPermissions(String userId) async {
    try {
      final adminDoc = await _firestore
          .collection(_adminUsersCollection)
          .doc(userId)
          .get();

      if (!adminDoc.exists) {
        print('❌ Admin document not found for user: $userId');
        return false;
      }

      final data = adminDoc.data()!;
      final isActive = data['isActive'];
      final role = data['role'];

      print('📋 Admin data: isActive=$isActive, role=$role');

      // التحقق من حالة التفعيل
      bool adminActive = false;
      if (isActive is bool) {
        adminActive = isActive;
      } else if (isActive is String) {
        adminActive = isActive.toLowerCase() == 'true';
      } else {
        adminActive = isActive == true;
      }

      if (!adminActive) {
        print('❌ Admin account is not active');
        return false;
      }

      // التحقق من الدور (اختياري)
      if (role != null && role != 'admin' && role != 'super_admin') {
        print('❌ Invalid admin role: $role');
        return false;
      }

      return true;
    } catch (e) {
      print('❌ Error checking admin permissions: $e');
      return false;
    }
  }

  /// تحديث آخر تسجيل دخول
  Future<void> _updateLastLogin(String userId) async {
    try {
      await _firestore
          .collection(_adminUsersCollection)
          .doc(userId)
          .update({
        'lastLoginAt': FieldValue.serverTimestamp(),
        'lastLoginIP': 'web', // يمكن تحسينه للحصول على IP الحقيقي
      });
      print('✅ Last login updated');
    } catch (e) {
      print('⚠️ Failed to update last login: $e');
      // لا نرمي خطأ هنا لأن هذا ليس أمراً حرجاً
    }
  }

  /// إنشاء حساب مدير جديد (للمديرين المخولين فقط)
  Future<AdminAuthResult> createAdminAccount({
    required String email,
    required String password,
    required String fullName,
    String role = 'admin',
  }) async {
    try {
      // التحقق من أن المستخدم الحالي مدير
      final currentIsAdmin = await isAdminLoggedIn();
      if (!currentIsAdmin) {
        return AdminAuthResult.failure(
          'يجب أن تكون مديراً لإنشاء حسابات إدارية جديدة'
        );
      }

      print('🔧 Creating new admin account for: $email');

      // إنشاء الحساب في Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        return AdminAuthResult.failure('فشل في إنشاء الحساب');
      }

      // إنشاء مستند المدير
      await _firestore
          .collection(_adminUsersCollection)
          .doc(user.uid)
          .set({
        'email': email.trim(),
        'fullName': fullName,
        'role': role,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': _auth.currentUser?.uid,
        'permissions': [
          'read_achievements',
          'write_achievements',
          'manage_users',
          'view_statistics',
        ],
      });

      // تحديث الملف الشخصي
      await user.updateDisplayName(fullName);

      print('✅ Admin account created successfully');

      return AdminAuthResult.success(
        'تم إنشاء الحساب الإداري بنجاح',
        user,
      );
    } on FirebaseAuthException catch (e) {
      print('❌ Firebase Auth Error creating admin: ${e.code} - ${e.message}');
      
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'هذا البريد الإلكتروني مستخدم بالفعل';
          break;
        case 'invalid-email':
          errorMessage = 'البريد الإلكتروني غير صحيح';
          break;
        case 'weak-password':
          errorMessage = 'كلمة المرور ضعيفة. يجب أن تكون 6 أحرف على الأقل';
          break;
        default:
          errorMessage = 'حدث خطأ أثناء إنشاء الحساب: ${e.message}';
      }

      return AdminAuthResult.failure(errorMessage);
    } catch (e) {
      print('❌ Unexpected error creating admin: $e');
      return AdminAuthResult.failure('حدث خطأ غير متوقع: $e');
    }
  }

  /// تعطيل/تفعيل حساب مدير
  Future<bool> toggleAdminStatus(String adminId, bool isActive) async {
    try {
      // التحقق من صلاحيات المستخدم الحالي
      final currentIsAdmin = await isAdminLoggedIn();
      if (!currentIsAdmin) {
        throw Exception('يجب أن تكون مديراً لتعديل حالة المديرين');
      }

      await _firestore
          .collection(_adminUsersCollection)
          .doc(adminId)
          .update({
        'isActive': isActive,
        'modifiedAt': FieldValue.serverTimestamp(),
        'modifiedBy': _auth.currentUser?.uid,
      });

      print('✅ Admin status updated: $adminId -> $isActive');
      return true;
    } catch (e) {
      print('❌ Error updating admin status: $e');
      return false;
    }
  }

  /// الحصول على معلومات المدير الحالي
  Future<Map<String, dynamic>?> getCurrentAdminInfo() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final adminDoc = await _firestore
          .collection(_adminUsersCollection)
          .doc(user.uid)
          .get();

      if (!adminDoc.exists) return null;

      final data = adminDoc.data()!;
      data['uid'] = user.uid;
      data['email'] = user.email;
      
      return data;
    } catch (e) {
      print('❌ Error getting current admin info: $e');
      return null;
    }
  }

  /// مراقبة حالة المصادقة
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// الحصول على نتيجة المصادقة الأخيرة
  AdminAuthResult? get lastAuthResult => _lastAuthResult;
}

/// نتيجة عملية المصادقة الإدارية
class AdminAuthResult {
  final bool isSuccess;
  final String message;
  final String? errorMessage;
  final User? user;

  AdminAuthResult._({
    required this.isSuccess,
    required this.message,
    this.errorMessage,
    this.user,
  });

  /// نتيجة ناجحة
  factory AdminAuthResult.success(String message, User user) {
    return AdminAuthResult._(
      isSuccess: true,
      message: message,
      user: user,
    );
  }

  /// نتيجة فاشلة
  factory AdminAuthResult.failure(String errorMessage) {
    return AdminAuthResult._(
      isSuccess: false,
      message: 'فشلت العملية',
      errorMessage: errorMessage,
    );
  }

  @override
  String toString() {
    return 'AdminAuthResult(isSuccess: $isSuccess, message: $message, error: $errorMessage)';
  }
}
