import 'package:dartz/dartz.dart';
import 'package:leksika/core/errors/failures.dart';
import 'package:leksika/features/auth/domain/repositories/auth_repository.dart';
import 'package:leksika/features/auth/domain/entities/user_entity.dart';

class GoogleLoginUsecase {
  final AuthRepository repository;
  GoogleLoginUsecase(this.repository);

  Future<Either<Failure, UserEntity>> call(String idToken) {
    return repository.loginWithGoogle(idToken);
  }
}