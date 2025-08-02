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

      final adminDoc = await _firestore
          .collection(_adminUsersCollection)
          .doc(userId)
          .get();

      print('📄 Admin document exists: ${adminDoc.exists}');
      print('📂 Collection path: $_adminUsersCollection/$userId');

      if (adminDoc.exists) {
        final data = adminDoc.data();
        print('📋 Admin document data: $data');

        // Check for required fields
        final isActive = data?['isActive'];
        final role = data?['role'];
        final permissions = data?['permissions'];

        print('✅ isActive field: $isActive (type: ${isActive.runtimeType})');
        print('👤 role field: $role');
        print('🔐 permissions field: $permissions');

        print('🎯 Final admin status: $isActive');

        return isActive == 'true' ? true : false; // Ensure boolean return type
      } else {
        print('❌ Admin document does not exist for user: $userId');

        // Try to create an admin document for this user
        // This is helpful for initial setup
        try {
          print('� Attempting to create admin document for initial setup...');
          await _createAdminDocument(userId);
          print('✅ Successfully created admin document');
          return true; // User is now an admin
        } catch (e) {
          print('❌ Failed to create admin document: $e');
          return false;
        }
      }
    } catch (e) {
      print('💥 Error checking admin status: $e');
      print('📍 Error type: ${e.runtimeType}');
      return false;
    }
  }

  // Helper method to create admin document
  Future<void> _createAdminDocument(String userId) async {
    try {
      await _firestore.collection(_adminUsersCollection).doc(userId).set({
        'isActive': true,
        'role': 'admin',
        'permissions': [
          'read_achievements',
          'write_achievements',
          'manage_users',
          'view_statistics',
        ],
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': 'auto-setup',
        'email': _auth.currentUser?.email,
      });
      print('✅ Successfully created admin document for user: $userId');
    } catch (e) {
      print('❌ Error creating admin document: $e');
      rethrow;
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
      print('🔍 Getting admin statistics...');
      
      // Check if current user is admin first
      final isAdmin = await isCurrentUserAdmin();
      if (!isAdmin) {
        print('❌ User is not admin, returning empty statistics');
        throw Exception('غير مسموح: يجب أن تكون مديراً للوصول للإحصائيات');
      }

      print('✅ User is admin, proceeding with statistics...');

      // Get users count (with better error handling)
      int totalUsers = 0;
      try {
        final usersSnapshot = await _firestore.collection(_usersCollection).get();
        totalUsers = usersSnapshot.size;
        print('📊 Total users: $totalUsers');
      } catch (e) {
        print('⚠️ Error getting users count: $e');
        // Try to get count from alternative source or use cached data
        totalUsers = 0;
      }

      // Get achievements count (with better error handling) 
      int totalAchievements = 0;
      int pendingAchievements = 0;
      int approvedAchievements = 0;
      int rejectedAchievements = 0;

      try {
        final achievementsSnapshot = await _firestore.collection(_achievementsCollection).get();
        totalAchievements = achievementsSnapshot.size;

        for (final doc in achievementsSnapshot.docs) {
          final status = doc.data()['status'] ?? 'pending';
          switch (status) {
            case 'pending':
              pendingAchievements++;
              break;
            case 'approved':
              approvedAchievements++;
              break;
            case 'rejected':
              rejectedAchievements++;
              break;
          }
        }

        print('📊 Achievements statistics:');
        print('   Total: $totalAchievements');
        print('   Pending: $pendingAchievements');
        print('   Approved: $approvedAchievements');
        print('   Rejected: $rejectedAchievements');
      } catch (e) {
        print('⚠️ Error getting achievements statistics: $e');
        // Use stream-based approach as fallback
        try {
          final streamSnapshot = await getAllAchievements().first;
          totalAchievements = streamSnapshot.length;
          pendingAchievements = streamSnapshot.where((a) => a.status == 'pending').length;
          approvedAchievements = streamSnapshot.where((a) => a.status == 'approved').length;
          rejectedAchievements = streamSnapshot.where((a) => a.status == 'rejected').length;
          print('📊 Got statistics from stream fallback');
        } catch (streamError) {
          print('❌ Stream fallback also failed: $streamError');
        }
      }

      final result = {
        'totalUsers': totalUsers,
        'totalAchievements': totalAchievements,
        'pendingAchievements': pendingAchievements,
        'approvedAchievements': approvedAchievements,
        'rejectedAchievements': rejectedAchievements,
      };

      print('✅ Returning statistics: $result');
      return result;
    } catch (e) {
      print('❌ Error getting statistics: $e');
      
      // Return empty statistics with proper error indication
      if (e.toString().contains('غير مسموح')) {
        rethrow; // Re-throw permission errors
      }
      
      // For other errors, return empty stats
      return {
        'totalUsers': 0,
        'totalAchievements': 0,
        'pendingAchievements': 0,
        'approvedAchievements': 0,
        'rejectedAchievements': 0,
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
