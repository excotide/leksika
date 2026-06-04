import 'package:dartz/dartz.dart';
import 'package:leksika/core/errors/failures.dart';
import 'package:leksika/features/profile/domain/entities/profile_entity.dart';
import 'package:leksika/features/profile/domain/repositories/profile_repository.dart';

class UploadPhotoUsecase {
  final ProfileRepository repository;
  UploadPhotoUsecase(this.repository);

  Future<Either<Failure, ProfileEntity>> call(String filePath) {
    return repository.uploadPhoto(filePath);
  }
}
