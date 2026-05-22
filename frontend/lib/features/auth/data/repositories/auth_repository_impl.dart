import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:leksika/core/errors/exceptions.dart';
import 'package:leksika/core/errors/failures.dart';
import 'package:leksika/core/storage/secure_storage.dart';
import 'package:leksika/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:leksika/features/auth/domain/entities/user_entity.dart';
import 'package:leksika/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.secureStorage,
  });

  final AuthRemoteDataSource remoteDataSource;
  final SecureStorage secureStorage;

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.login(
        email: email,
        password: password,
      );
      await _persistToken(user.token);
      return Right(user);
    } on EmailNotVerifiedException {
      return Left(EmailNotVerifiedFailure());
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final user = await remoteDataSource.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      await _persistToken(user.token);
      return Right(user);
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> verifyOtp({required String otp}) async {
    try {
      await remoteDataSource.verifyOtp(otp: otp);
      return const Right(null);
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> resendOtp() async {
    try {
      await remoteDataSource.resendOtp();
      return const Right(null);
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  Future<void> _persistToken(String? token) async {
    if (token == null || token.isEmpty) {
      throw ServerException();
    }
    await secureStorage.saveToken(token);
  }

  @override
  Future<Either<Failure, UserEntity>> getUser() async {
    try {
      final user = await remoteDataSource.getUser();
      return Right(user);
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

 @override
  Future<Either<Failure, void>> logout() async {
    try {
      try {
        await remoteDataSource.logout();
      } catch (e) {
        debugPrint("Remote logout failed, proceeding with local clear.");
      }
      
      await secureStorage.clearToken(); 
      
      return const Right(null); 
    } catch (e) {
      await secureStorage.clearToken();
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, UserEntity>> loginWithGoogle(String idToken) async {
    try {
      final user = await remoteDataSource.loginWithGoogle(idToken);
      await _persistToken(user.token);
      return Right(user);
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
