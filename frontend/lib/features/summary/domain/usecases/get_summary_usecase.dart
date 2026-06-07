import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:leksika/core/errors/failures.dart';
import 'package:leksika/features/summary/domain/entities/document_entity.dart';
import 'package:leksika/features/summary/domain/repositories/summary_repository.dart';

class GetDocumentsUsecase {
  GetDocumentsUsecase(this.repository);

  final SummaryRepository repository;

  Future<Either<Failure, List<DocumentEntity>>> call([
    GetDocumentsParams params = const GetDocumentsParams(),
  ]) {
    return repository.getDocuments(search: params.search);
  }
}

class GetDocumentsParams extends Equatable {
  const GetDocumentsParams({this.search});

  final String? search;

  @override
  List<Object?> get props => [search];
}

class GetDocumentDetailUsecase {
  GetDocumentDetailUsecase(this.repository);

  final SummaryRepository repository;

  Future<Either<Failure, DocumentEntity>> call(GetDocumentDetailParams params) {
    return repository.getDocumentDetail(params.id);
  }
}

class GetDocumentDetailParams extends Equatable {
  const GetDocumentDetailParams({required this.id});

  final int id;

  @override
  List<Object?> get props => [id];
}

class CreateFlashcardsUsecase {
  CreateFlashcardsUsecase(this.repository);

  final SummaryRepository repository;

  Future<Either<Failure, DocumentEntity>> call(CreateFlashcardsParams params) {
    return repository.createFlashcards(
      params.id,
      quizCount: params.quizCount,
    );
  }
}

class CreateFlashcardsParams extends Equatable {
  const CreateFlashcardsParams({
    required this.id,
    this.quizCount,
  });

  final int id;
  final String? quizCount;

  @override
  List<Object?> get props => [id, quizCount];
}

class UploadDocumentUsecase {
  UploadDocumentUsecase(this.repository);

  final SummaryRepository repository;

  Future<Either<Failure, DocumentEntity>> call(UploadDocumentParams params) {
    return repository.uploadDocument(
      filePath: params.filePath,
      length: params.length,
      makeQuiz: params.makeQuiz,
      quizCount: params.quizCount,
    );
  }
}

class UploadDocumentParams extends Equatable {
  const UploadDocumentParams({
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
