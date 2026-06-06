import 'package:equatable/equatable.dart';
import 'package:leksika/features/summary/domain/entities/notification_entity.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

class NotificationLoaded extends NotificationState {
  const NotificationLoaded(this.notifications);

  final List<NotificationEntity> notifications;

  @override
  List<Object?> get props => [notifications];
}

class NotificationFailure extends NotificationState {
  const NotificationFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
