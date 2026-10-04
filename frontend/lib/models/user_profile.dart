import 'package:cloud_firestore/cloud_firestore.dart';

/// User profile data model representing technicians and admins in MachineTrack.
class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String role;
  final String? shift;
  final DateTime? createdAt;

  const UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    this.role = 'technician',
    this.shift,
    this.createdAt,
  });

  bool get isAdmin => role.toLowerCase() == 'admin';

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  factory UserProfile.fromMap(Map<String, dynamic> map, {String uid = ''}) {
    return UserProfile(
      uid: uid.isNotEmpty ? uid : (map['uid']?.toString() ?? ''),
      name: map['name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      role: map['role']?.toString() ?? 'technician',
      shift: map['shift']?.toString(),
      createdAt: _parseDateTime(map['createdAt']),
    );
  }

  factory UserProfile.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    return UserProfile.fromMap(doc.data() ?? {}, uid: doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      if (shift != null) 'shift': shift,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  UserProfile copyWith({
    String? uid,
    String? name,
    String? email,
    String? role,
    String? shift,
    DateTime? createdAt,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      shift: shift ?? this.shift,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
