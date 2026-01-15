# Subtitle Editor 🎬✨

A powerful, cross-platform Flutter application for creating, editing, and synchronizing subtitles (SRT) with video playback. High performance, real-time sync, and a premium user experience.

## Features 🚀

- **🎥 Multi-format Video Playback**: Support for various video formats via `media_kit`.
- **✍️ Real-time Editing**: Edit subtitle text and timing in place with an intuitive timeline.
- **⏱️ Synchronized Timeline**: Automatic scrolling and highlighting of the active subtitle segment.
- **🛠️ Advanced Operations**:
  - **Add Subtitles**: Insert new segments at the current video position.
  - **Delete Subtitles**: Remove unwanted lines instantly.
  - **Time Shifting**: Shift all subtitles by a specific offset (milliseconds) to fix audio sync.
- **📂 Cross-platform Export**: Save your work back to `.srt` format on Web, Desktop, and Mobile.
- **✨ Dynamic Naming**: Automatically suggests export filenames based on the loaded video.
- **🌍 RTL Support**: Clean input behavior for both LTR and RTL subtitle content.

## Getting Started 🏁

### Prerequisites

- Flutter SDK (^3.10.7)
- Dart SDK

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/subtitle_editor.git
   cd subtitle_editor
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the application:
   ```bash
   # For Desktop
   flutter run -d windows
   
   # For Web
   flutter run -d chrome
   ```

## Usage 📖

1. **Load Video**: Click the 🎬 icon in the toolbar to select your video file.
2. **Load Subtitles**: Click the 📂 icon to import an existing `.srt` file.
3. **Edit**: 
   - Change text directly in the list.
   - Adjust timings using the `HH:MM:SS,mmm` fields.
4. **Add/Sync**: Navigate to a specific video position and click ➕ to add a new subtitle.
5. **Export**: Click the 💾 icon to save your edited file.

## Architecture 🏗️

The project follows a Clean Architecture approach:
- `/lib/models`: Data structures (`SubtitleItem`).
- `/lib/services`: Business logic and parsers (`SrtParser`).
- `/lib/providers`: State management using Riverpod.
- `/lib/ui`: Functional and responsive UI components.

## License 📄

This project is licensed under the **WTFPL** - see the [LICENSE](LICENSE) file for details.

---
Built with ❤️ using Flutter and MediaKit.
