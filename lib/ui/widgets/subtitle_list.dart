import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../../providers/subtitle_provider.dart';
import 'subtitle_list_item.dart';

class SubtitleList extends ConsumerStatefulWidget {
  const SubtitleList({super.key});

  @override
  ConsumerState<SubtitleList> createState() => _SubtitleListState();
}

class _SubtitleListState extends ConsumerState<SubtitleList> {
  final ItemScrollController _itemScrollController = ItemScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final subtitles = ref.watch(subtitleListProvider);

    // Listen for changes in the active index to trigger scrolling
    ref.listen<int>(currentSubtitleIndexProvider, (previous, next) {
      if (next != -1 && next != previous && _itemScrollController.isAttached) {
        _itemScrollController.scrollTo(
          index: next,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
        );
      }
    });

    if (subtitles.isEmpty) {
      return const Center(
        child: Text(
          'No subtitles loaded. Use the folder icon to load an SRT file.',
        ),
      );
    }

    return ScrollablePositionedList.builder(
      itemCount: subtitles.length,
      itemScrollController: _itemScrollController,
      itemBuilder: (context, index) {
        return SubtitleListItem(index: index, item: subtitles[index]);
      },
    );
  }
}
