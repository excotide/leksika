import 'package:leksika/core/utils/content_sanitizer.dart';
import 'package:leksika/features/summary/domain/entities/document_entity.dart';
import 'package:leksika/features/summary/data/models/flashcard_model.dart';

class DocumentModel extends DocumentEntity {
  const DocumentModel({
    required super.id,
    required super.title,
    required super.summary,
    required super.createdAt,
    super.flashcards,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    final titleField = _formatTitle(
      json['file_name'] as String? ?? json['title'] as String? ?? 'Tanpa Judul',
    );

    String summaryText = '';
    if (json['summary'] != null && json['summary'] is Map) {
      summaryText = json['summary']['summary_text'] as String? ?? '';
    } else if (json['summary'] is String) {
      summaryText = json['summary'] as String;
    }

    final flashcards = (json['flashcards'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(FlashcardModel.fromJson)
        .toList();

    return DocumentModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: titleField,
      summary: ContentSanitizer.cleanGeneratedText(summaryText),
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
      flashcards: flashcards,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'created_at': createdAt?.toIso8601String(),
      'flashcards': flashcards
          .map(
            (flashcard) => {
              'id': flashcard.id,
              'document_id': flashcard.documentId,
              'question': flashcard.question,
              'answer': flashcard.answer,
              'created_at': flashcard.createdAt?.toIso8601String(),
            },
          )
          .toList(),
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
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
