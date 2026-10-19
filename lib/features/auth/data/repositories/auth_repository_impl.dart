import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';
import '../../../../core/services/otp_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Future<UserEntity> login(String email, String password) async {
    try {
      final UserCredential credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final User? user = credential.user;
      if (user == null) {
        throw Exception('User is null after signing in.');
      }
      if (!user.emailVerified) throw const EmailNotVerifiedException();

      String nameVal = user.displayName ?? 'Noorva User';
      String? dobVal;
      String? genderVal;
      String? occupationVal;

      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data();
          nameVal = data?['name'] ?? nameVal;
          dobVal = data?['dob'];
          genderVal = data?['gender'];
          occupationVal = data?['occupation'];
        }
      } catch (firestoreError) {
        debugPrint('Firestore fetch error on login: $firestoreError');
      }

      return UserModel(
        id: user.uid,
        email: user.email ?? email,
        name: nameVal,
        profilePic: user.photoURL,
        dob: dobVal,
        gender: genderVal,
        occupation: occupationVal,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Login Error: $e');
      if (e.code == 'user-not-found') throw const AccountNotFoundException();
      rethrow;
    } catch (e) {
      debugPrint('Firebase Login Error: $e');
      rethrow;
    }
  }

  @override
  Future<UserEntity> register({
    required String email,
    required String password,
    required String name,
    String? dob,
    String? gender,
    String? occupation,
  }) async {
    try {
      final UserCredential credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final User? user = credential.user;
      if (user == null) {
        throw Exception('User is null after registration.');
      }

      // Sign-up is the only place the full profile is written.
      try {
        await user.updateDisplayName(name);
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'id': user.uid,
          'email': email.trim(),
          'name': name,
          'profilePic': user.photoURL,
          'dob': dob,
          'gender': gender,
          'occupation': occupation,
          'provider': 'password',
          'createdAt': FieldValue.serverTimestamp(),
        });
      } catch (firestoreError) {
        // Don't leave an auth account without a profile behind; undo it so
        // the user can retry sign-up with the same email.
        debugPrint('Firestore save error on register: $firestoreError');
        try {
          await user.delete();
        } catch (deleteError) {
          debugPrint('Could not delete account after failed profile save: $deleteError');
        }
        await _firebaseAuth.signOut();
        throw Exception('Could not save your profile. Please try again.');
      }

      // Failure here isn't fatal: the verify screen can resend the link.
      try {
        await user.sendEmailVerification();
      } catch (e) {
        debugPrint('Could not send verification email: $e');
      }

      return UserModel(
        id: user.uid,
        email: user.email ?? email,
        name: name,
        profilePic: user.photoURL,
        dob: dob,
        gender: gender,
        occupation: occupation,
      );
    } catch (e) {
      debugPrint('Firebase Register Error: $e');
      rethrow;
    }
  }

  @override
  Future<UserEntity> signInWithGoogle({bool isSignUp = false}) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw Exception('Google Sign-In Cancelled');

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user == null) throw Exception('Firebase Google Sign-In failed');

      // Sign-in (not sign-up) must not create accounts: if Firebase just
      // created this one, undo it and send the user to sign up instead.
      if (!isSignUp && (userCredential.additionalUserInfo?.isNewUser ?? false)) {
        try {
          await user.delete();
        } catch (deleteError) {
          debugPrint('Could not delete just-created account: $deleteError');
        }
        await _firebaseAuth.signOut();
        await _googleSignIn.signOut();
        throw const AccountNotFoundException();
      }

      String nameVal = user.displayName ?? googleUser.displayName ?? 'Google User';
      String? dobVal;
      String? genderVal;
      String? occupationVal;

      final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      try {
        final doc = await docRef.get();
        if (doc.exists) {
          // Login (or sign-up with an existing account): read only.
          final data = doc.data();
          nameVal = data?['name'] ?? nameVal;
          dobVal = data?['dob'];
          genderVal = data?['gender'];
          occupationVal = data?['occupation'];
        } else if (isSignUp) {
          // Sign-up is the only place the profile is written.
          await docRef.set({
            'id': user.uid,
            'email': user.email ?? googleUser.email,
            'name': nameVal,
            'profilePic': user.photoURL ?? googleUser.photoUrl,
            'dob': null,
            'gender': null,
            'occupation': null,
            'provider': 'google',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      } catch (firestoreError) {
        debugPrint('Firestore fetch/create error on Google sign-in: $firestoreError');
        if (isSignUp) {
          await _firebaseAuth.signOut();
          await _googleSignIn.signOut();
          throw Exception('Could not save your profile. Please try again.');
        }
      }

      return UserModel(
        id: user.uid,
        email: user.email ?? googleUser.email,
        name: nameVal,
        profilePic: user.photoURL ?? googleUser.photoUrl,
        dob: dobVal,
        gender: genderVal,
        occupation: occupationVal,
      );
    } catch (e) {
      debugPrint('Google Sign-In failed: $e');
      rethrow;
    }
  }

  @override
  Future<UserEntity> signInWithApple() async {
    try {
      final AuthorizationCredentialAppleID credential =
          await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final OAuthProvider oAuthProvider = OAuthProvider('apple.com');
      final AuthCredential authCredential = oAuthProvider.credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(authCredential);
      final User? user = userCredential.user;

      if (user == null) throw Exception('Firebase Apple Sign-In failed');

      String nameVal = user.displayName ??
          '${credential.givenName ?? ''} ${credential.familyName ?? ''}'.trim();
      if (nameVal.isEmpty) nameVal = 'Apple User';
      String? dobVal;
      String? genderVal;
      String? occupationVal;

      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data();
          nameVal = data?['name'] ?? nameVal;
          dobVal = data?['dob'];
          genderVal = data?['gender'];
          occupationVal = data?['occupation'];
        } else {
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'id': user.uid,
            'email': user.email ?? credential.email ?? 'apple@example.com',
            'name': nameVal,
            'profilePic': user.photoURL,
            'dob': null,
            'gender': null,
            'occupation': null,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      } catch (firestoreError) {
        debugPrint('Firestore fetch/create error on Apple sign-in: $firestoreError');
      }

      return UserModel(
        id: user.uid,
        email: user.email ?? credential.email ?? 'apple@example.com',
        name: nameVal,
        profilePic: user.photoURL,
        dob: dobVal,
        gender: genderVal,
        occupation: occupationVal,
      );
    } catch (e) {
      debugPrint('Apple Sign-In failed: $e');
      // Mock Fallback for simulator or missing config
      if (e.toString().contains('not_supported') ||
          e.toString().contains('failed')) {
        debugPrint('Using Mock User for testing...');
        return const UserModel(
          id: 'mock_apple_id',
          email: 'test.apple@example.com',
          name: 'Noorva Explorer (Apple Mock)',
        );
      }
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } catch (e) {
      debugPrint('Firebase Forgot Password Error: $e');
      rethrow;
    }
  }

  @override
  Future<void> resetPassword({required String email, required String newPassword}) async {
    // Local simulation of resetting password, since real reset is triggered by the email link
    debugPrint('Local simulation: Password for $email updated to $newPassword');
  }

  @override
  Future<UserEntity> updateProfile({
    required String name,
    required String email,
    String? dob,
    String? gender,
    String? occupation,
  }) async {
    try {
      final User? user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('No user logged in.');
      }

      // Update Display Name in Firebase Auth
      await user.updateDisplayName(name);

      // Update Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'id': user.uid,
        'email': email.trim(),
        'name': name,
        'profilePic': user.photoURL,
        'dob': dob,
        'gender': gender,
        'occupation': occupation,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return UserModel(
        id: user.uid,
        email: email,
        name: name,
        profilePic: user.photoURL,
        dob: dob,
        gender: gender,
        occupation: occupation,
      );
    } catch (e) {
      debugPrint('Firebase Update Profile Error: $e');
      rethrow;
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final User? user = _firebaseAuth.currentUser;
      if (user == null) return null;

      // An unverified email/password session doesn't count as logged in.
      final isPasswordUser = user.providerData.any((p) => p.providerId == 'password');
      if (isPasswordUser && !user.emailVerified) {
        await _firebaseAuth.signOut();
        return null;
      }

      String nameVal = user.displayName ?? 'Noorva User';
      String? dobVal;
      String? genderVal;
      String? occupationVal;

      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data();
          nameVal = data?['name'] ?? nameVal;
          dobVal = data?['dob'];
          genderVal = data?['gender'];
          occupationVal = data?['occupation'];
        }
      } catch (firestoreError) {
        debugPrint('Firestore fetch error on getCurrentUser: $firestoreError');
      }

      return UserModel(
        id: user.uid,
        email: user.email ?? '',
        name: nameVal,
        profilePic: user.photoURL,
        dob: dobVal,
        gender: genderVal,
        occupation: occupationVal,
      );
    } catch (e) {
      debugPrint('GetCurrentUser Error: $e');
      return null;
    }
  }

  @override
  Future<void> sendVerificationEmail() async {
    final User? user = _firebaseAuth.currentUser;
    if (user == null) throw Exception('Session expired. Please log in again.');
    try {
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'too-many-requests') {
        throw Exception('Too many emails sent. Please wait a few minutes and try again.');
      }
      rethrow;
    }
  }

  @override
  Future<UserEntity?> checkEmailVerified() async {
    final User? user = _firebaseAuth.currentUser;
    if (user == null) throw Exception('Session expired. Please log in again.');
    await user.reload();
    if (!(_firebaseAuth.currentUser?.emailVerified ?? false)) return null;
    return getCurrentUser();
  }

  @override
  Future<void> sendEmailOtp(
    String email, {
    String purpose = 'verification',
  }) async {
    await OtpService.createAndSendOtp(email, purpose: purpose);
  }

  @override
  Future<OtpVerificationResult> verifyEmailOtp(
    String email,
    String otp,
  ) async {
    return OtpService.verifyOtp(email, otp);
  }
}
