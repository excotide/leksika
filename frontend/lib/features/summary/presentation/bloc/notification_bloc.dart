import 'package:bloc/bloc.dart';
import 'package:leksika/core/errors/failures.dart';
import 'package:leksika/features/summary/domain/entities/notification_entity.dart';
import 'package:leksika/features/summary/domain/usecases/notification_usecases.dart';
import 'package:leksika/features/summary/presentation/bloc/notification_event.dart';
import 'package:leksika/features/summary/presentation/bloc/notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc({
    required this.getNotificationsUsecase,
    required this.markNotificationAsReadUsecase,
    required this.markAllNotificationsAsReadUsecase,
  }) : super(const NotificationInitial()) {
    on<FetchNotificationsRequested>(_onFetchNotifications);
    on<MarkNotificationReadRequested>(_onMarkNotificationRead);
    on<MarkAllNotificationsReadRequested>(_onMarkAllNotificationsRead);
  }

  final GetNotificationsUsecase getNotificationsUsecase;
  final MarkNotificationAsReadUsecase markNotificationAsReadUsecase;
  final MarkAllNotificationsAsReadUsecase markAllNotificationsAsReadUsecase;

  Future<void> _onFetchNotifications(
    FetchNotificationsRequested event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading());
    final result = await getNotificationsUsecase();
    result.fold(
      (failure) => emit(NotificationFailure(_mapFailure(failure))),
      (notifications) => emit(NotificationLoaded(notifications)),
    );
  }

  Future<void> _onMarkNotificationRead(
    MarkNotificationReadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    final current = state;
    if (current is NotificationLoaded) {
      emit(NotificationLoaded(_markOneLocal(current.notifications, event.id)));
    }

    final result = await markNotificationAsReadUsecase(event.id);
    result.fold(
      (failure) => emit(NotificationFailure(_mapFailure(failure))),
      (_) => add(const FetchNotificationsRequested()),
    );
  }

  Future<void> _onMarkAllNotificationsRead(
    MarkAllNotificationsReadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    final current = state;
    if (current is NotificationLoaded) {
      emit(NotificationLoaded(_markAllLocal(current.notifications)));
    }

    final result = await markAllNotificationsAsReadUsecase();
    result.fold(
      (failure) => emit(NotificationFailure(_mapFailure(failure))),
      (_) => add(const FetchNotificationsRequested()),
    );
  }

  List<NotificationEntity> _markOneLocal(
    List<NotificationEntity> notifications,
    int id,
  ) {
    return notifications
        .map(
          (notification) => notification.id == id
              ? NotificationEntity(
                  id: notification.id,
                  documentId: notification.documentId,
                  title: notification.title,
                  message: notification.message,
                  type: notification.type,
                  isRead: true,
                  createdAt: notification.createdAt,
                )
              : notification,
        )
        .toList();
  }

  List<NotificationEntity> _markAllLocal(
    List<NotificationEntity> notifications,
  ) {
    return notifications
        .map(
          (notification) => NotificationEntity(
            id: notification.id,
            documentId: notification.documentId,
            title: notification.title,
            message: notification.message,
            type: notification.type,
            isRead: true,
            createdAt: notification.createdAt,
          ),
        )
        .toList();
  }

  String _mapFailure(Failure failure) {
    if (failure is EmailNotVerifiedFailure) {
      return 'Email belum diverifikasi. Silakan verifikasi OTP.';
    }
    if (failure is UnauthorizedFailure) {
      return 'Sesi berakhir. Silakan login kembali.';
    }
    return 'Gagal memuat notifikasi. Silakan coba lagi.';
  }
}
