import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/admin_service.dart';
import 'services/achievement_service.dart';

/// Debug utility to test admin permissions and troubleshoot access issues
class AdminPermissionsDebugger {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AdminService _adminService = AdminService();
  final AchievementService _achievementService = AchievementService();

  /// Test admin permissions and create debug report
  Future<void> debugAdminPermissions() async {
    print('🔍 === ADMIN PERMISSIONS DEBUG REPORT ===');

    // Check authentication
    final user = _auth.currentUser;
    print('👤 User Authentication:');
    print('   - Logged in: ${user != null}');
    print('   - User ID: ${user?.uid}');
    print('   - Email: ${user?.email}');
    print('   - Email verified: ${user?.emailVerified}');
    print('');

    if (user == null) {
      print('❌ User not authenticated. Please log in first.');
      return;
    }

    // Check admin document
    print('🔧 Admin Document Check:');
    try {
      final adminDoc = await _firestore
          .collection('admin_users')
          .doc(user.uid)
          .get();

      print('   - Admin document exists: ${adminDoc.exists}');
      if (adminDoc.exists) {
        final data = adminDoc.data()!;
        print('   - isActive: ${data['isActive']}');
        print('   - role: ${data['role'] ?? 'Not set'}');
        print('   - permissions: ${data['permissions'] ?? 'Not set'}');
        print('   - createdAt: ${data['createdAt']}');
      } else {
        print('   - Creating admin document...');
        await _createAdminDocument(user.uid);
        print('   ✅ Admin document created successfully');
      }
    } catch (e) {
      print('   ❌ Error checking admin document: $e');
    }
    print('');

    // Test admin service
    print('🎯 Admin Service Check:');
    try {
      final isAdmin = await _adminService.isCurrentUserAdmin();
      print('   - isCurrentUserAdmin(): $isAdmin');
    } catch (e) {
      print('   ❌ Error checking admin status: $e');
    }
    print('');

    // Test achievements access
    print('📊 Achievements Access Test:');
    try {
      print('   - Testing user achievements...');
      final userAchievements = await _achievementService
          .getUserAchievements()
          .first;
      print('   ✅ User achievements: ${userAchievements.length} found');
    } catch (e) {
      print('   ❌ Error accessing user achievements: $e');
    }

    try {
      print('   - Testing admin achievements access...');
      final allAchievements = await _adminService.getAllAchievements().first;
      print('   ✅ Admin achievements: ${allAchievements.length} found');
    } catch (e) {
      print('   ❌ Error accessing admin achievements: $e');
    }
    print('');

    // Test Firestore rules
    print('🛡️ Firestore Rules Test:');
    try {
      print('   - Testing read permission on achievements collection...');
      final testQuery = await _firestore
          .collection('achievements')
          .limit(1)
          .get();
      print('   ✅ Basic read access: ${testQuery.docs.length} documents');
    } catch (e) {
      print('   ❌ Basic read access failed: $e');
    }

    try {
      print('   - Testing orderBy query...');
      final orderByQuery = await _firestore
          .collection('achievements')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();
      print('   ✅ OrderBy query: ${orderByQuery.docs.length} documents');
    } catch (e) {
      print('   ❌ OrderBy query failed: $e');
    }
    print('');

    print('✅ === DEBUG REPORT COMPLETE ===');
  }

  /// Force create admin document for current user
  Future<void> _createAdminDocument(String userId) async {
    try {
      await _firestore.collection('admin_users').doc(userId).set({
        'isActive': true,
        'role': 'admin',
        'permissions': [
          'read_all_achievements',
          'manage_achievements',
          'manage_users',
        ],
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': 'auto_setup',
      });
    } catch (e) {
      print('❌ Failed to create admin document: $e');
      rethrow;
    }
  }

  /// Fix common permission issues
  Future<void> fixPermissionIssues() async {
    print('🔧 === FIXING PERMISSION ISSUES ===');

    final user = _auth.currentUser;
    if (user == null) {
      print('❌ No user logged in');
      return;
    }

    print('1. Ensuring admin document exists...');
    try {
      await _createAdminDocument(user.uid);
      print('   ✅ Admin document created/updated');
    } catch (e) {
      print('   ❌ Failed to create admin document: $e');
    }

    print('2. Testing admin access...');
    try {
      final isAdmin = await _adminService.isCurrentUserAdmin();
      print('   ✅ Admin status: $isAdmin');
    } catch (e) {
      print('   ❌ Admin check failed: $e');
    }

    print('✅ === PERMISSION FIX COMPLETE ===');
  }
}
