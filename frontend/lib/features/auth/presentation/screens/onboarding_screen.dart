import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static const String seenKey = 'has_seen_onboarding';

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const Color _topGreen = Color(0xFF4B9083);
  static const Color _darkGreenButton = Color(0xFF0C6B58);

  final PageController _controller = PageController();
  int _index = 0;

  final List<_OnboardingPageData> _pages = const [
    _OnboardingPageData(
      icon: Icons.menu_book_rounded,
      title: 'Upload PDF,\ndapat Ringkasan Instan',
      description:
          'AI kami membaca materi di dokumenmu dan mengubahnya jadi ringkasan yang mudah dipahami dalam detik.',
    ),
    _OnboardingPageData(
      icon: Icons.style_outlined,
      title: 'Ubah Materi\njadi Flashcard',
      description:
          'Dari dokumen yang sama, Leksika membantu membuat kartu tanya jawab agar kamu bisa review lebih cepat.',
    ),
    _OnboardingPageData(
      icon: Icons.notifications_active_outlined,
      title: 'Belajar Teratur\ndengan Pengingat',
      description:
          'Leksika mengingatkanmu untuk mengulang flashcard agar materi tidak cepat terlupakan.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(OnboardingScreen.seenKey, true);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _next() {
    if (_index == _pages.length - 1) {
      _finish();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: _pages.length,
              onPageChanged: (value) => setState(() => _index = value),
              itemBuilder: (context, index) => _OnboardingPage(
                data: _pages[index],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 0, 30, 36),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: _index == index ? 22 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: _index == index
                            ? _darkGreenButton
                            : const Color(0xFFD5E8E3),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _darkGreenButton,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(220, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 4,
                  ),
                  onPressed: _next,
                  child: Text(
                    _index == _pages.length - 1 ? 'MULAI' : 'LANJUT',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.data});

  final _OnboardingPageData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.55,
          color: _OnboardingScreenState._topGreen,
          child: Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SizedBox(
                  width: 150,
                  height: 150,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 150,
                        height: 150,
                        decoration: const BoxDecoration(
                          color: Color(0xFFAFEBE4),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            data.icon,
                            size: 72,
                            color: _OnboardingScreenState._topGreen,
                          ),
                        ),
                      ),
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
                Text(
                  data.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  data.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
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
