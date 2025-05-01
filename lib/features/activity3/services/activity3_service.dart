import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:namuiwam/core/models/level_model.dart';
import 'package:namuiwam/core/services/logger_service.dart';

class Activity3Service {
  const Activity3Service();
  static final LoggerService _logger = LoggerService();

  // Método para obtener datos específicos para un nivel
  Future<Map<String, dynamic>> getLevelData(LevelModel level) async {
    // Aquí se implementará la lógica específica para cada nivel
    if (level.id == 1) {
      return await _getLevel1Data();
    } else if (level.id == 2) {
      return await _getLevel2Data();
    } else if (level.id == 3) {
      return await _getLevel3Data();
    }

    // Para otros niveles, devolvemos un mapa básico
    return {
      'levelId': level.id,
      'description': level.description,
    };
  }

  // Método para obtener datos específicos para el nivel 1
  Future<Map<String, dynamic>> _getLevel1Data() async {
    try {
      // Cargar datos del archivo JSON
      final String jsonString =
          await rootBundle.loadString('assets/data/namtrik_hours.json');
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
    } catch (e, stackTrace) {
      _logger.error('Error al cargar datos del nivel 1', e, stackTrace);
      throw Exception('Error al cargar datos del nivel 1: $e');
    }
  }

  // Método para obtener datos específicos para el nivel 2
  Future<Map<String, dynamic>> _getLevel2Data() async {
    try {
      // Cargar datos del archivo JSON
      final String jsonString =
          await rootBundle.loadString('assets/data/namtrik_hours.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      // Obtener la lista de horas
      final List<dynamic> hours = jsonData['hours']['namui_wam'];

      // Asegurarse de que tenemos suficientes elementos
      if (hours.length < 4) {
        throw Exception('No hay suficientes datos para el juego');
      }

      final random = Random();

      // Seleccionar un elemento aleatorio como respuesta correcta
      final int correctIndex = random.nextInt(hours.length);
      final correctItem = hours[correctIndex];

      // Crear una lista para almacenar las opciones (incluida la correcta)
      final List<Map<String, dynamic>> options = [];
      final Set<int> selectedIndices = {correctIndex};

      // Añadir la respuesta correcta
      options.add({
        'id': correctItem['numbers'].toString(),
        'hour_namtrik': correctItem['hours_namtrik'],
        'is_correct': true,
      });

      // Seleccionar 3 elementos aleatorios incorrectos
      while (selectedIndices.length < 4) {
        final int index = random.nextInt(hours.length);
        if (!selectedIndices.contains(index)) {
          selectedIndices.add(index);
          options.add({
            'id': hours[index]['numbers'].toString(),
            'hour_namtrik': hours[index]['hours_namtrik'],
            'is_correct': false,
          });
        }
      }

      // Desordenar las opciones para que no siempre la correcta sea la primera
      options.shuffle();

      return {
        'levelId': 2,
        'description': 'Nivel 2',
        'clock_image': correctItem['clocks_images'],
        'correct_id': correctItem['numbers'].toString(),
        'correct_hour': correctItem['hours_namtrik'],
        'options': options,
      };
    } catch (e, stackTrace) {
      _logger.error('Error al cargar datos del nivel 2', e, stackTrace);
      throw Exception('Error al cargar datos del nivel 2: $e');
    }
  }

  // Método para obtener datos específicos para el nivel 3
  Future<Map<String, dynamic>> _getLevel3Data() async {
    try {
      // Cargar datos del archivo JSON
      final String jsonString =
          await rootBundle.loadString('assets/data/namtrik_hours.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      // Obtener la lista de horas
      final List<dynamic> hours = jsonData['hours']['namui_wam'];

      // Asegurarse de que tenemos suficientes elementos
      if (hours.length < 4) {
        throw Exception('No hay suficientes datos para el juego');
      }

      final random = Random();

      // Seleccionar un elemento aleatorio para mostrar
      final int selectedIndex = random.nextInt(hours.length);
      final selectedItem = hours[selectedIndex];

      // Extraer la información de la hora del nombre del archivo de imagen
      // Por ejemplo, "clock_01_30.png" representa 1:30
      final String clockImage = selectedItem['clocks_images'];
      final List<String> clockParts =
          clockImage.replaceAll('.png', '').split('_');
      final int hour = int.parse(clockParts[1]);
      final int minute = int.parse(clockParts[2]);

      return {
        'levelId': 3,
        'description': 'Nivel 3',
        'hour_namtrik': selectedItem['hours_namtrik'],
        'clock_image': selectedItem['clocks_images'],
        'correct_hour': hour,
        'correct_minute': minute,
        'item_id': selectedItem['numbers'].toString(),
      };
    } catch (e, stackTrace) {
      _logger.error('Error al cargar datos del nivel 3', e, stackTrace);
      throw Exception('Error al cargar datos del nivel 3: $e');
    }
  }

  // Método para verificar si una combinación es correcta
  bool isMatchCorrect(String clockId, String namtrikId) {
    return clockId == namtrikId;
  }

  // Método para verificar si la hora seleccionada es correcta para el nivel 3
  bool isTimeCorrect(int hour, int minute, int correctHour, int correctMinute) {
    return hour == correctHour && minute == correctMinute;
  }
}
