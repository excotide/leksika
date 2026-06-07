import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leksika/core/di/injection_container.dart';
import 'package:leksika/features/summary/domain/entities/document_entity.dart';
import 'package:leksika/features/summary/presentation/bloc/summary_bloc.dart';
import 'package:leksika/features/summary/presentation/bloc/summary_event.dart';
import 'package:leksika/features/summary/presentation/bloc/summary_state.dart';
import 'package:leksika/features/summary/presentation/widgets/bottom_navbar.dart';
import 'package:leksika/shared/widgets/loading_widget.dart';

// ============================================================
// PRESENTATION LAYER — Clean Architecture
// File: lib/features/flashcard/presentation/pages/flashcard_page.dart
// ============================================================

// Model sederhana untuk data flashcard — normalnya ada di domain layer
class FlashcardItem {
  final DocumentEntity document;
  final String fileName;
  final int cardCount;
  final DateTime? createdAt;

  const FlashcardItem({
    required this.document,
    required this.fileName,
    required this.cardCount,
    required this.createdAt,
  });
}

class FlashcardPage extends StatelessWidget {
  const FlashcardPage({super.key});

  List<FlashcardItem> _itemsFromDocuments(List<DocumentEntity> documents) {
    return documents
        .where((document) => document.flashcards.isNotEmpty)
        .map(
          (document) => FlashcardItem(
            document: document,
            fileName: document.title,
            cardCount: document.flashcards.length,
            createdAt: document.createdAt,
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SummaryBloc>()..add(const FetchDocumentsRequested()),
      child: Scaffold(
      backgroundColor: const Color(0xFFE8F5EE),

      // ── AppBar melengkung ke bawah ──────────────────────────
      // Pakai PreferredSize + Container dengan borderRadius bottomLeft/Right
      // agar efek pill/rounded bottom seperti di foto.
      floatingActionButton: Transform.translate(
        offset: const Offset(0, 8),
        child: FloatingActionButton(
          onPressed: () => Navigator.pushNamed(context, '/create-rangkuman'),
          backgroundColor: const Color(0xFF006947),
          shape: const CircleBorder(),
          elevation: 4,
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const BottomNavbar(activeIndex: 2),

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
                  // Judul halaman — benar-benar di tengah
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

      // ── Body ──────────────────────────────────────────────────
      body: BlocBuilder<SummaryBloc, SummaryState>(
        builder: (context, state) {
          if (state is SummaryLoading) {
            return const Center(
              child: LoadingWidget(message: 'Memuat flashcard...'),
            );
          }

          if (state is SummaryFailure) {
            return _FlashcardMessage(
              icon: Icons.error_outline,
              title: 'Gagal memuat flashcard',
              body: state.message,
            );
          }

          final documents = state is SummaryListLoaded
              ? state.documents
              : <DocumentEntity>[];
          final items = _itemsFromDocuments(documents);

          if (items.isEmpty) {
            return const _FlashcardMessage(
              icon: Icons.style_outlined,
              title: 'Belum ada flashcard',
              body: 'Buat rangkuman dengan opsi flashcard untuk mulai belajar.',
            );
          }

          return SingleChildScrollView(
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
                ...items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _FlashcardCard(item: item),
                  ),
                ),
              ],
            ),
          );
        },
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
    void navigate() => Navigator.pushNamed(
          context,
          '/isi-flashcard',
          arguments: item.document,
        );

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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: navigate,
          borderRadius: BorderRadius.circular(12),
          splashColor: const Color(0x1A004C31),
          highlightColor: const Color(0x0D004C31),
          child: Padding(
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
                      onTap: navigate,
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
                    _MetaChip(
                      icon: Icons.style_outlined,
                      label: '${item.cardCount} Cards',
                    ),

                    const SizedBox(width: 16),

                    _MetaChip(
                      icon: Icons.access_time_outlined,
                      label: _formatDate(item.createdAt),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FlashcardMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _FlashcardMessage({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF004C31), size: 42),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF121E18),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              body,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF3F4943),
                fontSize: 13,
              ),
            ),
          ],
        ),
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

String _formatDate(DateTime? date) {
  if (date == null) return 'Baru saja';
  return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
}
