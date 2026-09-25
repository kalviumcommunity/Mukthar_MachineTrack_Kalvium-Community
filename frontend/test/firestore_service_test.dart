import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/constants/firestore_constants.dart';
import 'package:frontend/services/firestore_service.dart';

void main() {
  group('FirestoreCollections constants tests', () {
    test('collection names match expected schema constants', () {
      expect(FirestoreCollections.users, equals('users'));
      expect(FirestoreCollections.machines, equals('machines'));
      expect(FirestoreCollections.inspections, equals('inspections'));
      expect(FirestoreCollections.breakdowns, equals('breakdowns'));
    });
  });

  group('FirestoreService foundation tests', () {
    test('can instantiate FirestoreService safely', () {
      final service = FirestoreService();
      expect(service, isNotNull);
    });

    test('firestoreOrNull and isAvailable handle uninitialized environment safely', () {
      final service = FirestoreService();
      // In a pure headless unit test without Firebase initialization,
      // firestoreOrNull safely returns null and isAvailable returns false.
      expect(service.isAvailable, isFalse);
      expect(service.firestoreOrNull, isNull);
    });
  });
}
