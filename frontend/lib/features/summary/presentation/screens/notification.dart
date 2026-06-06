import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leksika/core/di/injection_container.dart';
import 'package:leksika/features/summary/domain/entities/notification_entity.dart';
import 'package:leksika/features/summary/presentation/bloc/notification_bloc.dart';
import 'package:leksika/features/summary/presentation/bloc/notification_event.dart';
import 'package:leksika/features/summary/presentation/bloc/notification_state.dart';

class NotificationItem {
  final int id;
  final int? documentId;
  final String title;
  final String body;
  final String time;
  final NotifType type;
  final DateTime? createdAt;
  final NotificationEntity source;
  bool isRead;

  NotificationItem({
    required this.id,
    this.documentId,
    required this.title,
    required this.body,
    required this.time,
    required this.type,
    required this.source,
    this.createdAt,
    this.isRead = false,
  });
}

enum NotifType { rangkuman, motivasi, update, tips, keamanan }

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  static const Color _primaryGreen  = Color(0xFF1A7A4A);
  static const Color _bgColor       = Color(0xFFD8FFF0); // ✅ hijau sesuai Figma
  static const Color _unreadCardBg  = Color(0xFFB8F0D8); // ✅ kartu unread lebih hijau
  static const Color _readCardBg    = Colors.white;
  static const Color _tipsCardColor = Color(0xFF1A7A4A);
  static const Color _leftBorder    = Color(0xFF1A7A4A);

  List<NotificationItem> _itemsFromEntities(
    List<NotificationEntity> notifications,
  ) {
    return notifications
        .map(
          (notification) => NotificationItem(
            id: notification.id,
            documentId: notification.documentId,
            title: notification.title,
            body: notification.message,
            time: _formatTime(notification.createdAt),
            type: _typeFromBackend(notification.type),
            createdAt: notification.createdAt,
            source: notification,
            isRead: notification.isRead,
          ),
        )
        .toList();
  }

  List<NotificationItem> _todayItems(List<NotificationItem> items) {
    return items.where((item) => _isSameDay(item.createdAt, DateTime.now())).toList();
  }

  List<NotificationItem> _yesterdayItems(List<NotificationItem> items) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return items.where((item) => _isSameDay(item.createdAt, yesterday)).toList();
  }

  List<NotificationItem> _olderItems(List<NotificationItem> items) {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    return items
        .where(
          (item) =>
              !_isSameDay(item.createdAt, today) &&
              !_isSameDay(item.createdAt, yesterday),
        )
        .toList();
  }

  bool _isSameDay(DateTime? value, DateTime target) {
    if (value == null) return false;
    final local = value.toLocal();
    return local.year == target.year &&
        local.month == target.month &&
        local.day == target.day;
  }

  String _formatTime(DateTime? value) {
    if (value == null) return '';
    final local = value.toLocal();
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    if (_isSameDay(local, now)) {
      final hour = local.hour.toString().padLeft(2, '0');
      final minute = local.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }
    if (_isSameDay(local, yesterday)) return 'Kemarin';
    return '${local.day}/${local.month}/${local.year}';
  }

  NotifType _typeFromBackend(String type) {
    switch (type) {
      case 'summary_success':
        return NotifType.rangkuman;
      case 'quiz_reminder':
        return NotifType.motivasi;
      case 'tips':
        return NotifType.tips;
      case 'security':
        return NotifType.keamanan;
      default:
        return NotifType.update;
    }
  }

  bool _allRead(List<NotificationItem> items) {
    return items.every((n) => n.isRead);
  }

  void _markAllRead(BuildContext context) {
    context
        .read<NotificationBloc>()
        .add(const MarkAllNotificationsReadRequested());
  }

  void _markOneRead(BuildContext context, NotificationItem item) {
    if (!item.isRead) {
      context
          .read<NotificationBloc>()
          .add(MarkNotificationReadRequested(item.id));
    }
  }

  void _openNotificationDetail(BuildContext context, NotificationItem item) {
    _markOneRead(context, item);
    Navigator.pushNamed(
      context,
      '/notification-detail',
      arguments: item.source,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<NotificationBloc>()..add(const FetchNotificationsRequested()),
      child: BlocConsumer<NotificationBloc, NotificationState>(
        listener: (context, state) {
          if (state is NotificationFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          final items = state is NotificationLoaded
              ? _itemsFromEntities(state.notifications)
              : <NotificationItem>[];
          final todayNotifs = _todayItems(items);
          final yesterdayNotifs = _yesterdayItems(items);
          final olderNotifs = _olderItems(items);
          final allRead = _allRead(items);
          final unreadTodayCount = todayNotifs.where((n) => !n.isRead).length;

          return Scaffold(
            backgroundColor: _bgColor,
            appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1A1A1A), size: 20),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, '/home');
            }
          },
        ),
        title: const Text(
          'Notifikasi',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
        ),
        centerTitle: true,
        actions: [
          if (items.isNotEmpty && !allRead)
            TextButton(
              onPressed: () => _markAllRead(context),
              child: const Text(
                'Tandai dibaca',
                style: TextStyle(color: _primaryGreen, fontSize: 13, fontWeight: FontWeight.w500),
              ),
          ),
        ],
      ),
            body: state is NotificationLoading
                ? const Center(
                    child: CircularProgressIndicator(color: _primaryGreen),
                  )
                : items.isEmpty
                    ? _buildEmptyState()
                    : ListView(
              padding: const EdgeInsets.only(bottom: 32),
              children: [
                if (todayNotifs.isNotEmpty) ...[
                  _buildSectionHeader('Hari Ini', unreadCount: unreadTodayCount),
                  ...todayNotifs.map((n) => _buildNotifCard(context, n)),
                ],
                if (yesterdayNotifs.isNotEmpty) ...[
                  _buildSectionHeader('Kemarin'),
                  ...yesterdayNotifs.map((n) => _buildNotifCard(context, n)),
                ],
                if (olderNotifs.isNotEmpty) ...[
                  _buildSectionHeader('Sebelumnya'),
                  ...olderNotifs.map((n) => _buildNotifCard(context, n)),
                ],
                if (allRead) _buildAllReadFooter(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, {int unreadCount = 0}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
          if (unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _primaryGreen,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$unreadCount BARU',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.4,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNotifCard(BuildContext context, NotificationItem item) {
    final isTips = item.type == NotifType.tips;
    if (isTips) return _buildTipsCard(context, item);

    final isUnread = !item.isRead;

    return GestureDetector(
      onTap: () => _openNotificationDetail(context, item),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
          color: isUnread ? _unreadCardBg : _readCardBg,
          borderRadius: BorderRadius.circular(14),
          border: isUnread
              ? const Border(left: BorderSide(color: _leftBorder, width: 4))
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isUnread ? const Color(0xFFCCEEDD) : const Color(0xFFF0F0F0),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _iconForType(item.type),
                  color: isUnread ? _primaryGreen : Colors.grey.shade400,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                              color: const Color(0xFF1A1A1A),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          item.time,
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.body,
                      style: TextStyle(
                        fontSize: 13,
                        color: isUnread ? const Color(0xFF2D6A4F) : Colors.grey.shade600,
                        height: 1.45,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipsCard(BuildContext context, NotificationItem item) {
    return GestureDetector(
      onTap: () => _openNotificationDetail(context, item),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _tipsCardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: _tipsCardColor.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Text(
                  item.time,
                  style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.7)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item.body,
              style: const TextStyle(fontSize: 13, color: Colors.white, height: 1.5),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'BACA SELENGKAPNYA',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: _primaryGreen,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllReadFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Color(0xFFE0F5EC),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.done_all_rounded, color: _primaryGreen, size: 32),
          ),
          const SizedBox(height: 14),
          const Text(
            'Semua notifikasi telah ditampilkan',
            style: TextStyle(fontSize: 14, color: Color(0xFF888888), fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(color: Color(0xFFE0F5EC), shape: BoxShape.circle),
            child: const Icon(Icons.notifications_off_outlined, color: _primaryGreen, size: 36),
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum ada notifikasi',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
          ),
          const SizedBox(height: 6),
          Text(
            'Notifikasi terbaru akan muncul di sini',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  IconData _iconForType(NotifType type) {
    switch (type) {
      case NotifType.rangkuman: return Icons.check_circle_rounded;
      case NotifType.motivasi:  return Icons.local_fire_department_rounded;
      case NotifType.update:    return Icons.notifications_rounded;
      case NotifType.tips:      return Icons.lightbulb_rounded;
      case NotifType.keamanan:  return Icons.person_rounded;
    }
  }
}
