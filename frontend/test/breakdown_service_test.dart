import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/breakdown.dart';
import 'package:frontend/services/breakdown_service.dart';
import 'package:frontend/services/firestore_service.dart';

void main() {
  group('BreakdownService & Breakdown Model Tests', () {
    test('can instantiate BreakdownService with default and custom FirestoreService', () {
      final defaultService = BreakdownService();
      expect(defaultService, isNotNull);

      final customService = BreakdownService(firestoreService: FirestoreService());
      expect(customService, isNotNull);
    });

    test('streams handle uninitialized environment safely', () {
      final service = BreakdownService();
      expect(service.getBreakdownsStream(), isNotNull);
      expect(service.getBreakdownsForMachineStream('1'), isNotNull);
      expect(service.getBreakdownsForMachineStream(''), isNotNull);
    });

    test('Breakdown model converts to and from map and record map correctly', () {
      final now = DateTime(2026, 10, 4, 10, 45);
      final breakdown = Breakdown(
        id: 'BRK-001',
        machineId: '1',
        machineName: 'Hydraulic Press 500T',
        machineCode: 'PRESS-500T-04',
        machineLocation: 'Zone A',
        title: 'Pressure drop',
        description: 'Fluid leak detected',
        severity: 'Critical',
        reportedById: 'tech_01',
        reportedByName: 'Mukthar',
        createdAt: now,
      );

      final map = breakdown.toMap();
      expect(map['machineId'], equals('1'));
      expect(map['severity'], equals('Critical'));
      expect(map['resolved'], isFalse);

      final recordMap = breakdown.toMapForRecord();
      expect(recordMap['id'], equals('BRK-001'));
      expect(recordMap['recordType'], equals('Breakdown'));
      expect(recordMap['status'], equals('Critical'));
    });
  });
}
