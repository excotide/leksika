import 'package:dartz/dartz.dart';
import 'package:leksika/core/errors/failures.dart';
import 'package:leksika/features/summary/domain/entities/notification_entity.dart';
import 'package:leksika/features/summary/domain/repositories/notification_repository.dart';

class GetNotificationsUsecase {
  GetNotificationsUsecase(this.repository);

  final NotificationRepository repository;

  Future<Either<Failure, List<NotificationEntity>>> call() {
    return repository.getNotifications();
  }
}

class MarkNotificationAsReadUsecase {
  MarkNotificationAsReadUsecase(this.repository);

  final NotificationRepository repository;

  Future<Either<Failure, void>> call(int id) {
    return repository.markAsRead(id);
  }
}

class MarkAllNotificationsAsReadUsecase {
  MarkAllNotificationsAsReadUsecase(this.repository);

  final NotificationRepository repository;

  Future<Either<Failure, void>> call() {
    return repository.markAllAsRead();
  }
}
