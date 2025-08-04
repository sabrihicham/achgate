import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';

class UserManagementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _usersCollection = 'users';

  // Get all users with pagination
  Stream<List<AppUser>> getAllUsers({int? limit}) {
    Query query = _firestore
        .collection(_usersCollection)
        .orderBy('createdAt', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) {
            try {
              final data = doc.data() as Map<String, dynamic>;
              return AppUser.fromMap(data, doc.id);
            } catch (e) {
              print('Error converting document ${doc.id}: $e');
              return null;
            }
          })
          .where((user) => user != null)
          .cast<AppUser>()
          .toList(),
    );
  }

  // Get user by ID
  Future<AppUser?> getUserById(String userId) async {
    try {
      final doc = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data();
        if (data is Map<String, dynamic>) {
          return AppUser.fromMap(data, doc.id);
        } else {
          print('Document data is not Map<String, dynamic>: $data');
          return null;
        }
      }
      return null;
    } catch (e) {
      print('Error getting user by ID: $e');
      return null;
    }
  }

  // Get user by email
  Future<AppUser?> getUserByEmail(String email) async {
    try {
      final querySnapshot = await _firestore
          .collection(_usersCollection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final data = doc.data();
        return AppUser.fromMap(data, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting user by email: $e');
      return null;
    }
  }

  // Create new user
  Future<void> createUser(AppUser user) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(user.id)
          .set(user.toMap());
    } catch (e) {
      throw Exception('فشل في إنشاء المستخدم: $e');
    }
  }

  // Update user
  Future<void> updateUser(AppUser user) async {
    try {
      final updateData = user.toMap();
      updateData['updatedAt'] = Timestamp.now();

      await _firestore
          .collection(_usersCollection)
          .doc(user.id)
          .update(updateData);
    } catch (e) {
      throw Exception('فشل في تحديث المستخدم: $e');
    }
  }

  // Delete user
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection(_usersCollection).doc(userId).delete();
    } catch (e) {
      throw Exception('فشل في حذف المستخدم: $e');
    }
  }

  // Update user status (activate/deactivate)
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

  // Add role to user
  Future<void> addRoleToUser(String userId, String role) async {
    try {
      final user = await getUserById(userId);
      if (user != null) {
        final updatedRoles = List<String>.from(user.roles);
        if (!updatedRoles.contains(role)) {
          updatedRoles.add(role);
          await _firestore.collection(_usersCollection).doc(userId).update({
            'roles': updatedRoles,
            'updatedAt': Timestamp.now(),
          });
        }
      }
    } catch (e) {
      throw Exception('فشل في إضافة الدور: $e');
    }
  }

  // Remove role from user
  Future<void> removeRoleFromUser(String userId, String role) async {
    try {
      final user = await getUserById(userId);
      if (user != null) {
        final updatedRoles = List<String>.from(user.roles);
        updatedRoles.remove(role);
        if (updatedRoles.isEmpty) {
          updatedRoles.add('user'); // Ensure at least one role
        }
        await _firestore.collection(_usersCollection).doc(userId).update({
          'roles': updatedRoles,
          'updatedAt': Timestamp.now(),
        });
      }
    } catch (e) {
      throw Exception('فشل في إزالة الدور: $e');
    }
  }

  // Search users
  Stream<List<AppUser>> searchUsers(String query) {
    if (query.isEmpty) {
      return getAllUsers();
    }

    return _firestore
        .collection(_usersCollection)
        .orderBy('email')
        .startAt([query.toLowerCase()])
        .endAt([query.toLowerCase() + '\uf8ff'])
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) {
                try {
                  final data = doc.data();
                  return AppUser.fromMap(data, doc.id);
                } catch (e) {
                  print('Error converting document ${doc.id}: $e');
                  return null;
                }
              })
              .where((user) => user != null)
              .cast<AppUser>()
              .toList(),
        );
  }

  // Filter users by role
  Stream<List<AppUser>> getUsersByRole(String role) {
    return _firestore
        .collection(_usersCollection)
        .where('roles', arrayContains: role)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) {
                try {
                  final data = doc.data();
                  return AppUser.fromMap(data, doc.id);
                } catch (e) {
                  print('Error converting document ${doc.id}: $e');
                  return null;
                }
              })
              .where((user) => user != null)
              .cast<AppUser>()
              .toList(),
        );
  }

  // Filter users by department
  Stream<List<AppUser>> getUsersByDepartment(String department) {
    return _firestore
        .collection(_usersCollection)
        .where('department', isEqualTo: department)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) {
                try {
                  final data = doc.data();
                  return AppUser.fromMap(data, doc.id);
                } catch (e) {
                  print('Error converting document ${doc.id}: $e');
                  return null;
                }
              })
              .where((user) => user != null)
              .cast<AppUser>()
              .toList(),
        );
  }

  // Filter users by status
  Stream<List<AppUser>> getUsersByStatus(bool isActive) {
    return _firestore
        .collection(_usersCollection)
        .where('isActive', isEqualTo: isActive)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) {
                try {
                  final data = doc.data();
                  return AppUser.fromMap(data, doc.id);
                } catch (e) {
                  print('Error converting document ${doc.id}: $e');
                  return null;
                }
              })
              .where((user) => user != null)
              .cast<AppUser>()
              .toList(),
        );
  }

  // Get users statistics
  Future<Map<String, int>> getUsersStatistics() async {
    try {
      final allUsers = await _firestore.collection(_usersCollection).get();

      int totalUsers = allUsers.size;
      int activeUsers = 0;
      int adminUsers = 0;
      int inactiveUsers = 0;

      for (final doc in allUsers.docs) {
        try {
          final data = doc.data();
          final isActive = data['isActive'] ?? true;
          final roles = List<String>.from(data['roles'] ?? ['user']);

          if (isActive) {
            activeUsers++;
          } else {
            inactiveUsers++;
          }

          if (roles.contains('admin') || roles.contains('manager')) {
            adminUsers++;
          }
        } catch (e) {
          print('Error processing user statistics for doc ${doc.id}: $e');
          continue;
        }
      }

      return {
        'total': totalUsers,
        'active': activeUsers,
        'inactive': inactiveUsers,
        'admins': adminUsers,
      };
    } catch (e) {
      print('Error getting user statistics: $e');
      return {'total': 0, 'active': 0, 'inactive': 0, 'admins': 0};
    }
  }

  // Reset user password
  Future<void> resetUserPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('فشل في إرسال رابط إعادة تعيين كلمة المرور: $e');
    }
  }

  // Create user with email and password
  Future<String> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
    String? department,
    String? mainDepartment,
    String? subDepartment,
    String? jobTitle,
    String? employeeId,
    List<String> roles = const ['user'],
  }) async {
    try {
      // Create user in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('فشل في إنشاء الحساب');
      }

      // Update display name
      await user.updateDisplayName(fullName);

      // Create user document in Firestore
      final appUser = AppUser(
        id: user.uid,
        email: email,
        displayName: fullName,
        fullName: fullName,
        phoneNumber: phoneNumber,
        department: department,
        mainDepartment: mainDepartment,
        subDepartment: subDepartment,
        jobTitle: jobTitle,
        employeeId: employeeId,
        isActive: true,
        isEmailVerified: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        roles: roles,
      );

      await createUser(appUser);

      return user.uid;
    } catch (e) {
      throw Exception('فشل في إنشاء المستخدم: $e');
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String userId,
    String? fullName,
    String? phoneNumber,
    String? department,
    String? mainDepartment,
    String? subDepartment,
    String? jobTitle,
    String? employeeId,
  }) async {
    try {
      final updateData = <String, dynamic>{'updatedAt': Timestamp.now()};

      if (fullName != null) updateData['fullName'] = fullName;
      if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;
      if (department != null) updateData['department'] = department;
      if (mainDepartment != null) updateData['mainDepartment'] = mainDepartment;
      if (subDepartment != null) updateData['subDepartment'] = subDepartment;
      if (jobTitle != null) updateData['jobTitle'] = jobTitle;
      if (employeeId != null) updateData['employeeId'] = employeeId;

      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .update(updateData);
    } catch (e) {
      throw Exception('فشل في تحديث الملف الشخصي: $e');
    }
  }
}
