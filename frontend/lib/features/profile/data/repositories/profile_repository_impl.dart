import 'package:dartz/dartz.dart';
import 'package:leksika/core/errors/exceptions.dart';
import 'package:leksika/core/errors/failures.dart';
import 'package:leksika/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:leksika/features/profile/domain/entities/profile_entity.dart';
import 'package:leksika/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this.remoteDataSource);

  final ProfileRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, ProfileEntity>> getProfile() async {
    try {
      final profile = await remoteDataSource.getProfile();
      return Right(profile);
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } on EmailNotVerifiedException {
      return Left(EmailNotVerifiedFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, ProfileEntity>> updateProfile({
    String? name,
    String? bio,
    String? institution,
    String? address,
  }) async {
    try {
      final profile = await remoteDataSource.updateProfile(
        name: name,
        bio: bio,
        institution: institution,
        address: address,
      );
      return Right(profile);
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } on EmailNotVerifiedException {
      return Left(EmailNotVerifiedFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, ProfileEntity>> uploadPhoto(String filePath) async {
    try {
      final profile = await remoteDataSource.uploadPhoto(filePath);
      return Right(profile);
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } on EmailNotVerifiedException {
      return Left(EmailNotVerifiedFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
