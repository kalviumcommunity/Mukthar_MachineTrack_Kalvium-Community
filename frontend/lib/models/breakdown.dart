import 'package:cloud_firestore/cloud_firestore.dart';
import 'machine.dart';

/// Breakdown incident data model representing machine failures in MachineTrack.
class Breakdown {
  final String id;
  final String machineId;
  final String machineName;
  final String machineCode;
  final String? machineLocation;
  final String title;
  final String description;
  final String severity;
  final String? component;
  final String? priority;
  final String? shift;
  final String reportedById;
  final String reportedByName;
  final bool resolved;
  final DateTime? resolvedAt;
  final String? resolvedById;
  final String? resolutionNotes;
  final DateTime? createdAt;

  const Breakdown({
    required this.id,
    required this.machineId,
    required this.machineName,
    required this.machineCode,
    this.machineLocation,
    required this.title,
    required this.description,
    required this.severity,
    this.component,
    this.priority,
    this.shift,
    required this.reportedById,
    required this.reportedByName,
    this.resolved = false,
    this.resolvedAt,
    this.resolvedById,
    this.resolutionNotes,
    this.createdAt,
  });

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  factory Breakdown.fromMap(Map<String, dynamic> map, {String id = ''}) {
    return Breakdown(
      id: id.isNotEmpty ? id : (map['id']?.toString() ?? ''),
      machineId: map['machineId']?.toString() ?? '',
      machineName: map['machineName']?.toString() ?? '',
      machineCode: map['machineCode']?.toString() ?? '',
      machineLocation: map['machineLocation']?.toString(),
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      severity: map['severity']?.toString() ?? 'Critical',
      component: map['component']?.toString(),
      priority: map['priority']?.toString(),
      shift: map['shift']?.toString(),
      reportedById: map['reportedById']?.toString() ?? '',
      reportedByName: map['reportedByName']?.toString() ?? '',
      resolved: map['resolved'] as bool? ?? false,
      resolvedAt: _parseDateTime(map['resolvedAt']),
      resolvedById: map['resolvedById']?.toString(),
      resolutionNotes: map['resolutionNotes']?.toString(),
      createdAt: _parseDateTime(map['createdAt']),
    );
  }

  factory Breakdown.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    return Breakdown.fromMap(doc.data() ?? {}, id: doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'machineId': machineId,
      'machineName': machineName,
      'machineCode': machineCode,
      if (machineLocation != null) 'machineLocation': machineLocation,
      'title': title,
      'description': description,
      'severity': severity,
      if (component != null) 'component': component,
      if (priority != null) 'priority': priority,
      if (shift != null) 'shift': shift,
      'reportedById': reportedById,
      'reportedByName': reportedByName,
      'resolved': resolved,
      if (resolvedAt != null) 'resolvedAt': Timestamp.fromDate(resolvedAt!),
      if (resolvedById != null) 'resolvedById': resolvedById,
      if (resolutionNotes != null) 'resolutionNotes': resolutionNotes,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toMapForRecord() {
    final displayTime = createdAt != null
        ? Machine.formatRelativeTime(createdAt!)
        : 'Just now';

    return {
      'id': id,
      'title': title,
      'machineName': machineName,
      'machineCode': machineCode,
      'machineLocation': machineLocation ?? 'Factory Floor',
      'recordType': 'Breakdown',
      'status': resolved ? 'Resolved' : severity,
      'timestamp': displayTime,
      'description': description,
      'reportedBy': reportedByName,
      'shift': shift ?? 'Shift #1',
      'priority': priority ?? (severity == 'Critical' ? 'Urgent / Line Halt' : 'Medium'),
      'component': component ?? 'General Subsystem',
      'resolved': resolved,
      'rawDate': createdAt ?? DateTime.now(),
    };
  }

  Breakdown copyWith({
    String? id,
    String? machineId,
    String? machineName,
    String? machineCode,
    String? machineLocation,
    String? title,
    String? description,
    String? severity,
    String? component,
    String? priority,
    String? shift,
    String? reportedById,
    String? reportedByName,
    bool? resolved,
    DateTime? resolvedAt,
    String? resolvedById,
    String? resolutionNotes,
    DateTime? createdAt,
  }) {
    return Breakdown(
      id: id ?? this.id,
      machineId: machineId ?? this.machineId,
      machineName: machineName ?? this.machineName,
      machineCode: machineCode ?? this.machineCode,
      machineLocation: machineLocation ?? this.machineLocation,
      title: title ?? this.title,
      description: description ?? this.description,
      severity: severity ?? this.severity,
      component: component ?? this.component,
      priority: priority ?? this.priority,
      shift: shift ?? this.shift,
      reportedById: reportedById ?? this.reportedById,
      reportedByName: reportedByName ?? this.reportedByName,
      resolved: resolved ?? this.resolved,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolvedById: resolvedById ?? this.resolvedById,
      resolutionNotes: resolutionNotes ?? this.resolutionNotes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
