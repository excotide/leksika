import 'package:bloc/bloc.dart';
import 'package:leksika/core/errors/failures.dart';
import 'package:leksika/features/auth/domain/usecases/get_user_usecase.dart';
import 'package:leksika/features/auth/domain/usecases/login_usecase.dart';
import 'package:leksika/features/auth/domain/usecases/register_usecase.dart';
import 'package:leksika/features/auth/domain/usecases/resend_otp_usecase.dart';
import 'package:leksika/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:leksika/features/auth/presentation/bloc/auth_event.dart';
import 'package:leksika/features/auth/presentation/bloc/auth_state.dart';
import 'package:leksika/features/auth/domain/usecases/logout_usecase.dart';
import 'package:leksika/features/auth/domain/usecases/google_login_usecase.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required this.loginUsecase,
    required this.registerUsecase,
    required this.verifyOtpUsecase,
    required this.resendOtpUsecase,
    required this.getUserUsecase,
    required this.logoutUsecase,
    required this.googleLoginUsecase
  }) : super(const AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<VerifyOtpRequested>(_onVerifyOtpRequested);
    on<ResendOtpRequested>(_onResendOtpRequested);
    on<FetchUserRequested>(_onFetchUser);
    on<LogoutRequested>(_onLogoutRequested);
    on<GoogleLoginRequested>(_onGoogleLoginRequested);
  }

  final LoginUsecase loginUsecase;
  final RegisterUsecase registerUsecase;
  final VerifyOtpUsecase verifyOtpUsecase;
  final ResendOtpUsecase resendOtpUsecase;
  final GetUserUsecase getUserUsecase;
  final LogoutUsecase logoutUsecase;
  final GoogleLoginUsecase googleLoginUsecase;

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await loginUsecase(
      LoginParams(email: event.email, password: event.password),
    );
    result.fold(
      (failure) => emit(_mapFailureToState(failure)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    // print('>>> Bloc menerima RegisterRequested'); // ← tambah ini
    // print('>>> name=${event.name}, email=${event.email}'); // ← tambah ini
    emit(const AuthLoading());
    final result = await registerUsecase(
      RegisterParams(
        name: event.name,
        email: event.email,
        password: event.password,
        passwordConfirmation: event.passwordConfirmation,
      ),
    );
    result.fold(
      (failure) {
        // print('>>> Failure: ${failure.message}'); // ← tambah ini
        emit(_mapFailureToState(failure));
      },
      (user) {
        // print('>>> Success: ${user.email}'); // ← tambah ini
        emit(Authenticated(user));
      },
    );
  }

  Future<void> _onVerifyOtpRequested(
    VerifyOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await verifyOtpUsecase(VerifyOtpParams(otp: event.otp));
    result.fold(
      (failure) => emit(_mapFailureToState(failure)),
      (_) => emit(const OtpVerified()),
    );
  }

  Future<void> _onResendOtpRequested(
    ResendOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await resendOtpUsecase();
    result.fold(
      (failure) => emit(_mapFailureToState(failure)),
      (_) => emit(const OtpResent()),
    );
  }

  AuthState _mapFailureToState(Failure failure) {
    // print('>>> Failure type: ${failure.runtimeType}');
    // print('>>> Failure message: ${failure.message}');

    if (failure is EmailNotVerifiedFailure) {
      return const AuthEmailNotVerified('Email belum diverifikasi');
    }
    if (failure is UnauthorizedFailure) {
      return const AuthFailure('Email atau password salah');
    }
    return AuthFailure(failure.message); // ← tampilkan pesan asli dari server
  }

  Future<void> _onFetchUser(
    FetchUserRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state is Authenticated) return;

    final result = await getUserUsecase();

    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await logoutUsecase(); 
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (_) => emit(const AuthInitial()), 
    );
  }
  
  Future<void> _onGoogleLoginRequested(
    GoogleLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await googleLoginUsecase(event.idToken);
    result.fold(
      (failure) => emit(_mapFailureToState(failure)),
      (user) => emit(Authenticated(user)),
    );
  }
}
