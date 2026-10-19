import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/otp_service.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;

  // Starts loading so the splash screen waits for the saved-session check.
  AuthBloc(this._repository) : super(const AuthState(isLoading: true)) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthGoogleSignInRequested>(_onGoogleSignInRequested);
    on<AuthAppleSignInRequested>(_onAppleSignInRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthPendingRegisterDataSet>(_onPendingRegisterDataSet);
    on<AuthPendingProfileDataSet>(_onPendingProfileDataSet);
    on<AuthSignupOtpRequested>(_onSignupOtpRequested);
    on<AuthPasswordResetOtpRequested>(_onPasswordResetOtpRequested);
    on<AuthOtpVerifyRequested>(_onOtpVerifyRequested);
    on<AuthResetPasswordRequested>(_onResetPasswordRequested);
    on<AuthProfileUpdateRequested>(_onProfileUpdateRequested);
    on<AuthSignupRequested>(_onSignupRequested);
    on<AuthVerificationEmailResendRequested>(_onVerificationEmailResendRequested);
    on<AuthEmailVerificationCheckRequested>(_onEmailVerificationCheckRequested);
    on<AuthPasswordResetEmailRequested>(_onPasswordResetEmailRequested);

    add(const AuthCheckRequested());
  }

  Future<void> _onCheckRequested(AuthCheckRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final user = await _repository.getCurrentUser();
      emit(state.copyWith(isLoading: false, user: user));
    } catch (e) {
      debugPrint('AuthBloc initialization error: $e');
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _onLoginRequested(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isLoading: true, clearError: true, status: AuthStatus.initial));
    try {
      final user = await _repository.login(event.email, event.password);
      emit(state.copyWith(isLoading: false, user: user, status: AuthStatus.loginSuccess));
    } on AccountNotFoundException catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString(), status: AuthStatus.accountNotFound));
    } on EmailNotVerifiedException catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        verificationEmail: event.email.trim(),
        status: AuthStatus.emailNotVerified,
      ));
    } catch (e) {
      final message = e.toString().contains('Exception: ')
          ? e.toString().replaceAll('Exception: ', '')
          : 'Login failed: ${e.toString()}';
      debugPrint('Login Error: $e');
      emit(state.copyWith(isLoading: false, errorMessage: message, status: AuthStatus.loginFailure));
    }
  }

  Future<void> _onGoogleSignInRequested(AuthGoogleSignInRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isGoogleLoading: true, clearError: true, status: AuthStatus.initial));
    try {
      final user = await _repository.signInWithGoogle(isSignUp: event.isSignUp);
      emit(state.copyWith(isGoogleLoading: false, user: user, status: AuthStatus.googleSignInSuccess));
    } on AccountNotFoundException catch (e) {
      emit(state.copyWith(isGoogleLoading: false, errorMessage: e.toString(), status: AuthStatus.accountNotFound));
    } catch (e) {
      final message = e.toString().contains('Exception: ')
          ? e.toString().replaceAll('Exception: ', '')
          : 'Google Sign-In failed';
      debugPrint('Google Sign In Error: $e');
      emit(state.copyWith(isGoogleLoading: false, errorMessage: message, status: AuthStatus.googleSignInFailure));
    }
  }

  Future<void> _onAppleSignInRequested(AuthAppleSignInRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isAppleLoading: true, clearError: true, status: AuthStatus.initial));
    try {
      final user = await _repository.signInWithApple();
      emit(state.copyWith(isAppleLoading: false, user: user, status: AuthStatus.appleSignInSuccess));
    } catch (e) {
      final message = e.toString().contains('Exception: ')
          ? e.toString().replaceAll('Exception: ', '')
          : 'Apple Sign-In failed';
      debugPrint('Apple Sign In Error: $e');
      emit(state.copyWith(isAppleLoading: false, errorMessage: message, status: AuthStatus.appleSignInFailure));
    }
  }

  Future<void> _onLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      await _repository.logout();
      emit(state.copyWith(isLoading: false, clearUser: true, status: AuthStatus.logoutSuccess));
    } catch (e) {
      debugPrint('Logout Error: $e');
      emit(state.copyWith(isLoading: false));
    }
  }

  void _onPendingRegisterDataSet(AuthPendingRegisterDataSet event, Emitter<AuthState> emit) {
    emit(state.copyWith(
      pendingName: event.name,
      pendingEmail: event.email,
      pendingPassword: event.password,
    ));
  }

  void _onPendingProfileDataSet(AuthPendingProfileDataSet event, Emitter<AuthState> emit) {
    emit(state.copyWith(
      pendingDob: event.dob,
      pendingGender: event.gender,
      pendingOccupation: event.occupation,
    ));
  }

  Future<void> _onSignupOtpRequested(AuthSignupOtpRequested event, Emitter<AuthState> emit) async {
    if (state.pendingEmail == null) {
      emit(state.copyWith(
        errorMessage: 'No email address set. Please restart registration.',
        status: AuthStatus.signupOtpFailure,
      ));
      return;
    }
    emit(state.copyWith(isOtpLoading: true, clearError: true, status: AuthStatus.initial));
    try {
      await _repository.sendEmailOtp(state.pendingEmail!, purpose: 'verification');
      emit(state.copyWith(
        isOtpLoading: false,
        otpTargetEmail: state.pendingEmail,
        status: AuthStatus.signupOtpSent,
      ));
    } catch (e) {
      final message = e.toString().contains('Exception: ')
          ? e.toString().replaceAll('Exception: ', '')
          : 'Failed to send OTP. Please check your connection.';
      debugPrint('sendSignupOtp error: $e');
      emit(state.copyWith(isOtpLoading: false, errorMessage: message, status: AuthStatus.signupOtpFailure));
    }
  }

  Future<void> _onPasswordResetOtpRequested(AuthPasswordResetOtpRequested event, Emitter<AuthState> emit) async {
    final email = event.email.trim();
    emit(state.copyWith(
      isOtpLoading: true,
      clearError: true,
      recoveryEmail: email,
      status: AuthStatus.initial,
    ));
    try {
      await _repository.sendEmailOtp(email, purpose: 'forgotPassword');
      emit(state.copyWith(isOtpLoading: false, otpTargetEmail: email, status: AuthStatus.passwordResetOtpSent));
    } catch (e) {
      final message = e.toString().contains('Exception: ')
          ? e.toString().replaceAll('Exception: ', '')
          : 'Failed to send OTP. Please check your connection.';
      debugPrint('sendPasswordResetOtp error: $e');
      emit(state.copyWith(isOtpLoading: false, errorMessage: message, status: AuthStatus.passwordResetOtpFailure));
    }
  }

  Future<void> _onOtpVerifyRequested(AuthOtpVerifyRequested event, Emitter<AuthState> emit) async {
    final email = state.otpTargetEmail;
    if (email == null) {
      emit(state.copyWith(
        status: AuthStatus.otpVerificationFailure,
        errorMessage: 'Verification failed. Please try again.',
      ));
      return;
    }
    emit(state.copyWith(isOtpLoading: true, clearError: true, status: AuthStatus.initial));
    try {
      final result = await _repository.verifyEmailOtp(email, event.otp);
      if (result != OtpVerificationResult.success) {
        emit(state.copyWith(
          isOtpLoading: false,
          errorMessage: _otpResultMessage(result),
          status: AuthStatus.otpVerificationFailure,
        ));
        return;
      }

      if (event.flow == 'forgotPassword') {
        emit(state.copyWith(isOtpLoading: false, status: AuthStatus.otpVerifiedForgotPasswordFlow));
        return;
      }

      // register flow: immediately register the pending user
      if (state.pendingEmail == null || state.pendingPassword == null || state.pendingName == null) {
        emit(state.copyWith(
          isOtpLoading: false,
          errorMessage: 'Missing registration details',
          status: AuthStatus.registerFailure,
        ));
        return;
      }
      try {
        final user = await _repository.register(
          email: state.pendingEmail!,
          password: state.pendingPassword!,
          name: state.pendingName!,
          dob: state.pendingDob,
          gender: state.pendingGender,
          occupation: state.pendingOccupation,
        );
        emit(state.copyWith(
          isOtpLoading: false,
          user: user,
          clearPendingRegistration: true,
          status: AuthStatus.otpVerifiedRegisterFlow,
        ));
      } catch (e) {
        final message = e.toString().contains('Exception: ')
            ? e.toString().replaceAll('Exception: ', '')
            : 'Registration failed: ${e.toString()}';
        debugPrint('Registration Error: $e');
        emit(state.copyWith(isOtpLoading: false, errorMessage: message, status: AuthStatus.registerFailure));
      }
    } catch (e) {
      debugPrint('verifyOtp error: $e');
      emit(state.copyWith(
        isOtpLoading: false,
        errorMessage: 'Verification failed. Please try again.',
        status: AuthStatus.otpVerificationFailure,
      ));
    }
  }

  Future<void> _onResetPasswordRequested(AuthResetPasswordRequested event, Emitter<AuthState> emit) async {
    if (state.recoveryEmail == null) {
      emit(state.copyWith(
        errorMessage: 'Recovery session expired. Please enter your email again.',
        status: AuthStatus.resetPasswordFailure,
      ));
      return;
    }
    emit(state.copyWith(isLoading: true, clearError: true, status: AuthStatus.initial));
    try {
      await _repository.resetPassword(email: state.recoveryEmail!, newPassword: event.newPassword);
      emit(state.copyWith(isLoading: false, status: AuthStatus.resetPasswordSuccess));
    } catch (e) {
      debugPrint('Reset Password Error: $e');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Password reset failed.',
        status: AuthStatus.resetPasswordFailure,
      ));
    }
  }

  Future<void> _onProfileUpdateRequested(AuthProfileUpdateRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isLoading: true, clearError: true, status: AuthStatus.initial));
    try {
      final user = await _repository.updateProfile(
        name: event.name,
        email: event.email,
        dob: event.dob,
        gender: event.gender,
        occupation: event.occupation,
      );
      emit(state.copyWith(isLoading: false, user: user, status: AuthStatus.profileUpdateSuccess));
    } catch (e) {
      final message = e.toString().contains('Exception: ')
          ? e.toString().replaceAll('Exception: ', '')
          : 'Profile update failed: ${e.toString()}';
      debugPrint('Profile Update Error: $e');
      emit(state.copyWith(isLoading: false, errorMessage: message, status: AuthStatus.profileUpdateFailure));
    }
  }

  Future<void> _onSignupRequested(AuthSignupRequested event, Emitter<AuthState> emit) async {
    if (state.pendingEmail == null || state.pendingPassword == null || state.pendingName == null) {
      emit(state.copyWith(
        errorMessage: 'Missing registration details. Please restart registration.',
        status: AuthStatus.registerFailure,
      ));
      return;
    }
    emit(state.copyWith(isLoading: true, clearError: true, status: AuthStatus.initial));
    try {
      final email = state.pendingEmail!;
      await _repository.register(
        email: email,
        password: state.pendingPassword!,
        name: state.pendingName!,
        dob: state.pendingDob,
        gender: state.pendingGender,
        occupation: state.pendingOccupation,
      );
      // Not logged in yet: the user is set once the email is verified.
      emit(state.copyWith(
        isLoading: false,
        verificationEmail: email,
        clearPendingRegistration: true,
        status: AuthStatus.verificationEmailSent,
      ));
    } catch (e) {
      final message = e.toString().contains('email-already-in-use')
          ? 'An account with this email already exists. Please log in.'
          : e.toString().contains('Exception: ')
              ? e.toString().replaceAll('Exception: ', '')
              : 'Registration failed: ${e.toString()}';
      debugPrint('Registration Error: $e');
      emit(state.copyWith(isLoading: false, errorMessage: message, status: AuthStatus.registerFailure));
    }
  }

  Future<void> _onVerificationEmailResendRequested(
      AuthVerificationEmailResendRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isLoading: true, clearError: true, status: AuthStatus.initial));
    try {
      await _repository.sendVerificationEmail();
      emit(state.copyWith(isLoading: false, status: AuthStatus.verificationEmailSent));
    } catch (e) {
      final message = e.toString().contains('Exception: ')
          ? e.toString().replaceAll('Exception: ', '')
          : 'Could not send the email. Please try again.';
      debugPrint('Resend verification email error: $e');
      emit(state.copyWith(isLoading: false, errorMessage: message, status: AuthStatus.verificationEmailFailure));
    }
  }

  Future<void> _onEmailVerificationCheckRequested(
      AuthEmailVerificationCheckRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isLoading: true, clearError: true, status: AuthStatus.initial));
    try {
      final user = await _repository.checkEmailVerified();
      if (user == null) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Email not verified yet. Open the link we sent you, then try again.',
          status: AuthStatus.emailVerificationPending,
        ));
        return;
      }
      emit(state.copyWith(isLoading: false, user: user, status: AuthStatus.emailVerified));
    } catch (e) {
      final message = e.toString().contains('Exception: ')
          ? e.toString().replaceAll('Exception: ', '')
          : 'Could not check verification. Please try again.';
      debugPrint('Check email verification error: $e');
      emit(state.copyWith(isLoading: false, errorMessage: message, status: AuthStatus.emailVerificationPending));
    }
  }

  Future<void> _onPasswordResetEmailRequested(
      AuthPasswordResetEmailRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isLoading: true, clearError: true, status: AuthStatus.initial));
    try {
      await _repository.forgotPassword(event.email);
      emit(state.copyWith(isLoading: false, status: AuthStatus.passwordResetEmailSent));
    } catch (e) {
      final message = e.toString().contains('invalid-email')
          ? 'Please enter a valid email address.'
          : 'Could not send the reset link. Please try again.';
      debugPrint('Password reset email error: $e');
      emit(state.copyWith(isLoading: false, errorMessage: message, status: AuthStatus.passwordResetEmailFailure));
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
