import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/machine.dart';
import 'firestore_service.dart';

/// Dedicated service for Machine inventory operations backed by Firestore.
class MachineService {
  final FirestoreService _firestoreService;

  MachineService({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  /// Collection reference for machines.
  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestoreService.machinesCollection;

  /// Fetches all machines from Firestore once.
  Future<List<Machine>> getMachines() async {
    try {
      final snapshot = await _collection.get();
      return snapshot.docs.map((doc) => Machine.fromFirestore(doc)).toList();
    } on FirebaseException catch (e) {
      throw 'Failed to fetch machines: ${e.message ?? e.code}';
    } catch (e) {
      throw 'An unexpected error occurred while fetching machines.';
    }
  }

  /// Fetches a single machine by document ID.
  Future<Machine?> getMachineById(String id) async {
    if (id.trim().isEmpty) return null;
    try {
      final doc = await _collection.doc(id.trim()).get();
      if (!doc.exists) return null;
      return Machine.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw 'Failed to fetch machine $id: ${e.message ?? e.code}';
    } catch (e) {
      throw 'An unexpected error occurred while fetching machine $id.';
    }
  }

  /// Real-time stream of all machines in Firestore.
  Stream<List<Machine>> getMachinesStream() {
    try {
      return _collection.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) => Machine.fromFirestore(doc)).toList();
      });
    } catch (_) {
      return const Stream.empty();
    }
  }

  /// Real-time stream of a single machine by document ID.
  Stream<Machine?> getMachineStream(String id) {
    if (id.trim().isEmpty) return const Stream.empty();
    try {
      return _collection.doc(id.trim()).snapshots().map((doc) {
        if (!doc.exists) return null;
        return Machine.fromFirestore(doc);
      });
    } catch (_) {
      return const Stream.empty();
    }
  }
}
