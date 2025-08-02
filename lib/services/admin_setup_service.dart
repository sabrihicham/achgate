import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminSetupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _adminUsersCollection = 'admin_users';

  /// Add a user as admin by email
  /// This method requires the user to already be registered in Firebase Auth
  Future<bool> addAdminByEmail(String email) async {
    try {
      print('Searching for user with email: $email');

      // Check if the current user is trying to add themselves
      final currentUser = _auth.currentUser;
      if (currentUser != null && currentUser.email == email) {
        print('User is adding themselves as admin');
        return await addAdminByUserId(currentUser.uid);
      }

      // For other users, we need to try a different approach since we can't query all users
      // We'll ask the user to provide the User ID directly
      throw Exception('''
لا يمكن البحث عن المستخدمين بالبريد الإلكتروني بسبب قيود الصلاحيات.

الحلول المتاحة:
1. إذا كنت تريد إضافة نفسك كمدير، استخدم زر "إضافة صلاحيات الأدمين للمستخدم الحالي"
2. لإضافة مستخدم آخر، احصل على معرف المستخدم (User ID) واستخدم خانة "إضافة أدمين بمعرف المستخدم"
3. أو اتبع التعليمات في Firebase Console كما هو موضح أدناه

التعليمات اليدوية:
1. اذهب إلى Firebase Console
2. فتح Firestore Database  
3. إنشاء/فتح collection "admin_users"
4. إضافة document بـ ID = معرف المستخدم المطلوب
5. إضافة field: isActive = true
      ''');
    } catch (e) {
      print('Error adding admin by email: $e');
      rethrow; // Re-throw to preserve the original error message
    }
  }

  /// Add a user as admin by User ID
  Future<bool> addAdminByUserId(String userId) async {
    try {
      print('Attempting to add user as admin: $userId');

      // Try to add the document directly
      try {
        await _firestore.collection(_adminUsersCollection).doc(userId).set({
          'isActive': true,
          'createdAt': Timestamp.now(),
          'createdBy': _auth.currentUser?.uid ?? 'system',
          'role': 'admin',
          'permissions': [
            'read_achievements',
            'write_achievements',
            'manage_users',
            'view_statistics',
          ],
        });

        print('Successfully added user $userId as admin');
        return true;
      } catch (permissionError) {
        print('Permission error when adding admin: $permissionError');

        // If we get a permission error, provide alternative instructions
        throw Exception('''
خطأ في الصلاحيات. لإضافة المدير، يرجى:

1. الذهاب إلى Firebase Console
2. فتح Firestore Database  
3. إنشاء collection باسم "admin_users" (إذا لم يكن موجوداً)
4. إضافة document بـ ID: $userId
5. إضافة field: isActive = true

أو تحديث قواعد Firestore لتسمح بإضافة المديرين.
        ''');
      }
    } catch (e) {
      print('Error in addAdminByUserId: $e');
      rethrow;
    }
  }

  /// Add current user as admin (for first-time setup)
  /// This method tries to add the current user as admin
  /// If it fails due to permissions, it will provide instructions
  Future<bool> makeCurrentUserAdmin() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('لا يوجد مستخدم مسجل الدخول');
      }

      print('Attempting to add current user as admin: ${user.uid}');

      // Try to add the document directly
      try {
        await _firestore.collection(_adminUsersCollection).doc(user.uid).set({
          'isActive': true,
          'email': user.email,
          'createdAt': Timestamp.now(),
          'createdBy': 'self-setup',
        });

        print('Successfully added current user as admin');
        return true;
      } catch (permissionError) {
        print('Permission error when adding admin: $permissionError');

        // If we get a permission error, provide alternative instructions
        throw Exception('''
خطأ في الصلاحيات. لإضافة المدير الأول، يرجى:

1. الذهاب إلى Firebase Console
2. فتح Firestore Database  
3. إنشاء collection باسم "admin_users"
4. إضافة document بـ ID: ${user.uid}
5. إضافة field: isActive = true

أو تحديث قواعد Firestore لتسمح بالإعداد الأولي.
        ''');
      }
    } catch (e) {
      print('Error in makeCurrentUserAdmin: $e');
      rethrow;
    }
  }

  /// Remove admin privileges from a user
  Future<bool> removeAdmin(String userId) async {
    try {
      await _firestore.collection(_adminUsersCollection).doc(userId).update({
        'isActive': false,
        'deactivatedAt': Timestamp.now(),
        'deactivatedBy': _auth.currentUser?.uid,
      });

      print('Successfully removed admin privileges from user $userId');
      return true;
    } catch (e) {
      print('Error removing admin: $e');
      return false;
    }
  }

  /// Check if any admins exist in the system
  Future<bool> hasAnyAdmins() async {
    try {
      final querySnapshot = await _firestore
          .collection(_adminUsersCollection)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking for existing admins: $e');
      return false;
    }
  }

  /// Get current user information for admin setup
  Map<String, String?> getCurrentUserInfo() {
    final user = _auth.currentUser;
    return {
      'uid': user?.uid,
      'email': user?.email,
      'displayName': user?.displayName,
    };
  }

  /// Check if current user is already an admin
  Future<bool> isCurrentUserAlreadyAdmin() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final doc = await _firestore
          .collection(_adminUsersCollection)
          .doc(user.uid)
          .get();

      return doc.exists && (doc.data()?['isActive'] ?? false);
    } catch (e) {
      print('Error checking current user admin status: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> listAllAdmins() async {
    try {
      final snapshot = await _firestore
          .collection(_adminUsersCollection)
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => {'userId': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      print('Error listing admins: $e');
      return [];
    }
  }

  /// Check if a specific user is admin
  Future<bool> isUserAdmin(String userId) async {
    try {
      final doc = await _firestore
          .collection(_adminUsersCollection)
          .doc(userId)
          .get();

      return doc.exists && (doc.data()?['isActive'] ?? false);
    } catch (e) {
      print('Error checking admin status: $e');
      return false;
    }
  }

  /// Get admin user details
  Future<Map<String, dynamic>?> getAdminDetails(String userId) async {
    try {
      final doc = await _firestore
          .collection(_adminUsersCollection)
          .doc(userId)
          .get();

      if (doc.exists) {
        return {'userId': doc.id, ...doc.data()!};
      }
      return null;
    } catch (e) {
      print('Error getting admin details: $e');
      return null;
    }
  }
}
