import 'package:cloud_firestore/cloud_firestore.dart';

/// Profile stored at `users/{uid}` in Cloud Firestore.
class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.createdAt,
    this.fcmTokens = const <String>[],
  });

  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final DateTime? createdAt;
  final List<String> fcmTokens;

  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    final created = data['createdAt'];
    return AppUser(
      uid: doc.id,
      email: (data['email'] as String?) ?? '',
      // Falls back to legacy keys written by the existing auth repository.
      displayName: (data['displayName'] ?? data['name']) as String?,
      photoUrl: (data['photoUrl'] ?? data['profilePic']) as String?,
      createdAt: created is Timestamp ? created.toDate() : null,
      fcmTokens: List<String>.from(data['fcmTokens'] as List? ?? const []),
    );
  }

  /// Fields used on create. `createdAt` is a server timestamp.
  Map<String, dynamic> toCreateMap() => <String, dynamic>{
        'uid': uid,
        'email': email,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'fcmTokens': fcmTokens,
      };

  AppUser copyWith({
    String? email,
    String? displayName,
    String? photoUrl,
    List<String>? fcmTokens,
  }) {
    return AppUser(
      uid: uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt,
      fcmTokens: fcmTokens ?? this.fcmTokens,
    );
  }
}
