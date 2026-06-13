import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';

class HiveService {
  static late Box<int> _playbackBox;
  static late Box<List<String>> _favoritesBox;
  static late Box<String> _playlistsBox;
  static late Box<dynamic> _settingsBox;

  static Future<void> init() async {
    await Hive.initFlutter();

    final results = await Future.wait([
      Hive.openBox<int>(AppConstants.playbackBox),
      Hive.openBox<List<String>>(AppConstants.favoritesBox),
      Hive.openBox<String>(AppConstants.playlistsBox),
      Hive.openBox<dynamic>(AppConstants.settingsBox),
    ]);

    _playbackBox = results[0] as Box<int>;
    _favoritesBox = results[1] as Box<List<String>>;
    _playlistsBox = results[2] as Box<String>;
    _settingsBox = results[3];
  }

  static Box<int> get playbackBox => _playbackBox;
  static Box<List<String>> get favoritesBox => _favoritesBox;
  static Box<String> get playlistsBox => _playlistsBox;
  static Box<dynamic> get settingsBox => _settingsBox;
}
