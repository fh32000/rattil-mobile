# 11 Development Guide

## Prerequisites

- Flutter SDK 3.8+ (Dart 3.8+)
- Android Studio / VS Code with Flutter plugins
- Xcode (for iOS builds, macOS only)

## Setup

```bash
# Clone
git clone https://github.com/bootfi/rattil-mobile.git
cd rattil-mobile

# Install dependencies
flutter pub get

# Run (choose device)
flutter run
```

## Build Commands

### Android APK

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (Play Store)

```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS

```bash
flutter build ios --release
# Then archive via Xcode
```

### Web

```bash
flutter build web --release
# Output: build/web/
```

## Running in Debug Mode

```bash
flutter run
# Or with specific device:
flutter run -d emulator-5554
flutter run -d chrome  # Web
```

Profile mode (for performance testing):

```bash
flutter run --profile
```

## Debugging Tools

| Tool | Command/Usage |
| :--- | :--- |
| Flutter DevTools | `dart devtools` (integrated in IDE) |
| Riverpod inspector | DevTools → "Provider" tab |
| Network logging | DevTools → "Network" tab (check update service calls) |
| Audio debugging | `print()` statements in `audio_handler.dart` (commented out except for errors) |

## Code Analysis

```bash
# Lint
flutter analyze

# Format
dart format lib/
```

## Testing

```bash
# Run all tests
flutter test

# Run specific test
flutter test test/widget_test.dart
```

## Project Patterns to Follow

### Adding a New Screen

1. Create feature folder: `lib/features/<feature_name>/`
2. Create `screens/<feature_name>_screen.dart`
3. Create `widgets/` subfolder if needed
4. Add route in `lib/core/router/app_router.dart`
5. If it needs audio state, watch `audioHandlerProvider` + related providers

### Adding a New Provider

- Use `Provider` for simple DI (services, repositories)
- Use `StreamProvider` for reactive streams (audio state)
- Use `StateNotifierProvider` for mutable state (favorites, playlists)
- Define in the feature's `providers/` folder

### Working with Hive

```dart
// Read
HiveService.favoritesBox.get('key') ?? [];

// Write
HiveService.favoritesBox.put('key', value);

// Key note: No need to run build_runner — Hive types are NOT used
// (data is stored as primitive types or JSON strings)
```

## Common Issues

### Audio Not Playing

1. Check asset path in `pubspec.yaml` is correctly declared
2. Verify MP3 file exists at the exact path
3. Check Android manifest for audio focus permissions

### Missing Fonts

Google Fonts requires internet on first launch. If offline:
- The app falls back to system fonts
- To bundle: pre-download and add to `assets/fonts/`

### Hive Errors

```bash
# If adding HiveType adapters in the future:
flutter pub run build_runner build
```

Currently, Hive stores primitives (int, List<String>, String) — no TypeAdapters needed.

### Android Manifest Permissions

Check `android/app/src/main/AndroidManifest.xml` for:
```xml
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
```

### iOS Info.plist

Check `ios/Runner/Info.plist` for:
```xml
<key>UIBackgroundModes</key>
<array>
  <string>audio</string>
</array>
```

## Architecture Reminders

- **Never** put business logic in widgets — use Services/Repositories
- **Always** use `ConsumerWidget` or `ConsumerStatefulWidget` for Riverpod
- **Keep** feature folders self-contained — minimize cross-feature imports
- **One** `AudioPlayer` instance for the entire app (singleton)
- **Static data** for surahs/letters — no API calls for core content
