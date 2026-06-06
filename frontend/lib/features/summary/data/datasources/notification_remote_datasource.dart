import 'package:dio/dio.dart';
import 'package:leksika/core/errors/exceptions.dart';
import 'package:leksika/features/summary/data/models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications();

  Future<void> markAsRead(int id);

  Future<void> markAllAsRead();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  NotificationRemoteDataSourceImpl(this.dio);

  final Dio dio;

  @override
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await dio.get('/notifications');
      final data = response.data as Map<String, dynamic>;
      return (data['data'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(NotificationModel.fromJson)
          .toList();
    } on DioException catch (error) {
      _handleDioError(error);
    }
  }

  @override
  Future<void> markAsRead(int id) async {
    try {
      await dio.put('/notifications/$id/read');
    } on DioException catch (error) {
      _handleDioError(error);
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      await dio.put('/notifications/read-all');
    } on DioException catch (error) {
      _handleDioError(error);
    }
  }

  Never _handleDioError(DioException error) {
    final statusCode = error.response?.statusCode ?? 0;
    if (statusCode == 401) {
      throw UnauthorizedException();
    }
    if (statusCode == 403) {
      throw EmailNotVerifiedException();
    }
    throw ServerException();
  }
}
