import 'dart:async';

import 'package:flutter/material.dart';
import 'package:leksika/core/navigation/app_navigator.dart';

class InAppNotificationService {
  static OverlayEntry? _activeOverlay;
  static Timer? _dismissTimer;

  static void show({
    required String title,
    String body = '',
    IconData icon = Icons.notifications_rounded,
    Color backgroundColor = Colors.white,
    Color titleColor = const Color(0xFF1A1A1A),
    Color bodyColor = const Color(0xFF2D6A4F),
    Color iconBackgroundColor = const Color(0xFFE0F5EC),
    Color iconColor = const Color(0xFF1A7A4A),
    Color closeIconColor = const Color(0xFF6B7280),
    int bodyMaxLines = 2,
    VoidCallback? onTap,
    Duration duration = const Duration(seconds: 4),
  }) {
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
                  onTap?.call();
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: backgroundColor,
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
                        decoration: BoxDecoration(
                          color: iconBackgroundColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon,
                          color: iconColor,
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
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: titleColor,
                              ),
                            ),
                            if (body.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text(
                                body,
                                maxLines: bodyMaxLines,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.35,
                                  color: bodyColor,
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
                          size: 20,
                        ),
                        color: closeIconColor,
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
    _dismissTimer = Timer(duration, _dismissCurrentOverlay);
  }

  static void _dismissCurrentOverlay() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _activeOverlay?.remove();
    _activeOverlay = null;
  }
}
