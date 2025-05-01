import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'activity_levels.dart';

/// {@template activities_state}
/// Gestiona el estado global de todas las actividades de aprendizaje en la aplicación.
///
/// Utiliza [ChangeNotifier] para notificar a los oyentes (widgets) sobre cambios en el estado,
/// como la finalización de niveles, el desbloqueo de nuevos niveles o el reinicio del progreso.
/// Mantiene un mapa de [ActivityLevels] indexado por el ID de la actividad.
/// {@endtemplate}
class ActivitiesState extends ChangeNotifier {
  /// Mapa que almacena el estado de cada actividad, usando el ID de actividad como clave.
  final Map<int, ActivityLevels> _activities = {};

  /// {@macro activities_state}
  ActivitiesState() {
    // Inicializar el estado como vacío.
    // Las actividades se agregarán dinámicamente usando [addActivity].
  }

  /// Agrega o actualiza el estado de una actividad.
  ///
  /// [activity] El objeto [ActivityLevels] que contiene la información de la actividad.
  void addActivity(ActivityLevels activity) {
    _activities[activity.activityId] = activity;
    notifyListeners(); // Notifica a los oyentes que se agregó/actualizó una actividad.
  }

  /// Obtiene el estado de una actividad específica por su ID.
  ///
  /// [activityId] El ID de la actividad a recuperar.
  /// Retorna el [ActivityLevels] correspondiente o `null` si no existe.
  ActivityLevels? getActivity(int activityId) {
    return _activities[activityId];
  }

  /// Marca un nivel como completado para una actividad específica.
  ///
  /// Si el nivel se completa por primera vez y no es parte de las actividades 4 o 5,
  /// intenta desbloquear el siguiente nivel de la misma actividad si existe y está bloqueado.
  ///
  /// [activityId] El ID de la actividad.
  /// [levelId] El ID del nivel completado.
  void completeLevel(int activityId, int levelId) {
    final activity = _activities[activityId];
    if (activity != null) {
      final wasCompleted = activity.isLevelCompleted(levelId);
      activity.completeLevel(levelId);

      // Desbloqueo automático del siguiente nivel (excepto para A4 y A5)
      if (!wasCompleted && activityId != 4 && activityId != 5) {
        final nextLevel = activity.getLevel(levelId + 1);
        // Corrected logic: Only unlock if the next level exists AND is currently locked.
        if (nextLevel != null && nextLevel.isLocked) {
          nextLevel.unlockLevel();
          // Podría ser útil loggear o notificar sobre el desbloqueo
        }
      }

      notifyListeners(); // Notifica cambios en el estado de la actividad.
    }
  }

  /// Calcula y devuelve el total de puntos acumulados en todas las actividades.
  int getTotalPoints() {
    return _activities.values.fold(0, (sum, activity) => sum + activity.totalPoints);
  }

  /// Reinicia el progreso de una actividad específica.
  ///
  /// Restablece los niveles a su estado inicial (bloqueados/no completados).
  /// [activityId] El ID de la actividad a reiniciar.
  void resetActivity(int activityId) {
    final activity = _activities[activityId];
    if (activity != null) {
      activity.resetActivity();
      notifyListeners(); // Notifica que la actividad fue reiniciada.
    }
  }

  /// Reinicia el progreso de todas las actividades registradas.
  void resetAllActivities() {
    for (var activity in _activities.values) {
      activity.resetActivity();
    }
    notifyListeners(); // Notifica que todas las actividades fueron reiniciadas.
  }

  /// Verifica si una actividad con el ID especificado está registrada en el estado.
  ///
  /// [activityId] El ID de la actividad a verificar.
  /// Retorna `true` si la actividad existe, `false` en caso contrario.
  bool isActivityAvailable(int activityId) {
    return _activities.containsKey(activityId);
  }

  /// Método estático de conveniencia para obtener la instancia de [ActivitiesState]
  /// desde el [BuildContext] usando [Provider].
  ///
  /// [context] El contexto del widget.
  /// Retorna la instancia de [ActivitiesState] sin escuchar cambios (`listen: false`).
  static ActivitiesState of(BuildContext context) {
    // listen: false es común aquí para evitar reconstrucciones innecesarias
    // si solo se necesita llamar a un método del estado.
    return Provider.of<ActivitiesState>(context, listen: false);
  }
}
