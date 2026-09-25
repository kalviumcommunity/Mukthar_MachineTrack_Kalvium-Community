import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/firestore_constants.dart';

/// Foundation service for Firebase Firestore operations in MachineTrack.
class FirestoreService {
  final FirebaseFirestore? _customFirestore;

  FirestoreService({FirebaseFirestore? firestore})
      : _customFirestore = firestore;

  /// Returns the FirebaseFirestore instance (custom if provided, or default instance).
  FirebaseFirestore get firestore {
    if (_customFirestore != null) return _customFirestore;
    return FirebaseFirestore.instance;
  }

  /// Safe accessor that returns null if Firebase/Firestore is not initialized.
  FirebaseFirestore? get firestoreOrNull {
    if (_customFirestore != null) return _customFirestore;
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  /// Helper to access any collection reference by path.
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) {
    return firestore.collection(collectionPath);
  }

  /// Reference to the 'users' collection.
  CollectionReference<Map<String, dynamic>> get usersCollection =>
      collection(FirestoreCollections.users);

  /// Reference to the 'machines' collection.
  CollectionReference<Map<String, dynamic>> get machinesCollection =>
      collection(FirestoreCollections.machines);

  /// Reference to the 'inspections' collection.
  CollectionReference<Map<String, dynamic>> get inspectionsCollection =>
      collection(FirestoreCollections.inspections);

  /// Reference to the 'breakdowns' collection.
  CollectionReference<Map<String, dynamic>> get breakdownsCollection =>
      collection(FirestoreCollections.breakdowns);

  /// Checks if Firestore instance is accessible without throwing.
  bool get isAvailable {
    return firestoreOrNull != null;
  }
}
