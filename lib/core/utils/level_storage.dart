import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/level_model.dart';

class LevelStorage {
  static const String _keyPrefix = 'activity_levels_';
  
  static Future<void> saveLevels(int activityId, List<LevelModel> levels) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_keyPrefix$activityId';
      final levelsJson = levels.map((level) => level.toJson()).toList();
      await prefs.setString(key, jsonEncode(levelsJson));
    } catch (e) {
      print('Error saving levels: $e');
      rethrow;
    }
  }

  static Future<List<LevelModel>> loadLevels(int activityId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_keyPrefix$activityId';
      final levelsString = prefs.getString(key);
      
      if (levelsString != null) {
        final levelsJson = jsonDecode(levelsString) as List;
        return levelsJson
            .map((json) => LevelModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      
      return [];
    } catch (e) {
      print('Error loading levels: $e');
      return [];
    }
  }

  static Future<void> resetProgress(int activityId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_keyPrefix$activityId';
      await prefs.remove(key);
    } catch (e) {
      print('Error resetting progress: $e');
      rethrow;
    }
  }

  static Future<void> resetAllProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith(_keyPrefix));
      for (final key in keys) {
        await prefs.remove(key);
      }
    } catch (e) {
      print('Error resetting all progress: $e');
      rethrow;
    }
  }
}