import 'package:flutter/foundation.dart';
import 'package:namui_wam/core/models/level_model.dart';
import 'package:namui_wam/features/activity1/data/activity1_levels.dart';

class Activity1GameState extends ChangeNotifier {
  static final Activity1GameState _instance = Activity1GameState._internal();
  
  factory Activity1GameState() => _instance;
  
  Activity1GameState._internal() {
    // Inicializar el primer nivel como desbloqueado
    activity1Levels[0].status = LevelStatus.unlocked;
  }

  final Map<int, int> _levelScores = {};
  static const int maxLevelScore = 5;

  // Obtener la puntuación de un nivel específico
  int getLevelScore(int levelId) => _levelScores[levelId] ?? 0;

  // Verificar si un nivel está desbloqueado
  bool isLevelUnlocked(int levelId) {
    if (levelId < 1 || levelId > activity1Levels.length) return false;
    final level = activity1Levels.firstWhere(
      (l) => l.id == levelId,
      orElse: () => activity1Levels[0],
    );
    return level.status == LevelStatus.unlocked || level.status == LevelStatus.completed;
  }

  // Desbloquear el siguiente nivel y asignar puntuación
  void unlockNextLevel(int currentLevelId) {
    try {
      // Marcar el nivel actual como completado
      final currentLevel = activity1Levels.firstWhere((l) => l.id == currentLevelId);
      currentLevel.completeLevel();

      // Solo asignar puntuación si aún no se ha obtenido
      if (!_levelScores.containsKey(currentLevelId)) {
        _levelScores[currentLevelId] = maxLevelScore;
      }

      // Buscar y desbloquear el siguiente nivel
      final currentIndex = activity1Levels.indexWhere((l) => l.id == currentLevelId);
      if (currentIndex >= 0 && currentIndex < activity1Levels.length - 1) {
        activity1Levels[currentIndex + 1].unlockLevel();
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error al desbloquear el siguiente nivel: $e');
    }
  }

  // Obtener la puntuación total de la actividad 1
  int get totalScore => _levelScores.values.fold(0, (sum, score) => sum + score);

  // Verificar si un nivel ya ha sido completado
  bool isLevelCompleted(int levelId) {
    try {
      final level = activity1Levels.firstWhere((l) => l.id == levelId);
      return level.status == LevelStatus.completed;
    } catch (e) {
      debugPrint('Error al verificar el estado del nivel: $e');
      return false;
    }
  }
}
