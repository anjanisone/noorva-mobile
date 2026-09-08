import 'package:flutter/material.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/services/otp_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;
  UserEntity? _user;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _isAppleLoading = false;

  AuthProvider(this._repository) {
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    _isLoading = true;
    notifyListeners();
    try {
      _user = await _repository.getCurrentUser();
    } catch (e) {
      debugPrint('AuthProvider initialization error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  UserEntity? get user => _user;
  bool get isLoading => _isLoading;
  bool get isGoogleLoading => _isGoogleLoading;
  bool get isAppleLoading => _isAppleLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Temporary fields for multi-step registration flow
  String? _pendingName;
  String? _pendingEmail;
  String? _pendingPassword;
  String? _pendingDob;
  String? _pendingGender;
  String? _pendingOccupation;

  // Stored email for forgot/reset password flow
  String? _recoveryEmail;

  // ── OTP state ──────────────────────────────────────────────────────────────
  bool _isOtpLoading = false;
  bool get isOtpLoading => _isOtpLoading;

  /// The email that has an active OTP pending verification.
  String? _otpTargetEmail;
  String? get otpTargetEmail => _otpTargetEmail;

  void setPendingRegisterData({
    required String name,
    required String email,
    required String password,
  }) {
    _pendingName = name;
    _pendingEmail = email;
    _pendingPassword = password;
  }

  void setPendingProfileData({
    required String dob,
    required String gender,
    required String occupation,
  }) {
    _pendingDob = dob;
    _pendingGender = gender;
    _pendingOccupation = occupation;
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _user = await _repository.login(email, password);
      return _user != null;
    } catch (e) {
      _errorMessage = e.toString().contains('Exception: ') 
          ? e.toString().replaceAll('Exception: ', '') 
          : 'Login failed: ${e.toString()}';
      debugPrint('Login Error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> registerPendingUser() async {
    if (_pendingEmail == null || _pendingPassword == null || _pendingName == null) {
      _errorMessage = 'Missing registration details';
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _user = await _repository.register(
        email: _pendingEmail!,
        password: _pendingPassword!,
        name: _pendingName!,
        dob: _pendingDob,
        gender: _pendingGender,
        occupation: _pendingOccupation,
      );
      // Clear pending state
      _pendingName = null;
      _pendingEmail = null;
      _pendingPassword = null;
      _pendingDob = null;
      _pendingGender = null;
      _pendingOccupation = null;
      return _user != null;
    } catch (e) {
      _errorMessage = e.toString().contains('Exception: ') 
          ? e.toString().replaceAll('Exception: ', '') 
          : 'Registration failed: ${e.toString()}';
      debugPrint('Registration Error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    _recoveryEmail = email;
    notifyListeners();
    try {
      await _repository.forgotPassword(email);
      return true;
    } catch (e) {
      _errorMessage = e.toString().contains('Exception: ') 
          ? e.toString().replaceAll('Exception: ', '') 
          : 'Forgot password request failed';
      debugPrint('Forgot Password Error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> resetPassword(String newPassword) async {
    if (_recoveryEmail == null) {
      _errorMessage = 'Recovery session expired. Please enter your email again.';
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.resetPassword(email: _recoveryEmail!, newPassword: newPassword);
      return true;
    } catch (e) {
      _errorMessage = e.toString().contains('Exception: ') 
          ? e.toString().replaceAll('Exception: ', '') 
          : 'Password reset failed';
      debugPrint('Reset Password Error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signInWithGoogle() async {
    _isGoogleLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _user = await _repository.signInWithGoogle();
      return _user != null;
    } catch (e) {
      _errorMessage = e.toString().contains('Exception: ') 
          ? e.toString().replaceAll('Exception: ', '') 
          : 'Google Sign-In failed';
      debugPrint('Google Sign In Error: $e');
      return false;
    } finally {
      _isGoogleLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signInWithApple() async {
    _isAppleLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _user = await _repository.signInWithApple();
      return _user != null;
    } catch (e) {
      _errorMessage = e.toString().contains('Exception: ') 
          ? e.toString().replaceAll('Exception: ', '') 
          : 'Apple Sign-In failed';
      debugPrint('Apple Sign In Error: $e');
      return false;
    } finally {
      _isAppleLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.logout();
      _user = null;
    } catch (e) {
      debugPrint('Logout Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateUserProfile({
    required String name,
    required String email,
    String? dob,
    String? gender,
    String? occupation,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _user = await _repository.updateProfile(
        name: name,
        email: email,
        dob: dob,
        gender: gender,
        occupation: occupation,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString().contains('Exception: ')
          ? e.toString().replaceAll('Exception: ', '')
          : 'Profile update failed: ${e.toString()}';
      debugPrint('Profile Update Error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── OTP Methods ────────────────────────────────────────────────────────────

  /// Sends a signup OTP to the pending registration email.
  /// Must be called after [setPendingRegisterData].
  Future<bool> sendSignupOtp() async {
    if (_pendingEmail == null) {
      _errorMessage = 'No email address set. Please restart registration.';
      notifyListeners();
      return false;
    }
    _isOtpLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.sendEmailOtp(
        _pendingEmail!,
        purpose: 'verification',
      );
      _otpTargetEmail = _pendingEmail;
      return true;
    } catch (e) {
      _errorMessage = e.toString().contains('Exception: ')
          ? e.toString().replaceAll('Exception: ', '')
          : 'Failed to send OTP. Please check your connection.';
      debugPrint('sendSignupOtp error: $e');
      return false;
    } finally {
      _isOtpLoading = false;
      notifyListeners();
    }
  }

  /// Sends a password-reset OTP to [email].
  Future<bool> sendPasswordResetOtp(String email) async {
    _isOtpLoading = true;
    _errorMessage = null;
    _recoveryEmail = email.trim();
    notifyListeners();
    try {
      await _repository.sendEmailOtp(
        email,
        purpose: 'forgotPassword',
      );
      _otpTargetEmail = email.trim();
      return true;
    } catch (e) {
      _errorMessage = e.toString().contains('Exception: ')
          ? e.toString().replaceAll('Exception: ', '')
          : 'Failed to send OTP. Please check your connection.';
      debugPrint('sendPasswordResetOtp error: $e');
      return false;
    } finally {
      _isOtpLoading = false;
      notifyListeners();
    }
  }

  /// Verifies the OTP the user entered.
  /// [flow] must be `'register'` or `'forgotPassword'`.
  Future<OtpVerificationResult> verifyOtp(String otp, {required String flow}) async {
    final email = _otpTargetEmail;
    if (email == null) {
      return OtpVerificationResult.error;
    }
    _isOtpLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final result = await _repository.verifyEmailOtp(email, otp);
      if (result != OtpVerificationResult.success) {
        _errorMessage = _otpResultMessage(result);
      }
      return result;
    } catch (e) {
      _errorMessage = 'Verification failed. Please try again.';
      debugPrint('verifyOtp error: $e');
      return OtpVerificationResult.error;
    } finally {
      _isOtpLoading = false;
      notifyListeners();
    }
  }

  String _otpResultMessage(OtpVerificationResult result) {
    switch (result) {
      case OtpVerificationResult.invalid:
        return "The code you entered doesn't match. Please check and try again.";
      case OtpVerificationResult.expired:
        return 'This code has expired. Please request a new one.';
      case OtpVerificationResult.tooManyAttempts:
        return 'Too many incorrect attempts. Please request a new code.';
      case OtpVerificationResult.notFound:
        return 'No verification code found. Please request a new one.';
      default:
        return 'Verification failed. Please try again.';
    }
  }
}
