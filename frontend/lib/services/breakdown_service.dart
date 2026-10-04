import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/breakdown.dart';
import 'firestore_service.dart';

/// Service responsible for managing breakdown incident logs in Firestore.
class BreakdownService {
  final FirestoreService _firestoreService;

  BreakdownService({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestoreService.breakdownsCollection;

  /// Fetches all breakdown incident reports once, ordered by creation date descending.
  Future<List<Breakdown>> getBreakdowns() async {
    try {
      final snapshot = await _collection.orderBy('createdAt', descending: true).get();
      return snapshot.docs.map((doc) => Breakdown.fromFirestore(doc)).toList();
    } on FirebaseException catch (e) {
      throw 'Failed to fetch breakdowns: ${e.message ?? e.code}';
    } catch (e) {
      throw 'An unexpected error occurred while fetching breakdowns.';
    }
  }

  /// Real-time stream of all breakdown incidents ordered by creation time descending.
  Stream<List<Breakdown>> getBreakdownsStream() {
    try {
      return _collection
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => Breakdown.fromFirestore(doc)).toList();
      });
    } catch (_) {
      return const Stream.empty();
    }
  }

  /// Real-time stream of breakdowns filtered by machine ID.
  Stream<List<Breakdown>> getBreakdownsForMachineStream(String machineId) {
    if (machineId.trim().isEmpty) return const Stream.empty();
    try {
      return _collection
          .where('machineId', '==', machineId.trim())
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => Breakdown.fromFirestore(doc)).toList();
      });
    } catch (_) {
      return const Stream.empty();
    }
  }

  /// Logs a new breakdown incident document into Firestore.
  ///
  /// Returns the newly generated document ID.
  Future<String> reportBreakdown(Breakdown breakdown) async {
    try {
      final data = breakdown.toMap();
      final docRef = await _collection.add(data);
      return docRef.id;
    } on FirebaseException catch (e) {
      throw 'Failed to report breakdown: ${e.message ?? e.code}';
    } catch (e) {
      throw 'An unexpected error occurred while reporting breakdown.';
    }
  }

  /// Resolves an open breakdown incident.
  Future<void> resolveBreakdown({
    required String breakdownId,
    required String resolvedById,
    String? resolutionNotes,
  }) async {
    if (breakdownId.trim().isEmpty) return;
    try {
      await _collection.doc(breakdownId.trim()).update({
        'resolved': true,
        'resolvedAt': FieldValue.serverTimestamp(),
        'resolvedById': resolvedById,
        if (resolutionNotes != null && resolutionNotes.trim().isNotEmpty)
          'resolutionNotes': resolutionNotes.trim(),
      });
    } on FirebaseException catch (e) {
      throw 'Failed to resolve breakdown: ${e.message ?? e.code}';
    } catch (e) {
      throw 'An unexpected error occurred while resolving breakdown.';
    }
  }
}
