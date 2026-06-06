import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:leksika/core/errors/failures.dart';
import 'package:leksika/features/auth/domain/repositories/auth_repository.dart';

class VerifyForgotOtpParams extends Equatable {
  const VerifyForgotOtpParams({required this.email, required this.otp});

  final String email;
  final String otp;

  @override
  List<Object?> get props => [email, otp];
}

class VerifyForgotOtpUsecase {
  VerifyForgotOtpUsecase(this.repository);

  final AuthRepository repository;

  Future<Either<Failure, String>> call(VerifyForgotOtpParams params) =>
      repository.verifyForgotOtp(email: params.email, otp: params.otp);
}
