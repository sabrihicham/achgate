/// User model for profile management
class UserProfile {
  final String id;
  final String fullName;
  final String employeeId;
  final String jobTitle;
  final String email;
  final String phoneNumber;
  final String profileImageUrl;
  final UserStatus status;
  final List<String> roles;
  final Department department;
  final DateTime createdAt;
  final DateTime lastUpdated;
  final DateTime lastLogin;

  const UserProfile({
    required this.id,
    required this.fullName,
    required this.employeeId,
    required this.jobTitle,
    required this.email,
    required this.phoneNumber,
    required this.profileImageUrl,
    required this.status,
    required this.roles,
    required this.department,
    required this.createdAt,
    required this.lastUpdated,
    required this.lastLogin,
  });

  // Create a copy with updated fields
  UserProfile copyWith({
    String? id,
    String? fullName,
    String? employeeId,
    String? jobTitle,
    String? email,
    String? phoneNumber,
    String? profileImageUrl,
    UserStatus? status,
    List<String>? roles,
    Department? department,
    DateTime? createdAt,
    DateTime? lastUpdated,
    DateTime? lastLogin,
  }) {
    return UserProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      employeeId: employeeId ?? this.employeeId,
      jobTitle: jobTitle ?? this.jobTitle,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      status: status ?? this.status,
      roles: roles ?? this.roles,
      department: department ?? this.department,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'employeeId': employeeId,
      'jobTitle': jobTitle,
      'email': email,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'status': status.name,
      'roles': roles,
      'department': department.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
      'lastLogin': lastLogin.toIso8601String(),
    };
  }

  // Create from JSON
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      fullName: json['fullName'],
      employeeId: json['employeeId'],
      jobTitle: json['jobTitle'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      profileImageUrl: json['profileImageUrl'],
      status: UserStatus.values.firstWhere((e) => e.name == json['status']),
      roles: List<String>.from(json['roles']),
      department: Department.fromJson(json['department']),
      createdAt: DateTime.parse(json['createdAt']),
      lastUpdated: DateTime.parse(json['lastUpdated']),
      lastLogin: DateTime.parse(json['lastLogin']),
    );
  }

  // Sample user for demo
  static UserProfile get sampleUser => UserProfile(
    id: 'user_001',
    fullName: 'أحمد محمد علي السلمي',
    employeeId: 'EMP001234',
    jobTitle: 'مطور تطبيقات',
    email: 'ahmed.ali@jchc.gov.sa',
    phoneNumber: '+966 50 123 4567',
    profileImageUrl: '',
    status: UserStatus.active,
    roles: ['مستخدم', 'مشرف'],
    department: Department.sampleDepartment,
    createdAt: DateTime(2024, 10, 15),
    lastUpdated: DateTime(2025, 8, 2),
    lastLogin: DateTime(2025, 8, 2, 10, 30),
  );
}

/// User status enumeration
enum UserStatus {
  active('نشط'),
  inactive('غير نشط'),
  suspended('معلق'),
  pending('معلقة');

  const UserStatus(this.displayName);
  final String displayName;
}

/// Department model
class Department {
  final String id;
  final String executiveDepartment;
  final String mainDepartment;
  final String subDepartment;

  const Department({
    required this.id,
    required this.executiveDepartment,
    required this.mainDepartment,
    required this.subDepartment,
  });

  // Create a copy with updated fields
  Department copyWith({
    String? id,
    String? executiveDepartment,
    String? mainDepartment,
    String? subDepartment,
  }) {
    return Department(
      id: id ?? this.id,
      executiveDepartment: executiveDepartment ?? this.executiveDepartment,
      mainDepartment: mainDepartment ?? this.mainDepartment,
      subDepartment: subDepartment ?? this.subDepartment,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'executiveDepartment': executiveDepartment,
      'mainDepartment': mainDepartment,
      'subDepartment': subDepartment,
    };
  }

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'],
      executiveDepartment: json['executiveDepartment'],
      mainDepartment: json['mainDepartment'],
      subDepartment: json['subDepartment'],
    );
  }

  static Department get sampleDepartment => const Department(
    id: 'dept_001',
    executiveDepartment: 'الإدارة التنفيذية لتقنية المعلومات',
    mainDepartment: 'إدارة تطوير الأنظمة',
    subDepartment: 'قسم تطوير التطبيقات',
  );
}
