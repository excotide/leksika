import 'package:flutter/material.dart';
import 'dart:math' as math;

// ============================================================
// PRESENTATION LAYER — Clean Architecture
// File: lib/features/flashcard/presentation/pages/flashcard_detail_page.dart
// ============================================================

class FlashcardDetailPage extends StatefulWidget {
  const FlashcardDetailPage({super.key});

  @override
  State<FlashcardDetailPage> createState() => _FlashcardDetailPageState();
}

class _FlashcardDetailPageState extends State<FlashcardDetailPage>
    with SingleTickerProviderStateMixin {

  // ── Animation Controller ──────────────────────────────────
  // Controller untuk animasi flip 3D pada kartu.
  late final AnimationController _controller;

  // Animasi dari 0.0 (depan/soal) → 1.0 (belakang/jawaban)
  late final Animation<double> _animation;

  // Flag: apakah sedang menampilkan sisi belakang (jawaban)?
  bool _isFlipped = false;

  // Progress dummy — nantinya dari BLoC
  // Representasi: 1 dari 12 kartu sudah diselesaikan
  final int _currentCard = 1;
  final int _totalCards = 12;

  @override
  void initState() {
    super.initState();

    // Duration 400ms — cukup smooth, tidak terlalu lambat
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // CurvedAnimation: easeInOut supaya flip terasa natural
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ── Fungsi flip ───────────────────────────────────────────
  // Dipanggil saat user tap kartu.
  // Kalau belum flip → forward (soal → jawaban)
  // Kalau sudah flip → reverse (jawaban → soal)
  void _flipCard() {
    if (_isFlipped) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    setState(() => _isFlipped = !_isFlipped);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5EE),

      // ── AppBar rounded bottom ──────────────────────────────
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF006947),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(48),
              bottomRight: Radius.circular(48),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x1A00362A),
                blurRadius: 30,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: const [
                  BackButton(color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    'Flashcard',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      // ── Body ───────────────────────────────────────────────
      body: Column(
        children: [
          // Scrollable content area — header + kartu
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Column(
                children: [
                  // Judul + badge bagian
                  const _CardHeader(),

                  const SizedBox(height: 24),

                  // ── Flashcard yang bisa di-flip ─────────────
                  // GestureDetector untuk deteksi tap → flip
                  GestureDetector(
                    onTap: _flipCard,
                    child: _FlipCard(
                      animation: _animation,
                      currentCard: _currentCard,
                      totalCards: _totalCards,
                      // Konten sisi depan (soal)
                      frontChild: const _CardFront(),
                      // Konten sisi belakang (jawaban)
                      backChild: _CardBack(
                        onSudahMengerti: () {
                          
                          _flipCard(); // balik ke soal
                        },
                        onBelumMengerti: () {
                          
                          _flipCard(); // balik ke soal
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Navigasi bawah: Kembali & Selanjutnya ──────────
          const _BottomNav(),
        ],
      ),
    );
  }
}

// ============================================================
// WIDGET — _CardHeader
// Judul flashcard + badge "Bagian 1" di tengah.
// ============================================================
class _CardHeader extends StatelessWidget {
  const _CardHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Judul bold hijau tua, center
        const Text(
          'Flashcard - Virtual Private\nNetwork',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF004C31),
            fontSize: 24,
            fontWeight: FontWeight.bold,
            height: 1.3,
          ),
        ),

        const SizedBox(height: 10),

        // Badge pill hijau muda "Bagian 1"
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF7EFBAE),
            borderRadius: BorderRadius.circular(9999),
          ),
          child: const Text(
            'Bagian 1',
            style: TextStyle(
              color: Color(0xFF007442),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// WIDGET — _FlipCard
// Widget utama yang menangani animasi flip 3D.
// Menggunakan AnimatedBuilder + Transform untuk rotasi sumbu Y.
//
// Cara kerja flip 3D:
//   - Sisi depan: rotasi dari 0 → π (180°) → tapi hanya terlihat di 0–π/2
//   - Sisi belakang: rotasi dari -π → 0 → tapi hanya terlihat di π/2–π
//   - Keduanya di-stack, visibility diatur lewat threshold animation.value
// ============================================================
class _FlipCard extends StatelessWidget {
  final Animation<double> animation;
  final Widget frontChild;
  final Widget backChild;
  final int currentCard;
  final int totalCards;

  const _FlipCard({
    required this.animation,
    required this.frontChild,
    required this.backChild,
    required this.currentCard,
    required this.totalCards,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        // angle: 0.0 (depan) → π (belakang)
        // animation.value: 0.0 → 1.0
        final angle = animation.value * math.pi;

        // Kalau angle < π/2 → tampilkan depan
        // Kalau angle >= π/2 → tampilkan belakang
        final showFront = angle < math.pi / 2;

        return Stack(
          children: [
            // ── Sisi DEPAN (soal) ────────────────────────────
            // Visibility: hanya tampil kalau showFront == true
            Transform(
              alignment: Alignment.center,
              // Rotasi sumbu Y: 0 → π
              transform: Matrix4.rotationY(angle),
              child: Visibility(
                visible: showFront,
                maintainSize: true,       // tetap ambil space walau invisible
                maintainAnimation: true,
                maintainState: true,
                child: _CardShell(
                  currentCard: currentCard,
                  totalCards: totalCards,
                  child: frontChild,
                ),
              ),
            ),

            // ── Sisi BELAKANG (jawaban) ──────────────────────
            // Visibility: hanya tampil kalau showFront == false
            Transform(
              alignment: Alignment.center,
              // Rotasi: mulai dari -π (tersembunyi) → menuju 0 (tampil)
              transform: Matrix4.rotationY(angle - math.pi),
              child: Visibility(
                visible: !showFront,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: _CardShell(
                  currentCard: currentCard,
                  totalCards: totalCards,
                  child: backChild,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ============================================================
// WIDGET — _CardShell
// Shell kartu putih yang sama untuk depan maupun belakang:
//   - Container putih rounded dengan shadow
//   - Label "PROGRES" + progress bar di atas
//   - Slot untuk konten (soal atau jawaban)
// ============================================================
class _CardShell extends StatelessWidget {
  final Widget child;
  final int currentCard;
  final int totalCards;

  const _CardShell({
    required this.child,
    required this.currentCard,
    required this.totalCards,
  });

  @override
  Widget build(BuildContext context) {
    final progress = currentCard / totalCards; // 0.0 – 1.0

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(27),
        border: Border.all(color: const Color(0xFFB4B4B4), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      child: Column(
        children: [
          // Label "PROGRES"
          const Text(
            'PROGRES',
            style: TextStyle(
              color: Color(0xFF3F4943),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),

          const SizedBox(height: 8),

          // Progress bar — lebar mengikuti parent card
          LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                width: constraints.maxWidth,
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDECE1),
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    // FractionallySizedBox lebih clean daripada kalkulasi manual
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF004C31),
                        borderRadius: BorderRadius.circular(9999),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 32),

          // Slot konten — diisi oleh _CardFront atau _CardBack
          child,
        ],
      ),
    );
  }
}

// ============================================================
// WIDGET — _CardFront (Sisi Soal)
// Teks soal di tengah + tombol "Lihat Jawaban".
// Tap tombol tidak perlu — user tap seluruh kartu untuk flip.
// ============================================================
class _CardFront extends StatelessWidget {
  const _CardFront();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Teks soal — center, bold, hitam
        const Text(
          'VPN berfungsi seperti gerbang yang memastikan setiap data yang dikirim maupun diterima tidak lagi menggunakan jalur umum yang terbuka, melainkan terbungkus aman di dalam sistem perlindungan tambahan',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF000000),
            fontSize: 15,
            fontWeight: FontWeight.bold,
            height: 1.6,
          ),
        ),

        const SizedBox(height: 40),

        // Tombol "Lihat Jawaban" — border hijau, background putih
        // Tap kartu sudah cukup untuk flip, tombol ini visual hint
        OutlinedButton(
          onPressed: null, // tap kartu yang trigger flip
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFF059669), width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
          ),
          child: const Text(
            'Lihat\nJawaban',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF000000),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Hint tap
        const Text(
          'Tap kartu untuk melihat jawaban',
          style: TextStyle(
            color: Color(0xFFAAAAAA),
            fontSize: 11,
          ),
        ),

        const SizedBox(height: 8),
      ],
    );
  }
}

// ============================================================
// WIDGET — _CardBack (Sisi Jawaban)
// Judul "JAWABAN" + dua tombol: Sudah Mengerti & Belum Mengerti
// ============================================================
class _CardBack extends StatelessWidget {
  final VoidCallback onSudahMengerti;
  final VoidCallback onBelumMengerti;

  const _CardBack({
    required this.onSudahMengerti,
    required this.onBelumMengerti,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Label "JAWABAN" — bold, center, besar
        const Text(
          'JAWABAN',
          style: TextStyle(
            color: Color(0xFF000000),
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),

        const SizedBox(height: 60),

        const SizedBox(height: 80),

        // Dua tombol berdampingan: Sudah Mengerti (hijau) & Belum Mengerti (kuning)
        Row(
          children: [
            // Tombol Sudah Mengerti — hijau tua
            Expanded(
              child: ElevatedButton(
                onPressed: onSudahMengerti,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF004C31),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'SUDAH\nMENGERTI',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Tombol Belum Mengerti — kuning/oranye muda
            Expanded(
              child: ElevatedButton(
                onPressed: onBelumMengerti,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF5A623),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'BELUM\nMENGERTI',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),
      ],
    );
  }
}

// ============================================================
// WIDGET — _BottomNav
// Navigasi bawah: tombol "< Kembali" dan "Selanjutnya >"
// ============================================================
class _BottomNav extends StatelessWidget {
  const _BottomNav();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      color: const Color(0xFFE8F5EE),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.chevron_left, size: 18, color: Color(0xFF004C31)),
            label: const Text(
              'Kembali',
              style: TextStyle(
                color: Color(0xFF004C31),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF004C31),
              elevation: 2,
              shadowColor: Colors.black12,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),

          // Tombol Selanjutnya
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Text(
              'Selanjutnya',
              style: TextStyle(
                color: Color(0xFF004C31),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            label: const Icon(Icons.chevron_right, size: 18, color: Color(0xFF004C31)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF004C31),
              elevation: 2,
              shadowColor: Colors.black12,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }
}