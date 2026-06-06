import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Tambahkan import bloc
import 'package:leksika/core/di/injection_container.dart'; // Import service locator (sl)
import 'package:leksika/core/navigation/app_navigator.dart';
import 'package:leksika/core/router/app_router.dart';
import 'package:leksika/core/services/fcm_notification_service.dart';
import 'package:leksika/features/auth/presentation/bloc/auth_bloc.dart'; // Import AuthBloc
import 'package:leksika/features/auth/presentation/bloc/auth_event.dart'; // Import AuthEvent
import 'package:leksika/features/auth/presentation/bloc/auth_state.dart';
import 'package:leksika/shared/theme/app_theme.dart';

class LeksikaApp extends StatelessWidget {
  const LeksikaApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Membungkus MaterialApp dengan BlocProvider global
    final authBloc = sl<AuthBloc>()..add(const FetchUserRequested());

    return BlocProvider.value(
      // Fetch user dilakukan satu kali saat aplikasi pertama kali dijalankan
      value: authBloc,
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            sl<FcmNotificationService>().registerCurrentToken();
          }
          if (state is AuthInitial) {
            sl<FcmNotificationService>().unregisterCurrentToken();
          }
        },
        child: MaterialApp(
          navigatorKey: appNavigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'Leksika',
          theme: AppTheme.light,
          initialRoute: AppRouter.initialRoute,
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      ),
    );
  }
}
