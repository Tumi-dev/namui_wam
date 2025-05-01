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
/// Persiste el estado (puntos y niveles completados) usando [SharedPreferences].
/// Interactúa con [ActivitiesState] para realizar reinicios globales.
/// Utiliza [ChangeNotifier] para notificar cambios.
/// {@endtemplate}
class GameState extends ChangeNotifier {
  /// Clave para SharedPreferences: indica si la alerta de 100 puntos ya se mostró.
  static const String _alertShownKey = 'alert_shown_at_100_points';
  /// Clave para SharedPreferences: almacena los puntos globales.
  static const String _pointsKey = 'global_points';
  /// Clave para SharedPreferences: almacena la lista de claves de niveles completados.
  static const String _completedLevelsKey = 'completed_levels';
  /// Puntuación máxima requerida para habilitar el reinicio manual.
  static const int maxPoints = 100;

  /// Puntos globales acumulados por el jugador.
  int _globalPoints = 0;
  /// Mapa que rastrea los niveles completados globalmente. La clave es 'activityId-levelId'.
  final Map<String, bool> _completedLevels = {};
  /// Referencia al estado de las actividades para coordinar reinicios.
  final ActivitiesState _activitiesState;
  /// Servicio de logging.
  final LoggerService _logger = getIt<LoggerService>();

  /// {@macro game_state}
  ///
  /// [activitiesState] La instancia de [ActivitiesState] necesaria para los reinicios.
  GameState(this._activitiesState) {
    _logger.info('Inicializando GameState...');
    _loadState();
    _loadAlertFlag();
  }

  /// Indica si la alerta por alcanzar los 100 puntos ya ha sido mostrada.
  bool _alertShownAt100Points = false;
  /// Obtiene el estado del flag que indica si la alerta de 100 puntos ya se mostró.
  bool get alertShownAt100Points => _alertShownAt100Points;

  /// Carga el estado del flag [_alertShownAt100Points] desde SharedPreferences.
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
  /// [activityId] ID de la actividad.
  /// [levelId] ID del nivel.
  /// Retorna `true` si el nivel está completado, `false` en caso contrario.
  bool isLevelCompleted(int activityId, int levelId) {
    final levelKey = '$activityId-$levelId';
    return _completedLevels[levelKey] ?? false;
  }

  /// Añade puntos al marcador global y marca un nivel como completado.
  ///
  /// Solo añade puntos y marca el nivel si no estaba completado previamente.
  /// Guarda el estado actualizado y notifica a los oyentes.
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
  /// Reinicia el estado en [ActivitiesState] para las actividades especificadas,
  /// guarda el estado reiniciado de los niveles usando [LevelStorage],
  /// resetea los puntos globales a 0, limpia los niveles completados correspondientes
  /// y guarda el nuevo [GameState]. También resetea el flag de la alerta de 100 puntos.
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
  bool get canManuallyReset => _globalPoints >= maxPoints;

  /// Solicita un reinicio manual del progreso.
  ///
  /// Solo procede si [canManuallyReset] es `true`.
  /// Llama a [_triggerGlobalReset] para efectuar el reinicio.
  Future<void> requestManualReset() async {
    if (canManuallyReset) {
      _logger.info('Solicitud de reinicio manual aceptada (Puntos: $_globalPoints >= $maxPoints).');
      await _triggerGlobalReset();
    } else {
      _logger.warning('Solicitud de reinicio manual rechazada (Puntos: $_globalPoints < $maxPoints).');
    }
  }

  /// Obtiene los puntos globales actuales.
  int get globalPoints => _globalPoints;
  /// Calcula los puntos restantes para alcanzar la puntuación máxima [maxPoints].
  int get remainingPoints => maxPoints - _globalPoints;

  /// **ADVERTENCIA:** Este método solo resetea el estado interno de [GameState]
  /// ([_globalPoints] y [_completedLevels]) y lo guarda.
  /// **NO** reinicia el estado en [ActivitiesState] ni en [LevelStorage].
  /// Usar [_triggerGlobalReset] o [requestManualReset] para un reinicio completo.
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
  /// [context] El contexto del widget.
  /// Retorna la instancia de [GameState] sin escuchar cambios (`listen: false`).
  static GameState of(BuildContext context) {
    return Provider.of<GameState>(context, listen: false);
  }
}
