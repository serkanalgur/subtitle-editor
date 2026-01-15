import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/subtitle_item.dart';

/// Provider for the list of subtitles with operations.
final subtitleListProvider =
    NotifierProvider<SubtitleListNotifier, List<SubtitleItem>>(
      SubtitleListNotifier.new,
    );

/// Provider for the name of the currently loaded video.
final videoNameProvider = NotifierProvider<VideoNameNotifier, String?>(
  VideoNameNotifier.new,
);

class VideoNameNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String? name) {
    state = name;
  }
}

class SubtitleListNotifier extends Notifier<List<SubtitleItem>> {
  @override
  List<SubtitleItem> build() => [];

  void setSubtitles(List<SubtitleItem> items) {
    state = items;
  }

  void addSubtitle(Duration start, Duration end, String text) {
    final newList = [
      ...state,
      SubtitleItem(start: start, end: end, text: text),
    ];
    // Keep list sorted by start time
    newList.sort((a, b) => a.start.compareTo(b.start));
    state = newList;
  }

  void deleteSubtitle(int index) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i != index) state[i],
    ];
  }

  void shiftSubtitles(Duration offset) {
    state = [
      for (final item in state)
        SubtitleItem(
          start: item.start + offset < Duration.zero
              ? Duration.zero
              : item.start + offset,
          end: item.end + offset < Duration.zero
              ? Duration.zero
              : item.end + offset,
          text: item.text,
        ),
    ];
  }

  void updateText(int index, String newText) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index)
          SubtitleItem(start: state[i].start, end: state[i].end, text: newText)
        else
          state[i],
    ];
  }

  void updateStartTime(int index, Duration newStart) {
    final newList = [
      for (int i = 0; i < state.length; i++)
        if (i == index)
          SubtitleItem(start: newStart, end: state[i].end, text: state[i].text)
        else
          state[i],
    ];
    newList.sort((a, b) => a.start.compareTo(b.start));
    state = newList;
  }

  void updateEndTime(int index, Duration newEnd) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index)
          SubtitleItem(start: state[i].start, end: newEnd, text: state[i].text)
        else
          state[i],
    ];
  }
}

/// Provider for the current video position.
final videoPositionProvider = NotifierProvider<VideoPositionNotifier, Duration>(
  VideoPositionNotifier.new,
);

class VideoPositionNotifier extends Notifier<Duration> {
  @override
  Duration build() => Duration.zero;

  void update(Duration position) {
    state = position;
  }
}

/// Provider for the index of the currently active subtitle.
final currentSubtitleIndexProvider = Provider<int>((ref) {
  final position = ref.watch(videoPositionProvider);
  final subtitles = ref.watch(subtitleListProvider);

  for (int i = 0; i < subtitles.length; i++) {
    if (position >= subtitles[i].start && position <= subtitles[i].end) {
      return i;
    }
  }
  return -1;
});

/// Provider to check if a specific subtitle is active.
final isActiveSubtitleProvider = Provider.family<bool, int>((ref, index) {
  final activeIndex = ref.watch(currentSubtitleIndexProvider);
  return activeIndex == index;
});
