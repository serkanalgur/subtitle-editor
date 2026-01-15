import 'dart:async';
import 'dart:convert';
import 'dart:io' show File;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_saver/file_saver.dart';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../../providers/subtitle_provider.dart';
import '../../services/subtitle_parser.dart';
import '../widgets/subtitle_list.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final Player player = Player();
  late final VideoController controller = VideoController(player);
  StreamSubscription<Duration>? _positionSubscription;

  @override
  void initState() {
    super.initState();
    // Listen to player position and update provider
    _positionSubscription = player.stream.position.listen((position) {
      ref.read(videoPositionProvider.notifier).update(position);
    });
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    player.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );

    if (result != null && result.files.single.path != null) {
      ref.read(videoNameProvider.notifier).set(result.files.single.name);
      player.open(Media(result.files.single.path!));
    }
  }

  Future<void> _pickSubtitles() async {
    final messenger = ScaffoldMessenger.of(context);
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['srt'],
      withData: true, // Required for Web to get bytes
    );

    if (result != null) {
      String content;
      if (kIsWeb) {
        final bytes = result.files.single.bytes!;
        content = utf8.decode(bytes);
      } else {
        final path = result.files.single.path!;
        final file = File(path);
        content = await file.readAsString();
      }

      final items = SrtParser.parse(content);
      ref.read(subtitleListProvider.notifier).setSubtitles(items);

      messenger.showSnackBar(
        SnackBar(content: Text('Loaded ${items.length} subtitles')),
      );
    }
  }

  Future<void> _exportSubtitles() async {
    final messenger = ScaffoldMessenger.of(context);
    final subtitles = ref.read(subtitleListProvider);
    if (subtitles.isEmpty) return;

    final srtContent = SrtParser.toSrtString(subtitles);
    final Uint8List bytes = Uint8List.fromList(utf8.encode(srtContent));

    try {
      final String? videoName = ref.read(videoNameProvider);
      String fileName = 'edited_subtitles.srt';
      if (videoName != null) {
        final lastDot = videoName.lastIndexOf('.');
        if (lastDot != -1) {
          fileName = '${videoName.substring(0, lastDot)}.srt';
        } else {
          fileName = '$videoName.srt';
        }
      }

      // file_saver works on Web, Mobile and Desktop.
      await FileSaver.instance.saveFile(
        name: fileName,
        bytes: bytes,
        fileExtension: 'srt',
        mimeType: MimeType.text,
      );

      messenger.showSnackBar(
        const SnackBar(content: Text('Subtitles exported successfully')),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }

  void _addSubtitle() {
    final currentPos = player.state.position;
    ref
        .read(subtitleListProvider.notifier)
        .addSubtitle(
          currentPos,
          currentPos + const Duration(seconds: 2),
          'New Subtitle',
        );
  }

  void _shiftSubtitles() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Shift All Subtitles'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Offset in milliseconds (e.g., 500 or -1000)',
            ),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final offsetMs = int.tryParse(controller.text);
                if (offsetMs != null) {
                  ref
                      .read(subtitleListProvider.notifier)
                      .shiftSubtitles(Duration(milliseconds: offsetMs));
                }
                Navigator.pop(context);
              },
              child: const Text('Shift'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subtitle Editor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.video_file),
            onPressed: _pickVideo,
            tooltip: 'Load Video',
          ),
          IconButton(
            icon: const Icon(Icons.subtitles),
            onPressed: _pickSubtitles,
            tooltip: 'Load SRT Subtitles',
          ),
          IconButton(
            icon: const Icon(Icons.add_comment),
            onPressed: _addSubtitle,
            tooltip: 'Add Subtitle at Current Time',
          ),
          IconButton(
            icon: const Icon(Icons.timer),
            onPressed: _shiftSubtitles,
            tooltip: 'Shift All Subtitles',
          ),
          IconButton(
            icon: const Icon(Icons.save_alt),
            onPressed: _exportSubtitles,
            tooltip: 'Export SRT',
          ),
        ],
      ),
      body: Row(
        children: [
          // Left side: Video Player
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.black,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Video(controller: controller),
                  // Simple overlay for the active subtitle text
                  Positioned(
                    bottom: 40,
                    child: Consumer(
                      builder: (context, ref, child) {
                        final index = ref.watch(currentSubtitleIndexProvider);
                        final subtitles = ref.watch(subtitleListProvider);
                        if (index != -1 && index < subtitles.length) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              subtitles[index].text,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Right side: Editable List
          const VerticalDivider(width: 1),
          Expanded(
            flex: 2,
            child: Container(
              color: Theme.of(context).colorScheme.surface,
              child: const SubtitleList(),
            ),
          ),
        ],
      ),
    );
  }
}
