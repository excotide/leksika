import 'dart:io';

import 'package:dio/dio.dart';
import 'package:leksika/core/errors/exceptions.dart';
import 'package:leksika/features/summary/data/models/document_model.dart';

abstract class SummaryRemoteDataSource {
  Future<List<DocumentModel>> getDocuments();

  Future<DocumentModel> getDocumentDetail(int id);

  Future<DocumentModel> uploadDocument({
    required String filePath,
    String? length,
    String? makeQuiz,
    String? quizCount,
  });
}

class SummaryRemoteDataSourceImpl implements SummaryRemoteDataSource {
  SummaryRemoteDataSourceImpl(this.dio);

  final Dio dio;

  @override
  Future<List<DocumentModel>> getDocuments() async {
    try {
      final response = await dio.get('/documents');
      final data = response.data as Map<String, dynamic>;
      final list = (data['data'] as List<dynamic>? ?? [])
          .map((item) => DocumentModel.fromJson(item as Map<String, dynamic>))
          .toList();
      return list;
    } on DioException catch (error) {
      _handleDioError(error);
    }
  }

  @override
  Future<DocumentModel> getDocumentDetail(int id) async {
    try {
      final response = await dio.get('/documents/$id');
      final data = response.data as Map<String, dynamic>;
      return DocumentModel.fromJson(data['data'] as Map<String, dynamic>);
    } on DioException catch (error) {
      _handleDioError(error);
    }
  }

  @override
  Future<DocumentModel> uploadDocument({
    required String filePath,
    String? length,
    String? makeQuiz,
    String? quizCount,
  }) async {
    try {
      final file = File(filePath);
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.uri.pathSegments.last,
        ),
        'length': ?length,
        'makeQuiz': ?makeQuiz,
        'quizCount': ?quizCount,
      });
      final response = await dio.post(
        '/documents',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      final data = response.data as Map<String, dynamic>;
      final document = data['document'] as Map<String, dynamic>?;
      if (document != null) {
        return DocumentModel.fromJson(document);
      }
      return DocumentModel.fromJson(data['data'] as Map<String, dynamic>);
    } on DioException catch (error) {
      _handleDioError(error);
    }
  }

  Never _handleDioError(DioException error) {
    final statusCode = error.response?.statusCode ?? 0;
    if (statusCode == 401) {
      throw UnauthorizedException();
    }
    if (statusCode == 403) {
      throw EmailNotVerifiedException();
    }
    throw ServerException();
  }
}
