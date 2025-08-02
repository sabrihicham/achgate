import 'package:cloud_firestore/cloud_firestore.dart';

class Achievement {
  final String? id;
  final String participationType;
  final String executiveDepartment;
  final String mainDepartment;
  final String subDepartment;
  final String topic;
  final String goal;
  final DateTime date;
  final String location;
  final String duration;
  final String impact;
  final List<String> attachments;
  final String userId; // To associate with the user who created it
  final DateTime createdAt;
  final DateTime updatedAt;
  final String status; // pending, approved, rejected
  final String? reviewedBy; // ID of admin who reviewed
  final DateTime? reviewedAt; // When it was reviewed
  final String? reviewNotes; // Review notes

  Achievement({
    this.id,
    required this.participationType,
    required this.executiveDepartment,
    required this.mainDepartment,
    required this.subDepartment,
    required this.topic,
    required this.goal,
    required this.date,
    required this.location,
    required this.duration,
    required this.impact,
    required this.attachments,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.status = 'pending',
    this.reviewedBy,
    this.reviewedAt,
    this.reviewNotes,
  });

  // Convert Achievement to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'participationType': participationType,
      'executiveDepartment': executiveDepartment,
      'mainDepartment': mainDepartment,
      'subDepartment': subDepartment,
      'topic': topic,
      'goal': goal,
      'date': Timestamp.fromDate(date),
      'location': location,
      'duration': duration,
      'impact': impact,
      'attachments': attachments,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'status': status,
      'reviewedBy': reviewedBy,
      'reviewedAt': reviewedAt != null ? Timestamp.fromDate(reviewedAt!) : null,
      'reviewNotes': reviewNotes,
    };
  }

  // Create Achievement from Firestore document
  factory Achievement.fromMap(Map<String, dynamic> map, String id) {
    return Achievement(
      id: id,
      participationType: map['participationType'] ?? '',
      executiveDepartment: map['executiveDepartment'] ?? '',
      mainDepartment: map['mainDepartment'] ?? '',
      subDepartment: map['subDepartment'] ?? '',
      topic: map['topic'] ?? '',
      goal: map['goal'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      location: map['location'] ?? '',
      duration: map['duration'] ?? '',
      impact: map['impact'] ?? '',
      attachments: List<String>.from(map['attachments'] ?? []),
      userId: map['userId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      status: map['status'] ?? 'pending',
      reviewedBy: map['reviewedBy'],
      reviewedAt: map['reviewedAt'] != null
          ? (map['reviewedAt'] as Timestamp).toDate()
          : null,
      reviewNotes: map['reviewNotes'],
    );
  }

  // Create a copy with updated fields
  Achievement copyWith({
    String? id,
    String? participationType,
    String? executiveDepartment,
    String? mainDepartment,
    String? subDepartment,
    String? topic,
    String? goal,
    DateTime? date,
    String? location,
    String? duration,
    String? impact,
    List<String>? attachments,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? status,
    String? reviewedBy,
    DateTime? reviewedAt,
    String? reviewNotes,
  }) {
    return Achievement(
      id: id ?? this.id,
      participationType: participationType ?? this.participationType,
      executiveDepartment: executiveDepartment ?? this.executiveDepartment,
      mainDepartment: mainDepartment ?? this.mainDepartment,
      subDepartment: subDepartment ?? this.subDepartment,
      topic: topic ?? this.topic,
      goal: goal ?? this.goal,
      date: date ?? this.date,
      location: location ?? this.location,
      duration: duration ?? this.duration,
      impact: impact ?? this.impact,
      attachments: attachments ?? this.attachments,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewNotes: reviewNotes ?? this.reviewNotes,
    );
  }

  @override
  String toString() {
    return 'Achievement(id: $id, participationType: $participationType, topic: $topic, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Achievement &&
        other.id == id &&
        other.participationType == participationType &&
        other.executiveDepartment == executiveDepartment &&
        other.mainDepartment == mainDepartment &&
        other.subDepartment == subDepartment &&
        other.topic == topic &&
        other.goal == goal &&
        other.date == date &&
        other.location == location &&
        other.duration == duration &&
        other.impact == impact &&
        other.userId == userId &&
        other.status == status;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        participationType.hashCode ^
        executiveDepartment.hashCode ^
        mainDepartment.hashCode ^
        subDepartment.hashCode ^
        topic.hashCode ^
        goal.hashCode ^
        date.hashCode ^
        location.hashCode ^
        duration.hashCode ^
        impact.hashCode ^
        userId.hashCode ^
        status.hashCode;
  }
}
