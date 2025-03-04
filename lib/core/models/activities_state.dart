import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'activity_levels.dart';

class ActivitiesState extends ChangeNotifier {
  final Map<int, ActivityLevels> _activities = {};

  ActivitiesState() {
    // Inicializar el estado como vacío
    // Las actividades se agregarán a través de addActivity
  }

  void addActivity(ActivityLevels activity) {
    _activities[activity.activityId] = activity;
    notifyListeners();
  }

  ActivityLevels? getActivity(int activityId) {
    return _activities[activityId];
  }

  void completeLevel(int activityId, int levelId) {
    final activity = _activities[activityId];
    if (activity != null) {
      final wasCompleted = activity.isLevelCompleted(levelId);
      activity.completeLevel(levelId);
      
      if (!wasCompleted && activityId != 4 && activityId != 5) {
        // Desbloquear el siguiente nivel si existe y no es actividad 4 o 5
        final nextLevel = activity.getLevel(levelId + 1);
        if (nextLevel != null) {
          nextLevel.unlockLevel();
        }
      }
      
      notifyListeners();
    }
  }

  int getTotalPoints() {
    return _activities.values.fold(0, (sum, activity) => sum + activity.totalPoints);
  }

  void resetActivity(int activityId) {
    final activity = _activities[activityId];
    if (activity != null) {
      activity.resetActivity();
      notifyListeners();
    }
  }

  void resetAllActivities() {
    for (var activity in _activities.values) {
      activity.resetActivity();
    }
    notifyListeners();
  }

  bool isActivityAvailable(int activityId) {
    return _activities.containsKey(activityId);
  }

  static ActivitiesState of(BuildContext context) {
    return Provider.of<ActivitiesState>(context, listen: false);
  }
}
