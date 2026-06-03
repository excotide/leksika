import 'package:flutter/material.dart';

// ============================================================
// PRESENTATION LAYER — Clean Architecture
// File: lib/features/flashcard/presentation/pages/flashcard_result_page.dart
// ============================================================

class FlashcardResultPage extends StatelessWidget {
  const FlashcardResultPage({super.key});

  // Data dummy — normalnya dari BLoC/state setelah sesi selesai
  static const String _topicName = 'Virtual Private Network';
  static const int _totalCards = 10;
  static const int _score = 80;
  static const int _sudahMengerti = 8;
  static const int _belumMengerti = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5EE),

      // ── AppBar rounded bottom hijau tua ───────────────────
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
                    'Hasil Flashcard',
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

      body: Column(
        children: [
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                top: 28,
                left: 24,
                right: 24,
                bottom: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Header: "SESI SELESAI" + nama topik + jumlah kartu
                  const _SessionHeader(
                    topicName: _topicName,
                    totalCards: _totalCards,
                  ),

                  const SizedBox(height: 28),

                  // 2. Kartu skor utama
                  const _ScoreCard(
                    score: _score,
                    sudahMengerti: _sudahMengerti,
                    belumMengerti: _belumMengerti,
                  ),

                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),

          // 3. Tombol aksi bawah: Ulangi & Selesai
          _BottomActions(
            onUlangi: () {
            
            },
            onSelesai: () {
          
            },
          ),
        ],
      ),
    );
  }
}

// ============================================================
// WIDGET — _SessionHeader
// Label "🏆 SESI SELESAI" + judul topik bold + sub-info kartu
// ============================================================
class _SessionHeader extends StatelessWidget {
  final String topicName;
  final int totalCards;

  const _SessionHeader({
    required this.topicName,
    required this.totalCards,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row ikon trofi + label "SESI SELESAI"
        Row(
          children: [
            // Ikon trofi kuning — pengganti Image.network
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: const Color(0xFFFFB95F),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                color: Color(0xFF5E3900),
                size: 18,
              ),
            ),

            const SizedBox(width: 8),

            // Label uppercase abu-abu
            const Text(
              'SESI SELESAI',
              style: TextStyle(
                color: Color(0xFF3F4943),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Nama topik — besar, bold, hijau tua
        Text(
          topicName,
          style: const TextStyle(
            color: Color(0xFF004C31),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 4),

        // Sub info: jumlah kartu dipelajari
        Text(
          '$totalCards Kartu telah dipelajari',
          style: const TextStyle(
            color: Color(0xFF3F4943),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// WIDGET — _ScoreCard
// Kartu putih bulat berisi:
//   - Label "SKOR KAMU"
//   - Angka skor besar hijau neon
//   - Sub-teks motivasi
//   - Divider garis putus-putus
//   - Dua kolom: sudah mengerti (hijau) vs belum mengerti (merah)
// ============================================================
class _ScoreCard extends StatelessWidget {
  final int score;
  final int sudahMengerti;
  final int belumMengerti;

  const _ScoreCard({
    required this.score,
    required this.sudahMengerti,
    required this.belumMengerti,
  });

  // Teks motivasi berdasarkan skor
  String get _motivationText {
    if (score >= 80) return 'Bagus! Terus tingkatkan';
    if (score >= 60) return 'Lumayan! Masih bisa lebih baik';
    return 'Jangan menyerah, coba lagi!';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color(0xFFC0C0C0), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      child: Column(
        children: [
          // Label "SKOR KAMU" — abu, bold, agak besar
          const Text(
            'SKOR KAMU',
            style: TextStyle(
              color: Color(0xFF6F7A72),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          // Angka skor — sangat besar, hijau neon (#00FF5D)
          Text(
            '$score',
            style: const TextStyle(
              color: Color(0xFF00FF5D),
              fontSize: 96,
              fontWeight: FontWeight.bold,
              height: 1.0,
            ),
          ),

          const SizedBox(height: 8),

          // Teks motivasi
          Text(
            _motivationText,
            style: const TextStyle(
              color: Color(0xFF000000),
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 16),

          // Divider putus-putus — pakai CustomPaint
          const _DashedDivider(),

          const SizedBox(height: 24),

          // Dua kolom statistik: sudah vs belum mengerti
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Kolom kiri: Sudah Mengerti — hijau
              _StatColumn(
                value: '$sudahMengerti',
                valueColor: const Color(0xFF059669),
                label: 'sudah\nMengerti',
              ),

              // Jarak antar kolom
              const SizedBox(width: 80),

              // Kolom kanan: Belum Mengerti — merah
              _StatColumn(
                value: '$belumMengerti',
                valueColor: const Color(0xFFD92528),
                label: 'belum\nmengerti',
              ),
            ],
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ============================================================
// WIDGET — _StatColumn
// Satu kolom angka + label untuk statistik mengerti/tidak.
// ============================================================
class _StatColumn extends StatelessWidget {
  final String value;
  final Color valueColor;
  final String label;

  const _StatColumn({
    required this.value,
    required this.valueColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Angka besar berwarna
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 4),

        // Label 2 baris, center, abu-abu
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF6F7A72),
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// WIDGET — _DashedDivider
// Garis putus-putus horizontal menggunakan CustomPainter.
// Lebih akurat daripada teks "---" seperti di kode asli.
// ============================================================
class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 1,
      child: CustomPaint(
        painter: _DashedLinePainter(),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFB4B4B4)
      ..strokeWidth = 1.2;

    // dashWidth: lebar satu strip
    // dashSpace: jarak antar strip
    const dashWidth = 6.0;
    const dashSpace = 4.0;

    double startX = 0;

    // Loop sampai habis lebar widget
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter oldDelegate) => false;
}

// ============================================================
// WIDGET — _BottomActions
// Dua tombol bawah full-height: Ulangi (kuning) & Selesai (hijau tua)
// ============================================================
class _BottomActions extends StatelessWidget {
  final VoidCallback onUlangi;
  final VoidCallback onSelesai;

  const _BottomActions({
    required this.onUlangi,
    required this.onSelesai,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
      child: Row(
        children: [
          // Tombol ULANGI — kuning/oranye
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onUlangi,
              icon: const Icon(Icons.replay_rounded, size: 18),
              label: const Text(
                'ULANGI',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFB95F),
                foregroundColor: const Color(0xFF5E3900),
                elevation: 2,
                shadowColor: const Color(0x1A000000),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Tombol SELESAI — hijau tua
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onSelesai,
              icon: const Icon(Icons.check_circle_outline, size: 18),
              label: const Text(
                'SELESAI',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF004C31),
                foregroundColor: Colors.white,
                elevation: 2,
                shadowColor: const Color(0x1A000000),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}