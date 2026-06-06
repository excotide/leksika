import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:leksika/core/navigation/app_navigator.dart';
import 'package:leksika/core/services/in_app_notification_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class FcmNotificationService {
  FcmNotificationService(this._dio);

  final Dio _dio;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    if (kIsWeb) return;

    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen(_showForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_openNotificationPage);
    FirebaseMessaging.instance.onTokenRefresh.listen(_sendTokenToBackend);

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _openNotificationPage(initialMessage);
    }
  }

  Future<void> registerCurrentToken() async {
    if (kIsWeb) return;
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null && token.isNotEmpty) {
      await _sendTokenToBackend(token);
    }
  }

  Future<void> unregisterCurrentToken() async {
    if (kIsWeb) return;
    final token = await FirebaseMessaging.instance.getToken();
    if (token == null || token.isEmpty) return;

    try {
      await _dio.delete('/fcm-token', data: {'token': token});
    } on DioException {
      // Token cleanup should not block logout or normal navigation.
    }
  }

  Future<void> _sendTokenToBackend(String token) async {
    try {
      await _dio.post('/fcm-token', data: {'token': token});
    } on DioException {
      // This can happen before the user logs in. Register again after auth.
    }
  }

  void _showForegroundMessage(RemoteMessage message) {
    final title = message.notification?.title ?? message.data['title'] ?? 'Notifikasi';
    final body = message.notification?.body ?? message.data['body'] ?? message.data['message'] ?? '';

    InAppNotificationService.show(
      title: title,
      body: body,
      onTap: () => _openNotificationPage(message),
    );
  }

  void _openNotificationPage(RemoteMessage message) {
    final navigator = appNavigatorKey.currentState;
    if (navigator == null) return;
    navigator.pushNamed('/notifikasi');
  }

}
