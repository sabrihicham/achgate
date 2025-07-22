import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/achievement.dart';

class AchievementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  static const String _collection = 'achievements';

  // Get current user ID
  String? get _currentUserId => _auth.currentUser?.uid;

  // Helper method to check authentication
  void _checkAuthentication() {
    if (_currentUserId == null) {
      throw Exception('المستخدم غير مسجل الدخول - يجب تسجيل الدخول أولاً');
    }
  }

  // Helper method to log debug information
  void _logDebugInfo(String operation) {
    final user = _auth.currentUser;
    print('=== $operation DEBUG ===');
    print('User authenticated: ${user != null}');
    print('User ID: ${user?.uid}');
    print('User email: ${user?.email}');
    print('User email verified: ${user?.emailVerified}');
    print('========================');
  }

  // Add new achievement
  Future<String> addAchievement(Achievement achievement) async {
    try {
      _checkAuthentication();
      _logDebugInfo('ADD_ACHIEVEMENT');

      final now = DateTime.now();
      final achievementData = achievement.copyWith(
        userId: _currentUserId!,
        createdAt: now,
        updatedAt: now,
      );

      print('Creating achievement with data: ${achievementData.toMap()}');

      final docRef = await _firestore
          .collection(_collection)
          .add(achievementData.toMap());

      print('Achievement created successfully with ID: ${docRef.id}');
      return docRef.id;
    } on FirebaseException catch (e) {
      print('Firebase error in addAchievement: ${e.code} - ${e.message}');
      switch (e.code) {
        case 'permission-denied':
          throw Exception('خطأ في الصلاحيات: لا يمكنك إضافة منجزات في الوقت الحالي. تأكد من تسجيل الدخول.');
        case 'unavailable':
          throw Exception('خدمة قاعدة البيانات غير متوفرة حالياً. حاول مرة أخرى لاحقاً.');
        default:
          throw Exception('خطأ في إضافة المنجز: ${e.message}');
      }
    } catch (e) {
      print('Unexpected error in addAchievement: $e');
      throw Exception('خطأ في إضافة المنجز: $e');
    }
  }

  // Update existing achievement
  Future<void> updateAchievement(Achievement achievement) async {
    try {
      if (achievement.id == null) {
        throw Exception('معرف المنجز مطلوب للتحديث');
      }

      _checkAuthentication();
      _logDebugInfo('UPDATE_ACHIEVEMENT');

      final updatedAchievement = achievement.copyWith(
        updatedAt: DateTime.now(),
      );

      print('Updating achievement ${achievement.id} with data: ${updatedAchievement.toMap()}');

      await _firestore
          .collection(_collection)
          .doc(achievement.id)
          .update(updatedAchievement.toMap());

      print('Achievement updated successfully');
    } on FirebaseException catch (e) {
      print('Firebase error in updateAchievement: ${e.code} - ${e.message}');
      switch (e.code) {
        case 'permission-denied':
          throw Exception('خطأ في الصلاحيات: لا يمكنك تعديل هذا المنجز.');
        case 'not-found':
          throw Exception('المنجز غير موجود أو تم حذفه.');
        default:
          throw Exception('خطأ في تحديث المنجز: ${e.message}');
      }
    } catch (e) {
      print('Unexpected error in updateAchievement: $e');
      throw Exception('خطأ في تحديث المنجز: $e');
    }
  }

  // Delete achievement
  Future<void> deleteAchievement(String achievementId) async {
    try {
      _checkAuthentication();
      _logDebugInfo('DELETE_ACHIEVEMENT');

      print('Deleting achievement: $achievementId');

      await _firestore
          .collection(_collection)
          .doc(achievementId)
          .delete();

      print('Achievement deleted successfully');
    } on FirebaseException catch (e) {
      print('Firebase error in deleteAchievement: ${e.code} - ${e.message}');
      switch (e.code) {
        case 'permission-denied':
          throw Exception('خطأ في الصلاحيات: لا يمكنك حذف هذا المنجز.');
        case 'not-found':
          throw Exception('المنجز غير موجود أو تم حذفه مسبقاً.');
        default:
          throw Exception('خطأ في حذف المنجز: ${e.message}');
      }
    } catch (e) {
      print('Unexpected error in deleteAchievement: $e');
      throw Exception('خطأ في حذف المنجز: $e');
    }
  }

  // Get achievement by ID
  Future<Achievement?> getAchievementById(String achievementId) async {
    try {
      final doc = await _firestore
          .collection(_collection)
          .doc(achievementId)
          .get();

      if (!doc.exists) {
        return null;
      }

      return Achievement.fromMap(doc.data()!, doc.id);
    } catch (e) {
      throw Exception('خطأ في جلب المنجز: $e');
    }
  }

  // Get all achievements for current user
  Stream<List<Achievement>> getUserAchievements() {
    if (_currentUserId == null) {
      print('Warning: getUserAchievements called with null user ID');
      return Stream.value([]);
    }

    try {
      _logDebugInfo('GET_USER_ACHIEVEMENTS');
      print('Querying achievements for user: $_currentUserId');

      return _firestore
          .collection(_collection)
          .where('userId', isEqualTo: _currentUserId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .handleError((error) {
            print('Stream error in getUserAchievements: $error');
            if (error is FirebaseException) {
              switch (error.code) {
                case 'permission-denied':
                  throw Exception('خطأ في الصلاحيات: لا يمكن الوصول إلى المنجزات');
                case 'failed-precondition':
                  throw Exception('خطأ في الفهرسة: تحتاج إلى إنشاء فهرس مركب في Firestore');
                case 'unavailable':
                  throw Exception('خدمة قاعدة البيانات غير متوفرة حالياً');
                default:
                  throw Exception('خطأ في جلب المنجزات: ${error.message}');
              }
            }
            throw Exception('خطأ غير متوقع في جلب المنجزات: $error');
          })
          .map((snapshot) {
        print('Retrieved ${snapshot.docs.length} achievements');
        return snapshot.docs.map((doc) {
          try {
            return Achievement.fromMap(doc.data(), doc.id);
          } catch (e) {
            print('Error parsing achievement ${doc.id}: $e');
            rethrow;
          }
        }).toList();
      });
    } catch (e) {
      print('خطأ في جلب المنجزات: $e');
      return Stream.error(e);
    }
  }

  // Get achievements by status for current user
  Stream<List<Achievement>> getUserAchievementsByStatus(String status) {
    if (_currentUserId == null) {
      print('Warning: getUserAchievementsByStatus called with null user ID');
      return Stream.value([]);
    }

    try {
      _logDebugInfo('GET_USER_ACHIEVEMENTS_BY_STATUS');
      print('Querying achievements for user: $_currentUserId, status: $status');

      return _firestore
          .collection(_collection)
          .where('userId', isEqualTo: _currentUserId)
          .where('status', isEqualTo: status)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .handleError((error) {
            print('Stream error in getUserAchievementsByStatus: $error');
            if (error is FirebaseException) {
              switch (error.code) {
                case 'permission-denied':
                  throw Exception('خطأ في الصلاحيات: لا يمكن الوصول إلى المنجزات');
                case 'failed-precondition':
                  throw Exception('خطأ في الفهرسة: تحتاج إلى إنشاء فهرس مركب في Firestore');
                default:
                  throw Exception('خطأ في جلب المنجزات: ${error.message}');
              }
            }
            throw Exception('خطأ غير متوقع في جلب المنجزات: $error');
          })
          .map((snapshot) {
        print('Retrieved ${snapshot.docs.length} achievements with status: $status');
        return snapshot.docs.map((doc) {
          return Achievement.fromMap(doc.data(), doc.id);
        }).toList();
      });
    } catch (e) {
      print('خطأ في جلب المنجزات بالحالة: $e');
      return Stream.error(e);
    }
  }

  // Get achievements by department for current user
  Stream<List<Achievement>> getUserAchievementsByDepartment(String department) {
    if (_currentUserId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: _currentUserId)
        .where('executiveDepartment', isEqualTo: department)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Achievement.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // Get achievements by date range for current user
  Stream<List<Achievement>> getUserAchievementsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    if (_currentUserId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: _currentUserId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Achievement.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // Search achievements by topic or goal
  Future<List<Achievement>> searchUserAchievements(String searchTerm) async {
    if (_currentUserId == null) {
      return [];
    }

    try {
      // Note: Firestore doesn't support full-text search natively
      // This is a basic implementation - for better search, consider using Algolia or similar
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: _currentUserId)
          .get();

      final searchTermLower = searchTerm.toLowerCase();
      
      return snapshot.docs
          .map((doc) => Achievement.fromMap(doc.data(), doc.id))
          .where((achievement) {
            return achievement.topic.toLowerCase().contains(searchTermLower) ||
                   achievement.goal.toLowerCase().contains(searchTermLower) ||
                   achievement.participationType.toLowerCase().contains(searchTermLower);
          })
          .toList();
    } catch (e) {
      throw Exception('خطأ في البحث: $e');
    }
  }

  // Get achievements count by status for current user
  Future<Map<String, int>> getUserAchievementsCount() async {
    if (_currentUserId == null) {
      return {
        'total': 0,
        'pending': 0,
        'approved': 0,
        'rejected': 0,
      };
    }

    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: _currentUserId)
          .get();

      final achievements = snapshot.docs
          .map((doc) => Achievement.fromMap(doc.data(), doc.id))
          .toList();

      final pending = achievements.where((a) => a.status == 'pending').length;
      final approved = achievements.where((a) => a.status == 'approved').length;
      final rejected = achievements.where((a) => a.status == 'rejected').length;

      return {
        'total': achievements.length,
        'pending': pending,
        'approved': approved,
        'rejected': rejected,
      };
    } catch (e) {
      throw Exception('خطأ في جلب إحصائيات المنجزات: $e');
    }
  }

  // Update achievement status (admin function)
  Future<void> updateAchievementStatus(String achievementId, String status) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(achievementId)
          .update({
        'status': status,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('خطأ في تحديث حالة المنجز: $e');
    }
  }

  // Get all achievements (admin function)
  Stream<List<Achievement>> getAllAchievements() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Achievement.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // Get achievements by status (admin function)
  Stream<List<Achievement>> getAchievementsByStatus(String status) {
    return _firestore
        .collection(_collection)
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Achievement.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }
}
