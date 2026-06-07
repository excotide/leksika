import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leksika/features/summary/data/datasources/summary_remote_datasource.dart';

class RecordingAdapter implements HttpClientAdapter {
  RequestOptions? lastRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    return ResponseBody.fromString(
      '{"status":true,"data":{"id":7,"file_name":"Materi","summary":{"summary_text":"Ringkasan"},"flashcards":[{"id":1,"document_id":7,"question":"Q","answer":"A"}]}}',
      201,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test('createFlashcards posts to the document flashcards endpoint', () async {
    final adapter = RecordingAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api'))
      ..httpClientAdapter = adapter;
    final dataSource = SummaryRemoteDataSourceImpl(dio);

    final document = await dataSource.createFlashcards(7, quizCount: '10 Soal');

    expect(adapter.lastRequest?.method, 'POST');
    expect(adapter.lastRequest?.path, '/documents/7/flashcards');
    expect(adapter.lastRequest?.data, {'quiz_count': '10 Soal'});
    expect(document.flashcards, hasLength(1));
  });
}
