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
    throw ServerException(
      message: _extractMessage(error.response?.data) ??
          'Terjadi kesalahan. Coba lagi.',
      statusCode: statusCode,
    );
  }

  /// Ambil pesan yang manusiawi dari respons error Laravel.
  /// Menangani dua format:
  ///   - {"message": "teks error"}                      (validasi default)
  ///   - {"message": {"email": ["..."]}} / {"errors": {...}}  (MessageBag)
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