import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/user_profile.dart';
import 'package:frontend/services/firestore_service.dart';
import 'package:frontend/services/user_service.dart';

void main() {
  group('UserService & UserProfile Model Tests', () {
    test('can instantiate UserService with default and custom FirestoreService', () {
      final defaultService = UserService();
      expect(defaultService, isNotNull);

      final customService = UserService(firestoreService: FirestoreService());
      expect(customService, isNotNull);
    });

    test('streams handle uninitialized environment safely', () {
      final service = UserService();
      expect(service.getUsersStream(), isNotNull);
      expect(service.getUserProfileStream('uid_123'), isNotNull);
      expect(service.getUserProfileStream(''), isNotNull);
    });

    test('UserProfile model parses data and checks admin status correctly', () {
      const techProfile = UserProfile(
        uid: 'user_1',
        name: 'Mukthar',
        email: 'mukthar@factory.com',
        role: 'technician',
      );
      expect(techProfile.isAdmin, isFalse);

      const adminProfile = UserProfile(
        uid: 'admin_1',
        name: 'Admin User',
        email: 'admin@factory.com',
        role: 'admin',
      );
      expect(adminProfile.isAdmin, isTrue);

      final map = techProfile.toMap();
      expect(map['role'], equals('technician'));
      expect(map['name'], equals('Mukthar'));
    });
  });
}
