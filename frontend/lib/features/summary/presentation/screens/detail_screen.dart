import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:leksika/core/di/injection_container.dart';
import 'package:leksika/core/services/in_app_notification_service.dart';
import 'package:leksika/core/utils/content_sanitizer.dart';
import 'package:leksika/features/summary/domain/entities/document_entity.dart';
import 'package:leksika/features/summary/domain/usecases/get_summary_usecase.dart';

class SummaryDetailScreen extends StatefulWidget {
  const SummaryDetailScreen({
    super.key,
    required this.title,
    required this.pageCount,
    required this.contents,
    this.document,
  });

  final String title;
  final String pageCount;
  final List<Map<String, String>> contents;
  final DocumentEntity? document;

  @override
  State<SummaryDetailScreen> createState() => _SummaryDetailScreenState();
}

class _SummaryDetailScreenState extends State<SummaryDetailScreen> {
  DocumentEntity? _document;
  bool _isCreatingFlashcards = false;

  @override
  void initState() {
    super.initState();
    _document = widget.document;
  }

  @override
  Widget build(BuildContext context) {
    final document = _document;

    return Scaffold(
      backgroundColor: const Color(0xFFDFF5EC),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00362A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Dibuat dari ${widget.pageCount}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF2F6555),
                    ),
                  ),
                  if (document != null) ...[
                    const SizedBox(height: 16),
                    document.flashcards.isNotEmpty
                        ? _buildFlashcardShortcut(context, document)
                        : _buildCreateFlashcardShortcut(context, document),
                  ],
                  const SizedBox(height: 24),
                  ...widget.contents.map((data) => _buildContentCard(
                        data['subTitle'] ?? '',
                        data['body'] ?? '',
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlashcardShortcut(BuildContext context, DocumentEntity document) {
    final totalCards = document.flashcards.length;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.pushNamed(
          context,
          '/isi-flashcard',
          arguments: document,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFB7EDD9), width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8FAF2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.style_outlined,
                  color: Color(0xFF006947),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Buka Flashcard',
                      style: TextStyle(
                        color: Color(0xFF00362A),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$totalCards kartu siap dipelajari',
                      style: const TextStyle(
                        color: Color(0xFF2F6555),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF006947),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateFlashcardShortcut(
    BuildContext context,
    DocumentEntity document,
  ) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: _isCreatingFlashcards
            ? null
            : () => _showFlashcardCountPicker(context, document),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFB7EDD9), width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8FAF2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _isCreatingFlashcards
                    ? const Padding(
                        padding: EdgeInsets.all(10),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(
                        Icons.add_card_outlined,
                        color: Color(0xFF006947),
                        size: 22,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isCreatingFlashcards
                          ? 'Membuat Flashcard...'
                          : 'Buat Flashcard',
                      style: const TextStyle(
                        color: Color(0xFF00362A),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Pilih jumlah soal sebelum membuat kartu',
                      style: TextStyle(
                        color: Color(0xFF2F6555),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF006947),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showFlashcardCountPicker(
    BuildContext context,
    DocumentEntity document,
  ) async {
    final selectedQuizCount = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        const options = ['5 Soal', '10 Soal', '15 Soal'];

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDDEDE8),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Jumlah Flashcard',
                  style: TextStyle(
                    color: Color(0xFF00362A),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Pilih berapa soal yang ingin dibuat dari rangkuman ini.',
                  style: TextStyle(
                    color: Color(0xFF2F6555),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                ...options.map(
                  (option) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Material(
                      color: const Color(0xFFE8FAF2),
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => Navigator.pop(context, option),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.style_outlined,
                                color: Color(0xFF006947),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  option,
                                  style: const TextStyle(
                                    color: Color(0xFF00362A),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: Color(0xFF006947),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || selectedQuizCount == null) return;
    await _createFlashcards(document, selectedQuizCount);
  }

  Future<void> _createFlashcards(
    DocumentEntity document,
    String quizCount,
  ) async {
    setState(() => _isCreatingFlashcards = true);
    final result = await sl<CreateFlashcardsUsecase>()(
      CreateFlashcardsParams(id: document.id, quizCount: quizCount),
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() => _isCreatingFlashcards = false);
        InAppNotificationService.show(
          title: 'Gagal membuat flashcard',
          body: failure.message,
          icon: Icons.error_outline_rounded,
          backgroundColor: const Color(0xFFFF3B30),
          titleColor: Colors.white,
          bodyColor: Colors.white,
          iconBackgroundColor: const Color(0x33FFFFFF),
          iconColor: Colors.white,
          closeIconColor: Colors.white,
          bodyMaxLines: 5,
          duration: const Duration(seconds: 6),
        );
      },
      (updatedDocument) {
        setState(() {
          _document = updatedDocument;
          _isCreatingFlashcards = false;
        });
        InAppNotificationService.show(
          title: 'Flashcard berhasil dibuat',
          body: '${updatedDocument.flashcards.length} kartu siap dipelajari.',
          icon: Icons.check_circle_rounded,
          onTap: () => Navigator.pushNamed(
            context,
            '/isi-flashcard',
            arguments: updatedDocument,
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
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
          child: Row(
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
              const Text(
                'Rangkuman',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              // ✅ FIX: GestureDetector ditambahkan
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/notifikasi'),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.notifications_none_outlined, color: Color(0xFF006947), size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentCard(String subTitle, String body) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF1FAF7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFB7EDD9), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00362A),
            ),
          ),
          const Divider(color: Color(0xFFB7EDD9), height: 24),
          _buildMarkdownContent(
            _normalizeMarkdownForDisplay(
              ContentSanitizer.cleanGeneratedText(body),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarkdownContent(String markdown) {
    final hasTable = _containsMarkdownTable(markdown);
    final tableWidth = _estimatedTableWidth(markdown);
    final markdownBody = MarkdownBody(
      data: markdown,
      selectable: true,
      styleSheet: _markdownStyleSheet(hasTable: hasTable),
    );

    if (!hasTable) return markdownBody;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.swipe_left_rounded, color: Color(0xFF2F6555), size: 16),
            SizedBox(width: 6),
            Text(
              'Geser tabel ke samping',
              style: TextStyle(
                color: Color(0xFF2F6555),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            return Scrollbar(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: math.max(constraints.maxWidth, tableWidth),
                  child: markdownBody,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  MarkdownStyleSheet _markdownStyleSheet({required bool hasTable}) {
    return MarkdownStyleSheet(
      h1: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Color(0xFF00362A),
        height: 1.35,
      ),
      h2: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF00362A),
        height: 1.35,
      ),
      h3: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF00362A),
        height: 1.35,
      ),
      p: const TextStyle(
        fontSize: 15,
        color: Color(0xFF2F6555),
        height: 1.6,
      ),
      strong: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Color(0xFF00362A),
      ),
      listBullet: const TextStyle(
        color: Color(0xFF006947),
        fontSize: 15,
      ),
      tableHead: const TextStyle(
        color: Color(0xFF00362A),
        fontSize: 13,
        fontWeight: FontWeight.bold,
        height: 1.35,
      ),
      tableBody: const TextStyle(
        color: Color(0xFF1F4038),
        fontSize: 13,
        height: 1.4,
      ),
      tableColumnWidth:
          hasTable ? const FixedColumnWidth(132) : const FlexColumnWidth(),
      tableCellsPadding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 10,
      ),
      tableBorder: TableBorder.all(
        color: const Color(0xFF8EA09A),
        width: 1,
      ),
      blockSpacing: 12,
    );
  }

  bool _containsMarkdownTable(String markdown) {
    final lines = markdown.split('\n');
    for (var i = 0; i < lines.length - 1; i++) {
      if (_markdownTableColumnCount(lines[i]) >= 2 &&
          RegExp(r'^\s*\|?\s*:?-{3,}:?\s*(\|\s*:?-{3,}:?\s*)+\|?\s*$')
              .hasMatch(lines[i + 1])) {
        return true;
      }
    }
    return false;
  }

  double _estimatedTableWidth(String markdown) {
    final maxColumns = markdown.split('\n').map(_markdownTableColumnCount).fold<int>(
          0,
          (previous, current) => math.max(previous, current),
        );
    return (math.max(0, maxColumns) * 132).toDouble();
  }

  int _markdownTableColumnCount(String line) {
    final trimmed = line.trim();
    if (!trimmed.contains('|')) return 0;
    final cells = trimmed
        .replaceAll(RegExp(r'^\|'), '')
        .replaceAll(RegExp(r'\|$'), '')
        .split('|')
        .where((cell) => cell.trim().isNotEmpty)
        .length;
    return cells;
  }

  String _normalizeMarkdownForDisplay(String value) {
    final normalizedLines = value
        .split('\n')
        .map((line) {
          var cleaned = line.trimRight();

          cleaned = cleaned.replaceFirstMapped(
            RegExp(r'^\s*[-*]\s+\*\*(.+)\*\*\s*$'),
            (match) => '**${match.group(1)?.trim()}**',
          );
          cleaned = cleaned.replaceFirstMapped(
            RegExp(r'^\s*\*\s+(.+):\*\*\s*$'),
            (match) => '**${match.group(1)?.trim()}:**',
          );
          cleaned = cleaned.replaceFirstMapped(
            RegExp(r'^\s*\*\s+(.+)\*\*\s*$'),
            (match) => '**${match.group(1)?.trim()}**',
          );

          if (cleaned.trim() == '*') return '';
          return cleaned;
        })
        .join('\n');

    return normalizedLines
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }
}
