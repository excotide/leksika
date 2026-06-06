import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:leksika/core/errors/failures.dart';
import 'package:leksika/features/auth/domain/repositories/auth_repository.dart';

class ResetPasswordParams extends Equatable {
  const ResetPasswordParams({
    required this.email,
    required this.resetToken,
    required this.password,
    required this.passwordConfirmation,
  });

  final String email;
  final String resetToken;
  final String password;
  final String passwordConfirmation;

  @override
  List<Object?> get props => [email, resetToken, password, passwordConfirmation];
}

class ResetPasswordUsecase {
  ResetPasswordUsecase(this.repository);

  final AuthRepository repository;

  Future<Either<Failure, void>> call(ResetPasswordParams params) =>
      repository.resetPassword(
        email: params.email,
        resetToken: params.resetToken,
        password: params.password,
        passwordConfirmation: params.passwordConfirmation,
      );
}
