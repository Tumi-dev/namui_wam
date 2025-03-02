import 'package:namui_wam/core/models/level_model.dart';

/// Servicio para la actividad 5 - Aprendamos a contar el dinero
class Activity5Service {
  /// Obtiene los datos para un nivel específico de la actividad 5
  Future<Map<String, dynamic>?> getLevelData(LevelModel level) async {
    // Simulamos una carga asíncrona
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Por ahora, retornamos datos de ejemplo
    // En el futuro, aquí se implementará la lógica específica del juego
    return {
      'levelId': level.id,
      'description': level.description,
      'status': 'in_development',
    };
  }
}
