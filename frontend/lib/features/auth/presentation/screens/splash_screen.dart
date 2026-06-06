import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leksika/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:leksika/features/auth/presentation/bloc/auth_state.dart';
import 'package:leksika/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isSecondSplash = false;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => isSecondSplash = true);
      Timer(const Duration(seconds: 3), () async {
        if (!mounted) return;
        final prefs = await SharedPreferences.getInstance();
        if (!mounted) return;
        final hasSeenOnboarding =
            prefs.getBool(OnboardingScreen.seenKey) ?? false;
        final authState = context.read<AuthBloc>().state;
        Navigator.pushReplacementNamed(
          context,
          authState is Authenticated
              ? '/home'
              : hasSeenOnboarding
                  ? '/login'
                  : '/onboarding',
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF337165);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          Positioned(
            top: -size.height * 0.15,
            left: size.width * 0.5 - size.width * 0.55,
            child: _circle(size.width * 1.1, Colors.white, 0.10),
          ),
          Positioned(
            top: -size.height * 0.12,
            left: -size.width * 0.30,
            child: _circle(size.width * 0.70, Colors.white, 0.08),
          ),
          Positioned(
            top: size.height * 0.30,
            right: -size.width * 0.30,
            child: _circle(size.width * 0.70, Colors.white, 0.08),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            child: isSecondSplash
                ? _buildSplash2(key: const ValueKey('s2'))
                : _buildSplash1(key: const ValueKey('s1')),
          ),
        ],
      ),
    );
  }

  Widget _circle(double size, Color color, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: opacity),
      ),
    );
  }

  Widget _buildSplash1({Key? key}) {
    return SizedBox.expand(
      key: key,
      child: const Center(
        child: Text(
          'AI Study Assistant',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.w400,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildSplash2({Key? key}) {
    // Lingkaran dalam: 80x80, icon buku: 42px
    // Pojok kanan atas buku ~ right = (80-42)/2 = 19, top = 19
    // Bintang 18px: top=12, right=12
    return SizedBox.expand(
      key: key,
      child: Column(
        children: [
          const Spacer(flex: 3),
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Lingkaran dalam warna AFEBE4
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: Color(0xFFAFEBE4),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.menu_book_rounded,
                          size: 42,
                          color: Color(0xFF337165),
                        ),
                      ),
                    ),
                    // Bintang di pojok kanan atas buku
                    const Positioned(
                      top: 12,
                      right: 12,
                      child: CustomPaint(
                        size: Size(18, 18),
                        painter: _FourPointStarPainter(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'LEKSIKA',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 5,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'AI Study Assistant',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
              letterSpacing: 1,
            ),
          ),
          const Spacer(flex: 3),
          const Padding(
            padding: EdgeInsets.only(bottom: 36),
            child: Text(
              'Belajar lebih cerdas, Bukan lebih keras.',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 12,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FourPointStarPainter extends CustomPainter {
  final Color color;
  const _FourPointStarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final outer = size.width / 2;
    final inner = size.width * 0.18;

    final path = Path();
    for (int i = 0; i < 4; i++) {
      final outerAngle = (i * pi / 2) - pi / 2;
      final innerAngle1 = outerAngle + pi / 4;
      final innerAngle2 = outerAngle - pi / 4;

      final px = cx + outer * cos(outerAngle);
      final py = cy + outer * sin(outerAngle);
      final ix1 = cx + inner * cos(innerAngle2);
      final iy1 = cy + inner * sin(innerAngle2);
      final ix2 = cx + inner * cos(innerAngle1);
      final iy2 = cy + inner * sin(innerAngle1);

      if (i == 0) {
        path.moveTo(ix1, iy1);
      } else {
        path.lineTo(ix1, iy1);
      }
      path.lineTo(px, py);
      path.lineTo(ix2, iy2);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
