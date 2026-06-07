import 'package:dartz/dartz.dart';
import 'package:leksika/core/errors/failures.dart';
import 'package:leksika/features/summary/domain/entities/document_entity.dart';

abstract class SummaryRepository {
  Future<Either<Failure, List<DocumentEntity>>> getDocuments({String? search});

  Future<Either<Failure, DocumentEntity>> getDocumentDetail(int id);

  Future<Either<Failure, DocumentEntity>> createFlashcards(
    int id, {
    String? quizCount,
  });

  Future<Either<Failure, DocumentEntity>> uploadDocument({
    required String filePath,
    String? length,
    String? makeQuiz,
    String? quizCount,
  });
}
