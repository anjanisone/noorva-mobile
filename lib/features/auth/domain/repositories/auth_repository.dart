import '../entities/user_entity.dart';
import '../../../../core/services/otp_service.dart';

/// Thrown when a sign-in is attempted for an account that does not exist yet.
class AccountNotFoundException implements Exception {
  const AccountNotFoundException();

  @override
  String toString() => 'No account found. Please sign up first.';
}

/// Thrown when an email/password user signs in before clicking the
/// verification link. The user stays signed in so the link can be resent.
class EmailNotVerifiedException implements Exception {
  const EmailNotVerifiedException();

  @override
  String toString() => 'Please verify your email before logging in.';
}

abstract class AuthRepository {
  Future<UserEntity> login(String email, String password);
  /// With [isSignUp] false, a Google account that has no Noorva account yet
  /// throws [AccountNotFoundException] instead of being created.
  Future<UserEntity> signInWithGoogle({bool isSignUp = false});
  Future<UserEntity> signInWithApple();
  Future<void> logout();
  Future<void> forgotPassword(String email);
  Future<UserEntity> register({
    required String email,
    required String password,
    required String name,
    String? dob,
    String? gender,
    String? occupation,
  });
  Future<void> resetPassword({required String email, required String newPassword});
  Future<UserEntity> updateProfile({
    required String name,
    required String email,
    String? dob,
    String? gender,
    String? occupation,
  });
  Future<UserEntity?> getCurrentUser();

  /// Sends Firebase's verification link to the signed-in user's email.
  Future<void> sendVerificationEmail();

  /// Reloads the signed-in user; returns the profile once the email is
  /// verified, or null if the link hasn't been clicked yet.
  Future<UserEntity?> checkEmailVerified();

  /// Generates a 6-digit OTP, stores it in Firestore, and sends it to [email].
  /// [purpose] is either `'verification'` (signup) or `'forgotPassword'`.
  Future<void> sendEmailOtp(String email, {String purpose});

  /// Verifies [otp] for [email] against the Firestore record.
  Future<OtpVerificationResult> verifyEmailOtp(String email, String otp);
}

