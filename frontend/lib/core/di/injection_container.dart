import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:leksika/core/network/dio_client.dart';
import 'package:leksika/core/storage/secure_storage.dart';
import 'package:leksika/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:leksika/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:leksika/features/auth/domain/repositories/auth_repository.dart';
import 'package:leksika/features/auth/domain/usecases/get_user_usecase.dart';
import 'package:leksika/features/auth/domain/usecases/google_login_usecase.dart';
import 'package:leksika/features/auth/domain/usecases/login_usecase.dart';
import 'package:leksika/features/auth/domain/usecases/register_usecase.dart';
import 'package:leksika/features/auth/domain/usecases/resend_otp_usecase.dart';
import 'package:leksika/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:leksika/features/auth/domain/usecases/logout_usecase.dart';
import 'package:leksika/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:leksika/features/summary/data/datasources/summary_remote_datasource.dart';
import 'package:leksika/features/summary/data/repositories/summary_repository_impl.dart';
import 'package:leksika/features/summary/domain/repositories/summary_repository.dart';
import 'package:leksika/features/summary/domain/usecases/get_summary_usecase.dart';
import 'package:leksika/features/summary/presentation/bloc/summary_bloc.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  sl
    ..registerLazySingleton<FlutterSecureStorage>(
      () => const FlutterSecureStorage(),
    )
    ..registerLazySingleton<SecureStorage>(
      () => SecureStorage(sl<FlutterSecureStorage>()),
    )
    ..registerLazySingleton<DioClient>(
      () => DioClient(sl<SecureStorage>()),
    )
    ..registerLazySingleton<Dio>(() => sl<DioClient>().dio);

  sl
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(sl<Dio>()),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        remoteDataSource: sl<AuthRemoteDataSource>(),
        secureStorage: sl<SecureStorage>(),
      ),
    )
    ..registerLazySingleton<LoginUsecase>(
      () => LoginUsecase(sl<AuthRepository>()),
    )
    ..registerLazySingleton<RegisterUsecase>(
      () => RegisterUsecase(sl<AuthRepository>()),
    )
    ..registerLazySingleton<VerifyOtpUsecase>(
      () => VerifyOtpUsecase(sl<AuthRepository>()),
    )
    ..registerLazySingleton<ResendOtpUsecase>(
      () => ResendOtpUsecase(sl<AuthRepository>()),
    )
    ..registerLazySingleton<GetUserUsecase>(
      () => GetUserUsecase(sl<AuthRepository>()),
    )
    ..registerLazySingleton<LogoutUsecase>(
      () => LogoutUsecase(sl<AuthRepository>()),
    )

    ..registerLazySingleton<GoogleLoginUsecase>(
      () => GoogleLoginUsecase(sl<AuthRepository>()),
    )

    ..registerFactory<AuthBloc>(
      () => AuthBloc(
        loginUsecase: sl<LoginUsecase>(),
        registerUsecase: sl<RegisterUsecase>(),
        verifyOtpUsecase: sl<VerifyOtpUsecase>(),
        resendOtpUsecase: sl<ResendOtpUsecase>(),
        getUserUsecase: sl<GetUserUsecase>(),
        logoutUsecase: sl<LogoutUsecase>(),
        googleLoginUsecase: sl<GoogleLoginUsecase>(),
      ),
    );

  sl
    ..registerLazySingleton<SummaryRemoteDataSource>(
      () => SummaryRemoteDataSourceImpl(sl<Dio>()),
    )
    ..registerLazySingleton<SummaryRepository>(
      () => SummaryRepositoryImpl(sl<SummaryRemoteDataSource>()),
    )
    ..registerLazySingleton<GetDocumentsUsecase>(
      () => GetDocumentsUsecase(sl<SummaryRepository>()),
    )
    ..registerLazySingleton<GetDocumentDetailUsecase>(
      () => GetDocumentDetailUsecase(sl<SummaryRepository>()),
    )
    ..registerLazySingleton<UploadDocumentUsecase>(
      () => UploadDocumentUsecase(sl<SummaryRepository>()),
    )
    ..registerFactory<SummaryBloc>(
      () => SummaryBloc(
        getDocumentsUsecase: sl<GetDocumentsUsecase>(),
        getDocumentDetailUsecase: sl<GetDocumentDetailUsecase>(),
        uploadDocumentUsecase: sl<UploadDocumentUsecase>(),
      ),
    );
}
