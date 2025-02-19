import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'level_model.dart';

class ActivityLevels extends ChangeNotifier {
  final List<LevelModel> levels;
  final int activityId;

  ActivityLevels({
    required this.activityId,
    required this.levels,
  }) {
    _initializeLevels();
  }

  void _initializeLevels() {
    if (levels.isNotEmpty) {
      levels[0].status = LevelStatus.unlocked;
    }
  }

  bool canAccessLevel(int levelId) {
    if (levelId <= 0) return true;
    return levels[levelId - 1].isCompleted;
  }

  void completeLevel(int levelId) {
    if (levelId >= 0 && levelId < levels.length) {
      levels[levelId].completeLevel();
      
      if (levelId + 1 < levels.length) {
        levels[levelId + 1].unlockLevel();
      }
      
      notifyListeners();
    }
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