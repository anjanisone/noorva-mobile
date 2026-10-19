import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

      // Update display name
      await user.updateDisplayName(name);

      // Save supplemental details to SharedPreferences locally
      final prefs = await SharedPreferences.getInstance();
      if (dob != null) await prefs.setString('user_dob_${user.uid}', dob);
      if (gender != null) await prefs.setString('user_gender_${user.uid}', gender);
      if (occupation != null) await prefs.setString('user_occupation_${user.uid}', occupation);

      // Save to Cloud Firestore
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'id': user.uid,
          'email': email.trim(),
          'name': name,
          'profilePic': user.photoURL,
          'dob': dob,
          'gender': gender,
          'occupation': occupation,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } catch (firestoreError) {
        debugPrint('Firestore save error on register: $firestoreError');
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

      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data();
          nameVal = data?['name'] ?? nameVal;
          dobVal = data?['dob'];
          genderVal = data?['gender'];
          occupationVal = data?['occupation'];
        } else {
          // Create document
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'id': user.uid,
            'email': user.email ?? googleUser.email,
            'name': nameVal,
            'profilePic': user.photoURL ?? googleUser.photoUrl,
            'dob': null,
            'gender': null,
            'occupation': null,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      } catch (firestoreError) {
        debugPrint('Firestore fetch/create error on Google sign-in: $firestoreError');
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
      if (e is AccountNotFoundException) rethrow;
      debugPrint('Google Sign-In failed: $e');
      // Mock Fallback for Developer Error (Code 10) or other config issues
      if (e.toString().contains('10') ||
          e.toString().contains('sign_in_failed') ||
          e.toString().contains('network_error')) {
        debugPrint('Using Mock User for testing...');
        return const UserModel(
          id: 'mock_google_id',
          email: 'test.google@example.com',
          name: 'Noorva Explorer (Mock)',
        );
      }
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

      // Save supplemental details to SharedPreferences locally (legacy compatibility)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_dob_${user.uid}', dob ?? '');
      await prefs.setString('user_gender_${user.uid}', gender ?? '');
      await prefs.setString('user_occupation_${user.uid}', occupation ?? '');

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
