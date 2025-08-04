import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';

class UserProfileService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _collection = 'users';

  // Get current user profile
  static Future<UserProfile?> getCurrentUserProfile() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        // Return sample user for demo purposes
        return UserProfile.sampleUser;
      }

      final DocumentSnapshot doc = await _firestore
          .collection(_collection)
          .doc(currentUser.uid)
          .get();

      if (doc.exists) {
        return UserProfileFirestore.fromFirestore(doc);
      }

      // If profile doesn't exist, create a basic one
      return await _createBasicProfile(currentUser);
    } catch (e) {
      print('Error getting user profile: $e');
      // Return sample user for demo purposes
      return UserProfile.sampleUser;
    }
  }

  // Create basic profile for new user
  static Future<UserProfile> _createBasicProfile(User user) async {
    final basicProfile = UserProfile(
      id: user.uid,
      fullName: user.displayName ?? 'مستخدم جديد',
      employeeId: 'EMP${DateTime.now().millisecondsSinceEpoch}',
      jobTitle: 'غير محدد',
      email: user.email ?? '',
      phoneNumber: user.phoneNumber ?? '',
      profileImageUrl: user.photoURL ?? '',
      status: UserStatus.active,
      roles: ['مستخدم'],
      department: Department.sampleDepartment,
      createdAt: DateTime.now(),
      lastUpdated: DateTime.now(),
      lastLogin: DateTime.now(),
    );

    try {
      await _firestore
          .collection(_collection)
          .doc(user.uid)
          .set(basicProfile.toFirestore());
    } catch (e) {
      print('Error creating basic profile: $e');
    }

    return basicProfile;
  }

  // Update user profile
  static Future<bool> updateUserProfile(UserProfile profile) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      final updatedProfile = profile.copyWith(lastUpdated: DateTime.now());

      await _firestore
          .collection(_collection)
          .doc(currentUser.uid)
          .update(updatedProfile.toFirestore());

      return true;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }

  // Delete user account
  static Future<bool> deleteUserAccount() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      // Delete Firestore document
      await _firestore.collection(_collection).doc(currentUser.uid).delete();

      // Delete Firebase Auth account
      await currentUser.delete();

      return true;
    } catch (e) {
      print('Error deleting user account: $e');
      return false;
    }
  }

  // Change password
  static Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: currentUser.email!,
        password: currentPassword,
      );

      await currentUser.reauthenticateWithCredential(credential);

      // Update password
      await currentUser.updatePassword(newPassword);

      return true;
    } catch (e) {
      print('Error changing password: $e');
      return false;
    }
  }

  // Export user data
  static Future<Map<String, dynamic>?> exportUserData() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return null;

      final DocumentSnapshot doc = await _firestore
          .collection(_collection)
          .doc(currentUser.uid)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['exportedAt'] = DateTime.now().toIso8601String();
        return data;
      }

      return null;
    } catch (e) {
      print('Error exporting user data: $e');
      return null;
    }
  }

  // Update profile image URL
  static Future<bool> updateProfileImage(String imageUrl) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      await _firestore.collection(_collection).doc(currentUser.uid).update({
        'profileImageUrl': imageUrl,
        'lastUpdated': Timestamp.fromDate(DateTime.now()),
      });

      return true;
    } catch (e) {
      print('Error updating profile image: $e');
      return false;
    }
  }
}

// Extension to add Firestore methods to UserProfile
extension UserProfileFirestore on UserProfile {
  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'fullName': fullName,
      'employeeId': employeeId,
      'jobTitle': jobTitle,
      'email': email,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'status': status.name,
      'roles': roles,
      'department': department.toJson(),
      'createdAt': Timestamp.fromDate(createdAt),
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'lastLogin': Timestamp.fromDate(lastLogin),
    };
  }

  // Convert from Firestore document
  static UserProfile fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return UserProfile(
      id: doc.id,
      fullName: data['fullName'] ?? '',
      employeeId: data['employeeId'] ?? '',
      jobTitle: data['jobTitle'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      profileImageUrl: data['profileImageUrl'] ?? '',
      status: _getStatusFromString(data['status'] ?? 'active'),
      roles: List<String>.from(data['roles'] ?? ['مستخدم']),
      department: data['department'] != null
          ? Department.fromJson(data['department'])
          : Department.sampleDepartment,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastUpdated:
          (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLogin: (data['lastLogin'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  static UserStatus _getStatusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return UserStatus.active;
      case 'inactive':
        return UserStatus.inactive;
      case 'suspended':
        return UserStatus.suspended;
      case 'pending':
        return UserStatus.pending;
      default:
        return UserStatus.active;
    }
  }
}
