import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/screens/machines/machine_details_screen.dart';

void main() {
  group('MachineDetailsScreen Widget Tests', () {
    testWidgets('renders MachineDetailsScreen with machine specifications', (WidgetTester tester) async {
      const sampleMachineData = {
        'id': 'PRESS-500T-04',
        'name': 'Hydraulic Press 500T',
        'code': 'PRESS-500T-04',
        'location': 'Zone A - Heavy Stamping',
        'status': 'Breakdown',
        'model': 'StamperPro 500',
        'serialNumber': 'SN-99812-A',
        'assignedTech': 'Mukthar',
        'installationDate': '12 Jan 2024',
      };

      await tester.pumpWidget(
        const MaterialApp(
          home: MachineDetailsScreen(
            machineData: sampleMachineData,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Machine Specifications'), findsOneWidget);
      expect(find.text('Hydraulic Press 500T'), findsAtLeastNWidgets(1));
      expect(find.text('ID: PRESS-500T-04'), findsOneWidget);
      expect(find.text('Zone A - Heavy Stamping'), findsOneWidget);
      expect(find.text('Breakdown'), findsAtLeastNWidgets(1));
      expect(find.text('StamperPro 500'), findsOneWidget);
      expect(find.text('SN-99812-A'), findsOneWidget);
      expect(find.text('Mukthar'), findsAtLeastNWidgets(1));
      expect(find.text('12 Jan 2024'), findsOneWidget);
      expect(find.text('Log Inspection'), findsOneWidget);
      expect(find.text('Report Fault'), findsOneWidget);
    });
  });
}
