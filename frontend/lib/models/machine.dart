import 'package:cloud_firestore/cloud_firestore.dart';

/// Machine data model representing factory machine inventory in MachineTrack.
class Machine {
  final String id;
  final String name;
  final String code;
  final String location;
  final String status;
  final String? lastInspected;
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
    this.model,
    this.serialNumber,
    this.assignedTech,
    this.installationDate,
  });

  /// Factory constructor to parse data from a Map.
  factory Machine.fromMap(Map<String, dynamic> map, {String id = ''}) {
    return Machine(
      id: id.isNotEmpty ? id : (map['id']?.toString() ?? ''),
      name: map['name']?.toString() ?? '',
      code: map['code']?.toString() ?? '',
      location: map['location']?.toString() ?? '',
      status: map['status']?.toString() ?? 'Idle',
      lastInspected: map['lastInspected']?.toString(),
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
      model.hashCode ^
      serialNumber.hashCode ^
      assignedTech.hashCode ^
      installationDate.hashCode;

  @override
  String toString() {
    return 'Machine(id: $id, name: $name, code: $code, location: $location, status: $status)';
  }
}
