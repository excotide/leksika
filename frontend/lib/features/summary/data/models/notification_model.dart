import 'package:leksika/features/summary/domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    super.documentId,
    required super.title,
    required super.message,
    required super.type,
    required super.isRead,
    super.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      documentId: (json['document_id'] as num?)?.toInt(),
      title: json['title'] as String? ?? '',
      message: _cleanMessage(json['message'] as String? ?? ''),
      type: json['type'] as String? ?? 'update',
      isRead: json['is_read'] == true || json['is_read'] == 1,
      createdAt: _parseDate(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'document_id': documentId,
      'title': title,
      'message': message,
      'type': type,
      'is_read': isRead,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  static String _cleanMessage(String value) {
    var message = value.replaceAllMapped(
      RegExp(r"dokumen '([^']+)'", caseSensitive: false),
      (match) => "dokumen '${_formatTitle(match.group(1) ?? '')}'",
    );

    message = message.replaceAllMapped(
      RegExp(r'dokumen\s+(.+?\.pdf)', caseSensitive: false),
      (match) => 'dokumen ${_formatTitle(match.group(1) ?? '')}',
    );

    return message;
  }

  static String _formatTitle(String value) {
    final withoutExtension = value.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '');
    final cleaned = withoutExtension
        .replaceAll(RegExp(r'[_+\-]+'), ' ')
        .replaceAll(RegExp(r'[^a-zA-Z0-9\u00C0-\u024F\s]'), ' ')
        .replaceAll(RegExp(r'\b\d{3,}\b'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (cleaned.isEmpty) return 'Tanpa Judul';

    return cleaned
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) {
          if (word.length <= 2 && word == word.toUpperCase()) {
            return word;
          }
          final lower = word.toLowerCase();
          return '${lower[0].toUpperCase()}${lower.substring(1)}';
        })
        .join(' ');
  }
}
