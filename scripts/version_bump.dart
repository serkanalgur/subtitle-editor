// ignore_for_file: avoid_print
import 'dart:io';

void main(List<String> args) {
  if (args.isEmpty || !['major', 'minor', 'patch'].contains(args[0])) {
    print('Usage: dart scripts/version_bump.dart <major|minor|patch>');
    exit(1);
  }

  final type = args[0];
  final file = File('pubspec.yaml');
  if (!file.existsSync()) {
    print('Error: pubspec.yaml not found');
    exit(1);
  }

  final lines = file.readAsLinesSync();
  String? currentVersion;
  int? versionLineIndex;

  for (var i = 0; i < lines.length; i++) {
    if (lines[i].startsWith('version: ')) {
      currentVersion = lines[i].replaceFirst('version: ', '').trim();
      versionLineIndex = i;
      break;
    }
  }

  if (currentVersion == null || versionLineIndex == null) {
    print('Error: Version not found in pubspec.yaml');
    exit(1);
  }

  // Handle version+build format (e.g., 1.0.0+1)
  final parts = currentVersion.split('+');
  final semver = parts[0].split('.');
  int major = int.parse(semver[0]);
  int minor = int.parse(semver[1]);
  int patch = int.parse(semver[2]);
  int build = parts.length > 1 ? int.parse(parts[1]) : 0;

  if (type == 'major') {
    major++;
    minor = 0;
    patch = 0;
  } else if (type == 'minor') {
    minor++;
    patch = 0;
  } else if (type == 'patch') {
    patch++;
  }

  build++;

  final newVersion = '$major.$minor.$patch+$build';
  lines[versionLineIndex] = 'version: $newVersion';

  file.writeAsStringSync('${lines.join('\n')}\n');

  print('✅ Version bumped from $currentVersion to $newVersion');
  print('Next steps:');
  print('1. git add pubspec.yaml');
  print('2. git commit -m "Bump version to $newVersion"');
  print('3. git tag v$major.$minor.$patch');
  print('4. git push origin main --tags');
}
