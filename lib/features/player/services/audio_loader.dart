import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

abstract class AudioLoader {
  AudioLoader._();

  /// Creates an [AudioSource] from an asset path.
  ///
  /// - **Mobile** (Android/iOS): uses [AudioSource.asset] — loads from the
  ///   app bundle via platform channels.
  /// - **Web**: uses [AudioSource.asset] as well, but strips the `assets/`
  ///   prefix because Flutter web's `AssetBundle.load` prepends `assets/`
  ///   internally, causing a double prefix (e.g. `assets/assets/audio/...`).
  ///
  /// No other part of the codebase needs platform checks for audio loading.
  static AudioSource createSource(String assetPath) {
    if (kIsWeb) {
      return AudioSource.asset(assetPath.startsWith('assets/') ? assetPath.substring(7) : assetPath);
    }
    return AudioSource.asset(assetPath);
  }
}
