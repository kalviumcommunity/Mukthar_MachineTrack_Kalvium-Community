import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';
import 'firestore_service.dart';

/// Service responsible for worker profile operations in Firestore.
class UserService {
  final FirestoreService _firestoreService;

  UserService({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestoreService.usersCollection;

  /// Fetches a user profile document by UID.
  Future<UserProfile?> getUserProfile(String uid) async {
    if (uid.trim().isEmpty) return null;
    try {
      final doc = await _collection.doc(uid.trim()).get();
      if (!doc.exists) return null;
      return UserProfile.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw 'Failed to fetch user profile: ${e.message ?? e.code}';
    } catch (e) {
      throw 'An unexpected error occurred while fetching user profile.';
    }
  }

  /// Real-time stream of a specific user profile document.
  Stream<UserProfile?> getUserProfileStream(String uid) {
    if (uid.trim().isEmpty) return const Stream.empty();
    try {
      return _collection.doc(uid.trim()).snapshots().map((doc) {
        if (!doc.exists) return null;
        return UserProfile.fromFirestore(doc);
      });
    } catch (_) {
      return const Stream.empty();
    }
  }

  /// Real-time stream of all team members.
  Stream<List<UserProfile>> getUsersStream() {
    try {
      return _collection.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) => UserProfile.fromFirestore(doc)).toList();
      });
    } catch (_) {
      return const Stream.empty();
    }
  }

  /// Fetches all team members once.
  Future<List<UserProfile>> getUsers() async {
    try {
      final snapshot = await _collection.get();
      return snapshot.docs.map((doc) => UserProfile.fromFirestore(doc)).toList();
    } on FirebaseException catch (e) {
      throw 'Failed to fetch team members: ${e.message ?? e.code}';
    } catch (e) {
      throw 'An unexpected error occurred while fetching team members.';
    }
  }

  /// Updates a user's own profile fields (name and shift only, per security rules).
  Future<void> updateProfile({
    required String uid,
    String? name,
    String? shift,
  }) async {
    if (uid.trim().isEmpty) return;
    try {
      final updates = <String, dynamic>{};
      if (name != null && name.trim().isNotEmpty) updates['name'] = name.trim();
      if (shift != null) updates['shift'] = shift.trim();

      if (updates.isEmpty) return;
      await _collection.doc(uid.trim()).update(updates);
    } on FirebaseException catch (e) {
      throw 'Failed to update profile: ${e.message ?? e.code}';
    } catch (e) {
      throw 'An unexpected error occurred while updating profile.';
    }
  }
}
