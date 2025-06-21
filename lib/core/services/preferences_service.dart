import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static const String _activityVisitedKeyPrefix = 'activity_visited_';

  bool isActivityVisited(int activityId) {
    final key = '$_activityVisitedKeyPrefix$activityId';
    return _prefs.getBool(key) ?? false;
  }

  Future<void> markActivityAsVisited(int activityId) async {
    final key = '$_activityVisitedKeyPrefix$activityId';
    await _prefs.setBool(key, true);
  }
} 