import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:leksika/features/summary/domain/entities/document_entity.dart';
import 'package:leksika/features/summary/domain/entities/flashcard_entity.dart';

// ============================================================
// PRESENTATION LAYER — Clean Architecture
// File: lib/features/flashcard/presentation/pages/flashcard_detail_page.dart
// ============================================================

class FlashcardDetailPage extends StatefulWidget {
  final Animation<double>? bodyAnimation;
  final DocumentEntity? document;

  const FlashcardDetailPage({super.key, this.bodyAnimation, this.document});

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

  int _currentIndex = 0;
  final Map<int, bool> _answersByCardIndex = {};

  List<FlashcardEntity> get _flashcards => widget.document?.flashcards ?? const [];

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

  void _nextCard() {
    if (_currentIndex < _flashcards.length - 1) {
      setState(() {
        _currentIndex++;
        _isFlipped = false;
      });
      _controller.reset();
    }
  }

  void _prevCard() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _isFlipped = false;
      });
      _controller.reset();
    }
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
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 16, 16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Text(
                    'Flashcard',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                        onPressed: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          } else {
                            Navigator.pushReplacementNamed(context, '/home');
                          }
                        },
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/notifikasi'),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.notifications_none_outlined,
                            color: Color(0xFF006947),
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      // ── Body ───────────────────────────────────────────────
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_flashcards.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Flashcard belum tersedia untuk dokumen ini.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF004C31),
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    final anim = widget.bodyAnimation;
    final currentFlashcard = _flashcards[_currentIndex];
    final hasAnsweredCurrentCard = _answersByCardIndex.containsKey(_currentIndex);
    final isLastCard = _currentIndex == _flashcards.length - 1;
    final body = SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          children: [
            // Judul + badge bagian
            _CardHeader(
              title: widget.document?.title ?? 'Flashcard',
              part: '${_currentIndex + 1}',
            ),

            const SizedBox(height: 24),

            // ── Flashcard yang bisa di-flip ─────────────
            // GestureDetector untuk deteksi tap → flip
            SizedBox(
              height: 520,
              child: GestureDetector(
                onTap: _flipCard,
                child: _FlipCard(
                  animation: _animation,
                  currentCard: _currentIndex + 1,
                  totalCards: _flashcards.length,
                  frontChild: _CardFront(question: currentFlashcard.question),
                  backChild: _CardBack(
                    answer: currentFlashcard.answer,
                    onSudahMengerti: () {
                      _answerCurrentCard(true);
                      _nextCard();
                    },
                    onBelumMengerti: () {
                      _answerCurrentCard(false);
                      _nextCard();
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Navigasi: Kembali & Selanjutnya ──────────
            _BottomNav(
              onBack: _prevCard,
              onNext: _nextCard,
              hasAnswered: hasAnsweredCurrentCard,
              isLastCard: isLastCard && hasAnsweredCurrentCard,
              onSelesai: _finishReview,
            ),
          ],
        ),
      );

    if (anim == null) return body;

    final slideTween = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).chain(CurveTween(curve: Curves.easeInOut));

    return FadeTransition(
      opacity: CurvedAnimation(parent: anim, curve: Curves.easeInOut),
      child: SlideTransition(
        position: anim.drive(slideTween),
        child: body,
      ),
    );
  }

  void _answerCurrentCard(bool understood) {
    setState(() {
      _answersByCardIndex[_currentIndex] = understood;
    });
  }

  void _finishReview() {
    final sudahMengerti = _answersByCardIndex.values.where((value) => value).length;
    final belumMengerti = _flashcards.length - sudahMengerti;
    final score = (_flashcards.isEmpty
        ? 0
        : ((sudahMengerti / _flashcards.length) * 100).round())
        .clamp(0, 100)
        .toInt();

    Navigator.pushNamed(
      context,
      '/hasil-flashcard',
      arguments: {
        'totalCards': _flashcards.length,
        'sudahMengerti': sudahMengerti,
        'belumMengerti': belumMengerti,
        'score': score,
        'topicName': widget.document?.title ?? 'Flashcard',
        'document': widget.document,
      },
    );
  }
}

// ============================================================
// WIDGET — _CardHeader
// Judul flashcard + badge "Bagian 1" di tengah.
// ============================================================
class _CardHeader extends StatelessWidget {
  final String title;
  final String part;

  const _CardHeader({required this.title, required this.part});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Judul bold hijau tua, center
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF004C31),
            fontSize: 24,
            fontWeight: FontWeight.bold,
            height: 1.3,
          ),
        ),

        const SizedBox(height: 10),

        // Badge pill hijau muda "Bagian N"
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF7EFBAE),
            borderRadius: BorderRadius.circular(9999),
          ),
          child: Text(
            'Bagian $part',
            style: const TextStyle(
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
      height: double.infinity,
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
        mainAxisSize: MainAxisSize.max,
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
          Expanded(child: child),
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
  final String question;

  const _CardFront({required this.question});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Spacer(),

        // Teks soal — center, bold, hitam
        Text(
          question,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF000000),
            fontSize: 15,
            fontWeight: FontWeight.bold,
            height: 1.6,
          ),
        ),

        const Spacer(),

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
  final String answer;
  final VoidCallback onSudahMengerti;
  final VoidCallback onBelumMengerti;

  const _CardBack({
    required this.answer,
    required this.onSudahMengerti,
    required this.onBelumMengerti,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Spacer(),

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

        const SizedBox(height: 24),

        Text(
          answer,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF000000),
            fontSize: 18,
            fontWeight: FontWeight.bold,
            height: 1.5,
          ),
        ),

        const Spacer(),

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
  final VoidCallback onBack;
  final VoidCallback onNext;
  final bool isLastCard;
  final bool hasAnswered;
  final VoidCallback onSelesai;

  const _BottomNav({
    required this.onBack,
    required this.onNext,
    required this.isLastCard,
    required this.hasAnswered,
    required this.onSelesai,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
      color: const Color(0xFFE8F5EE),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                onPressed: onBack,
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

              if (isLastCard)
                // Tombol Selesai — hijau tua solid
                ElevatedButton.icon(
                  onPressed: onSelesai,
                  icon: const Text(
                    'Selesai',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  label: const Icon(Icons.check, size: 18, color: Colors.white),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF004C31),
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shadowColor: Colors.black12,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                )
              else
                // Tombol Selanjutnya — disabled sampai user jawab
                Opacity(
                  opacity: hasAnswered ? 1.0 : 0.4,
                  child: ElevatedButton.icon(
                    onPressed: hasAnswered ? onNext : null,
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
                ),
            ],
          ),

        ],
      ),
    );
  }
}
