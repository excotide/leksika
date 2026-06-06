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
        'make_quiz': ?_normalizeBooleanString(makeQuiz),
        'quiz_count': ?quizCount,
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
    throw ServerException(
      message: _extractMessage(error) ?? _fallbackMessage(error),
      statusCode: statusCode,
    );
  }

  String? _normalizeBooleanString(String? value) {
    if (value == null) return null;
    final normalized = value.toLowerCase().trim();
    if (normalized == 'ya' || normalized == 'true' || normalized == '1') {
      return 'true';
    }
    return 'false';
  }

  String? _extractMessage(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) return message;

      final errors = data['errors'];
      if (errors is Map) {
        for (final value in errors.values) {
          if (value is List && value.isNotEmpty) return value.first.toString();
          if (value is String && value.isNotEmpty) return value;
        }
      }
    }
    return null;
  }

  String _fallbackMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Rangkuman belum bisa dibuat karena koneksi terlalu lama. Silakan coba lagi.';
      case DioExceptionType.connectionError:
        return 'Aplikasi belum bisa terhubung. Pastikan internet aktif lalu coba lagi.';
      default:
        return 'Terjadi kesalahan saat memproses dokumen. Silakan coba lagi.';
    }
  }
}
