import 'dart:math';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const topGreen = Color(0xFF4B9083);
    const darkGreenButton = Color(0xFF0C6B58);

    // Lingkaran dalam: 150x150
    // Icon buku: size 72, jadi buku kira-kira dari x=39 sampai x=111 (tengah 75)
    // Pojok kanan atas buku: right ~39, top ~39 (dari tepi lingkaran)

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.55,
            color: topGreen,
            child: Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SizedBox(
                    width: 150,
                    height: 150,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Lingkaran dalam warna AFEBE4
                        Container(
                          width: 150,
                          height: 150,
                          decoration: const BoxDecoration(
                            color: Color(0xFFAFEBE4),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.menu_book_rounded,
                              size: 72,
                              color: topGreen,
                            ),
                          ),
                        ),
                        // Bintang di pojok kanan atas buku
                        // Icon 72px di lingkaran 150px: center di 75,75
                        // Pojok kanan atas buku ~ right=75-(72/2)=39, top=75-(72/2)=39
                        // Bintang 28px: right=39-14=25 agar bintangnya pas di ujung buku
                        const Positioned(
                          top: 28,
                          right: 28,
                          child: CustomPaint(
                            size: Size(28, 28),
                            painter: _FourPointStarPainter(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  const Text(
                    'Upload PDF,\ndapat Ringkasan Instan',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'AI kami membaca materi di dokumenmu dan mengubahnya jadi ringkasan yang mudah dipahami dalam detik.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkGreenButton,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(200, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 4,
                    ),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const Text(
                      'MULAI',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
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