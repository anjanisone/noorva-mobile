import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/otp_service.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;

  AuthBloc(this._repository) : super(const AuthState()) {
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
      final user = await _repository.signInWithGoogle();
      emit(state.copyWith(isGoogleLoading: false, user: user, status: AuthStatus.googleSignInSuccess));
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
