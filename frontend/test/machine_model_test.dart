import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/machine.dart';

void main() {
  group('Machine Model Tests', () {
    test('creates Machine instance and converts to/from Map correctly', () {
      final sampleMap = {
        'id': 'PRESS-01',
        'name': 'Hydraulic Press 500T',
        'code': 'PRESS-500T-04',
        'location': 'Zone A - Stamping Line',
        'status': 'Breakdown',
        'lastInspected': '25 mins ago',
        'model': 'StamperPro 500',
        'serialNumber': 'SN-99812-A',
        'assignedTech': 'Mukthar',
        'installationDate': '12 Jan 2024',
      };

      final machine = Machine.fromMap(sampleMap);

      expect(machine.id, equals('PRESS-01'));
      expect(machine.name, equals('Hydraulic Press 500T'));
      expect(machine.code, equals('PRESS-500T-04'));
      expect(machine.location, equals('Zone A - Stamping Line'));
      expect(machine.status, equals('Breakdown'));
      expect(machine.lastInspected, equals('25 mins ago'));
      expect(machine.model, equals('StamperPro 500'));
      expect(machine.serialNumber, equals('SN-99812-A'));
      expect(machine.assignedTech, equals('Mukthar'));
      expect(machine.installationDate, equals('12 Jan 2024'));

      final convertedMap = machine.toMap();
      expect(convertedMap['name'], equals('Hydraulic Press 500T'));
      expect(convertedMap['code'], equals('PRESS-500T-04'));
      expect(convertedMap['location'], equals('Zone A - Stamping Line'));
      expect(convertedMap['status'], equals('Breakdown'));
      expect(convertedMap['lastInspected'], equals('25 mins ago'));
      expect(convertedMap['model'], equals('StamperPro 500'));
      expect(convertedMap['serialNumber'], equals('SN-99812-A'));
      expect(convertedMap['assignedTech'], equals('Mukthar'));
      expect(convertedMap['installationDate'], equals('12 Jan 2024'));
    });

    test('handles missing or null fields gracefully with safe fallbacks', () {
      final incompleteMap = <String, dynamic>{
        'name': 'CNC Lathe Machine #02',
      };

      final machine = Machine.fromMap(incompleteMap, id: 'DOC-123');

      expect(machine.id, equals('DOC-123'));
      expect(machine.name, equals('CNC Lathe Machine #02'));
      expect(machine.code, isEmpty);
      expect(machine.location, isEmpty);
      expect(machine.status, equals('Idle'));
      expect(machine.lastInspected, isNull);
      expect(machine.model, isNull);
      expect(machine.serialNumber, isNull);
      expect(machine.assignedTech, isNull);
      expect(machine.installationDate, isNull);

      final toMapResult = machine.toMap();
      expect(toMapResult.containsKey('lastInspected'), isFalse);
      expect(toMapResult.containsKey('model'), isFalse);
      expect(toMapResult.containsKey('serialNumber'), isFalse);
      expect(toMapResult.containsKey('assignedTech'), isFalse);
      expect(toMapResult.containsKey('installationDate'), isFalse);
    });

    test('copyWith updates specified fields only', () {
      const initialMachine = Machine(
        id: '1',
        name: 'Conveyor Belt #05',
        code: 'CNV-05',
        location: 'Zone C',
        status: 'Running',
      );

      final updatedMachine = initialMachine.copyWith(
        status: 'Maintenance',
        lastInspected: 'Just now',
      );

      expect(updatedMachine.id, equals('1'));
      expect(updatedMachine.name, equals('Conveyor Belt #05'));
      expect(updatedMachine.code, equals('CNV-05'));
      expect(updatedMachine.location, equals('Zone C'));
      expect(updatedMachine.status, equals('Maintenance'));
      expect(updatedMachine.lastInspected, equals('Just now'));
    });

    test('equality and hashCode work as expected', () {
      const machine1 = Machine(
        id: '1',
        name: 'WeldBot 900',
        code: 'WLD-01',
        location: 'Zone A',
        status: 'Running',
      );

      const machine2 = Machine(
        id: '1',
        name: 'WeldBot 900',
        code: 'WLD-01',
        location: 'Zone A',
        status: 'Running',
      );

      const machine3 = Machine(
        id: '2',
        name: 'WeldBot 900',
        code: 'WLD-01',
        location: 'Zone A',
        status: 'Running',
      );

      expect(machine1, equals(machine2));
      expect(machine1.hashCode, equals(machine2.hashCode));
      expect(machine1, isNot(equals(machine3)));
    });

    test('handles lastInspectedAt Timestamp correctly and formats relative time', () {
      final now = DateTime(2026, 10, 3, 12, 0, 0);

      // Just now (< 1 min)
      expect(
        Machine.formatRelativeTime(now.subtract(const Duration(seconds: 30)), clock: now),
        equals('Just now'),
      );

      // 25 mins ago
      expect(
        Machine.formatRelativeTime(now.subtract(const Duration(minutes: 25)), clock: now),
        equals('25 mins ago'),
      );

      // 1 min ago
      expect(
        Machine.formatRelativeTime(now.subtract(const Duration(minutes: 1)), clock: now),
        equals('1 min ago'),
      );

      // 2 hours ago
      expect(
        Machine.formatRelativeTime(now.subtract(const Duration(hours: 2)), clock: now),
        equals('2 hours ago'),
      );

      // 1 day ago
      expect(
        Machine.formatRelativeTime(now.subtract(const Duration(days: 1)), clock: now),
        equals('Yesterday'),
      );

      // 3 days ago
      expect(
        Machine.formatRelativeTime(now.subtract(const Duration(days: 3)), clock: now),
        equals('3 days ago'),
      );

      // 10 days ago (formatted date string)
      final pastDate = DateTime(2026, 9, 23, 10, 0);
      expect(
        Machine.formatRelativeTime(pastDate, clock: now),
        equals('23 Sep 2026'),
      );
    });

    test('parses lastInspectedAt from various formats (DateTime, String, millis)', () {
      final dt = DateTime(2026, 10, 3, 11, 30);
      final mapWithIso = {
        'id': 'M-1',
        'name': 'Press',
        'code': 'P-01',
        'location': 'Zone A',
        'lastInspectedAt': dt.toIso8601String(),
      };
      final machineFromIso = Machine.fromMap(mapWithIso);
      expect(machineFromIso.lastInspectedAt, equals(dt));

      final mapWithMillis = {
        'id': 'M-2',
        'name': 'Lathe',
        'code': 'L-01',
        'location': 'Zone B',
        'lastInspectedAt': dt.millisecondsSinceEpoch,
      };
      final machineFromMillis = Machine.fromMap(mapWithMillis);
      expect(machineFromMillis.lastInspectedAt, equals(dt));

      final routeMap = machineFromIso.toRouteMap();
      expect(routeMap['id'], equals('M-1'));
      expect(routeMap['lastInspectedAt'], equals(dt.toIso8601String()));
    });
  });
}
