import 'package:cloud_firestore/cloud_firestore.dart';
import 'machine.dart';

/// Inspection data model representing machine audits in MachineTrack.
class Inspection {
  final String id;
  final String machineId;
  final String machineName;
  final String machineCode;
  final String? machineLocation;
  final String condition;
  final Map<String, bool> checklist;
  final String? notes;
  final String inspectorId;
  final String inspectorName;
  final String? shift;
  final DateTime inspectedAt;
  final DateTime? createdAt;

  const Inspection({
    required this.id,
    required this.machineId,
    required this.machineName,
    required this.machineCode,
    this.machineLocation,
    required this.condition,
    required this.checklist,
    this.notes,
    required this.inspectorId,
    required this.inspectorName,
    this.shift,
    required this.inspectedAt,
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

  factory Inspection.fromMap(Map<String, dynamic> map, {String id = ''}) {
    return Inspection(
      id: id.isNotEmpty ? id : (map['id']?.toString() ?? ''),
      machineId: map['machineId']?.toString() ?? '',
      machineName: map['machineName']?.toString() ?? '',
      machineCode: map['machineCode']?.toString() ?? '',
      machineLocation: map['machineLocation']?.toString(),
      condition: map['condition']?.toString() ?? 'Passed',
      checklist: Map<String, bool>.from(map['checklist'] as Map? ?? {}),
      notes: map['notes']?.toString(),
      inspectorId: map['inspectorId']?.toString() ?? '',
      inspectorName: map['inspectorName']?.toString() ?? '',
      shift: map['shift']?.toString(),
      inspectedAt: _parseDateTime(map['inspectedAt']) ?? DateTime.now(),
      createdAt: _parseDateTime(map['createdAt']),
    );
  }

  factory Inspection.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    return Inspection.fromMap(doc.data() ?? {}, id: doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'machineId': machineId,
      'machineName': machineName,
      'machineCode': machineCode,
      if (machineLocation != null) 'machineLocation': machineLocation,
      'condition': condition,
      'checklist': checklist,
      if (notes != null) 'notes': notes,
      'inspectorId': inspectorId,
      'inspectorName': inspectorName,
      if (shift != null) 'shift': shift,
      'inspectedAt': Timestamp.fromDate(inspectedAt),
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toMapForRecord() {
    return {
      'id': id,
      'title': condition == 'Passed'
          ? 'Shift Inspection Passed'
          : 'Inspection Flag: $condition',
      'machineId': machineId,
      'machineName': machineName,
      'machineCode': machineCode,
      'machineLocation': machineLocation ?? 'Factory Floor',
      'recordType': 'Inspection',
      'status': condition,
      'timestamp': Machine.formatRelativeTime(inspectedAt),
      'description': notes != null && notes!.trim().isNotEmpty
          ? notes!
          : 'All checked items verified by inspector.',
      'reportedBy': inspectorName,
      'shift': shift ?? 'Shift #1',
      'checklist': checklist,
      'rawDate': inspectedAt,
    };
  }

  Inspection copyWith({
    String? id,
    String? machineId,
    String? machineName,
    String? machineCode,
    String? machineLocation,
    String? condition,
    Map<String, bool>? checklist,
    String? notes,
    String? inspectorId,
    String? inspectorName,
    String? shift,
    DateTime? inspectedAt,
    DateTime? createdAt,
  }) {
    return Inspection(
      id: id ?? this.id,
      machineId: machineId ?? this.machineId,
      machineName: machineName ?? this.machineName,
      machineCode: machineCode ?? this.machineCode,
      machineLocation: machineLocation ?? this.machineLocation,
      condition: condition ?? this.condition,
      checklist: checklist ?? this.checklist,
      notes: notes ?? this.notes,
      inspectorId: inspectorId ?? this.inspectorId,
      inspectorName: inspectorName ?? this.inspectorName,
      shift: shift ?? this.shift,
      inspectedAt: inspectedAt ?? this.inspectedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
