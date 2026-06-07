import 'package:dartz/dartz.dart';
import 'package:leksika/core/errors/exceptions.dart';
import 'package:leksika/core/errors/failures.dart';
import 'package:leksika/features/summary/data/datasources/summary_remote_datasource.dart';
import 'package:leksika/features/summary/domain/entities/document_entity.dart';
import 'package:leksika/features/summary/domain/repositories/summary_repository.dart';

class SummaryRepositoryImpl implements SummaryRepository {
  SummaryRepositoryImpl(this.remoteDataSource);

  final SummaryRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, List<DocumentEntity>>> getDocuments({
    String? search,
  }) async {
    try {
      final documents = await remoteDataSource.getDocuments(search: search);
      return Right(documents);
    } on EmailNotVerifiedException {
      return Left(EmailNotVerifiedFailure());
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    }
  }

  @override
  Future<Either<Failure, DocumentEntity>> getDocumentDetail(int id) async {
    try {
      final document = await remoteDataSource.getDocumentDetail(id);
      return Right(document);
    } on EmailNotVerifiedException {
      return Left(EmailNotVerifiedFailure());
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    }
  }

  @override
  Future<Either<Failure, DocumentEntity>> createFlashcards(
    int id, {
    String? quizCount,
  }) async {
    try {
      final document = await remoteDataSource.createFlashcards(
        id,
        quizCount: quizCount,
      );
      return Right(document);
    } on EmailNotVerifiedException {
      return Left(EmailNotVerifiedFailure());
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    }
  }

  @override
  Future<Either<Failure, DocumentEntity>> uploadDocument({
    required String filePath,
    String? length,
    String? makeQuiz,
    String? quizCount,
  }) async {
    try {
      final document = await remoteDataSource.uploadDocument(
        filePath: filePath,
        length: length,
        makeQuiz: makeQuiz,
        quizCount: quizCount,
      );
      return Right(document);
    } on EmailNotVerifiedException {
      return Left(EmailNotVerifiedFailure());
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    }
  }
}
