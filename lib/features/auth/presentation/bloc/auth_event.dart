import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class AuthGoogleSignInRequested extends AuthEvent {
  const AuthGoogleSignInRequested();
}

class AuthAppleSignInRequested extends AuthEvent {
  const AuthAppleSignInRequested();
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthPendingRegisterDataSet extends AuthEvent {
  final String name;
  final String email;
  final String password;

  const AuthPendingRegisterDataSet({
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [name, email, password];
}

class AuthPendingProfileDataSet extends AuthEvent {
  final String dob;
  final String gender;
  final String occupation;

  const AuthPendingProfileDataSet({
    required this.dob,
    required this.gender,
    required this.occupation,
  });

  @override
  List<Object?> get props => [dob, gender, occupation];
}

class AuthSignupOtpRequested extends AuthEvent {
  const AuthSignupOtpRequested();
}

class AuthPasswordResetOtpRequested extends AuthEvent {
  final String email;

  const AuthPasswordResetOtpRequested(this.email);

  @override
  List<Object?> get props => [email];
}

class AuthOtpVerifyRequested extends AuthEvent {
  final String otp;
  final String flow; // 'register' | 'forgotPassword'

  const AuthOtpVerifyRequested(this.otp, {required this.flow});

  @override
  List<Object?> get props => [otp, flow];
}

class AuthResetPasswordRequested extends AuthEvent {
  final String newPassword;

  const AuthResetPasswordRequested(this.newPassword);

  @override
  List<Object?> get props => [newPassword];
}

class AuthProfileUpdateRequested extends AuthEvent {
  final String name;
  final String email;
  final String? dob;
  final String? gender;
  final String? occupation;

  const AuthProfileUpdateRequested({
    required this.name,
    required this.email,
    this.dob,
    this.gender,
    this.occupation,
  });

  @override
  List<Object?> get props => [name, email, dob, gender, occupation];
}
