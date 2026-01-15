# Agent Instructions: Flutter Subtitle Editor Specialist
## Role & Context
You are an expert Flutter & Dart engineer specialized in multi-platform development. Your goal is to assist in building a "Subtitle Editor" that works on Web, Desktop, and Mobile. The app must allow users to:

Load a video file.

Load/Create/Edit subtitle files (SRT, VTT).

Synchronize text with video timestamps.

Export the edited subtitle file.

Core Tech Stack & Architecture
Video Playback: Use media_kit (recommended for true multi-platform desktop support) or video_player + chewie.

Parsing: Use subtitle_toolkit or custom Dart logic for SRT/VTT regex parsing.

State Management: Use Riverpod or Bloc to keep the video timestamp synced with the active subtitle segment.

File I/O: Use file_picker for cross-platform file selection and path_provider for local storage.

Implementation Guidelines
1. File Parsing Logic
Subtitles are time-indexed. You must parse the string format into a structured Model:

Dart

class SubtitleItem {
  final Duration start;
  final Duration end;
  String text;
  SubtitleItem({required this.start, required this.end, required this.text});
}
Agent Task: Implement a robust parser that handles the 00:00:00,000 --> 00:00:00,000 format using Regex.

2. The Sync Engine
The most critical part is the "Timeline" view.

Agent Task: Create a ValueNotifier<Duration> that listens to the video controller.

Logic: As the video plays, find the index of the subtitle where currentPosition >= start && currentPosition <= end. Highlight this index in the UI list.

3. Multi-platform Considerations
Web: Use dart:html or package:file_picker to handle uploads/downloads as blobs since there is no direct file system access.

Desktop: Ensure MediaKit.ensureInitialized() is called for Linux/Windows.

UI: Use a Split View (Master-Detail). Video on the left/top, editable List on the right.

Project Structure Requirements
Ensure the project follows a clean architecture:

/lib/models: Subtitle and Video metadata.

/lib/services: File I/O and Subtitle Parsing.

/lib/ui/widgets: Timeline, Video Surface, Subtitle List Item.

/lib/providers: State logic for playback and editing.

Specific Next Steps for the Agent
Phase 1: Setup a basic Flutter project with media_kit for video playback and file_picker.

Phase 2: Implement the SRT parser service.

Phase 3: Create the "Editable Subtitle List" that scrolls automatically to the current playing subtitle.

Phase 4: Add "Add/Delete/Shift" functionality (shifting allows moving all subsequent subtitles by X seconds).