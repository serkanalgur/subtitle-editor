import 'package:flutter_test/flutter_test.dart';
import 'package:subtitle_editor/services/subtitle_parser.dart';
import 'package:subtitle_editor/models/subtitle_item.dart';

void main() {
  group('SrtParser Tests', () {
    test('Parse basic SRT content', () {
      const content = '''1
00:00:01,000 --> 00:00:04,000
Hello world!

2
00:00:05,500 --> 00:00:08,200
This is a 
multi-line subtitle.
''';
      final items = SrtParser.parse(content);

      expect(items.length, 2);
      expect(items[0].text, 'Hello world!');
      expect(items[0].start, const Duration(seconds: 1));
      expect(items[0].end, const Duration(seconds: 4));

      expect(items[1].text, 'This is a \nmulti-line subtitle.');
      expect(items[1].start, const Duration(seconds: 5, milliseconds: 500));
      expect(items[1].end, const Duration(seconds: 8, milliseconds: 200));
    });

    test('Parse empty content', () {
      final items = SrtParser.parse('');
      expect(items.isEmpty, true);
    });

    test('Parse malformed content', () {
      const content = 'Invalid content';
      final items = SrtParser.parse(content);
      expect(items.isEmpty, true);
    });
    test('toSrtString conversion', () {
      final items = [
        SubtitleItem(
          start: const Duration(seconds: 1),
          end: const Duration(seconds: 4),
          text: 'Hello',
        ),
        SubtitleItem(
          start: const Duration(seconds: 5),
          end: const Duration(seconds: 8),
          text: 'World',
        ),
      ];
      final srt = SrtParser.toSrtString(items);

      expect(srt, contains('1'));
      expect(srt, contains('00:00:01,000 --> 00:00:04,000'));
      expect(srt, contains('Hello'));
      expect(srt, contains('2'));
      expect(srt, contains('00:00:05,000 --> 00:00:08,000'));
      expect(srt, contains('World'));
    });
  });
}
