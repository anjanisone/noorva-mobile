import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';

/// Typed access to the `users/{uid}` profile document.
class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _userRef(String uid) =>
      _db.collection('users').doc(uid);

  /// Creates the profile only if it does not exist yet. Returns true if created.
  Future<bool> createUserIfAbsent(AppUser user) async {
    final ref = _userRef(user.uid);
    return _db.runTransaction<bool>((tx) async {
      final snap = await tx.get(ref);
      if (snap.exists) return false;
      tx.set(ref, user.toCreateMap());
      return true;
    });
  }

  Future<AppUser?> getUser(String uid) async {
    final snap = await _userRef(uid).get();
    return snap.exists ? AppUser.fromFirestore(snap) : null;
  }

  Stream<AppUser?> watchUser(String uid) => _userRef(uid)
      .snapshots()
      .map((s) => s.exists ? AppUser.fromFirestore(s) : null);

  /// Merges the given fields into the profile (creates it if missing).
  Future<void> updateUser(String uid, Map<String, dynamic> fields) =>
      _userRef(uid).set(fields, SetOptions(merge: true));

  Future<void> deleteUser(String uid) => _userRef(uid).delete();

  Future<void> addFcmToken(String uid, String token) =>
      _userRef(uid).set(<String, dynamic>{
        'fcmTokens': FieldValue.arrayUnion(<String>[token]),
      }, SetOptions(merge: true));

  Future<void> removeFcmToken(String uid, String token) =>
      _userRef(uid).update(<String, dynamic>{
        'fcmTokens': FieldValue.arrayRemove(<String>[token]),
      });
}
