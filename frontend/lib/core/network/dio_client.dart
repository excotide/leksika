import 'package:dio/dio.dart';
import 'package:leksika/core/constants/api_constants.dart';
import 'package:leksika/core/storage/secure_storage.dart';

class DioClient {
  DioClient(this.secureStorage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 60),
        headers: const {'Accept': 'application/json'},
      ),
    );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await secureStorage.readToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  final SecureStorage secureStorage;
  late final Dio _dio;

  Dio get dio => _dio;
}
