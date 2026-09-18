import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/app.dart';

void main() {
  testWidgets('MachineTrackApp splash screen test', (WidgetTester tester) async {
    // Build MachineTrack app and trigger a frame.
    await tester.pumpWidget(const MachineTrackApp());

    // Verify that MachineTrack branding text exists on splash screen.
    expect(find.text('MachineTrack'), findsOneWidget);
  });
}
