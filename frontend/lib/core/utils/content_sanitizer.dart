class ContentSanitizer {
  const ContentSanitizer._();

  static String cleanGeneratedText(String value) {
    if (value.trim().isEmpty) return '';

    final lines = value
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .split('\n')
        .map(_cleanLine)
        .where((line) => line.trim().isNotEmpty)
        .toList();

    return lines
        .join('\n')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  static String cleanPreview(String value) {
    return cleanGeneratedText(value)
        .replaceAll(RegExp(r'^\s{0,3}#{1,6}\s*', multiLine: true), '')
        .replaceAll(RegExp(r'^\s*[-*+]\s+', multiLine: true), '')
        .replaceAll(RegExp(r'^\s*\d+[.)]\s+', multiLine: true), '')
        .replaceAll(RegExp(r'^\s*>\s?', multiLine: true), '')
        .replaceAll(RegExp(r'`+'), '')
        .replaceAll(RegExp(r'\*+'), '')
        .replaceAll(RegExp(r'_+'), '')
        .replaceAll(RegExp(r'\s*\n\s*'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static String _cleanLine(String value) {
    var line = value.trim();

    if (RegExp(r'^[=\-*_\s]{3,}$').hasMatch(line)) return '';

    line = line.replaceAll(RegExp(r'\s*={3,}\s*'), ' ').trim();

    line = line.replaceFirstMapped(
      RegExp(r'^\s*[-*]\s+\*\*(.+)\*\*\s*$'),
      (match) => '**${match.group(1)?.trim()}**',
    );
    line = line.replaceFirstMapped(
      RegExp(r'^\s*\*\s+(.+):\*\*\s*$'),
      (match) => '**${match.group(1)?.trim()}:**',
    );
    line = line.replaceFirstMapped(
      RegExp(r'^\s*\*\s+(.+)\*\*\s*$'),
      (match) => '**${match.group(1)?.trim()}**',
    );
    line = line.replaceFirstMapped(
      RegExp(r'^\s*\*(?!\*)(.+?)\*\s*$'),
      (match) => '**${match.group(1)?.trim()}**',
    );

    if (RegExp(r'^[=\-*_\s]{3,}$').hasMatch(line)) return '';
    return line;
  }
}
