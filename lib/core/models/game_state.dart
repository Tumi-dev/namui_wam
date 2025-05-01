import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:namuiwam/core/models/activities_state.dart';
import 'package:namuiwam/core/utils/level_storage.dart';

class GameState extends ChangeNotifier {
  static const String _alertShownKey = 'alert_shown_at_100_points';

  static const String _pointsKey = 'global_points';
  static const String _completedLevelsKey = 'completed_levels';
  static const int maxPoints = 100;
  int _globalPoints = 0;
  final Map<String, bool> _completedLevels = {};
  final ActivitiesState _activitiesState;

  GameState(this._activitiesState) {
    _loadState();
    _loadAlertFlag();
  }

  bool _alertShownAt100Points = false;
  bool get alertShownAt100Points => _alertShownAt100Points;

  Future<void> _loadAlertFlag() async {
    final prefs = await SharedPreferences.getInstance();
    _alertShownAt100Points = prefs.getBool(_alertShownKey) ?? false;
  }

  Future<void> setAlertShownAt100Points(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    _alertShownAt100Points = value;
    await prefs.setBool(_alertShownKey, value);
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

  Future<void> _triggerGlobalReset() async {
    await setAlertShownAt100Points(false); // Resetear el flag al reiniciar manualmente
    try {
      print('Starting global reset process...');
      for (int actId in [1, 2, 3, 4]) {
        final activity = _activitiesState.getActivity(actId);
        if (activity != null) {
          print('Resetting Activity $actId...');
          activity.resetActivity();
          await LevelStorage.saveLevels(actId, activity.levels);
          print('Activity $actId reset and saved to storage.');
        } else {
          print('Warning: Activity $actId not found in ActivitiesState during reset.');
        }
      }

      _globalPoints = 0;

      print('Clearing completed levels for activities 1-4...');
      _completedLevels.removeWhere((key, value) {
        final parts = key.split('-');
        if (parts.length == 2) {
          final actId = int.tryParse(parts[0]);
          return actId != null && actId >= 1 && actId <= 4;
        }
        return false;
      });
      print('Completed levels cleared.');

      await _saveState();
      print('Reset GameState saved.');

      notifyListeners();
      print('Global reset triggered and completed successfully. Points reset to 0.');
    await _loadAlertFlag(); // Refresca el flag tras reinicio
    } catch (e, s) {
      print('Error during global reset: $e \nStack trace:\n$s');
      notifyListeners();
    }
  }

  bool get canManuallyReset => _globalPoints >= maxPoints;

  Future<void> requestManualReset() async {
    if (canManuallyReset) { 
      print('Manual reset requested and condition met.');
      await _triggerGlobalReset(); 
    } else {
      print('Manual reset requested but condition not met ($_globalPoints points).');
    }
  }

  int get globalPoints => _globalPoints;
  int get remainingPoints => maxPoints - _globalPoints;

  Future<void> resetGame() async {
    print('WARNING: resetGame() called directly. This only resets GameState, not ActivityLevels.');
    _globalPoints = 0;
    _completedLevels.clear();
    await _saveState();
    notifyListeners();
  }

  static GameState of(BuildContext context) {
    return Provider.of<GameState>(context, listen: false);
  }
}
