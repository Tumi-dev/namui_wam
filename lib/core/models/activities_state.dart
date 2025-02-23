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
      activity.completeLevel(levelId);
      notifyListeners();
    }
  }

  bool isActivityAvailable(int activityId) {
    return _activities.containsKey(activityId);
  }

  static ActivitiesState of(BuildContext context) {
    return Provider.of<ActivitiesState>(context, listen: false);
  }
}
