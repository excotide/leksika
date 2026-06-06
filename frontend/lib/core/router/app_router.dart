import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leksika/core/di/injection_container.dart';
import 'package:leksika/core/router/smooth_page_route.dart';
import 'package:leksika/core/transitions/app_transitions.dart';
import 'package:leksika/features/auth/presentation/screens/login_screen.dart';
import 'package:leksika/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:leksika/features/auth/presentation/screens/otp_screen.dart';
import 'package:leksika/features/auth/presentation/screens/register_screen.dart';
import 'package:leksika/features/auth/presentation/screens/splash_screen.dart';
import 'package:leksika/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:leksika/features/auth/presentation/screens/forgot_otp_screen.dart';
import 'package:leksika/features/auth/presentation/screens/new_password_screen.dart';
import 'package:leksika/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:leksika/features/summary/domain/entities/document_entity.dart';
import 'package:leksika/features/summary/domain/entities/notification_entity.dart';
import 'package:leksika/features/summary/presentation/screens/create_rangkuman_screen.dart';
import 'package:leksika/features/summary/presentation/screens/detail_screen.dart';
import 'package:leksika/features/summary/presentation/screens/home_screen.dart';
import 'package:leksika/features/summary/presentation/screens/notification.dart'; // ← tambahan
import 'package:leksika/features/summary/presentation/screens/notification_detail.dart';
import 'package:leksika/features/summary/presentation/screens/riwayat_screen.dart';
import 'package:leksika/features/summary/presentation/screens/summary_screen.dart';
import 'package:leksika/features/summary/presentation/screens/flashcard.dart';
import 'package:leksika/features/summary/presentation/screens/isi_flashcard.dart';
import 'package:leksika/features/summary/presentation/screens/hasil_flashcard.dart';
import 'package:leksika/features/summary/presentation/screens/profile.dart';
import 'package:leksika/features/summary/presentation/screens/edit_profile.dart';
import 'package:leksika/shared/widgets/placeholder_screen.dart';

class AppRouter {
  static const String initialRoute = '/';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final routeName = settings.name ?? '/';

    switch (routeName) {
      case '/':
        return SmoothPageRoute(page: const SplashScreen());
      case '/onboarding':
        return SmoothPageRoute(page: const OnboardingScreen());
      case '/login':
        return SmoothPageRoute(
          page: BlocProvider.value(
            value: sl<AuthBloc>(),
            child: const LoginScreen(),
          ),
        );
      case '/register':
        return SmoothPageRoute(
          page: BlocProvider.value(
            value: sl<AuthBloc>(),
            child: const RegisterScreen(),
          ),
        );
      case '/otp':
        final otpArgs = settings.arguments as Map<String, dynamic>? ?? {};
        return SmoothPageRoute(
          page: BlocProvider.value(
            value: sl<AuthBloc>(),
            child: OtpScreen(
              email: otpArgs['email'] as String? ?? '',
            ),
          ),
        );
      case '/forgot-password':
        return SmoothPageRoute(
          page: BlocProvider.value(
            value: sl<AuthBloc>(),
            child: const ForgotPasswordScreen(),
          ),
        );
      case '/forgot-otp':
        final forgotArgs = settings.arguments as Map<String, dynamic>? ?? {};
        return SmoothPageRoute(
          page: BlocProvider.value(
            value: sl<AuthBloc>(),
            child: ForgotOtpScreen(
              email: forgotArgs['email'] as String? ?? '',
            ),
          ),
        );
      case '/new-password':
        final newPassArgs = settings.arguments as Map<String, dynamic>? ?? {};
        return SmoothPageRoute(
          page: BlocProvider.value(
            value: sl<AuthBloc>(),
            child: NewPasswordScreen(
              email: newPassArgs['email'] as String? ?? '',
              resetToken: newPassArgs['reset_token'] as String? ?? '',
            ),
          ),
        );
      case '/home':
        return FadeRoute(page: const HomeScreen(), settings: settings);
      case '/notifikasi':
        return SmoothPageRoute(page: const NotificationScreen());
      case '/notification-detail':
        return SmoothPageRoute(
          page: settings.arguments is NotificationEntity
              ? NotificationDetailScreen(
                  notification: settings.arguments as NotificationEntity,
                )
              : const PlaceholderScreen(title: 'Notifikasi tidak ditemukan'),
        );
      case '/riwayat':
        return FadeRoute(page: const RiwayatScreen(), settings: settings);
      case '/create-rangkuman':
        return SlideRightToLeftRoute(page: const CreateRangkumanScreen(), settings: settings);
      case '/detail':
        return SlideRightToLeftRoute(page: _buildDetailFromArgs(settings.arguments), settings: settings);
      case '/summary':
        return SmoothPageRoute(page: const SummaryScreen());
      case '/flashcard':
        return FadeRoute(page: const FlashcardPage(), settings: settings);
      case '/isi-flashcard':
        return PageRouteBuilder(
          settings: settings,
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (context, animation, secondaryAnimation) =>
              FlashcardDetailPage(
                bodyAnimation: animation,
                document: settings.arguments is DocumentEntity
                    ? settings.arguments as DocumentEntity
                    : null,
              ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) => child,
        );
      case '/hasil-flashcard':
        return PageRouteBuilder(
          settings: settings,
          transitionDuration: const Duration(milliseconds: 400),
          reverseTransitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (context, animation, secondaryAnimation) =>
              FlashcardResultPage(bodyAnimation: animation),
          transitionsBuilder: (context, animation, secondaryAnimation, child) => child,
        );
      case '/profil':
        return FadeRoute(page: const SetelanPage(), settings: settings);
      case '/edit-profil':
        return SlideRightToLeftRoute(page: const EditProfilePage(), settings: settings);
      default:
        return SmoothPageRoute(
            page: const PlaceholderScreen(title: 'Not Found'));
    }
  }

  static SummaryDetailScreen _buildDetailFromArgs(Object? args) {
    if (args is Map<String, dynamic>) {
      final title = args['title'] as String? ?? 'Rangkuman';
      final pageCount = args['pageCount'] as String? ?? '0 Halaman';
      final contents = (args['contents'] as List?)
              ?.whereType<Map<String, String>>()
              .toList() ??
          <Map<String, String>>[];
      return SummaryDetailScreen(
        title: title,
        pageCount: pageCount,
        contents: contents,
        document: args['document'] is DocumentEntity
            ? args['document'] as DocumentEntity
            : null,
      );
    }

    return const SummaryDetailScreen(
      title: 'Rangkuman',
      pageCount: '0 Halaman',
      contents: [],
    );
  }
}
