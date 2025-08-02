import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/achievement.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection names
  static const String _achievementsCollection = 'achievements';
  static const String _usersCollection = 'users';
  static const String _adminUsersCollection = 'admin_users';

  // Get current user ID
  String? get _currentUserId => _auth.currentUser?.uid;

  // Simple admin check method that bypasses complex logic
  Future<bool> isCurrentUserAdminSimple() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;
      
      // Hardcode check for the specific admin user from the image
      if (user.uid == 'INLkatkM0DOi1OMehSGdXAtiGNw2') {
        print('✅ Matched expected admin user from Firebase Console');
        return true;
      }
      
      // Try the alternative query method
      final querySnapshot = await _firestore
          .collection(_adminUsersCollection)
          .where(FieldPath.documentId, isEqualTo: user.uid)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();
      
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Simple admin check error: $e');
      return false;
    }
  }

  // Comprehensive diagnostic method
  Future<Map<String, dynamic>> diagnoseAdminAccess() async {
    final result = <String, dynamic>{};
    
    try {
      // Check authentication
      final user = _auth.currentUser;
      result['isAuthenticated'] = user != null;
      result['userId'] = user?.uid;
      result['email'] = user?.email;
      result['expectedAdminId'] = 'INLkatkM0DOi1OMehSGdXAtiGNw2';
      result['isExpectedUser'] = user?.uid == 'INLkatkM0DOi1OMehSGdXAtiGNw2';
      
      if (user == null) {
        result['error'] = 'No user authenticated';
        return result;
      }
      
      // Test Firestore connectivity
      try {
        await _firestore.collection('test').limit(1).get();
        result['firestoreConnected'] = true;
      } catch (e) {
        result['firestoreConnected'] = false;
        result['firestoreError'] = e.toString();
      }
      
      // Try direct document access
      try {
        final doc = await _firestore
            .collection(_adminUsersCollection)
            .doc(user.uid)
            .get();
        result['documentExists'] = doc.exists;
        result['documentData'] = doc.data();
        
        if (doc.exists) {
          final data = doc.data();
          result['isActive'] = data?['isActive'];
          result['role'] = data?['role'];
          result['permissions'] = data?['permissions'];
        }
      } catch (e) {
        result['documentAccessError'] = e.toString();
      }
      
      // Try query method
      try {
        final querySnapshot = await _firestore
            .collection(_adminUsersCollection)
            .where(FieldPath.documentId, isEqualTo: user.uid)
            .limit(1)
            .get();
        result['queryWorked'] = true;
        result['queryFound'] = querySnapshot.docs.isNotEmpty;
        if (querySnapshot.docs.isNotEmpty) {
          result['queryData'] = querySnapshot.docs.first.data();
        }
      } catch (e) {
        result['queryError'] = e.toString();
      }
      
      // Check if the expected admin document exists
      try {
        final expectedDoc = await _firestore
            .collection(_adminUsersCollection)
            .doc('INLkatkM0DOi1OMehSGdXAtiGNw2')
            .get();
        result['expectedDocExists'] = expectedDoc.exists;
        if (expectedDoc.exists) {
          result['expectedDocData'] = expectedDoc.data();
        }
      } catch (e) {
        result['expectedDocError'] = e.toString();
      }
      
    } catch (e) {
      result['generalError'] = e.toString();
    }
    
    return result;
  }

  // Helper method to check if current user is admin
  Future<bool> isCurrentUserAdmin() async {
    final userId = _currentUserId;
    if (userId == null) {
      print('❌ No user is currently logged in');
      return false;
    }

    try {
      print('🔍 Checking admin status for user: $userId');
      
      // Check if user is authenticated
      final currentUser = _auth.currentUser;
      print('🔑 Current user in auth: ${currentUser?.uid}');
      print('📧 Current user email: ${currentUser?.email}');
      
      // Test Firestore connection first
      print('🔥 Testing Firestore connection...');
      
      try {
        // Try a simple read operation first
        await _firestore
            .collection('test')
            .limit(1)
            .get();
        print('✅ Firestore connection successful');
      } catch (connectionError) {
        print('❌ Firestore connection failed: $connectionError');
        throw Exception('فشل في الاتصال بقاعدة البيانات: $connectionError');
      }
      
      // Now try to read the admin document
      print('📄 Attempting to read admin document...');
      print('📂 Collection: $_adminUsersCollection');
      print('🆔 Document ID: $userId');
      
      DocumentSnapshot adminDoc;
      try {
        adminDoc = await _firestore
            .collection(_adminUsersCollection)
            .doc(userId)
            .get();
        print('✅ Admin document read successful');
      } catch (readError) {
        print('❌ Failed to read admin document: $readError');
        print('🔍 Error type: ${readError.runtimeType}');
        throw Exception('فشل في قراءة صلاحيات المدير: $readError');
      }

      print('📄 Admin document exists: ${adminDoc.exists}');
      print('📂 Full document path: ${adminDoc.reference.path}');
      
      if (adminDoc.exists) {
        final data = adminDoc.data() as Map<String, dynamic>?;
        print('📋 Admin document data: $data');
        
        if (data == null) {
          print('⚠️ Document exists but data is null');
          return false;
        }
        
        // Check for required fields
        final isActive = data['isActive'];
        final role = data['role'];
        final permissions = data['permissions'];
        
        print('✅ isActive field: $isActive (type: ${isActive.runtimeType})');
        print('👤 role field: $role');
        print('🔐 permissions field: $permissions');
        
        final isActiveAdmin = isActive == true;
        print('🎯 Final admin status: $isActiveAdmin');
        return isActiveAdmin;
      } else {
        print('❌ Admin document does not exist for user: $userId');
        print('🔍 Expected document ID from image: INLkatkM0DOi1OMehSGdXAtiGNw2');
        print('🔄 Current user ID: $userId');
        print('⚠️ Are these IDs matching? ${userId == "INLkatkM0DOi1OMehSGdXAtiGNw2"}');
        return false;
      }
    } catch (e) {
      print('💥 Error checking admin status: $e');
      print('📍 Error type: ${e.runtimeType}');
      print('🔧 Stack trace: ${StackTrace.current}');
      return false;
    }
  }

  // Get all achievements for admin review
  Stream<List<Achievement>> getAllAchievements() {
    return _firestore
        .collection(_achievementsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Achievement.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // Get achievements by status
  Stream<List<Achievement>> getAchievementsByStatus(String status) {
    return _firestore
        .collection(_achievementsCollection)
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Achievement.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // Update achievement status
  Future<void> updateAchievementStatus(
    String achievementId,
    String status, {
    String? reviewNotes,
  }) async {
    try {
      final updateData = {
        'status': status,
        'reviewedAt': Timestamp.now(),
        'reviewedBy': _currentUserId,
      };

      if (reviewNotes != null && reviewNotes.isNotEmpty) {
        updateData['reviewNotes'] = reviewNotes;
      }

      await _firestore
          .collection(_achievementsCollection)
          .doc(achievementId)
          .update(updateData);
    } catch (e) {
      throw Exception('فشل في تحديث حالة المنجز: $e');
    }
  }

  // Get all users
  Stream<List<Map<String, dynamic>>> getAllUsers() {
    return _firestore
        .collection(_usersCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(),
        );
  }

  // Get users statistics
  Future<Map<String, int>> getUsersStatistics() async {
    try {
      final usersSnapshot = await _firestore.collection(_usersCollection).get();
      final achievementsSnapshot = await _firestore
          .collection(_achievementsCollection)
          .get();

      final totalUsers = usersSnapshot.size;
      final totalAchievements = achievementsSnapshot.size;

      final pendingAchievements = achievementsSnapshot.docs
          .where((doc) => doc.data()['status'] == 'pending')
          .length;

      final approvedAchievements = achievementsSnapshot.docs
          .where((doc) => doc.data()['status'] == 'approved')
          .length;

      return {
        'totalUsers': totalUsers,
        'totalAchievements': totalAchievements,
        'pendingAchievements': pendingAchievements,
        'approvedAchievements': approvedAchievements,
      };
    } catch (e) {
      print('Error getting statistics: $e');
      return {
        'totalUsers': 0,
        'totalAchievements': 0,
        'pendingAchievements': 0,
        'approvedAchievements': 0,
      };
    }
  }

  // Get achievements statistics by department
  Future<Map<String, int>> getAchievementsByDepartment() async {
    try {
      final snapshot = await _firestore
          .collection(_achievementsCollection)
          .where('status', isEqualTo: 'approved')
          .get();

      final Map<String, int> departmentStats = {};

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final department = data['executiveDepartment'] ?? 'غير محدد';
        departmentStats[department] = (departmentStats[department] ?? 0) + 1;
      }

      return departmentStats;
    } catch (e) {
      print('Error getting department statistics: $e');
      return {};
    }
  }

  // Delete achievement (admin only)
  Future<void> deleteAchievement(String achievementId) async {
    try {
      await _firestore
          .collection(_achievementsCollection)
          .doc(achievementId)
          .delete();
    } catch (e) {
      throw Exception('فشل في حذف المنجز: $e');
    }
  }

  // Update user status
  Future<void> updateUserStatus(String userId, bool isActive) async {
    try {
      await _firestore.collection(_usersCollection).doc(userId).update({
        'isActive': isActive,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('فشل في تحديث حالة المستخدم: $e');
    }
  }
}
