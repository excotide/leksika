import 'package:equatable/equatable.dart';
import 'package:leksika/features/auth/domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  const Authenticated(this.user);

  final UserEntity user;

  @override
  List<Object?> get props => [user];
}

class OtpVerified extends AuthState {
  const OtpVerified();
}

class OtpResent extends AuthState {
  const OtpResent();
}

class AuthFailure extends AuthState {
  const AuthFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class AuthEmailNotVerified extends AuthState {
  const AuthEmailNotVerified(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class UserLoaded extends AuthState {
  const UserLoaded(this.user);
  final UserEntity user;

  @override
  List<Object?> get props => [user];
}

class GoogleLoginLoading extends AuthState {}
class GoogleLoginSuccess extends AuthState {}
class GoogleLoginFailure extends AuthState {
  final String message;
  const GoogleLoginFailure(this.message);
}