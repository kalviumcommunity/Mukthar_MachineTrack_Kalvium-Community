import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/services/firestore_service.dart';
import 'package:frontend/services/machine_service.dart';

void main() {
  group('MachineService Foundation Tests', () {
    test('can instantiate MachineService with default and custom FirestoreService', () {
      final defaultService = MachineService();
      expect(defaultService, isNotNull);

      final customFirestoreService = FirestoreService();
      final customService = MachineService(firestoreService: customFirestoreService);
      expect(customService, isNotNull);
    });

    test('getMachinesStream and getMachineStream handle uninitialized environment safely', () {
      final service = MachineService();
      expect(service.getMachinesStream(), isNotNull);
      expect(service.getMachineStream('1'), isNotNull);
      expect(service.getMachineStream(''), isNotNull);
    });
  });
}
