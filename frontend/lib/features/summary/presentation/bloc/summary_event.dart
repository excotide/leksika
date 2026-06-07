import 'package:equatable/equatable.dart';

abstract class SummaryEvent extends Equatable {
  const SummaryEvent();

  @override
  List<Object?> get props => [];
}

class FetchDocumentsRequested extends SummaryEvent {
  const FetchDocumentsRequested({this.search});

  final String? search;

  @override
  List<Object?> get props => [search];
}

class FetchDocumentDetailRequested extends SummaryEvent {
  const FetchDocumentDetailRequested({required this.id});

  final int id;

  @override
  List<Object?> get props => [id];
}

class UploadDocumentRequested extends SummaryEvent {
  const UploadDocumentRequested({
    required this.filePath,
    this.length,
    this.makeQuiz,
    this.quizCount,
  });

  final String filePath;
  final String? length;
  final String? makeQuiz;
  final String? quizCount;

  @override
  List<Object?> get props => [filePath, length, makeQuiz, quizCount];
}

class CreateFlashcardsRequested extends SummaryEvent {
  const CreateFlashcardsRequested({
    required this.id,
    this.quizCount,
  });

  final int id;
  final String? quizCount;

  @override
  List<Object?> get props => [id, quizCount];
}
