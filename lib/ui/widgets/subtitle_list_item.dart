import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/subtitle_item.dart';
import '../../providers/subtitle_provider.dart';

class SubtitleListItem extends ConsumerStatefulWidget {
  final int index;
  final SubtitleItem item;

  const SubtitleListItem({super.key, required this.index, required this.item});

  @override
  ConsumerState<SubtitleListItem> createState() => _SubtitleListItemState();
}

class _SubtitleListItemState extends ConsumerState<SubtitleListItem> {
  late final TextEditingController _textController;
  late final TextEditingController _startController;
  late final TextEditingController _endController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.item.text);
    _startController = TextEditingController(
      text: _formatDuration(widget.item.start),
    );
    _endController = TextEditingController(
      text: _formatDuration(widget.item.end),
    );
  }

  @override
  void didUpdateWidget(SubtitleListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync controllers if items changed from external source (e.g. shift or sort)
    // but avoid updating if they are already what the controller shows to preserve cursor
    if (widget.item.text != _textController.text) {
      _textController.text = widget.item.text;
    }
    final formattedStart = _formatDuration(widget.item.start);
    if (formattedStart != _startController.text) {
      _startController.text = formattedStart;
    }
    final formattedEnd = _formatDuration(widget.item.end);
    if (formattedEnd != _endController.text) {
      _endController.text = formattedEnd;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  Duration? _parseDuration(String s) {
    try {
      final parts = s.split(RegExp('[:|,]'));
      if (parts.length != 4) return null;
      return Duration(
        hours: int.parse(parts[0]),
        minutes: int.parse(parts[1]),
        seconds: int.parse(parts[2]),
        milliseconds: int.parse(parts[3]),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isActive = ref.watch(isActiveSubtitleProvider(widget.index));

    return Container(
      color: isActive ? Colors.deepPurple.withValues(alpha: 0.3) : null,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 90,
                child: TextField(
                  controller: _startController,
                  style: TextStyle(
                    fontSize: 12,
                    color: isActive ? Colors.deepPurpleAccent : Colors.grey,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                  ),
                  onSubmitted: (val) {
                    final d = _parseDuration(val);
                    if (d != null) {
                      ref
                          .read(subtitleListProvider.notifier)
                          .updateStartTime(widget.index, d);
                    }
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  '-->',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ),
              SizedBox(
                width: 90,
                child: TextField(
                  controller: _endController,
                  style: TextStyle(
                    fontSize: 12,
                    color: isActive ? Colors.deepPurpleAccent : Colors.grey,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                  ),
                  onSubmitted: (val) {
                    final d = _parseDuration(val);
                    if (d != null) {
                      ref
                          .read(subtitleListProvider.notifier)
                          .updateEndTime(widget.index, d);
                    }
                  },
                ),
              ),
              const Spacer(),
              Text(
                '#${widget.index + 1}',
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 4),
          TextField(
            controller: _textController,
            maxLines: null,
            textDirection: TextDirection.ltr,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              suffixIcon: IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: Colors.redAccent,
                ),
                onPressed: () => ref
                    .read(subtitleListProvider.notifier)
                    .deleteSubtitle(widget.index),
                tooltip: 'Delete Subtitle',
              ),
            ),
            onChanged: (newText) {
              ref
                  .read(subtitleListProvider.notifier)
                  .updateText(widget.index, newText);
            },
          ),
          const Divider(),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String threeDigits(int n) => n.toString().padLeft(3, "0");
    final hours = twoDigits(d.inHours);
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    final milliseconds = threeDigits(d.inMilliseconds.remainder(1000));
    return "$hours:$minutes:$seconds,$milliseconds";
  }
}
