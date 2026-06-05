import 'package:dartz/dartz.dart';
import 'package:leksika/core/errors/failures.dart';
import 'package:leksika/features/profile/domain/entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<Either<Failure, ProfileEntity>> getProfile();

  Future<Either<Failure, ProfileEntity>> updateProfile({
    String? name,
    String? bio,
    String? institution,
    String? address,
  });

  Future<Either<Failure, ProfileEntity>> uploadPhoto(String filePath);
}
