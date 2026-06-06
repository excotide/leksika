import 'package:equatable/equatable.dart';
import 'package:leksika/features/summary/domain/entities/flashcard_entity.dart';

class DocumentEntity extends Equatable {
  const DocumentEntity({
    required this.id,
    required this.title,
    required this.summary,
    required this.createdAt,
    this.flashcards = const [],
  });

  final int id;
  final String title;
  final String summary;
  final DateTime? createdAt;
  final List<FlashcardEntity> flashcards;

  @override
  List<Object?> get props => [id, title, summary, createdAt, flashcards];
}
