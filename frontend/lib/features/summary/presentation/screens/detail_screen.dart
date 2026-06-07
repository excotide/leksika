import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:leksika/core/utils/content_sanitizer.dart';
import 'package:leksika/features/summary/domain/entities/document_entity.dart';

class SummaryDetailScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
                    title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00362A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Dibuat dari $pageCount',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF2F6555),
                    ),
                  ),
                  if (document?.flashcards.isNotEmpty ?? false) ...[
                    const SizedBox(height: 16),
                    _buildFlashcardShortcut(context),
                  ],
                  const SizedBox(height: 24),
                  ...contents.map((data) => _buildContentCard(
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

  Widget _buildFlashcardShortcut(BuildContext context) {
    final totalCards = document?.flashcards.length ?? 0;

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
