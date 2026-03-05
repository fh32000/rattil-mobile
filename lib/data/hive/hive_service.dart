import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';

class HiveService {
  static late Box<int> _playbackBox;
  static late Box<List<String>> _favoritesBox;
  static late Box<String> _playlistsBox;
  static late Box<dynamic> _settingsBox;

  static Future<void> init() async {
    await Hive.initFlutter();

    _playbackBox = await Hive.openBox<int>(AppConstants.playbackBox);
    _favoritesBox =
        await Hive.openBox<List<String>>(AppConstants.favoritesBox);
    _playlistsBox = await Hive.openBox<String>(AppConstants.playlistsBox);
    _settingsBox = await Hive.openBox<dynamic>(AppConstants.settingsBox);
  }

  static Box<int> get playbackBox => _playbackBox;
  static Box<List<String>> get favoritesBox => _favoritesBox;
  static Box<String> get playlistsBox => _playlistsBox;
  static Box<dynamic> get settingsBox => _settingsBox;
}
