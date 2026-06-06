import 'package:flutter/material.dart';
import 'package:leksika/core/di/injection_container.dart';
import 'package:leksika/core/services/in_app_notification_service.dart';
import 'package:leksika/features/summary/domain/entities/document_entity.dart';
import 'package:leksika/features/summary/domain/entities/notification_entity.dart';
import 'package:leksika/features/summary/domain/usecases/get_summary_usecase.dart';

class NotificationDetailScreen extends StatefulWidget {
  const NotificationDetailScreen({super.key, required this.notification});

  final NotificationEntity notification;

  @override
  State<NotificationDetailScreen> createState() =>
      _NotificationDetailScreenState();
}

class _NotificationDetailScreenState extends State<NotificationDetailScreen> {
  static const Color _primaryGreen = Color(0xFF1A7A4A);
  static const Color _appBarGreen  = Color(0xFF006947);
  static const Color _bgColor = Color(0xFFE8FAF2);

  bool _isOpening = false;

  @override
  Widget build(BuildContext context) {
    final notification = widget.notification;

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _appBarGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, '/notifikasi');
            }
          },
        ),
        title: const Text(
          'Detail Notifikasi',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE0F5EC),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _iconForType(notification.type),
                        color: _primaryGreen,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification.title,
                            style: const TextStyle(
                              fontSize: 22,
                              height: 1.25,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _formatDate(notification.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  notification.message,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.55,
                    color: Color(0xFF2D6A4F),
                  ),
                ),
              ],
            ),
          ),
          if (notification.documentId != null) ...[
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isOpening ? null : _openRelatedDocument,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _isOpening
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _isQuizReminder(notification.type)
                            ? 'Buka Flashcard'
                            : 'Buka Rangkuman',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _openRelatedDocument() async {
    final documentId = widget.notification.documentId;
    if (documentId == null) return;

    setState(() => _isOpening = true);
    final result = await sl<GetDocumentDetailUsecase>()(
      GetDocumentDetailParams(id: documentId),
    );
    if (!mounted) return;
    setState(() => _isOpening = false);

    final document = result.fold<DocumentEntity?>((_) => null, (doc) => doc);
    if (document == null) {
      InAppNotificationService.show(
        title: 'Materi belum bisa dibuka',
        body: 'Coba lagi nanti.',
        icon: Icons.error_outline_rounded,
        backgroundColor: const Color(0xFFFF3B30),
        titleColor: Colors.white,
        bodyColor: Colors.white,
        iconBackgroundColor: const Color(0x33FFFFFF),
        iconColor: Colors.white,
        closeIconColor: Colors.white,
      );
      return;
    }

    if (_isQuizReminder(widget.notification.type) &&
        document.flashcards.isNotEmpty) {
      Navigator.pushNamed(context, '/isi-flashcard', arguments: document);
      return;
    }

    Navigator.pushNamed(
      context,
      '/detail',
      arguments: {
        'title': document.title.isEmpty ? 'Rangkuman' : document.title,
        'pageCount': 'Ringkasan',
        'contents': [
          {'subTitle': 'Ringkasan', 'body': document.summary},
        ],
        'document': document,
      },
    );
  }

  bool _isQuizReminder(String type) => type == 'quiz_reminder';

  IconData _iconForType(String type) {
    switch (type) {
      case 'summary_success':
        return Icons.check_circle_rounded;
      case 'quiz_reminder':
        return Icons.local_fire_department_rounded;
      case 'tips':
        return Icons.lightbulb_rounded;
      case 'security':
        return Icons.person_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  String _formatDate(DateTime? value) {
    if (value == null) return 'Baru saja';
    final local = value.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.day}/${local.month}/${local.year} $hour:$minute';
  }
}
