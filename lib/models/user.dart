import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String email;
  final String? displayName;
  final String? fullName;
  final String? phoneNumber;
  final String? departmentId;
  final String? department; // الإدارة التنفيذية
  final String? mainDepartment; // الإدارة الرئيسية
  final String? subDepartment; // الإدارة الفرعية
  final String? jobTitle;
  final String? employeeId;
  final bool isActive;
  final bool isEmailVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLoginAt;
  final List<String> roles;
  final Map<String, dynamic>? metadata;

  AppUser({
    required this.id,
    required this.email,
    this.displayName,
    this.fullName,
    this.phoneNumber,
    this.departmentId,
    this.department,
    this.mainDepartment,
    this.subDepartment,
    this.jobTitle,
    this.employeeId,
    this.isActive = true,
    this.isEmailVerified = false,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
    this.roles = const ['user'],
    this.metadata,
  });

  // Convert AppUser to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'departmentId': departmentId,
      'department': department,
      'mainDepartment': mainDepartment,
      'subDepartment': subDepartment,
      'jobTitle': jobTitle,
      'employeeId': employeeId,
      'isActive': isActive,
      'isEmailVerified': isEmailVerified,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'lastLoginAt': lastLoginAt != null
          ? Timestamp.fromDate(lastLoginAt!)
          : null,
      'roles': roles,
      'metadata': metadata,
    };
  }

  // Create AppUser from Firestore document
  factory AppUser.fromMap(Map<String, dynamic> map, String id) {
    return AppUser(
      id: id,
      email: map['email'] ?? '',
      displayName: map['displayName'],
      fullName: map['fullName'],
      phoneNumber: map['phoneNumber'],
      departmentId: map['departmentId'],
      department: map['department'],
      mainDepartment: map['mainDepartment'],
      subDepartment: map['subDepartment'],
      jobTitle: map['jobTitle'],
      employeeId: map['employeeId'],
      isActive: map['isActive'] ?? true,
      isEmailVerified: map['isEmailVerified'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLoginAt: (map['lastLoginAt'] as Timestamp?)?.toDate(),
      roles: List<String>.from(map['roles'] ?? ['user']),
      metadata: map['metadata'],
    );
  }

  // Create a copy with updated fields
  AppUser copyWith({
    String? id,
    String? email,
    String? displayName,
    String? fullName,
    String? phoneNumber,
    String? departmentId,
    String? department,
    String? mainDepartment,
    String? subDepartment,
    String? jobTitle,
    String? employeeId,
    bool? isActive,
    bool? isEmailVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    List<String>? roles,
    Map<String, dynamic>? metadata,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      departmentId: departmentId ?? this.departmentId,
      department: department ?? this.department,
      mainDepartment: mainDepartment ?? this.mainDepartment,
      subDepartment: subDepartment ?? this.subDepartment,
      jobTitle: jobTitle ?? this.jobTitle,
      employeeId: employeeId ?? this.employeeId,
      isActive: isActive ?? this.isActive,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      roles: roles ?? this.roles,
      metadata: metadata ?? this.metadata,
    );
  }

  // Get user display name with fallback
  String get name => fullName ?? displayName ?? email.split('@').first;

  // Check if user has specific role
  bool hasRole(String role) => roles.contains(role);

  // Check if user is admin
  bool get isAdmin => roles.contains('admin') || roles.contains('super_admin');

  @override
  String toString() {
    return 'AppUser(id: $id, email: $email, fullName: $fullName, isActive: $isActive)';
  }
}
