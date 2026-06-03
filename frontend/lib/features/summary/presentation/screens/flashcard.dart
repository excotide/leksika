import 'package:flutter/material.dart';
import 'package:leksika/features/summary/presentation/widgets/bottom_navbar.dart';

// ============================================================
// PRESENTATION LAYER — Clean Architecture
// File: lib/features/flashcard/presentation/pages/flashcard_page.dart
// ============================================================

// Model sederhana untuk data flashcard — normalnya ada di domain layer
class FlashcardItem {
  final String fileName;
  final int cardCount;
  final int durationMinutes;
  final double progress; // 0.0 - 1.0, null berarti belum ada progress

  const FlashcardItem({
    required this.fileName,
    required this.cardCount,
    required this.durationMinutes,
    this.progress = 0.0,
  });
}

class FlashcardPage extends StatelessWidget {
  const FlashcardPage({super.key});

  // Data dummy — nantinya diambil dari BLoC/Cubit via repository
  static const _items = [
    FlashcardItem(
      fileName: 'Virtual Private Network.pdf',
      cardCount: 12,
      durationMinutes: 15,
      progress: 0.55, // card pertama punya progress bar
    ),
    FlashcardItem(
      fileName: 'Virtual Private Network.pdf',
      cardCount: 12,
      durationMinutes: 15,
      progress: 0.0, // card kedua belum ada progress
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5EE),

      // ── AppBar melengkung ke bawah ──────────────────────────
      // Pakai PreferredSize + Container dengan borderRadius bottomLeft/Right
      // agar efek pill/rounded bottom seperti di foto.
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/create-rangkuman'),
        backgroundColor: const Color(0xFF006947),
        shape: const CircleBorder(),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const BottomNavbar(activeIndex: 2),

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Tombol back
                  const BackButton(color: Colors.white),
                  const SizedBox(width: 4),
                  // Judul halaman
                  const Text(
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

      // ── Body ──────────────────────────────────────────────────
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          top: 24,
          left: 16,
          right: 16,
          bottom: 32,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subjudul section
            const _SectionHeader(),

            const SizedBox(height: 20),

            // List kartu flashcard
            ..._items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _FlashcardCard(item: item),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// WIDGET — _SectionHeader
// Label "-- PILIHAN MATERI" kecil di atas judul "Explore Flashcards"
// ============================================================
class _SectionHeader extends StatelessWidget {
  const _SectionHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label kecil uppercase hijau tua dengan dua strip di depan
        const Text(
          '— PILIHAN MATERI',
          style: TextStyle(
            color: Color(0xFF004C31),
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),

        const SizedBox(height: 4),

        // Judul besar
        const Text(
          'Explore Flashcards',
          style: TextStyle(
            color: Color(0xFF121E18),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// WIDGET — _FlashcardCard
// Kartu putih dengan:
//   - Ikon dokumen kiri atas
//   - Ikon panah diagonal kanan atas (navigate ke detail)
//   - Nama file
//   - Meta info: jumlah cards + durasi
//   - Progress bar opsional (hanya muncul kalau progress > 0)
// ============================================================
class _FlashcardCard extends StatelessWidget {
  final FlashcardItem item;

  const _FlashcardCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A004C31),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Baris atas: ikon dokumen kiri, panah kanan ──────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ikon dokumen — hijau tua, ukuran 48x48
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2E7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.insert_drive_file_outlined,
                  color: Color(0xFF004C31),
                  size: 28,
                ),
              ),

              // Ikon panah diagonal ke kanan atas (open / navigate)
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/isi-flashcard'),
                child: const Icon(
                  Icons.open_in_new,
                  color: Color(0xFF004C31),
                  size: 18,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Nama file ────────────────────────────────────────
          Text(
            item.fileName,
            style: const TextStyle(
              color: Color(0xFF121E18),
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 8),

          // ── Meta info: cards + durasi ─────────────────────────
          Row(
            children: [
              // Jumlah kartu
              _MetaChip(
                icon: Icons.style_outlined,
                label: '${item.cardCount} Cards',
              ),

              const SizedBox(width: 16),

              // Estimasi durasi
              _MetaChip(
                icon: Icons.access_time_outlined,
                label: '${item.durationMinutes}m',
              ),
            ],
          ),

          // ── Progress bar (hanya tampil kalau ada progress) ──
          if (item.progress > 0) ...[
            const SizedBox(height: 16),
            _ProgressBar(value: item.progress),
          ],
        ],
      ),
    );
  }
}

// ============================================================
// WIDGET — _MetaChip
// Pasangan ikon kecil + teks untuk info "12 Cards" dan "15m".
// ============================================================
class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: const Color(0xFF3F4943)),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF3F4943),
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// WIDGET — _ProgressBar
// Progress bar pill shape hijau tua di atas background hijau muda.
// value: 0.0 - 1.0
// ============================================================
class _ProgressBar extends StatelessWidget {
  final double value;

  const _ProgressBar({required this.value});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final trackWidth = constraints.maxWidth;
        final fillWidth = trackWidth * value.clamp(0.0, 1.0);

        return Container(
          width: trackWidth,
          height: 6,
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2E7),
            borderRadius: BorderRadius.circular(9999),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: fillWidth,
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFF004C31),
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
          ),
        );
      },
    );
  }
}