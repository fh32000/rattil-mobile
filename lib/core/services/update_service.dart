import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../../data/models/app_version.dart';

class UpdateService {
  Future<AppVersion?> fetchLatestVersion() async {
    try {
      final response = await http.get(Uri.parse(AppConstants.versionCheckUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return AppVersion.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error fetching versions: $e');
      return null;
    }
  }
}
