class SubtitleItem {
  final Duration start;
  final Duration end;
  String text;

  SubtitleItem({required this.start, required this.end, required this.text});

  @override
  String toString() => 'SubtitleItem(start: $start, end: $end, text: $text)';
}
