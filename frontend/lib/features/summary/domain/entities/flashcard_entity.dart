import 'package:equatable/equatable.dart';

class FlashcardEntity extends Equatable {
  const FlashcardEntity({
    required this.id,
    required this.documentId,
    required this.question,
    required this.answer,
    this.createdAt,
  });

  final int id;
  final int documentId;
  final String question;
  final String answer;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [id, documentId, question, answer, createdAt];
}
