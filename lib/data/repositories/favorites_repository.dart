import '../hive/hive_service.dart';

/// Repository for managing favorite tracks
class FavoritesRepository {
  static const String _key = 'favorite_tracks';

  List<String> _getFavorites() {
    return HiveService.favoritesBox.get(_key) ?? [];
  }

  void _saveFavorites(List<String> favorites) {
    HiveService.favoritesBox.put(_key, favorites);
  }

  /// Add a track to favorites
  void addFavorite(String trackId) {
    final favorites = _getFavorites();
    if (!favorites.contains(trackId)) {
      favorites.add(trackId);
      _saveFavorites(favorites);
    }
  }

  /// Remove a track from favorites
  void removeFavorite(String trackId) {
    final favorites = _getFavorites();
    favorites.remove(trackId);
    _saveFavorites(favorites);
  }

  /// Toggle favorite status
  bool toggleFavorite(String trackId) {
    if (isFavorite(trackId)) {
      removeFavorite(trackId);
      return false;
    } else {
      addFavorite(trackId);
      return true;
    }
  }

  /// Check if a track is in favorites
  bool isFavorite(String trackId) {
    return _getFavorites().contains(trackId);
  }

  /// Get all favorite track IDs
  List<String> getAllFavorites() {
    return _getFavorites();
  }
}
