import 'package:dio/dio.dart';
import 'package:leksika/core/errors/exceptions.dart';
import 'package:leksika/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  });

  Future<void> verifyOtp({required String otp});

  Future<void> resendOtp();

  Future<UserModel> getUser();

  Future<void> logout();

  Future<UserModel> loginWithGoogle(String idToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this.dio);

  final Dio dio;

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        '/login',
        data: {'email': email, 'password': password},
      );
      return UserModel.fromAuthResponse(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      _handleDioError(error);
    }
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      // print('>>> Register payload: name=$name, email=$email');
      final response = await dio.post(
        '/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'}, // ← tambah ini
        ),
      );
      return UserModel.fromAuthResponse(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      _handleDioError(error);
    }
  }

  @override
  Future<void> verifyOtp({required String otp}) async {
    try {
      await dio.post('/email/verify-otp', data: {'otp': otp});
    } on DioException catch (error) {
      _handleDioError(error);
    }
  }

  @override
  Future<void> resendOtp() async {
    try {
      await dio.post('/email/resend-otp');
    } on DioException catch (error) {
      _handleDioError(error);
    }
  }

  Never _handleDioError(DioException error) {
    // print('>>> DioException type: ${error.type}');
    // print('>>> Status code: ${error.response?.statusCode}');
    // print('>>> Response data: ${error.response?.data}');
    // print('>>> Message: ${error.message}');

    final statusCode = error.response?.statusCode ?? 0;
    if (statusCode == 401) throw UnauthorizedException();
    if (statusCode == 403) throw EmailNotVerifiedException();
    final message =
        error.response?.data['message'] as String? ?? 'Terjadi kesalahan';
    throw ServerException(message: message, statusCode: statusCode);
  }

  @override
  Future<UserModel> getUser() async {
    try {
      final response = await dio.get('/user');
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      _handleDioError(error);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await dio.post('/logout'); 
    } on DioException catch (error) {
      _handleDioError(error);
    }
  }

  @override
  Future<UserModel> loginWithGoogle(String idToken) async {
    try {
      final response = await dio.post(
        '/auth/google',
        data: {'id_token': idToken},
      );
      return UserModel.fromAuthResponse(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      _handleDioError(error);
    }
  }
}