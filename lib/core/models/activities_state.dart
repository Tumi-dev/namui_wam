import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'activity_levels.dart';

/// {@template activities_state}
/// Modelo central que gestiona el estado global de todas las actividades educativas.
///
/// Esta clase actúa como un contenedor para todas las actividades de la aplicación,
/// proporcionando métodos para:
/// - Registrar nuevas actividades
/// - Acceder a actividades existentes
/// - Completar niveles y gestionar el progreso
/// - Reiniciar el progreso de actividades individuales o todas juntas
///
/// Implementa [ChangeNotifier] para integrarse con el sistema de Provider,
/// notificando automáticamente a los widgets cuando el estado cambia.
///
/// Estructura organizativa:
/// ```
/// ActivitiesState
/// ├── ActivityLevels (Actividad 1)
/// │   ├── LevelModel (Nivel 1-1)
/// │   ├── LevelModel (Nivel 1-2)
/// │   └── ...
/// ├── ActivityLevels (Actividad 2)
/// │   ├── LevelModel (Nivel 2-1)
/// │   └── ...
/// └── ...
/// ```
///
/// Este modelo trabaja en conjunto con [GameState] para proporcionar
/// la gestión completa del progreso del usuario en la aplicación.
/// {@endtemplate}
class ActivitiesState extends ChangeNotifier {
  /// Mapa que almacena el estado de cada actividad, usando el ID de actividad como clave.
  ///
  /// Los IDs de actividad en la aplicación son:
  /// - 1: Muntsik mөik kөtasha sөl lau (Escoja el número correcto)
  /// - 2: Muntsikelan pөram kusrekun (Aprendamos a escribir los números)
  /// - 3: Nөsik utөwan asam kusrekun (Aprendamos a ver la hora)
  /// - 4: Anwan ashipelɵ kɵkun (Aprendamos a usar el dinero)
  /// - 5: Muntsielan namtrikmai yunөmarөpik (Convertir números en letras)
  /// - 6: Wammeran tulisha manchípik kui asamik pөrik (Diccionario)
  final Map<int, ActivityLevels> _activities = {};

  /// {@macro activities_state}
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// // En main.dart o en un setup inicial
  /// final activitiesState = ActivitiesState();
  ///
  /// // Registrar actividades
  /// activitiesState.addActivity(
  ///   ActivityLevels(
  ///     activityId: 1,
  ///     levels: [
  ///       LevelModel(id: 0, title: 'Nivel 1', ...),
  ///       LevelModel(id: 1, title: 'Nivel 2', ...),
  ///     ],
  ///   ),
  /// );
  ///
  /// // Proveer a la aplicación
  /// return ChangeNotifierProvider.value(
  ///   value: activitiesState,
  ///   child: MaterialApp(...),
  /// );
  /// ```
  ActivitiesState() {
    // Inicializar el estado como vacío.
    // Las actividades se agregarán dinámicamente usando [addActivity].
  }

  /// Agrega o actualiza el estado de una actividad.
  ///
  /// Este método registra una nueva [ActivityLevels] en el mapa interno
  /// o actualiza una existente si ya existe una con el mismo [activityId].
  /// Notifica a todos los widgets que estén escuchando cambios a través
  /// del mecanismo de [ChangeNotifier].
  ///
  /// Se utiliza típicamente durante la inicialización para configurar 
  /// las actividades disponibles en la aplicación.
  ///
  /// Ejemplo:
  /// ```dart
  /// final levels = [
  ///   LevelModel(id: 0, title: 'Básico', difficulty: 1, ...),
  ///   LevelModel(id: 1, title: 'Intermedio', difficulty: 2, ...),
  /// ];
  /// 
  /// activitiesState.addActivity(
  ///   ActivityLevels(activityId: 1, levels: levels)
  /// );
  /// ```
  ///
  /// [activity] El objeto [ActivityLevels] que contiene la información de la actividad.
  void addActivity(ActivityLevels activity) {
    _activities[activity.activityId] = activity;
    notifyListeners(); // Notifica a los oyentes que se agregó/actualizó una actividad.
  }

  /// Obtiene el estado de una actividad específica por su ID.
  ///
  /// Este método proporciona acceso al objeto [ActivityLevels] correspondiente
  /// a la actividad identificada por [activityId]. Es útil para acceder a los
  /// niveles individuales o consultar/modificar el estado de una actividad.
  ///
  /// Ejemplo:
  /// ```dart
  /// // Obtener actividad y verificar disponibilidad
  /// final activity1 = activitiesState.getActivity(1);
  /// if (activity1 != null) {
  ///   final level0 = activity1.getLevel(0);
  ///   print('¿Nivel 0 completado? ${level0?.isCompleted ?? false}');
  /// }
  /// ```
  ///
  /// [activityId] El ID de la actividad a recuperar.
  /// Retorna el [ActivityLevels] correspondiente o `null` si no existe.
  ActivityLevels? getActivity(int activityId) {
    return _activities[activityId];
  }

  /// Marca un nivel como completado para una actividad específica.
  ///
  /// Este método es el punto de entrada principal para actualizar el progreso
  /// del usuario cuando completa un nivel. Gestiona la lógica de:
  /// - Marcar el nivel como completado en la actividad correspondiente
  /// - Desbloquear el siguiente nivel automáticamente (excepto para actividades 4 y 5)
  /// - Notificar a la UI sobre los cambios de estado
  ///
  /// Ejemplo:
  /// ```dart
  /// // Cuando el usuario completa un nivel
  /// ElevatedButton(
  ///   onPressed: () {
  ///     // Guardar progreso y actualizar UI
  ///     ActivitiesState.of(context).completeLevel(1, 0);
  ///     // También actualizar GameState para los puntos globales
  ///     GameState.of(context).addPoints(1, 0, 5);
  ///   },
  ///   child: Text('Completar nivel'),
  /// )
  /// ```
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
  ///
  /// Este método suma los puntos de todas las actividades registradas para
  /// obtener una puntuación total. Nota: Esta puntuación es independiente
  /// de la que gestiona [GameState], que es la fuente de verdad para los
  /// puntos globales del juego.
  ///
  /// Ejemplo:
  /// ```dart
  /// final localPoints = activitiesState.getTotalPoints();
  /// print('Puntos acumulados localmente: $localPoints');
  /// ```
  ///
  /// Retorna la suma de puntos de todas las actividades registradas.
  int getTotalPoints() {
    return _activities.values.fold(0, (sum, activity) => sum + activity.totalPoints);
  }

  /// Reinicia el progreso de una actividad específica.
  ///
  /// Este método restablece una actividad a su estado inicial:
  /// - Reinicia los puntos acumulados a cero
  /// - Desbloquea solo los niveles que deberían estar disponibles inicialmente
  /// - Marca todos los niveles como no completados
  ///
  /// Nota: Este método solo afecta al estado en memoria. Para persistencia,
  /// debe combinarse con [LevelStorage] o mecanismos similares.
  ///
  /// Ejemplo:
  /// ```dart
  /// // Botón de reinicio para una actividad específica
  /// IconButton(
  ///   icon: Icon(Icons.refresh),
  ///   onPressed: () {
  ///     activitiesState.resetActivity(1);
  ///     // También actualizar el almacenamiento persistente
  ///     LevelStorage.saveLevels(1, activitiesState.getActivity(1)!.levels);
  ///   },
  /// )
  /// ```
  ///
  /// [activityId] El ID de la actividad a reiniciar.
  void resetActivity(int activityId) {
    final activity = _activities[activityId];
    if (activity != null) {
      activity.resetActivity();
      notifyListeners(); // Notifica que la actividad fue reiniciada.
    }
  }

  /// Reinicia el progreso de todas las actividades registradas.
  ///
  /// Este método restablece todas las actividades a su estado inicial,
  /// equivalente a llamar [resetActivity] para cada actividad registrada.
  /// Útil para implementar funciones de "reinicio completo" o "nueva partida".
  ///
  /// Ejemplo:
  /// ```dart
  /// // Botón de reinicio global con confirmación
  /// ElevatedButton(
  ///   onPressed: () {
  ///     showDialog(
  ///       context: context,
  ///       builder: (context) => AlertDialog(
  ///         title: Text('¿Reiniciar todo el progreso?'),
  ///         actions: [
  ///           TextButton(
  ///             onPressed: () {
  ///               Navigator.pop(context);
  ///               activitiesState.resetAllActivities();
  ///               // También actualizar almacenamiento persistente
  ///             },
  ///             child: Text('Confirmar'),
  ///           ),
  ///           TextButton(
  ///             onPressed: () => Navigator.pop(context),
  ///             child: Text('Cancelar'),
  ///           ),
  ///         ],
  ///       ),
  ///     );
  ///   },
  ///   child: Text('Reiniciar todo'),
  /// )
  /// ```
  void resetAllActivities() {
    for (var activity in _activities.values) {
      activity.resetActivity();
    }
    notifyListeners(); // Notifica que todas las actividades fueron reiniciadas.
  }

  /// Verifica si una actividad con el ID especificado está registrada en el estado.
  ///
  /// Este método comprueba la existencia de una actividad en el estado actual,
  /// útil para validaciones antes de realizar operaciones sobre una actividad.
  ///
  /// Ejemplo:
  /// ```dart
  /// // Verificar antes de navegar
  /// if (activitiesState.isActivityAvailable(3)) {
  ///   Navigator.pushNamed(context, '/activity/3');
  /// } else {
  ///   showDialog(
  ///     context: context,
  ///     builder: (context) => AlertDialog(
  ///       title: Text('Actividad no disponible'),
  ///       content: Text('Esta actividad aún no está implementada.'),
  ///     ),
  ///   );
  /// }
  /// ```
  ///
  /// [activityId] El ID de la actividad a verificar.
  /// Retorna `true` si la actividad existe, `false` en caso contrario.
  bool isActivityAvailable(int activityId) {
    return _activities.containsKey(activityId);
  }

  /// Método estático de conveniencia para obtener la instancia de [ActivitiesState]
  /// desde el [BuildContext] usando [Provider].
  ///
  /// Este método facilita el acceso al estado desde cualquier widget dentro
  /// del árbol que esté debajo del [Provider<ActivitiesState>].
  ///
  /// Ejemplo:
  /// ```dart
  /// // En un widget cualquiera
  /// final activitiesState = ActivitiesState.of(context);
  /// final activity1 = activitiesState.getActivity(1);
  ///
  /// // Para escuchar cambios (en un StatelessWidget con Consumer)
  /// Consumer<ActivitiesState>(
  ///   builder: (context, state, child) {
  ///     final activity = state.getActivity(1);
  ///     return Text('Puntos: ${activity?.totalPoints ?? 0}');
  ///   },
  /// )
  /// ```
  ///
  /// [context] El contexto del widget.
  /// Retorna la instancia de [ActivitiesState] sin escuchar cambios (`listen: false`).
  static ActivitiesState of(BuildContext context) {
    // listen: false es común aquí para evitar reconstrucciones innecesarias
    // si solo se necesita llamar a un método del estado.
    return Provider.of<ActivitiesState>(context, listen: false);
  }
}
