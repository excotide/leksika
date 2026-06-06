import 'package:dartz/dartz.dart';
import 'package:leksika/core/errors/failures.dart';
import 'package:leksika/features/summary/domain/entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<Either<Failure, List<NotificationEntity>>> getNotifications();

  Future<Either<Failure, void>> markAsRead(int id);

  Future<Either<Failure, void>> markAllAsRead();
}
