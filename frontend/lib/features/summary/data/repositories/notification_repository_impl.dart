import 'package:dartz/dartz.dart';
import 'package:leksika/core/errors/exceptions.dart';
import 'package:leksika/core/errors/failures.dart';
import 'package:leksika/features/summary/data/datasources/notification_remote_datasource.dart';
import 'package:leksika/features/summary/domain/entities/notification_entity.dart';
import 'package:leksika/features/summary/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this.remoteDataSource);

  final NotificationRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, List<NotificationEntity>>> getNotifications() async {
    try {
      final notifications = await remoteDataSource.getNotifications();
      return Right(notifications);
    } on EmailNotVerifiedException {
      return Left(EmailNotVerifiedFailure());
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(int id) async {
    try {
      await remoteDataSource.markAsRead(id);
      return const Right(null);
    } on EmailNotVerifiedException {
      return Left(EmailNotVerifiedFailure());
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> markAllAsRead() async {
    try {
      await remoteDataSource.markAllAsRead();
      return const Right(null);
    } on EmailNotVerifiedException {
      return Left(EmailNotVerifiedFailure());
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } on ServerException {
      return Left(ServerFailure());
    }
  }
}
