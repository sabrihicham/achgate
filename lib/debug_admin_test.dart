import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'services/admin_service.dart';

class DebugAdminTest extends StatefulWidget {
  const DebugAdminTest({Key? key}) : super(key: key);

  @override
  State<DebugAdminTest> createState() => _DebugAdminTestState();
}

class _DebugAdminTestState extends State<DebugAdminTest> {
  final AdminService _adminService = AdminService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isTestingPermissions = false;
  String _testResults = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اختبار صلاحيات المدير')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'معلومات المستخدم الحالي',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('المعرف: ${_auth.currentUser?.uid ?? 'غير متوفر'}'),
                    Text('البريد: ${_auth.currentUser?.email ?? 'غير متوفر'}'),
                    Text('مصادق: ${_auth.currentUser != null ? 'نعم' : 'لا'}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isTestingPermissions ? null : _testAdminPermissions,
              child: _isTestingPermissions
                  ? const CircularProgressIndicator()
                  : const Text('اختبار صلاحيات المدير'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _createAdminDocument,
              child: const Text('إنشاء مستند مدير'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _testAchievementsAccess,
              child: const Text('اختبار الوصول للمنجزات'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _testResults.isEmpty
                        ? 'نتائج الاختبار ستظهر هنا...'
                        : _testResults,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testAdminPermissions() async {
    setState(() {
      _isTestingPermissions = true;
      _testResults = 'بدء اختبار الصلاحيات...\n';
    });

    try {
      // Test 1: Check current user
      final user = _auth.currentUser;
      _addResult('✅ المستخدم الحالي: ${user?.uid}');
      _addResult('✅ البريد الإلكتروني: ${user?.email}');

      // Test 2: Check admin status
      _addResult('\n🔍 فحص حالة المدير...');
      final isAdmin = await _adminService.isCurrentUserAdmin();
      _addResult('📊 نتيجة فحص المدير: $isAdmin');

      // Test 3: Check admin document
      if (user != null) {
        _addResult('\n📄 فحص مستند المدير...');
        final adminDoc = await _firestore
            .collection('admin_users')
            .doc(user.uid)
            .get();

        _addResult('📋 المستند موجود: ${adminDoc.exists}');
        if (adminDoc.exists) {
          final data = adminDoc.data();
          _addResult('📋 بيانات المستند: $data');
        }
      }

      // Test 4: Test statistics access
      _addResult('\n📈 اختبار الوصول للإحصائيات...');
      try {
        final stats = await _adminService.getUsersStatistics();
        _addResult('✅ الإحصائيات: $stats');
      } catch (e) {
        _addResult('❌ خطأ في الإحصائيات: $e');
      }

      _addResult('\n✅ انتهى الاختبار');
    } catch (e) {
      _addResult('❌ خطأ في الاختبار: $e');
    } finally {
      setState(() {
        _isTestingPermissions = false;
      });
    }
  }

  Future<void> _createAdminDocument() async {
    final user = _auth.currentUser;
    if (user == null) {
      _addResult('❌ لا يوجد مستخدم مسجل دخول');
      return;
    }

    try {
      _addResult('\n🔧 إنشاء مستند مدير...');
      await _firestore.collection('admin_users').doc(user.uid).set({
        'isActive': true,
        'role': 'admin',
        'permissions': [
          'read_achievements',
          'write_achievements',
          'manage_users',
          'view_statistics',
        ],
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': 'debug-tool',
        'email': user.email,
      });
      _addResult('✅ تم إنشاء مستند المدير بنجاح');
    } catch (e) {
      _addResult('❌ خطأ في إنشاء مستند المدير: $e');
    }
  }

  Future<void> _testAchievementsAccess() async {
    _addResult('\n🎯 اختبار الوصول للمنجزات...');

    try {
      final achievementsStream = _adminService.getAllAchievements();
      final achievements = await achievementsStream.first.timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('انتهت مهلة الانتظار'),
      );

      _addResult('✅ تم جلب ${achievements.length} منجز');
      if (achievements.isNotEmpty) {
        _addResult('📝 أول منجز: ${achievements.first.topic}');
      }
    } catch (e) {
      _addResult('❌ خطأ في الوصول للمنجزات: $e');

      // Try direct Firestore access
      _addResult('\n🔄 محاولة الوصول المباشر...');
      try {
        final directSnapshot = await _firestore
            .collection('achievements')
            .limit(1)
            .get();
        _addResult('✅ الوصول المباشر: ${directSnapshot.docs.length} منجز');
      } catch (directError) {
        _addResult('❌ خطأ في الوصول المباشر: $directError');
      }
    }
  }

  void _addResult(String result) {
    setState(() {
      _testResults += '$result\n';
    });
  }
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => message;
}
