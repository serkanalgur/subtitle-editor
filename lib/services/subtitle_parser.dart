import '../models/subtitle_item.dart';

class SrtParser {
  /// Parses an SRT string into a list of SubtitleItems.
  static List<SubtitleItem> parse(String content) {
    final List<SubtitleItem> items = [];
    if (content.isEmpty) return items;

    // Normalize line endings to \n and split by empty lines (blocks)
    final normalizedContent = content.replaceAll('\r\n', '\n');
    final blocks = normalizedContent.trim().split(RegExp(r'\n\s*\n'));

    for (var block in blocks) {
      final lines = block.trim().split('\n');
      if (lines.length < 3) continue;

      // Line 0: Index (ignored)
      // Line 1: Timestamps
      // Line 2+: Subtitle Text

      final timeMatch = RegExp(
        r'(\d{2}:\d{2}:\d{2},\d{3}) --> (\d{2}:\d{2}:\d{2},\d{3})',
      ).firstMatch(lines[1]);

      if (timeMatch != null) {
        final startStr = timeMatch.group(1)!;
        final endStr = timeMatch.group(2)!;
        final text = lines.sublist(2).join('\n').trim();

        items.add(
          SubtitleItem(
            start: _parseDuration(startStr),
            end: _parseDuration(endStr),
            text: text,
          ),
        );
      }
    }

    return items;
  }

  /// Converts a list of SubtitleItems back to an SRT string.
  static String toSrtString(List<SubtitleItem> items) {
    final buffer = StringBuffer();
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      buffer.writeln('${i + 1}');
      buffer.writeln(
        '${_formatDuration(item.start)} --> ${_formatDuration(item.end)}',
      );
      buffer.writeln(item.text);
      buffer.writeln(); // Empty line between blocks
    }
    return buffer.toString().trim();
  }

  /// Formats a Duration into SRT time format (00:00:00,000).
  static String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String threeDigits(int n) => n.toString().padLeft(3, "0");
    final hours = twoDigits(d.inHours);
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    final milliseconds = threeDigits(d.inMilliseconds.remainder(1000));
    return "$hours:$minutes:$seconds,$milliseconds";
  }

  /// Parses a time string (00:00:00,000) into a Duration.
  static Duration _parseDuration(String time) {
    final parts = time.split(':');
    final secondsParts = parts[2].split(',');

    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);
    final seconds = int.parse(secondsParts[0]);
    final milliseconds = int.parse(secondsParts[1]);

    return Duration(
      hours: hours,
      minutes: minutes,
      seconds: seconds,
      milliseconds: milliseconds,
    );
  }
}
