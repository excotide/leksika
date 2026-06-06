import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class FetchNotificationsRequested extends NotificationEvent {
  const FetchNotificationsRequested();
}

class MarkNotificationReadRequested extends NotificationEvent {
  const MarkNotificationReadRequested(this.id);

  final int id;

  @override
  List<Object?> get props => [id];
}

class MarkAllNotificationsReadRequested extends NotificationEvent {
  const MarkAllNotificationsReadRequested();
}
