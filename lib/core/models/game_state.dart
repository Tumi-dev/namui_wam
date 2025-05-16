import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:namuiwam/core/models/activities_state.dart';
import 'package:namuiwam/core/utils/level_storage.dart'; // Asegúrate que esta ruta es correcta
import 'package:namuiwam/core/di/service_locator.dart'; // Para LoggerService
import 'package:namuiwam/core/services/logger_service.dart';

/// {@template game_state}
/// Gestiona el estado global del juego, incluyendo los puntos totales acumulados
/// y el estado de completitud de los niveles a través de todas las actividades.
///
/// Esta clase actúa como el punto central de gestión del progreso global del usuario,
/// proporcionando funcionalidades para:
/// - Almacenar y recuperar los puntos globales acumulados
/// - Rastrear qué niveles se han completado en todas las actividades
/// - Gestionar el reinicio global de progreso (manual o automático)
/// - Persistir todo el estado utilizando [SharedPreferences]
///
/// El modelo incluye una lógica especial para marcar un hito cuando el usuario
/// alcanza 100 puntos, momento en el cual se habilita la opción de reiniciar
/// manualmente el progreso del juego.
///
/// Implementa [ChangeNotifier] para integrarse con el sistema de Provider,
/// notificando automáticamente a los widgets cuando el estado cambia.
///
/// Relaciones principales:
/// - Coordina con [ActivitiesState] para reiniciar el progreso de actividades específicas
/// - Utiliza [LevelStorage] para persistir los cambios de estado de niveles
/// - Emplea [LoggerService] para registrar información de depuración y errores
/// - Se integra con [Provider] para la gestión de estado en la UI
/// {@endtemplate}
class GameState extends ChangeNotifier {
  /// Clave para SharedPreferences: indica si la alerta de 100 puntos ya se mostró.
  static const String _alertShownKey = 'alert_shown_at_100_points';
  
  /// Clave para SharedPreferences: almacena los puntos globales.
  static const String _pointsKey = 'global_points';
  
  /// Clave para SharedPreferences: almacena la lista de claves de niveles completados.
  static const String _completedLevelsKey = 'completed_levels';
  
  /// Puntuación máxima requerida para habilitar el reinicio manual.
  ///
  /// Cuando el usuario alcanza esta puntuación, se habilita el botón 
  /// de reinicio que permite volver a empezar todas las actividades.
  static const int maxPoints = 100;

  /// Puntos globales acumulados por el jugador.
  ///
  /// Representa la suma total de puntos obtenidos por completar niveles
  /// en todas las actividades. Estos puntos son persistentes entre sesiones.
  int _globalPoints = 0;
  
  /// Mapa que rastrea los niveles completados globalmente. La clave es 'activityId-levelId'.
  ///
  /// Este mapa funciona como un registro persistente para evitar que el usuario
  /// gane puntos múltiples veces por el mismo nivel. La estructura de la clave es
  /// importante: 'activityId-levelId' (por ejemplo: '1-3' para el nivel 3 de la actividad 1).
  final Map<String, bool> _completedLevels = {};
  
  /// Referencia al estado de las actividades para coordinar reinicios.
  ///
  /// Se utiliza principalmente durante el reinicio global para actualizar
  /// el estado de todas las actividades afectadas.
  final ActivitiesState _activitiesState;
  
  /// Servicio de logging.
  ///
  /// Utilizado para registrar eventos importantes durante la ejecución
  /// y facilitar la depuración de problemas.
  final LoggerService _logger = getIt<LoggerService>();

  /// {@macro game_state}
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// // En main.dart o en un setup inicial
  /// final activitiesState = ActivitiesState();
  /// final gameState = GameState(activitiesState);
  ///
  /// // Proveer ambos a la aplicación
  /// return MultiProvider(
  ///   providers: [
  ///     ChangeNotifierProvider.value(value: activitiesState),
  ///     ChangeNotifierProvider.value(value: gameState),
  ///   ],
  ///   child: MaterialApp(...),
  /// );
  /// ```
  ///
  /// Al inicializarse, carga automáticamente el estado persistido desde SharedPreferences.
  ///
  /// [ActivitiesState] La instancia de [ActivitiesState] necesaria para los reinicios.
  GameState(this._activitiesState) {
    _logger.info('Inicializando GameState...');
    _loadState();
    _loadAlertFlag();
  }

  /// Indica si la alerta por alcanzar los 100 puntos ya ha sido mostrada.
  ///
  /// Este flag evita mostrar repetidamente la alerta al usuario cuando
  /// alcanza los 100 puntos en diferentes sesiones.
  bool _alertShownAt100Points = false;
  
  /// Obtiene el estado del flag que indica si la alerta de 100 puntos ya se mostró.
  ///
  /// Utilizado para decidir si se debe mostrar la notificación sobre
  /// la posibilidad de reiniciar el juego.
  bool get alertShownAt100Points => _alertShownAt100Points;

  /// Carga el estado del flag [_alertShownAt100Points] desde SharedPreferences.
  ///
  /// Este método se llama automáticamente durante la inicialización para
  /// recuperar el estado persistido de la alerta entre sesiones.
  Future<void> _loadAlertFlag() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _alertShownAt100Points = prefs.getBool(_alertShownKey) ?? false;
      _logger.info('Flag de alerta de 100 puntos cargado: $_alertShownAt100Points');
    } catch (e, s) {
      _logger.error('Error cargando flag de alerta', e, s);
    }
  }

  /// Guarda el estado del flag [_alertShownAt100Points] en SharedPreferences.
  ///
  /// Este método permite actualizar la persistencia del flag cuando cambia su valor,
  /// asegurando que el estado se mantenga consistente entre sesiones.
  ///
  /// Ejemplo:
  /// ```dart
  /// // Al mostrar la alerta de 100 puntos
  /// if (gameState.globalPoints >= 100 && !gameState.alertShownAt100Points) {
  ///   showDialog(
  ///     context: context,
  ///     builder: (context) => AlertDialog(
  ///       title: Text('¡Felicidades!'),
  ///       content: Text('Has alcanzado 100 puntos. Ahora puedes reiniciar el juego.'),
  ///       actions: [
  ///         TextButton(
  ///           onPressed: () {
  ///             Navigator.pop(context);
  ///             gameState.setAlertShownAt100Points(true);
  ///           },
  ///           child: Text('Entendido'),
  ///         ),
  ///       ],
  ///     ),
  ///   );
  /// }
  /// ```
  ///
  /// [value] El nuevo valor para el flag.
  Future<void> setAlertShownAt100Points(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _alertShownAt100Points = value;
      await prefs.setBool(_alertShownKey, value);
      _logger.info('Flag de alerta de 100 puntos guardado: $value');
    } catch (e, s) {
      _logger.error('Error guardando flag de alerta', e, s);
    }
  }

  /// Carga el estado persistido ([_globalPoints] y [_completedLevels]) desde SharedPreferences.
  ///
  /// Este método recupera toda la información del progreso global desde el
  /// almacenamiento persistente, incluyendo los puntos acumulados y el registro
  /// de niveles completados. Se ejecuta automáticamente durante la inicialización.
  Future<void> _loadState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _globalPoints = prefs.getInt(_pointsKey) ?? 0;
      final completedLevelsList = prefs.getStringList(_completedLevelsKey) ?? [];
      _completedLevels.clear();
      for (var levelKey in completedLevelsList) {
        _completedLevels[levelKey] = true;
      }
      _logger.info('GameState cargado: Puntos=$_globalPoints, NivelesCompletados=${_completedLevels.length}');
      notifyListeners();
    } catch (e, s) {
      _logger.error('Error cargando GameState', e, s);
    }
  }

  /// Guarda el estado actual ([_globalPoints] y [_completedLevels]) en SharedPreferences.
  ///
  /// Este método persiste los cambios realizados al estado global del juego,
  /// asegurando que la información se conserve entre sesiones de la aplicación.
  /// Se llama automáticamente después de cualquier operación que modifique el estado.
  Future<void> _saveState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_pointsKey, _globalPoints);
      await prefs.setStringList(
        _completedLevelsKey,
        _completedLevels.keys.toList(),
      );
      _logger.info('GameState guardado: Puntos=$_globalPoints, NivelesCompletados=${_completedLevels.length}');
    } catch (e, s) {
      _logger.error('Error guardando GameState', e, s);
    }
  }

  /// Verifica si un nivel específico está marcado como completado globalmente.
  ///
  /// Este método comprueba el registro global de niveles completados para
  /// determinar si un nivel específico ha sido completado por el usuario.
  ///
  /// Ejemplo:
  /// ```dart
  /// // Verificar si el primer nivel de la primera actividad está completado
  /// final isCompleted = gameState.isLevelCompleted(1, 0);
  /// // Mostrar un indicador visual según el estado
  /// Icon(isCompleted ? Icons.check_circle : Icons.circle_outlined)
  /// ```
  ///
  /// [activityId] ID de la actividad.
  /// [levelId] ID del nivel.
  /// Retorna `true` si el nivel está completado, `false` en caso contrario.
  bool isLevelCompleted(int activityId, int levelId) {
    final levelKey = '$activityId-$levelId';
    return _completedLevels[levelKey] ?? false;
  }

  /// Añade puntos al marcador global y marca un nivel como completado.
  ///
  /// Este método es el punto de entrada principal para actualizar el progreso global
  /// cuando el usuario completa un nivel. Solo añade puntos si el nivel no estaba
  /// previamente completado, evitando que se acumulen puntos múltiples veces por
  /// el mismo nivel.
  ///
  /// Ejemplo:
  /// ```dart
  /// // Al completar un nivel exitosamente
  /// ElevatedButton(
  ///   onPressed: () async {
  ///     // Primero actualizar el estado local de la actividad
  ///     activity.completeLevel(currentLevelId);
  ///
  ///     // Luego actualizar el progreso global
  ///     final firstTime = await GameState.of(context).addPoints(
  ///       activity.activityId,
  ///       currentLevelId,
  ///       ActivityLevels.pointsPerLevel,
  ///     );
  ///
  ///     // Mostrar mensaje apropiado
  ///     ScaffoldMessenger.of(context).showSnackBar(
  ///       SnackBar(
  ///         content: Text(firstTime
  ///           ? '¡Nivel completado! +${ActivityLevels.pointsPerLevel} puntos'
  ///           : 'Nivel completado anteriormente. No se añadieron puntos.'),
  ///       ),
  ///     );
  ///   },
  ///   child: Text('Completar nivel'),
  /// )
  /// ```
  ///
  /// [activityId] ID de la actividad.
  /// [levelId] ID del nivel.
  /// [points] Puntos a añadir.
  /// Retorna `true` si los puntos fueron añadidos (nivel completado por primera vez),
  /// `false` si el nivel ya estaba completado.
  Future<bool> addPoints(int activityId, int levelId, int points) async {
    final levelKey = '$activityId-$levelId';
    if (!_completedLevels.containsKey(levelKey)) {
      _completedLevels[levelKey] = true;
      _globalPoints += points;
      _logger.info('Nivel $levelKey completado. Puntos añadidos: $points. Total: $_globalPoints');
      await _saveState();
      notifyListeners();
      return true;
    }
    _logger.info('Nivel $levelKey ya estaba completado. No se añadieron puntos.');
    return false;
  }

  /// Realiza un reinicio global del progreso para las actividades 1 a 4.
  ///
  /// Este método privado implementa la lógica completa del reinicio global:
  /// 1. Reinicia el estado en [ActivitiesState] para cada actividad (1-4)
  /// 2. Guarda el estado reiniciado en [LevelStorage] para persistencia
  /// 3. Reinicia los puntos globales a cero
  /// 4. Limpia los registros de niveles completados para las actividades afectadas
  /// 5. Reinicia el flag de alerta de 100 puntos
  /// 6. Persiste todos los cambios y notifica a los oyentes
  ///
  /// Este método no es accesible directamente desde fuera, sino que se llama
  /// a través de [requestManualReset] cuando se cumplen las condiciones.
  Future<void> _triggerGlobalReset() async {
    _logger.info('Iniciando proceso de reinicio global...');
    await setAlertShownAt100Points(false); // Resetear el flag
    try {
      // Reiniciar estado en ActivitiesState y guardar en LevelStorage
      for (int actId in [1, 2, 3, 4]) { // Asume que solo estas actividades se reinician
        final activity = _activitiesState.getActivity(actId);
        if (activity != null) {
          _logger.debug('Reiniciando Actividad $actId en ActivitiesState...');
          activity.resetActivity(); // Esto debería notificar a sus propios listeners
          _logger.debug('Guardando estado reiniciado de niveles para Actividad $actId...');
          await LevelStorage.saveLevels(actId, activity.levels);
          _logger.debug('Actividad $actId reiniciada y guardada en storage.');
        } else {
          _logger.warning('Actividad $actId no encontrada en ActivitiesState durante el reinicio.');
        }
      }

      // Resetear puntos globales
      _globalPoints = 0;

      // Limpiar niveles completados solo para las actividades reiniciadas
      _logger.debug('Limpiando niveles completados para actividades 1-4...');
      int countBefore = _completedLevels.length;
      _completedLevels.removeWhere((key, value) {
        final parts = key.split('-');
        if (parts.length == 2) {
          final actId = int.tryParse(parts[0]);
          // Asegúrate que el rango coincide con las actividades reiniciadas
          return actId != null && actId >= 1 && actId <= 4;
        }
        return false; // Claves con formato incorrecto también se eliminan (o se mantienen?)
      });
      int countAfter = _completedLevels.length;
      _logger.debug('Niveles completados limpiados. ${countBefore - countAfter} entradas eliminadas.');

      // Guardar el estado reseteado de GameState
      await _saveState();
      _logger.info('GameState reiniciado y guardado. Puntos: $_globalPoints');

      notifyListeners(); // Notificar a los oyentes de GameState
      _logger.info('Reinicio global completado exitosamente.');
      // await _loadAlertFlag(); // No es necesario, setAlertShownAt100Points ya actualiza la variable local
    } catch (e, s) {
      _logger.error('Error durante el reinicio global', e, s);
      // Considerar si notificar igual o manejar el error de otra forma
      notifyListeners();
    }
  }

  /// Indica si el jugador ha alcanzado la puntuación máxima para habilitar el reinicio manual.
  ///
  /// Esta propiedad se utiliza para determinar si se debe mostrar la opción
  /// de reinicio manual al usuario. Solo cuando los puntos globales alcanzan o superan
  /// el umbral de [maxPoints] (100 por defecto) se habilita esta funcionalidad.
  ///
  /// Ejemplo:
  /// ```dart
  /// // Mostrar u ocultar el botón de reinicio
  /// if (gameState.canManuallyReset) {
  ///   ElevatedButton(
  ///     onPressed: () => _showResetConfirmationDialog(context),
  ///     child: Text('Reiniciar progreso'),
  ///   )
  /// }
  /// ```
  bool get canManuallyReset => _globalPoints >= maxPoints;

  /// Solicita un reinicio manual del progreso.
  ///
  /// Este método inicia el proceso de reinicio global del juego, pero solo
  /// procede si el usuario ha alcanzado la puntuación mínima requerida
  /// ([maxPoints]). Si no se cumple esta condición, la solicitud es ignorada.
  ///
  /// Ejemplo:
  /// ```dart
  /// // Diálogo de confirmación de reinicio
  /// void _showResetConfirmationDialog(BuildContext context) {
  ///   showDialog(
  ///     context: context,
  ///     builder: (context) => AlertDialog(
  ///       title: Text('¿Reiniciar progreso?'),
  ///       content: Text('Se perderá todo tu avance en las actividades 1-4. Esta acción no se puede deshacer.'),
  ///       actions: [
  ///         TextButton(
  ///           onPressed: () {
  ///             Navigator.pop(context);
  ///             GameState.of(context).requestManualReset();
  ///           },
  ///           child: Text('Reiniciar'),
  ///         ),
  ///         TextButton(
  ///           onPressed: () => Navigator.pop(context),
  ///           child: Text('Cancelar'),
  ///         ),
  ///       ],
  ///     ),
  ///   );
  /// }
  /// ```
  Future<void> requestManualReset() async {
    if (canManuallyReset) {
      _logger.info('Solicitud de reinicio manual aceptada (Puntos: $_globalPoints >= $maxPoints).');
      await _triggerGlobalReset();
    } else {
      _logger.warning('Solicitud de reinicio manual rechazada (Puntos: $_globalPoints < $maxPoints).');
    }
  }

  /// Obtiene los puntos globales actuales.
  ///
  /// Representa la puntuación total acumulada por el usuario a través
  /// de todas las actividades y niveles completados.
  int get globalPoints => _globalPoints;
  
  /// Calcula los puntos restantes para alcanzar la puntuación máxima [maxPoints].
  ///
  /// Esta propiedad es útil para mostrar al usuario cuántos puntos adicionales
  /// necesita obtener para desbloquear la funcionalidad de reinicio manual.
  ///
  /// Ejemplo:
  /// ```dart
  /// // Mostrar progreso hacia el reinicio
  /// Text('Puntos para reinicio: ${gameState.remainingPoints}'),
  /// LinearProgressIndicator(
  ///   value: (GameState.maxPoints - gameState.remainingPoints) / GameState.maxPoints,
  /// )
  /// ```
  int get remainingPoints => maxPoints - _globalPoints;

  /// **ADVERTENCIA:** Este método solo resetea el estado interno de [GameState]
  /// ([_globalPoints] y [_completedLevels]) y lo guarda.
  /// **NO** reinicia el estado en [ActivitiesState] ni en [LevelStorage].
  /// Usar [_triggerGlobalReset] o [requestManualReset] para un reinicio completo.
  ///
  /// Este método está marcado como obsoleto porque no realiza un reinicio
  /// completo y coherente del estado del juego, lo que podría causar inconsistencias.
  @Deprecated('Use requestManualReset or _triggerGlobalReset for a full reset.')
  Future<void> resetGame() async {
    _logger.warning('resetGame() llamado. Reiniciando solo GameState (puntos y niveles completados). El estado de ActivitiesState no se ve afectado.');
    _globalPoints = 0;
    _completedLevels.clear();
    await _saveState();
    notifyListeners();
  }

  /// Método estático de conveniencia para obtener la instancia de [GameState]
  /// desde el [BuildContext] usando [Provider].
  ///
  /// Este método facilita el acceso al estado desde cualquier widget dentro
  /// del árbol que esté debajo del [Provider<GameState>].
  ///
  /// Ejemplo:
  /// ```dart
  /// // En un widget cualquiera
  /// final gameState = GameState.of(context);
  /// final points = gameState.globalPoints;
  ///
  /// // Para escuchar cambios (en un StatelessWidget con Consumer)
  /// Consumer<GameState>(
  ///   builder: (context, state, child) {
  ///     return Text('Puntos globales: ${state.globalPoints}');
  ///   },
  /// )
  /// ```
  ///
  /// [context] El contexto del widget.
  /// Retorna la instancia de [GameState] sin escuchar cambios (`listen: false`).
  static GameState of(BuildContext context) {
    return Provider.of<GameState>(context, listen: false);
  }
}
