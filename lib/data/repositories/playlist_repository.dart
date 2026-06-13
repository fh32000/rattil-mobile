import 'dart:convert';
import '../hive/hive_service.dart';
import '../models/playlist.dart';
import '../sources/juz_amma_data.dart';

/// Repository for CRUD operations on playlists
class PlaylistRepository {
  List<Playlist> getAllPlaylists() {
    final box = HiveService.playlistsBox;
    return box.values.map((json) {
      return Playlist.fromJson(jsonDecode(json) as Map<String, dynamic>);
    }).toList();
  }

  Playlist? getPlaylist(String id) {
    final json = HiveService.playlistsBox.get(id);
    if (json == null) return null;
    return Playlist.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  void savePlaylist(Playlist playlist) {
    HiveService.playlistsBox.put(playlist.id, jsonEncode(playlist.toJson()));
  }

  void deletePlaylist(String id) {
    HiveService.playlistsBox.delete(id);
  }

  void addTrackToPlaylist(String playlistId, String trackId) {
    final playlist = getPlaylist(playlistId);
    if (playlist != null && !playlist.trackIds.contains(trackId)) {
      final updated =
          playlist.copyWith(trackIds: [...playlist.trackIds, trackId]);
      savePlaylist(updated);
    }
  }

  void removeTrackFromPlaylist(String playlistId, String trackId) {
    final playlist = getPlaylist(playlistId);
    if (playlist != null) {
      final updated = playlist.copyWith(
        trackIds: playlist.trackIds.where((id) => id != trackId).toList(),
      );
      savePlaylist(updated);
    }
  }

  void sortTracksBySurahNumber(String playlistId) {
    final playlist = getPlaylist(playlistId);
    if (playlist == null) return;
    final allTracks = JuzAmmaData.tracks;
    final sorted = List<String>.from(playlist.trackIds);
    sorted.sort((a, b) {
      final trackA = allTracks.where((t) => t.id == a).firstOrNull;
      final trackB = allTracks.where((t) => t.id == b).firstOrNull;
      if (trackA == null || trackB == null) return 0;
      return trackA.surahNumber.compareTo(trackB.surahNumber);
    });
    savePlaylist(playlist.copyWith(trackIds: sorted));
  }

  void reorderTracks(String playlistId, int oldIndex, int newIndex) {
    final playlist = getPlaylist(playlistId);
    if (playlist != null) {
      final trackIds = List<String>.from(playlist.trackIds);
      final item = trackIds.removeAt(oldIndex);
      trackIds.insert(newIndex, item);
      savePlaylist(playlist.copyWith(trackIds: trackIds));
    }
  }
}
