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

        // Check for required fields - handling both bool and string values
        final isActive = data?['isActive'];
        final role = data?['role'];
        final permissions = data?['permissions'];

        print('✅ isActive field: $isActive (type: ${isActive.runtimeType})');
        print('👤 role field: $role');
        print('🔐 permissions field: $permissions');

        // Handle both boolean and string values for isActive
        bool adminStatus = false;
        if (isActive is bool) {
          adminStatus = isActive;
        } else if (isActive is String) {
          adminStatus = isActive.toLowerCase() == 'true';
        } else if (isActive == true) {
          adminStatus = true;
        }

        print('🎯 Final admin status: $adminStatus');
        return adminStatus;
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
  Stream<List<Achievement>> getAllAchievements() async* {
    // First check if user is admin
    try {
      final isAdmin = await isCurrentUserAdmin();
      if (!isAdmin) {
        print('❌ User is not admin, cannot access all achievements');
        throw Exception(
          'خطأ في الصلاحيات: يجب أن تكون مديراً لعرض جميع المنجزات',
        );
      }

      print('✅ Admin access confirmed, fetching all achievements...');
    } catch (e) {
      print('❌ Error checking admin status: $e');
      throw Exception('خطأ في التحقق من صلاحيات المدير: $e');
    }

    yield* _firestore
        .collection(_achievementsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .handleError((error) {
          print('❌ Error in getAllAchievements stream: $error');
          if (error.toString().contains('permission-denied')) {
            print('🔒 Permission denied - checking admin document...');
            // Try to ensure admin document exists
            final userId = _currentUserId;
            if (userId != null) {
              _createAdminDocument(userId).catchError((e) {
                print('❌ Failed to create admin document: $e');
              });
            }
            throw Exception(
              'خطأ في الصلاحيات: تحقق من إعدادات المدير في قاعدة البيانات',
            );
          }
          throw Exception('خطأ في تحميل المنجزات: $error');
        })
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Achievement.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // Get achievements by status
  Stream<List<Achievement>> getAchievementsByStatus(String status) async* {
    // First check if user is admin
    final isAdmin = await isCurrentUserAdmin();
    if (!isAdmin) {
      throw Exception(
        'خطأ في الصلاحيات: يجب أن تكون مديراً لعرض المنجزات حسب الحالة',
      );
    }

    try {
      // Try the optimized query first (requires index)
      yield* _firestore
          .collection(_achievementsCollection)
          .where('status', isEqualTo: status)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => Achievement.fromMap(doc.data(), doc.id))
                .toList(),
          );
    } catch (e) {
      print('❌ Error with indexed query: $e');
      if (e.toString().contains('requires an index')) {
        print('⚠️ Using fallback query without ordering...');
        // Fallback: query without orderBy, then sort client-side
        yield* _firestore
            .collection(_achievementsCollection)
            .where('status', isEqualTo: status)
            .snapshots()
            .map((snapshot) {
              final achievements = snapshot.docs
                  .map((doc) => Achievement.fromMap(doc.data(), doc.id))
                  .toList();

              // Sort client-side by createdAt descending
              achievements.sort((a, b) => b.createdAt.compareTo(a.createdAt));
              return achievements;
            });
      } else {
        // Re-throw other errors
        rethrow;
      }
    }
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
        final usersSnapshot = await _firestore
            .collection(_usersCollection)
            .get();
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
        final achievementsSnapshot = await _firestore
            .collection(_achievementsCollection)
            .get();
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
          pendingAchievements = streamSnapshot
              .where((a) => a.status == 'pending')
              .length;
          approvedAchievements = streamSnapshot
              .where((a) => a.status == 'approved')
              .length;
          rejectedAchievements = streamSnapshot
              .where((a) => a.status == 'rejected')
              .length;
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

  // Search achievements by query
  Stream<List<Achievement>> searchAchievements(String query) async* {
    final isAdmin = await isCurrentUserAdmin();
    if (!isAdmin) {
      throw Exception('خطأ في الصلاحيات: يجب أن تكون مديراً للبحث في المنجزات');
    }

    yield* _firestore
        .collection(_achievementsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Achievement.fromMap(doc.data(), doc.id))
              .where(
                (achievement) =>
                    achievement.topic.toLowerCase().contains(
                      query.toLowerCase(),
                    ) ||
                    achievement.goal.toLowerCase().contains(
                      query.toLowerCase(),
                    ) ||
                    achievement.executiveDepartment.toLowerCase().contains(
                      query.toLowerCase(),
                    ) ||
                    achievement.participationType.toLowerCase().contains(
                      query.toLowerCase(),
                    ),
              )
              .toList(),
        );
  }

  // Filter achievements by department (detailed)
  Stream<List<Achievement>> getAchievementsByDepartmentDetailed(
    String department,
  ) async* {
    final isAdmin = await isCurrentUserAdmin();
    if (!isAdmin) {
      throw Exception('خطأ في الصلاحيات: يجب أن تكون مديراً لفلترة المنجزات');
    }

    yield* _firestore
        .collection(_achievementsCollection)
        .where('executiveDepartment', isEqualTo: department)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Achievement.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // Filter achievements by date range
  Stream<List<Achievement>> getAchievementsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async* {
    final isAdmin = await isCurrentUserAdmin();
    if (!isAdmin) {
      throw Exception('خطأ في الصلاحيات: يجب أن تكون مديراً لفلترة المنجزات');
    }

    yield* _firestore
        .collection(_achievementsCollection)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Achievement.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // Get achievements with complex filtering
  Stream<List<Achievement>> getFilteredAchievements({
    String? status,
    String? department,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
  }) async* {
    final isAdmin = await isCurrentUserAdmin();
    if (!isAdmin) {
      throw Exception('خطأ في الصلاحيات: يجب أن تكون مديراً لفلترة المنجزات');
    }

    Query query = _firestore.collection(_achievementsCollection);

    // Apply filters
    if (status != null && status != 'all') {
      query = query.where('status', isEqualTo: status);
    }

    if (department != null && department != 'all') {
      query = query.where('executiveDepartment', isEqualTo: department);
    }

    if (startDate != null) {
      query = query.where(
        'date',
        isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
      );
    }

    if (endDate != null) {
      query = query.where(
        'date',
        isLessThanOrEqualTo: Timestamp.fromDate(endDate),
      );
    }

    // Order by creation date
    query = query.orderBy('createdAt', descending: true);

    yield* query.snapshots().map((snapshot) {
      var achievements = snapshot.docs
          .map(
            (doc) =>
                Achievement.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();

      // Apply text search filter if provided
      if (searchQuery != null && searchQuery.isNotEmpty) {
        achievements = achievements
            .where(
              (achievement) =>
                  achievement.topic.toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  ) ||
                  achievement.goal.toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  ) ||
                  achievement.executiveDepartment.toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  ) ||
                  achievement.participationType.toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  ),
            )
            .toList();
      }

      return achievements;
    });
  }

  // Bulk operations
  Future<void> bulkUpdateAchievementStatus(
    List<String> achievementIds,
    String status,
  ) async {
    final isAdmin = await isCurrentUserAdmin();
    if (!isAdmin) {
      throw Exception('خطأ في الصلاحيات: يجب أن تكون مديراً للتحديث المجمع');
    }

    final batch = _firestore.batch();

    for (final id in achievementIds) {
      final docRef = _firestore.collection(_achievementsCollection).doc(id);
      batch.update(docRef, {
        'status': status,
        'reviewedAt': Timestamp.now(),
        'reviewedBy': _currentUserId,
      });
    }

    try {
      await batch.commit();
    } catch (e) {
      throw Exception('فشل في التحديث المجمع: $e');
    }
  }

  Future<void> bulkDeleteAchievements(List<String> achievementIds) async {
    final isAdmin = await isCurrentUserAdmin();
    if (!isAdmin) {
      throw Exception('خطأ في الصلاحيات: يجب أن تكون مديراً للحذف المجمع');
    }

    final batch = _firestore.batch();

    for (final id in achievementIds) {
      final docRef = _firestore.collection(_achievementsCollection).doc(id);
      batch.delete(docRef);
    }

    try {
      await batch.commit();
    } catch (e) {
      throw Exception('فشل في الحذف المجمع: $e');
    }
  }

  // Export achievements to CSV-like format
  Future<List<Map<String, dynamic>>> exportAchievements({
    String? status,
    String? department,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final isAdmin = await isCurrentUserAdmin();
    if (!isAdmin) {
      throw Exception('خطأ في الصلاحيات: يجب أن تكون مديراً لتصدير المنجزات');
    }

    final achievements = await getFilteredAchievements(
      status: status,
      department: department,
      startDate: startDate,
      endDate: endDate,
    ).first;

    return achievements
        .map(
          (achievement) => {
            'id': achievement.id,
            'topic': achievement.topic,
            'goal': achievement.goal,
            'participationType': achievement.participationType,
            'executiveDepartment': achievement.executiveDepartment,
            'status': achievement.status,
            'date': achievement.date.toString(),
            'createdAt': achievement.createdAt.toString(),
            'userId': achievement.userId,
          },
        )
        .toList();
  }

  // User Management Methods

  // Get all users for admin
  Stream<List<Map<String, dynamic>>> getAllUsersForAdmin() async* {
    final isAdmin = await isCurrentUserAdmin();
    if (!isAdmin) {
      throw Exception(
        'خطأ في الصلاحيات: يجب أن تكون مديراً لعرض جميع المستخدمين',
      );
    }

    yield* _firestore
        .collection(_usersCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(),
        );
  }

  // Get user by ID for admin
  Future<Map<String, dynamic>?> getUserByIdForAdmin(String userId) async {
    final isAdmin = await isCurrentUserAdmin();
    if (!isAdmin) {
      throw Exception(
        'خطأ في الصلاحيات: يجب أن تكون مديراً لعرض بيانات المستخدمين',
      );
    }

    try {
      final doc = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .get();
      if (doc.exists) {
        return {'id': doc.id, ...doc.data()!};
      }
      return null;
    } catch (e) {
      throw Exception('فشل في جلب بيانات المستخدم: $e');
    }
  }

  // Update user status for admin
  Future<void> updateUserStatusForAdmin(String userId, bool isActive) async {
    final isAdmin = await isCurrentUserAdmin();
    if (!isAdmin) {
      throw Exception(
        'خطأ في الصلاحيات: يجب أن تكون مديراً لتحديث حالة المستخدمين',
      );
    }

    try {
      await _firestore.collection(_usersCollection).doc(userId).update({
        'isActive': isActive,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('فشل في تحديث حالة المستخدم: $e');
    }
  }

  // Delete user for admin
  Future<void> deleteUserForAdmin(String userId) async {
    final isAdmin = await isCurrentUserAdmin();
    if (!isAdmin) {
      throw Exception('خطأ في الصلاحيات: يجب أن تكون مديراً لحذف المستخدمين');
    }

    try {
      // Delete user document
      await _firestore.collection(_usersCollection).doc(userId).delete();

      // Also delete admin document if exists
      final adminDoc = await _firestore
          .collection(_adminUsersCollection)
          .doc(userId)
          .get();
      if (adminDoc.exists) {
        await _firestore.collection(_adminUsersCollection).doc(userId).delete();
      }
    } catch (e) {
      throw Exception('فشل في حذف المستخدم: $e');
    }
  }

  // Search users for admin
  Stream<List<Map<String, dynamic>>> searchUsersForAdmin(String query) async* {
    final isAdmin = await isCurrentUserAdmin();
    if (!isAdmin) {
      throw Exception(
        'خطأ في الصلاحيات: يجب أن تكون مديراً للبحث في المستخدمين',
      );
    }

    if (query.isEmpty) {
      yield* getAllUsersForAdmin();
      return;
    }

    yield* _firestore
        .collection(_usersCollection)
        .orderBy('email')
        .startAt([query.toLowerCase()])
        .endAt(['${query.toLowerCase()}\uf8ff'])
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(),
        );
  }

  // Get users statistics for admin
  Future<Map<String, int>> getUsersStatisticsForAdmin() async {
    final isAdmin = await isCurrentUserAdmin();
    if (!isAdmin) {
      throw Exception(
        'خطأ في الصلاحيات: يجب أن تكون مديراً لعرض إحصائيات المستخدمين',
      );
    }

    try {
      final allUsers = await _firestore.collection(_usersCollection).get();

      int totalUsers = allUsers.size;
      int activeUsers = 0;
      int adminUsers = 0;
      int inactiveUsers = 0;

      for (final doc in allUsers.docs) {
        final data = doc.data();
        final isActive = data['isActive'] ?? true;
        final roles = List<String>.from(data['roles'] ?? ['user']);

        if (isActive) {
          activeUsers++;
        } else {
          inactiveUsers++;
        }

        if (roles.contains('admin') || roles.contains('super_admin')) {
          adminUsers++;
        }
      }

      return {
        'total': totalUsers,
        'active': activeUsers,
        'inactive': inactiveUsers,
        'admins': adminUsers,
      };
    } catch (e) {
      throw Exception('فشل في جلب إحصائيات المستخدمين: $e');
    }
  }
}
