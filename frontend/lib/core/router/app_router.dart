import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leksika/core/di/injection_container.dart';
import 'package:leksika/core/router/smooth_page_route.dart';
import 'package:leksika/features/auth/presentation/screens/login_screen.dart';
import 'package:leksika/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:leksika/features/auth/presentation/screens/otp_screen.dart';
import 'package:leksika/features/auth/presentation/screens/register_screen.dart';
import 'package:leksika/features/auth/presentation/screens/splash_screen.dart';
import 'package:leksika/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:leksika/features/summary/presentation/screens/create_rangkuman_screen.dart';
import 'package:leksika/features/summary/presentation/screens/detail_screen.dart';
import 'package:leksika/features/summary/presentation/screens/home_screen.dart';
import 'package:leksika/features/summary/presentation/screens/notification.dart'; // ← tambahan
import 'package:leksika/features/summary/presentation/screens/riwayat_screen.dart';
import 'package:leksika/features/summary/presentation/screens/summary_screen.dart';
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
          page: BlocProvider(
            create: (_) => sl<AuthBloc>(),
            child: const LoginScreen(),
          ),
        );
      case '/register':
        return SmoothPageRoute(
          page: BlocProvider(
            create: (_) => sl<AuthBloc>(),
            child: const RegisterScreen(),
          ),
        );
      case '/otp':
        return SmoothPageRoute(
          page: BlocProvider(
            create: (_) => sl<AuthBloc>(),
            child: const OtpScreen(),
          ),
        );
      case '/home':
        return SmoothPageRoute(page: const HomeScreen());
      case '/notifikasi': // ← tambahan
        return SmoothPageRoute(page: const NotificationScreen());
      case '/riwayat':
        return SmoothPageRoute(page: const RiwayatScreen());
      case '/create-rangkuman':
        return SmoothPageRoute(page: const CreateRangkumanScreen());
      case '/detail':
        return SmoothPageRoute(page: _buildDetailFromArgs(settings.arguments));
      case '/summary':
        return SmoothPageRoute(page: const SummaryScreen());
      case '/flashcard':
        return SmoothPageRoute(
          page: const PlaceholderScreen(title: 'Flashcard'),
        );
      case '/profil':
        return SmoothPageRoute(
          page: const PlaceholderScreen(title: 'Profil'),
        );
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
      );
    }

    return const SummaryDetailScreen(
      title: 'Rangkuman',
      pageCount: '0 Halaman',
      contents: [],
    );
  }
}