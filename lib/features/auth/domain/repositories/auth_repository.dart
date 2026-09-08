import '../entities/user_entity.dart';
import '../../../../core/services/otp_service.dart';

abstract class AuthRepository {
  Future<UserEntity> login(String email, String password);
  Future<UserEntity> signInWithGoogle();
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

  /// Generates a 6-digit OTP, stores it in Firestore, and sends it to [email].
  /// [purpose] is either `'verification'` (signup) or `'forgotPassword'`.
  Future<void> sendEmailOtp(String email, {String purpose});

  /// Verifies [otp] for [email] against the Firestore record.
  Future<OtpVerificationResult> verifyEmailOtp(String email, String otp);
}

