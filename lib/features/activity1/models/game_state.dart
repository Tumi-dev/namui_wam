import 'package:flutter/foundation.dart';
import 'package:namuiwam/core/models/level_model.dart';
import 'package:namuiwam/features/activity1/data/activity1_levels.dart'; // Asume que activity1Levels está definido aquí

/// {@template activity1_game_state}
/// Gestiona el estado específico de la Actividad 1 (Números Namtrik).
///
/// Mantiene el puntaje por nivel, el estado de desbloqueo/completitud de los niveles
/// definidos en `activity1Levels` y notifica a los oyentes sobre cambios.
/// Utiliza el patrón Singleton para asegurar una única instancia.
/// {@endtemplate}
class Activity1GameState extends ChangeNotifier {
  // Instancia Singleton
  static final Activity1GameState _instance = Activity1GameState._internal();
  
  /// Fábrica para acceder a la instancia Singleton.
  factory Activity1GameState() => _instance;
  
  /// Constructor interno privado para el Singleton.
  /// Inicializa el primer nivel como desbloqueado.
  Activity1GameState._internal() {
    // Asegurarse que la lista de niveles no esté vacía antes de accederla.
    if (activity1Levels.isNotEmpty) {
      activity1Levels[0].unlockLevel(); // Usar el método del modelo
    }
  }

  /// Mapa que almacena la puntuación obtenida para cada nivel (ID de nivel -> puntuación).
  final Map<int, int> _levelScores = {};
  /// Puntuación máxima que se puede obtener por completar un nivel.
  static const int maxLevelScore = 5;

  /// Obtiene la puntuación registrada para un nivel específico.
  ///
  /// [levelId] El ID del nivel.
  /// Retorna la puntuación o 0 si no se ha registrado puntuación para ese nivel.
  int getLevelScore(int levelId) => _levelScores[levelId] ?? 0;

  /// Verifica si un nivel específico está desbloqueado o completado.
  ///
  /// [levelId] El ID del nivel a verificar.
  /// Retorna `true` si el nivel existe y su estado es [LevelStatus.unlocked]
  /// o [LevelStatus.completed], `false` en caso contrario.
  bool isLevelUnlocked(int levelId) {
    try {
      // Busca el nivel por ID en la lista `activity1Levels`.
      final level = activity1Levels.firstWhere((l) => l.id == levelId);
      return level.status == LevelStatus.unlocked || level.status == LevelStatus.completed;
    } catch (e) {
      // Si firstWhere no encuentra el nivel, lanza una excepción.
      debugPrint('Error buscando nivel $levelId en isLevelUnlocked: $e');
      return false;
    }
  }

  /// Marca un nivel como completado, asigna la puntuación máxima si no se había hecho,
  /// y desbloquea el siguiente nivel si existe.
  ///
  /// [currentLevelId] El ID del nivel que se acaba de completar.
  void unlockNextLevel(int currentLevelId) {
    try {
      // Marcar el nivel actual como completado en el modelo.
      final currentLevel = activity1Levels.firstWhere((l) => l.id == currentLevelId);
      currentLevel.completeLevel(); // Actualiza el estado en LevelModel

      // Asignar puntuación solo si no se había asignado antes para este nivel.
      if (!_levelScores.containsKey(currentLevelId)) {
        _levelScores[currentLevelId] = maxLevelScore;
      }

      // Buscar el índice del nivel actual para encontrar el siguiente.
      final currentIndex = activity1Levels.indexWhere((l) => l.id == currentLevelId);
      // Si el nivel actual existe y no es el último de la lista...
      if (currentIndex >= 0 && currentIndex < activity1Levels.length - 1) {
        // ...desbloquear el siguiente nivel.
        activity1Levels[currentIndex + 1].unlockLevel();
      }

      notifyListeners(); // Notificar a los oyentes sobre los cambios.
    } catch (e) {
      // Captura errores si firstWhere o indexWhere fallan.
      debugPrint('Error en unlockNextLevel para nivel $currentLevelId: $e');
    }
  }

  /// Calcula y retorna la puntuación total acumulada en la Actividad 1.
  int get totalScore => _levelScores.values.fold(0, (sum, score) => sum + score);

  /// Verifica si un nivel específico ha sido completado.
  ///
  /// [levelId] El ID del nivel a verificar.
  /// Retorna `true` si el nivel existe y su estado es [LevelStatus.completed],
  /// `false` en caso contrario.
  bool isLevelCompleted(int levelId) {
    try {
      final level = activity1Levels.firstWhere((l) => l.id == levelId);
      return level.isCompleted; // Usa el getter del modelo
    } catch (e) {
      debugPrint('Error buscando nivel $levelId en isLevelCompleted: $e');
      return false;
    }
  }
}
