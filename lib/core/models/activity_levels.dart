import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'level_model.dart';

/// {@template activity_levels}
/// Gestiona el estado y la lógica de los niveles para una actividad específica.
///
//// Mantiene una lista de [LevelModel], rastrea los niveles completados, calcula
/// los puntos totales y maneja el desbloqueo y reinicio de niveles.
/// Utiliza [ChangeNotifier] para notificar cambios en el estado de la actividad.
/// {@endtemplate}
class ActivityLevels extends ChangeNotifier {
  /// La lista de modelos de nivel asociados a esta actividad.
  final List<LevelModel> levels;
  /// El identificador único de esta actividad.
  final int activityId;
  /// Puntuación total acumulada en esta actividad.
  int _totalPoints = 0;
  /// Mapa para rastrear qué niveles (por ID/índice) han sido completados.
  final Map<int, bool> _completedLevels = {};
  /// Puntos otorgados por completar cada nivel.
  static const int pointsPerLevel = 5;

  /// {@macro activity_levels}
  ///
  /// [activityId] El ID de la actividad.
  /// [levels] La lista de [LevelModel] para esta actividad.
  ActivityLevels({
    required this.activityId,
    required this.levels,
  }) {
    _initializeLevels();
  }

  /// Inicializa el estado de los niveles al crear la instancia.
  ///
  /// Para las actividades 3 y 4, todos los niveles se desbloquean inicialmente.
  /// Para otras actividades (1, 2, etc.), solo el primer nivel se desbloquea.
  void _initializeLevels() {
    if (levels.isNotEmpty) {
      if (activityId == 3 || activityId == 4) {
        // Para actividades 3 y 4, desbloquear todos los niveles
        for (var level in levels) {
          level.unlockLevel(); // Usa el método del modelo
        }
      } else {
        // Para otras actividades, solo desbloquear el primer nivel
        levels[0].unlockLevel(); // Usa el método del modelo
      }
    }
  }

  /// Verifica si un nivel específico es accesible.
  ///
  /// **Nota:** La lógica actual (`levels[levelId - 1].isCompleted`) podría ser incorrecta.
  /// Generalmente, un nivel es accesible si está desbloqueado (`levels[levelId].isUnlocked`).
  /// Considera revisar esta lógica.
  ///
  /// [levelId] El índice del nivel a verificar (0-based).
  /// Retorna `true` si el nivel anterior está completado (según la lógica actual).
  bool canAccessLevel(int levelId) {
    // Validación de índice
    if (levelId < 0 || levelId >= levels.length) return false;
    // Lógica actual: ¿Debería ser `levels[levelId].isUnlocked`?
    if (levelId == 0) return levels[0].status != LevelStatus.locked; // El primer nivel es accesible si está desbloqueado
    return levels[levelId - 1].isCompleted; // Lógica actual para niveles > 0
  }

  /// Verifica si un nivel específico ha sido completado.
  ///
  /// [levelId] El índice del nivel a verificar (0-based).
  /// Retorna `true` si el nivel está marcado como completado, `false` en caso contrario.
  bool isLevelCompleted(int levelId) {
    // Usa el estado del LevelModel directamente
    if (levelId >= 0 && levelId < levels.length) {
      return levels[levelId].isCompleted;
    }
    return false;
    // return _completedLevels[levelId] ?? false; // Lógica anterior con mapa interno
  }

  /// Marca un nivel como completado.
  ///
  /// Si el nivel no estaba completado previamente, actualiza su estado,
  /// suma puntos, y desbloquea el siguiente nivel (si aplica y no es actividad 3 o 4).
  /// Notifica a los oyentes sobre el cambio.
  ///
  /// [levelId] El índice del nivel a completar (0-based).
  void completeLevel(int levelId) {
    if (levelId >= 0 && levelId < levels.length) {
      final level = levels[levelId];
      // Solo proceder si el nivel está desbloqueado y no completado
      if (level.status == LevelStatus.unlocked) {
        level.completeLevel(); // Actualiza el estado en el modelo
        _totalPoints += pointsPerLevel;
        // _completedLevels[levelId] = true; // Ya no es necesario si usamos el estado del modelo

        // Desbloquear el siguiente nivel si existe y no es actividad 3 o 4
        int nextLevelId = levelId + 1;
        if (nextLevelId < levels.length && activityId != 3 && activityId != 4) {
          levels[nextLevelId].unlockLevel();
        }

        notifyListeners();
      }
    }
  }

  /// Obtiene la puntuación total acumulada para esta actividad.
  int get totalPoints => _totalPoints;

  /// Reinicia el progreso de la actividad.
  ///
  /// Restablece los puntos totales, el estado de completado de los niveles
  /// y el estado (bloqueado/desbloqueado) de cada nivel según las reglas iniciales.
  /// Notifica a los oyentes.
  void resetActivity() {
    _totalPoints = 0;
    _completedLevels.clear(); // Limpiar el mapa si aún se usa, aunque parece redundante

    // Restablecer el estado de cada LevelModel
    for (int i = 0; i < levels.length; i++) {
      final level = levels[i];
      if (activityId == 3 || activityId == 4) {
        level.status = LevelStatus.unlocked;
      } else {
        // Para otras actividades, bloquear todos excepto el primero
        level.status = (i == 0) ? LevelStatus.unlocked : LevelStatus.locked;
      }
    }

    // No es necesario desbloquear explícitamente el primero aquí si se hizo en el bucle

    notifyListeners();
  }

  /// Obtiene el [LevelModel] para un ID (índice) de nivel específico.
  ///
  /// [levelId] El índice del nivel a obtener (0-based).
  /// Retorna el [LevelModel] o `null` si el índice está fuera de rango.
  LevelModel? getLevel(int levelId) {
    if (levelId >= 0 && levelId < levels.length) {
      return levels[levelId];
    }
    return null;
  }

  /// Obtiene una lista no modificable de todos los niveles de la actividad.
  List<LevelModel> get availableLevels => List.unmodifiable(levels);

  /// Método estático para obtener una instancia de [ActivityLevels] a través de Provider.
  ///
  /// **Nota:** Este método asume que [ActivityLevels] se proporciona directamente,
  /// lo cual podría no ser el caso si se gestiona dentro de [ActivitiesState].
  /// Además, filtra por `targetActivityId`, lo que puede ser propenso a errores si
  /// múltiples instancias (incorrectamente) existen en el árbol.
  /// Considera obtener [ActivityLevels] a través de `ActivitiesState.of(context).getActivity(activityId)`.
  ///
  /// [context] El BuildContext.
  /// [listen] Si el widget debe escuchar cambios (por defecto `true`).
  /// [targetActivityId] El ID de la actividad deseada.
  /// Retorna la instancia de [ActivityLevels] si se encuentra y coincide el ID, o `null`.
  @Deprecated('Consider using ActivitiesState.of(context).getActivity(activityId) instead')
  static ActivityLevels? of(BuildContext context, {bool listen = true, required int targetActivityId}) {
    try {
      // Esta línea probablemente fallará si ActivityLevels no se provee directamente.
      final provider = Provider.of<ActivityLevels>(context, listen: listen);
      // Comprueba si la instancia encontrada es la correcta.
      return provider.activityId == targetActivityId ? provider : null;
    } catch (e) {
      // Captura el error si Provider.of falla (ej. no se encontró el Provider).
      return null;
    }
  }
}