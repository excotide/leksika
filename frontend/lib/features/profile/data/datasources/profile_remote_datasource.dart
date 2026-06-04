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
      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(
          file.path,
          filename: file.uri.pathSegments.last,
        ),
      });
      final response = await dio.post(
        '/profile/photo',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return ProfileModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      _handleDioError(error);
    }
  }

  Never _handleDioError(DioException error) {
    final statusCode = error.response?.statusCode ?? 0;
    if (statusCode == 401) throw UnauthorizedException();
    if (statusCode == 403) throw EmailNotVerifiedException();
    final message =
        error.response?.data is Map<String, dynamic>
            ? error.response?.data['message'] as String?
            : null;
    throw ServerException(
      message: message ?? 'Terjadi kesalahan',
      statusCode: statusCode,
    );
  }
}
