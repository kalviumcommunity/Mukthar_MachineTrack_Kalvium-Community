import 'package:cloud_firestore/cloud_firestore.dart';

/// Machine data model representing factory machine inventory in MachineTrack.
class Machine {
  final String id;
  final String name;
  final String code;
  final String location;
  final String status;
  final String? lastInspected;
  final DateTime? lastInspectedAt;
  final String? model;
  final String? serialNumber;
  final String? assignedTech;
  final String? installationDate;

  const Machine({
    required this.id,
    required this.name,
    required this.code,
    required this.location,
    this.status = 'Idle',
    this.lastInspected,
    this.lastInspectedAt,
    this.model,
    this.serialNumber,
    this.assignedTech,
    this.installationDate,
  });

  /// Formats a [DateTime] into a friendly relative time string (e.g. "25 mins ago").
  static String formatRelativeTime(DateTime dateTime, {DateTime? now}) {
    final current = now ?? DateTime.now();
    final difference = current.difference(dateTime);

    if (difference.isNegative || difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final mins = difference.inMinutes;
      return mins == 1 ? '1 min ago' : '$mins mins ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return hours == 1 ? '1 hour ago' : '$hours hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
    } else {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? '1 month ago' : '$months months ago';
    }
  }

  /// Returns the relative time string computed from [lastInspectedAt],
  /// or falls back to the static [lastInspected] string if available.
  String get displayLastInspected {
    if (lastInspectedAt != null) {
      return formatRelativeTime(lastInspectedAt!);
    }
    return lastInspected ?? 'Never';
  }

  /// Helper to safely parse dynamic timestamp / DateTime / string / int.
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  /// Factory constructor to parse data from a Map.
  factory Machine.fromMap(Map<String, dynamic> map, {String id = ''}) {
    return Machine(
      id: id.isNotEmpty ? id : (map['id']?.toString() ?? ''),
      name: map['name']?.toString() ?? '',
      code: map['code']?.toString() ?? '',
      location: map['location']?.toString() ?? '',
      status: map['status']?.toString() ?? 'Idle',
      lastInspected: map['lastInspected']?.toString(),
      lastInspectedAt: _parseDateTime(map['lastInspectedAt']),
      model: map['model']?.toString(),
      serialNumber: map['serialNumber']?.toString(),
      assignedTech: map['assignedTech']?.toString(),
      installationDate: map['installationDate']?.toString(),
    );
  }

  /// Factory constructor to parse a Firestore DocumentSnapshot.
  factory Machine.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Machine.fromMap(data, id: doc.id);
  }

  /// Converts the Machine instance into a Map suitable for Firestore storage.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'code': code,
      'location': location,
      'status': status,
      if (lastInspected != null) 'lastInspected': lastInspected,
      if (lastInspectedAt != null) 'lastInspectedAt': Timestamp.fromDate(lastInspectedAt!),
      if (model != null) 'model': model,
      if (serialNumber != null) 'serialNumber': serialNumber,
      if (assignedTech != null) 'assignedTech': assignedTech,
      if (installationDate != null) 'installationDate': installationDate,
    };
  }

  /// Creates a copy of this Machine with updated fields.
  Machine copyWith({
    String? id,
    String? name,
    String? code,
    String? location,
    String? status,
    String? lastInspected,
    DateTime? lastInspectedAt,
    String? model,
    String? serialNumber,
    String? assignedTech,
    String? installationDate,
  }) {
    return Machine(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      location: location ?? this.location,
      status: status ?? this.status,
      lastInspected: lastInspected ?? this.lastInspected,
      lastInspectedAt: lastInspectedAt ?? this.lastInspectedAt,
      model: model ?? this.model,
      serialNumber: serialNumber ?? this.serialNumber,
      assignedTech: assignedTech ?? this.assignedTech,
      installationDate: installationDate ?? this.installationDate,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Machine &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          code == other.code &&
          location == other.location &&
          status == other.status &&
          lastInspected == other.lastInspected &&
          lastInspectedAt == other.lastInspectedAt &&
          model == other.model &&
          serialNumber == other.serialNumber &&
          assignedTech == other.assignedTech &&
          installationDate == other.installationDate;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      code.hashCode ^
      location.hashCode ^
      status.hashCode ^
      lastInspected.hashCode ^
      lastInspectedAt.hashCode ^
      model.hashCode ^
      serialNumber.hashCode ^
      assignedTech.hashCode ^
      installationDate.hashCode;

  @override
  String toString() {
    return 'Machine(id: $id, name: $name, code: $code, location: $location, status: $status, lastInspectedAt: $lastInspectedAt)';
  }
}
