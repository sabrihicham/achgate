import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DebugService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Check current authentication status
  Future<Map<String, dynamic>> checkAuthStatus() async {
    final user = _auth.currentUser;
    return {
      'isAuthenticated': user != null,
      'uid': user?.uid,
      'email': user?.email,
      'emailVerified': user?.emailVerified,
      'isAnonymous': user?.isAnonymous,
      'providerData': user?.providerData.map((p) => {
        'providerId': p.providerId,
        'uid': p.uid,
        'email': p.email,
      }).toList(),
    };
  }

  // Test basic Firestore read permissions
  Future<Map<String, dynamic>> testFirestorePermissions() async {
    final user = _auth.currentUser;
    final results = <String, dynamic>{};
    
    if (user == null) {
      return {'error': 'User not authenticated'};
    }

    try {
      // Test reading achievements collection with user filter
      print('Testing achievements read permission...');
      final achievementsQuery = await _firestore
          .collection('achievements')
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get();
      
      results['achievements_read'] = {
        'success': true,
        'count': achievementsQuery.docs.length,
        'message': 'Can read achievements collection'
      };
    } catch (e) {
      results['achievements_read'] = {
        'success': false,
        'error': e.toString(),
        'message': 'Cannot read achievements collection'
      };
    }

    try {
      // Test reading departments collection
      print('Testing departments read permission...');
      final departmentsQuery = await _firestore
          .collection('departments')
          .limit(1)
          .get();
      
      results['departments_read'] = {
        'success': true,
        'count': departmentsQuery.docs.length,
        'message': 'Can read departments collection'
      };
    } catch (e) {
      results['departments_read'] = {
        'success': false,
        'error': e.toString(),
        'message': 'Cannot read departments collection'
      };
    }

    try {
      // Test creating a test achievement document
      print('Testing achievement creation permission...');
      final testData = {
        'participationType': 'test',
        'executiveDepartment': 'test',
        'mainDepartment': 'test',
        'subDepartment': 'test',
        'topic': 'Test Achievement',
        'goal': 'Testing permissions',
        'date': Timestamp.now(),
        'location': 'Test Location',
        'duration': '1 hour',
        'impact': 'Testing impact',
        'attachments': <String>[],
        'userId': user.uid,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
        'status': 'pending',
      };

      final docRef = await _firestore
          .collection('achievements')
          .add(testData);
      
      // Clean up test document
      await docRef.delete();
      
      results['achievements_create'] = {
        'success': true,
        'message': 'Can create and delete achievements'
      };
    } catch (e) {
      results['achievements_create'] = {
        'success': false,
        'error': e.toString(),
        'message': 'Cannot create achievements'
      };
    }

    try {
      // Test reading users collection
      print('Testing users read permission...');
      final userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();
      
      results['users_read'] = {
        'success': true,
        'exists': userDoc.exists,
        'message': 'Can read user document'
      };
    } catch (e) {
      results['users_read'] = {
        'success': false,
        'error': e.toString(),
        'message': 'Cannot read user document'
      };
    }

    return results;
  }

  // Test specific query that might be failing
  Future<Map<String, dynamic>> testSpecificQuery() async {
    final user = _auth.currentUser;
    if (user == null) {
      return {'error': 'User not authenticated'};
    }

    try {
      print('Testing getUserAchievements query...');
      final stream = _firestore
          .collection('achievements')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .limit(5)
          .snapshots();

      // Wait for first emission
      final snapshot = await stream.first;
      
      return {
        'success': true,
        'count': snapshot.docs.length,
        'message': 'getUserAchievements query successful',
        'documents': snapshot.docs.map((doc) => {
          'id': doc.id,
          'data': doc.data(),
        }).toList(),
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'getUserAchievements query failed'
      };
    }
  }

  // Print comprehensive debug information
  Future<void> printDebugInfo() async {
    print('=== FIRESTORE DEBUG INFORMATION ===');
    
    final authStatus = await checkAuthStatus();
    print('Auth Status: $authStatus');
    
    final permissions = await testFirestorePermissions();
    print('Permissions Test: $permissions');
    
    final queryTest = await testSpecificQuery();
    print('Query Test: $queryTest');
    
    print('=== END DEBUG INFORMATION ===');
  }
}
