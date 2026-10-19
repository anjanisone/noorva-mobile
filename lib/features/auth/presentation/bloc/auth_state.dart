import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

enum AuthStatus {
  initial,
  loginSuccess,
  loginFailure,
  accountNotFound,
  googleSignInSuccess,
  googleSignInFailure,
  appleSignInSuccess,
  appleSignInFailure,
  signupOtpSent,
  signupOtpFailure,
  passwordResetOtpSent,
  passwordResetOtpFailure,
  otpVerifiedRegisterFlow,
  otpVerifiedForgotPasswordFlow,
  otpVerificationFailure,
  registerFailure,
  resetPasswordSuccess,
  resetPasswordFailure,
  profileUpdateSuccess,
  profileUpdateFailure,
  logoutSuccess,
  verificationEmailSent,
  verificationEmailFailure,
  emailNotVerified,
  emailVerificationPending,
  emailVerified,
  passwordResetEmailSent,
  passwordResetEmailFailure,
}

class AuthState extends Equatable {
  final UserEntity? user;
  final bool isLoading;
  final bool isGoogleLoading;
  final bool isAppleLoading;
  final bool isOtpLoading;
  final String? errorMessage;
  final AuthStatus status;

  // Temporary fields for multi-step registration flow
  final String? pendingName;
  final String? pendingEmail;
  final String? pendingPassword;
  final String? pendingDob;
  final String? pendingGender;
  final String? pendingOccupation;

  // Stored email for forgot/reset password flow
  final String? recoveryEmail;

  /// The email that has an active OTP pending verification.
  final String? otpTargetEmail;

  /// The email the verification link was sent to.
  final String? verificationEmail;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.isGoogleLoading = false,
    this.isAppleLoading = false,
    this.isOtpLoading = false,
    this.errorMessage,
    this.status = AuthStatus.initial,
    this.pendingName,
    this.pendingEmail,
    this.pendingPassword,
    this.pendingDob,
    this.pendingGender,
    this.pendingOccupation,
    this.recoveryEmail,
    this.otpTargetEmail,
    this.verificationEmail,
  });

  AuthState copyWith({
    UserEntity? user,
    bool clearUser = false,
    bool? isLoading,
    bool? isGoogleLoading,
    bool? isAppleLoading,
    bool? isOtpLoading,
    String? errorMessage,
    bool clearError = false,
    AuthStatus? status,
    String? pendingName,
    String? pendingEmail,
    String? pendingPassword,
    String? pendingDob,
    String? pendingGender,
    String? pendingOccupation,
    bool clearPendingRegistration = false,
    String? recoveryEmail,
    String? otpTargetEmail,
    String? verificationEmail,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      isGoogleLoading: isGoogleLoading ?? this.isGoogleLoading,
      isAppleLoading: isAppleLoading ?? this.isAppleLoading,
      isOtpLoading: isOtpLoading ?? this.isOtpLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      status: status ?? this.status,
      pendingName: clearPendingRegistration ? null : (pendingName ?? this.pendingName),
      pendingEmail: clearPendingRegistration ? null : (pendingEmail ?? this.pendingEmail),
      pendingPassword: clearPendingRegistration ? null : (pendingPassword ?? this.pendingPassword),
      pendingDob: clearPendingRegistration ? null : (pendingDob ?? this.pendingDob),
      pendingGender: clearPendingRegistration ? null : (pendingGender ?? this.pendingGender),
      pendingOccupation: clearPendingRegistration ? null : (pendingOccupation ?? this.pendingOccupation),
      recoveryEmail: recoveryEmail ?? this.recoveryEmail,
      otpTargetEmail: otpTargetEmail ?? this.otpTargetEmail,
      verificationEmail: verificationEmail ?? this.verificationEmail,
    );
  }

  @override
  List<Object?> get props => [
        user,
        isLoading,
        isGoogleLoading,
        isAppleLoading,
        isOtpLoading,
        errorMessage,
        status,
        pendingName,
        pendingEmail,
        pendingPassword,
        pendingDob,
        pendingGender,
        pendingOccupation,
        recoveryEmail,
        otpTargetEmail,
        verificationEmail,
      ];
}
