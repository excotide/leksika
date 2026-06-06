import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:leksika/core/navigation/app_navigator.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class FcmNotificationService {
  FcmNotificationService(this._dio);

  final Dio _dio;
  bool _initialized = false;
  OverlayEntry? _activeOverlay;
  Timer? _dismissTimer;

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

    _dismissCurrentOverlay();

    final overlay = appNavigatorKey.currentState?.overlay;
    if (overlay == null) return;

    _activeOverlay = OverlayEntry(
      builder: (overlayContext) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Material(
              color: Colors.transparent,
              child: GestureDetector(
                onTap: () {
                  _dismissCurrentOverlay();
                  _openNotificationPage(message);
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.14),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE0F5EC),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.notifications_rounded,
                          color: Color(0xFF1A7A4A),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            if (body.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text(
                                body,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  height: 1.35,
                                  color: Color(0xFF2D6A4F),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Color(0xFF6B7280),
                          size: 20,
                        ),
                        onPressed: _dismissCurrentOverlay,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    overlay.insert(_activeOverlay!);
    _dismissTimer = Timer(
      const Duration(seconds: 4),
      _dismissCurrentOverlay,
    );
  }

  void _openNotificationPage(RemoteMessage message) {
    final navigator = appNavigatorKey.currentState;
    if (navigator == null) return;
    navigator.pushNamed('/notifikasi');
  }

  void _dismissCurrentOverlay() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _activeOverlay?.remove();
    _activeOverlay = null;
  }
}
