import '../hive/hive_service.dart';

/// Repository for saving/restoring playback position per track
class PlaybackRepository {
  /// Save playback position in milliseconds for a track
  void savePosition(String trackId, int positionMs) {
    HiveService.playbackBox.put(trackId, positionMs);
  }

  /// Get saved playback position in milliseconds, or null if none
  int? getPosition(String trackId) {
    return HiveService.playbackBox.get(trackId);
  }

  /// Clear saved position for a track
  void clearPosition(String trackId) {
    HiveService.playbackBox.delete(trackId);
  }

  /// Clear all saved positions
  void clearAll() {
    HiveService.playbackBox.clear();
  }
}
