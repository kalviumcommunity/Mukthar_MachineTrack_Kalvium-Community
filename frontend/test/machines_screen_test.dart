import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/screens/machines/machines_screen.dart';

void main() {
  group('MachinesScreen Widget Tests', () {
    testWidgets('renders MachinesScreen and search input without throwing', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MachinesScreen(),
        ),
      );

      // Verify header and search field exist
      expect(find.text('Factory Machines'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search machine name, ID, or zone...'), findsOneWidget);
      expect(find.text('All'), findsWidgets);
      expect(find.text('Running'), findsOneWidget);
      expect(find.text('Maintenance'), findsOneWidget);
      expect(find.text('Breakdown'), findsOneWidget);
      expect(find.text('Idle'), findsOneWidget);
    });

    testWidgets('shows empty state when no machines are loaded', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MachinesScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No Machines Registered'), findsOneWidget);
      expect(
        find.text('There are no machines currently registered in Firestore inventory.'),
        findsOneWidget,
      );
    });
  });
}
