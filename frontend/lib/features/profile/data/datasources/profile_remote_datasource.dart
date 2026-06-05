import 'dart:io';

import 'package:dio/dio.dart';
import 'package:leksika/core/errors/exceptions.dart';
import 'package:leksika/features/profile/data/models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile();

  Future<ProfileModel> updateProfile({
    String? name,
    String? bio,
    String? institution,
    String? address,
  });

  Future<ProfileModel> uploadPhoto(String filePath);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  ProfileRemoteDataSourceImpl(this.dio);

  final Dio dio;

  @override
  Future<ProfileModel> getProfile() async {
    try {
      final response = await dio.get('/profile');
      return ProfileModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      _handleDioError(error);
    }
  }

  @override
  Future<ProfileModel> updateProfile({
    String? name,
    String? bio,
    String? institution,
    String? address,
  }) async {
    try {
      final response = await dio.put(
        '/profile',
        data: {
          'name': ?name,
          'bio': ?bio,
          'institution': ?institution,
          'address': ?address,
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      return ProfileModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      _handleDioError(error);
    }
  }

  @override
  Future<ProfileModel> uploadPhoto(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw ServerException(message: 'File foto tidak ditemukan. Pilih ulang foto.');
      }
      final filename = file.uri.pathSegments.where((s) => s.isNotEmpty).lastOrNull
          ?? 'photo.jpg';
      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(file.path, filename: filename),
      });
      final response = await dio.post('/profile/photo', data: formData);
      return ProfileModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      _handleDioError(error);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Gagal memproses foto: $e');
    }
  }

  Never _handleDioError(DioException error) {
    final statusCode = error.response?.statusCode ?? 0;
    if (statusCode == 401) throw UnauthorizedException();
    if (statusCode == 403) throw EmailNotVerifiedException();
    throw ServerException(
      message: _extractMessage(error.response?.data) ?? 'Terjadi kesalahan. Coba lagi.',
      statusCode: statusCode,
    );
  }

  /// Ambil pesan dari respons error Laravel (string atau MessageBag).
  String? _extractMessage(dynamic data) {
    if (data is! Map) return null;
    final message = data['message'];
    if (message is String && message.isNotEmpty) return message;
    final errors = message is Map ? message : data['errors'];
    if (errors is Map) {
      for (final value in errors.values) {
        if (value is List && value.isNotEmpty) return value.first.toString();
        if (value is String && value.isNotEmpty) return value;
      }
    }
    return null;
  }
}
