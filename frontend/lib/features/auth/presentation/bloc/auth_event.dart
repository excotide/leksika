import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  const LoginRequested({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  const RegisterRequested({
    required this.name,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
  });

  final String name;
  final String email;
  final String password;
  final String passwordConfirmation;

  @override
  List<Object?> get props => [name, email, password, passwordConfirmation];
}

class VerifyOtpRequested extends AuthEvent {
  const VerifyOtpRequested({
    required this.otp,
  });

  final String otp;

  @override
  List<Object?> get props => [otp];
}

class ResendOtpRequested extends AuthEvent {
  const ResendOtpRequested();
}

class FetchUserRequested extends AuthEvent {
  const FetchUserRequested();
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

class GoogleLoginRequested extends AuthEvent {
  final String idToken;
  const GoogleLoginRequested(this.idToken);
}