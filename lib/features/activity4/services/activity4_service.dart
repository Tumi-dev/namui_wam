import 'package:namui_wam/core/models/level_model.dart';

class Activity4Service {
  const Activity4Service();

  // Método para obtener datos específicos para un nivel
  Future<Map<String, dynamic>> getLevelData(LevelModel level) async {
    // Aquí se implementará la lógica específica para cada nivel
    // Por ahora, solo devolvemos un mapa básico
    return {
      'levelId': level.id,
      'description': level.description,
      'status': 'En desarrollo',
    };
  }
}
