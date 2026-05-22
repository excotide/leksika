import 'package:dartz/dartz.dart';
import 'package:leksika/core/errors/failures.dart';
import 'package:leksika/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  });

  Future<Either<Failure, void>> verifyOtp({
    required String otp,
  });

  Future<Either<Failure, void>> resendOtp();

  Future<Either<Failure, UserEntity>> getUser();

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, UserEntity>> loginWithGoogle(String idToken);
}
