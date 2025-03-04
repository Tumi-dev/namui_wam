import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:namui_wam/core/models/level_model.dart';

class Activity4Service {
  const Activity4Service();

  // Método para obtener datos específicos para un nivel
  Future<Map<String, dynamic>> getLevelData(LevelModel level) async {
    // Aquí se implementará la lógica específica para cada nivel
    if (level.id == 1) {
      return await _getLevel1Data();
    }
    
    // Para otros niveles, devolvemos un mapa básico
    return {
      'levelId': level.id,
      'description': level.description,
      'status': 'En desarrollo',
    };
  }

  // Método para obtener datos específicos para el nivel 1
  Future<Map<String, dynamic>> _getLevel1Data() async {
    try {
      // Cargar datos del archivo JSON
      final String jsonString = await rootBundle.loadString('assets/data/namtrik_hours.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      // Obtener la lista de horas
      final List<dynamic> hours = jsonData['hours']['namui_wam'];
      
      // Seleccionar 4 elementos aleatorios
      final random = Random();
      final List<Map<String, dynamic>> selectedItems = [];
      final Set<int> selectedIndices = {};
      
      // Asegurarse de que tenemos suficientes elementos
      if (hours.length < 4) {
        throw Exception('No hay suficientes datos para el juego');
      }
      
      // Seleccionar 4 elementos aleatorios sin repetición
      while (selectedIndices.length < 4) {
        final int index = random.nextInt(hours.length);
        if (!selectedIndices.contains(index)) {
          selectedIndices.add(index);
          selectedItems.add({
            'id': hours[index]['numbers'].toString(),
            'clock_image': hours[index]['clocks_images'],
            'hour_namtrik': hours[index]['hours_namtrik'],
          });
        }
      }
      
      return {
        'levelId': 1,
        'description': 'Nivel 1',
        'items': selectedItems,
      };
    } catch (e) {
      throw Exception('Error al cargar datos del nivel 1: $e');
    }
  }
  
  // Método para verificar si una combinación es correcta
  bool isMatchCorrect(String clockId, String namtrikId) {
    return clockId == namtrikId;
  }
}
