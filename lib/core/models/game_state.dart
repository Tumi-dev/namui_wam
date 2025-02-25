import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameState extends ChangeNotifier {
  static const String _pointsKey = 'global_points';
  static const String _completedLevelsKey = 'completed_levels';
  static const int maxPoints = 100;
  int _globalPoints = 0;
  final Map<String, bool> _completedLevels = {};

  GameState() {
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    _globalPoints = prefs.getInt(_pointsKey) ?? 0;
    final completedLevels = prefs.getStringList(_completedLevelsKey) ?? [];
    for (var levelKey in completedLevels) {
      _completedLevels[levelKey] = true;
    }
    notifyListeners();
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_pointsKey, _globalPoints);
    await prefs.setStringList(
      _completedLevelsKey,
      _completedLevels.keys.toList(),
    );
  }

  bool isLevelCompleted(int activityId, int levelId) {
    final levelKey = '$activityId-$levelId';
    return _completedLevels[levelKey] ?? false;
  }

  Future<bool> addPoints(int activityId, int levelId, int points) async {
    final levelKey = '$activityId-$levelId';
    if (!_completedLevels.containsKey(levelKey)) {
      _completedLevels[levelKey] = true;
      _globalPoints += points;
      await _saveState();
      notifyListeners();
      return true;
    }
    return false;
  }

  int get globalPoints => _globalPoints;
  int get remainingPoints => maxPoints - _globalPoints;

  Future<void> resetGame() async {
    _globalPoints = 0;
    _completedLevels.clear();
    await _saveState();
    notifyListeners();
  }

  static GameState of(BuildContext context) {
    return Provider.of<GameState>(context, listen: false);
  }
}
