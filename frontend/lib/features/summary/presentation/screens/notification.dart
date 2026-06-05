import 'package:flutter/material.dart';

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final String time;
  final NotifType type;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.type,
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

  final List<NotificationItem> _todayNotifs = [
    NotificationItem(
      id: '1',
      title: 'Rangkuman Siap!',
      body: 'Rangkuman Struktur Data & Algoritma sudah siap dipelajari. Yuk, cek sekarang!',
      time: '09:41',
      type: NotifType.rangkuman,
      isRead: false,
    ),
    NotificationItem(
      id: '2',
      title: 'Hebat!',
      body: 'Wah, streak kamu sudah 7 hari! Pertahankan semangat belajarmu hari ini.',
      time: '07:20',
      type: NotifType.motivasi,
      isRead: false,
    ),
  ];

  final List<NotificationItem> _yesterdayNotifs = [
    NotificationItem(
      id: '3',
      title: 'Update Fitur',
      body: 'Cek fitur baru Leksika sekarang! Kamu bisa menambahkan catatan suara ke dalam perpustakaan belajarmu.',
      time: 'Kemarin',
      type: NotifType.update,
      isRead: true,
    ),
    NotificationItem(
      id: '4',
      title: 'Tips Belajar Hari Ini',
      body: 'Ulangi materi yang baru dipelajari dalam 24 jam untuk meningkatkan retensi hingga 80%.',
      time: 'Kemarin',
      type: NotifType.tips,
      isRead: true,
    ),
    NotificationItem(
      id: '5',
      title: 'Keamanan',
      body: 'Password akun kamu berhasil diperbarui. Jika bukan kamu, segera hubungi tim support kami.',
      time: 'Kemarin',
      type: NotifType.keamanan,
      isRead: true,
    ),
  ];

  List<NotificationItem> get _allNotifs => [..._todayNotifs, ..._yesterdayNotifs];
  bool get _allRead => _allNotifs.every((n) => n.isRead);
  int get _unreadTodayCount => _todayNotifs.where((n) => !n.isRead).length;

  void _markAllRead() {
    setState(() {
      for (final n in _allNotifs) {
        n.isRead = true;
      }
    });
  }

  void _markOneRead(NotificationItem item) {
    if (!item.isRead) setState(() => item.isRead = true);
  }

  @override
  Widget build(BuildContext context) {
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
          if (!_allRead)
            TextButton(
              onPressed: _markAllRead,
              child: const Text(
                'Tandai dibaca',
                style: TextStyle(color: _primaryGreen, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
        ],
      ),
      body: _allNotifs.isEmpty
          ? _buildEmptyState()
          : ListView(
              padding: const EdgeInsets.only(bottom: 32),
              children: [
                if (_todayNotifs.isNotEmpty) ...[
                  _buildSectionHeader('Hari Ini', unreadCount: _unreadTodayCount),
                  ..._todayNotifs.map((n) => _buildNotifCard(n)),
                ],
                if (_yesterdayNotifs.isNotEmpty) ...[
                  _buildSectionHeader('Kemarin'),
                  ..._yesterdayNotifs.map((n) => _buildNotifCard(n)),
                ],
                if (_allRead) _buildAllReadFooter(),
              ],
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

  Widget _buildNotifCard(NotificationItem item) {
    final isTips = item.type == NotifType.tips;
    if (isTips) return _buildTipsCard(item);

    final isUnread = !item.isRead;

    return GestureDetector(
      onTap: () => _markOneRead(item),
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

  Widget _buildTipsCard(NotificationItem item) {
    return GestureDetector(
      onTap: () => _markOneRead(item),
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