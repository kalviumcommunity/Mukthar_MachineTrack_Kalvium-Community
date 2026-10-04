import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/inspection.dart';
import 'firestore_service.dart';

/// Service responsible for managing machine inspection records in Firestore.
class InspectionService {
  final FirestoreService _firestoreService;

  InspectionService({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestoreService.inspectionsCollection;

  /// Fetches all inspection records once, ordered by creation date descending.
  Future<List<Inspection>> getInspections() async {
    try {
      final snapshot = await _collection.orderBy('createdAt', descending: true).get();
      return snapshot.docs.map((doc) => Inspection.fromFirestore(doc)).toList();
    } on FirebaseException catch (e) {
      throw 'Failed to fetch inspections: ${e.message ?? e.code}';
    } catch (e) {
      throw 'An unexpected error occurred while fetching inspections.';
    }
  }

  /// Real-time stream of all inspections ordered by creation time descending.
  Stream<List<Inspection>> getInspectionsStream() {
    try {
      return _collection
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => Inspection.fromFirestore(doc)).toList();
      });
    } catch (_) {
      return const Stream.empty();
    }
  }

  /// Real-time stream of inspections filtered by machine ID.
  Stream<List<Inspection>> getInspectionsForMachineStream(String machineId) {
    if (machineId.trim().isEmpty) return const Stream.empty();
    try {
      return _collection
          .where('machineId', '==', machineId.trim())
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => Inspection.fromFirestore(doc)).toList();
      });
    } catch (_) {
      return const Stream.empty();
    }
  }

  /// Creates a new inspection document in Firestore.
  ///
  /// Returns the newly generated document ID.
  Future<String> createInspection(Inspection inspection) async {
    try {
      final data = inspection.toMap();
      final docRef = await _collection.add(data);
      return docRef.id;
    } on FirebaseException catch (e) {
      throw 'Failed to submit inspection: ${e.message ?? e.code}';
    } catch (e) {
      throw 'An unexpected error occurred while submitting inspection.';
    }
  }
}
