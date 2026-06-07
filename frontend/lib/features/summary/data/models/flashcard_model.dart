import 'package:leksika/core/utils/content_sanitizer.dart';
import 'package:leksika/features/summary/domain/entities/flashcard_entity.dart';

class FlashcardModel extends FlashcardEntity {
  const FlashcardModel({
    required super.id,
    required super.documentId,
    required super.question,
    required super.answer,
    super.createdAt,
  });

  factory FlashcardModel.fromJson(Map<String, dynamic> json) {
    return FlashcardModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      documentId: (json['document_id'] as num?)?.toInt() ?? 0,
      question: ContentSanitizer.cleanGeneratedText(
        json['question'] as String? ?? '',
      ),
      answer: ContentSanitizer.cleanGeneratedText(
        json['answer'] as String? ?? '',
      ),
      createdAt: _parseDate(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'document_id': documentId,
      'question': question,
      'answer': answer,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
