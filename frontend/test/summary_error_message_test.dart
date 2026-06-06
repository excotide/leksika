import 'package:flutter_test/flutter_test.dart';
import 'package:leksika/core/errors/exceptions.dart';
import 'package:leksika/core/errors/failures.dart';
import 'package:leksika/features/summary/data/datasources/summary_remote_datasource.dart';
import 'package:leksika/features/summary/data/models/document_model.dart';
import 'package:leksika/features/summary/data/repositories/summary_repository_impl.dart';

void main() {
  test('uploadDocument preserves backend error message', () async {
    const backendMessage =
        'Server AI sedang tidak dapat dihubungi. Periksa koneksi internet backend lalu coba lagi.';
    final repository = SummaryRepositoryImpl(
      _FailingSummaryRemoteDataSource(backendMessage),
    );

    final result = await repository.uploadDocument(filePath: 'materi.pdf');

    expect(
      result.fold((failure) => failure, (_) => null),
      isA<ServerFailure>().having(
        (failure) => failure.message,
        'message',
        backendMessage,
      ),
    );
  });
}

class _FailingSummaryRemoteDataSource implements SummaryRemoteDataSource {
  _FailingSummaryRemoteDataSource(this.message);

  final String message;

  @override
  Future<List<DocumentModel>> getDocuments() async {
    throw ServerException(message: message);
  }

  @override
  Future<DocumentModel> getDocumentDetail(int id) async {
    throw ServerException(message: message);
  }

  @override
  Future<DocumentModel> uploadDocument({
    required String filePath,
    String? length,
    String? makeQuiz,
    String? quizCount,
  }) async {
    throw ServerException(message: message);
  }
}
