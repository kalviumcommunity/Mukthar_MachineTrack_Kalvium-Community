import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/inspection.dart';
import 'package:frontend/services/firestore_service.dart';
import 'package:frontend/services/inspection_service.dart';

void main() {
  group('InspectionService & Inspection Model Tests', () {
    test('can instantiate InspectionService with default and custom FirestoreService', () {
      final defaultService = InspectionService();
      expect(defaultService, isNotNull);

      final customService = InspectionService(firestoreService: FirestoreService());
      expect(customService, isNotNull);
    });

    test('streams handle uninitialized environment safely', () {
      final service = InspectionService();
      expect(service.getInspectionsStream(), isNotNull);
      expect(service.getInspectionsForMachineStream('1'), isNotNull);
      expect(service.getInspectionsForMachineStream(''), isNotNull);
    });

    test('Inspection model converts to and from map and record map correctly', () {
      final now = DateTime(2026, 10, 4, 10, 30);
      final inspection = Inspection(
        id: 'INS-001',
        machineId: '1',
        machineName: 'Hydraulic Press 500T',
        machineCode: 'PRESS-500T-04',
        machineLocation: 'Zone A',
        condition: 'Passed',
        checklist: {'Oil level': true},
        notes: 'All checks passed',
        inspectorId: 'tech_01',
        inspectorName: 'Mukthar',
        shift: 'Shift #1',
        inspectedAt: now,
        createdAt: now,
      );

      final map = inspection.toMap();
      expect(map['machineId'], equals('1'));
      expect(map['condition'], equals('Passed'));

      final recordMap = inspection.toMapForRecord();
      expect(recordMap['id'], equals('INS-001'));
      expect(recordMap['recordType'], equals('Inspection'));
      expect(recordMap['status'], equals('Passed'));
    });
  });
}
