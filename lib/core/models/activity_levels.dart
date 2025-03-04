import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'level_model.dart';

class ActivityLevels extends ChangeNotifier {
  final List<LevelModel> levels;
  final int activityId;
  int _totalPoints = 0;
  final Map<int, bool> _completedLevels = {};
  static const int pointsPerLevel = 5;

  ActivityLevels({
    required this.activityId,
    required this.levels,
  }) {
    _initializeLevels();
  }

  void _initializeLevels() {
    if (levels.isNotEmpty) {
      if (activityId == 4 || activityId == 5) {
        // Para actividades 4 y 5, desbloquear todos los niveles
        for (var level in levels) {
          level.status = LevelStatus.unlocked;
        }
      } else {
        // Para otras actividades, solo desbloquear el primer nivel
        levels[0].status = LevelStatus.unlocked;
      }
    }
  }

  bool canAccessLevel(int levelId) {
    if (levelId <= 0) return true;
    return levels[levelId - 1].isCompleted;
  }

  bool isLevelCompleted(int levelId) {
    return _completedLevels[levelId] ?? false;
  }

  void completeLevel(int levelId) {
    if (levelId >= 0 && levelId < levels.length) {
      if (!isLevelCompleted(levelId)) {
        _completedLevels[levelId] = true;
        _totalPoints += pointsPerLevel;
        levels[levelId].completeLevel();
        
        // Desbloquear el siguiente nivel si existe y no es actividad 4 o 5
        if (levelId + 1 < levels.length && activityId != 4 && activityId != 5) {
          levels[levelId + 1].unlockLevel();
        }
        
        notifyListeners();
      }
    }
  }

  int get totalPoints => _totalPoints;

  void resetActivity() {
    _totalPoints = 0;
    _completedLevels.clear();
    
    // Restablecer todos los niveles
    for (var level in levels) {
      if (activityId == 4 || activityId == 5) {
        // Para actividades 4 y 5, desbloquear todos los niveles
        level.status = LevelStatus.unlocked;
      } else {
        level.status = LevelStatus.locked;
      }
    }
    
    // Desbloquear el primer nivel si no es actividad 4 o 5
    if (levels.isNotEmpty && activityId != 4 && activityId != 5) {
      levels[0].status = LevelStatus.unlocked;
    }
    
    notifyListeners();
  }

  LevelModel? getLevel(int levelId) {
    if (levelId >= 0 && levelId < levels.length) {
      return levels[levelId];
    }
    return null;
  }

  List<LevelModel> get availableLevels => List.unmodifiable(levels);
  
  static ActivityLevels? of(BuildContext context, {bool listen = true, required int targetActivityId}) {
    try {
      final provider = Provider.of<ActivityLevels>(context, listen: listen);
      return provider.activityId == targetActivityId ? provider : null;
    } catch (e) {
      return null;
    }
  }
}