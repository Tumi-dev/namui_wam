import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:namuiwam/core/models/level_model.dart';
import 'package:namuiwam/core/services/logger_service.dart';

/// Servicio para gestionar la lógica y los datos de la Actividad 3: "Nɵsik utɵwan asam kusrekun".
///
/// Proporciona métodos para:
/// - Cargar los datos específicos de cada nivel (1, 2 y 3).
/// - Validar las respuestas del usuario (emparejamiento en Nivel 1, ajuste de hora en Nivel 3).
///
/// Utiliza datos cargados desde `assets/data/namtrik_hours.json`.
class Activity3Service {
  /// Constructor constante para [Activity3Service].
  const Activity3Service();
  /// Instancia del servicio de logging para registrar errores.
  static final LoggerService _logger = LoggerService();

  /// Obtiene los datos específicos para un nivel dado de la Actividad 3.
  ///
  /// Llama a los métodos privados correspondientes (`_getLevel1Data`, `_getLevel2Data`, `_getLevel3Data`)
  /// según el [level.id].
  ///
  /// Devuelve un [Future] que resuelve a un [Map<String, dynamic>] con los datos del nivel.
  /// Lanza una excepción si ocurre un error durante la carga.
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

  /// Carga y prepara los datos para el Nivel 1 (Emparejamiento).
  ///
  /// - Lee `assets/data/namtrik_hours.json`.
  /// - Selecciona 4 elementos de hora aleatorios sin repetición.
  /// - Devuelve un [Map] con la lista de 'items' seleccionados, cada uno con 'id',
  ///   'clock_image' y 'hour_namtrik'.
  /// - Lanza una excepción si no hay suficientes datos o si ocurre un error.
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
            'id': hours[index]['numbers'].toString(), // Usar 'numbers' como ID único
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

  /// Carga y prepara los datos para el Nivel 2 (Selección Múltiple).
  ///
  /// - Lee `assets/data/namtrik_hours.json`.
  /// - Selecciona una hora aleatoria como respuesta correcta.
  /// - Selecciona 3 horas aleatorias incorrectas distintas.
  /// - Devuelve un [Map] con:
  ///   - 'clock_image': La imagen del reloj de la hora correcta.
  ///   - 'correct_id': El ID de la hora correcta.
  ///   - 'correct_hour': El texto Namtrik de la hora correcta.
  ///   - 'options': Una lista desordenada de 4 opciones (1 correcta, 3 incorrectas),
  ///     cada una con 'id', 'hour_namtrik' y 'is_correct'.
  /// - Lanza una excepción si no hay suficientes datos o si ocurre un error.
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

  /// Carga y prepara los datos para el Nivel 3 (Ajustar Hora).
  ///
  /// - Lee `assets/data/namtrik_hours.json`.
  /// - Selecciona una hora aleatoria.
  /// - Extrae la hora y el minuto correctos del nombre del archivo de imagen del reloj
  ///   (ej: "clock_01_30.png" -> hora=1, minuto=30).
  /// - Devuelve un [Map] con:
  ///   - 'hour_namtrik': El texto Namtrik de la hora objetivo.
  ///   - 'clock_image': La imagen del reloj (puede usarse como referencia).
  ///   - 'correct_hour': La hora correcta (0-11).
  ///   - 'correct_minute': El minuto correcto (0-59).
  ///   - 'item_id': El ID del elemento seleccionado.
  /// - Lanza una excepción si no hay suficientes datos o si ocurre un error.
  Future<Map<String, dynamic>> _getLevel3Data() async {
    try {
      // Cargar datos del archivo JSON
      final String jsonString =
          await rootBundle.loadString('assets/data/namtrik_hours.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      // Obtener la lista de horas
      final List<dynamic> hours = jsonData['hours']['namui_wam'];

      // Asegurarse de que tenemos suficientes elementos
      if (hours.isEmpty) { // Solo necesitamos 1 elemento para este nivel
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

      // Validar el formato del nombre del archivo
      if (clockParts.length != 3 || clockParts[0] != 'clock') {
         throw FormatException('Formato de nombre de archivo de reloj inesperado: $clockImage');
      }

      final int hour = int.parse(clockParts[1]);
      final int minute = int.parse(clockParts[2]);

      // Validar rangos de hora y minuto
      if (hour < 0 || hour > 11 || minute < 0 || minute > 59) {
        throw FormatException('Hora o minuto fuera de rango en $clockImage');
      }

      return {
        'levelId': 3,
        'description': 'Nivel 3',
        'hour_namtrik': selectedItem['hours_namtrik'],
        'clock_image': selectedItem['clocks_images'],
        'correct_hour': hour, // Hora 0-11
        'correct_minute': minute, // Minuto 0-59
        'item_id': selectedItem['numbers'].toString(),
      };
    } catch (e, stackTrace) {
      _logger.error('Error al cargar datos del nivel 3', e, stackTrace);
      throw Exception('Error al cargar datos del nivel 3: $e');
    }
  }

  /// Verifica si el ID del reloj y el ID del texto Namtrik coinciden (Nivel 1).
  ///
  /// Devuelve `true` si [clockId] es igual a [namtrikId], `false` en caso contrario.
  /// Asume que los IDs corresponden al mismo elemento si son iguales.
  bool isMatchCorrect(String clockId, String namtrikId) {
    // La lógica asume que si los IDs son iguales, la pareja es correcta.
    // Esto depende de cómo se generaron los IDs en _getLevel1Data.
    return clockId == namtrikId;
  }

  /// Verifica si la hora y minuto seleccionados coinciden con la hora y minuto correctos (Nivel 3).
  ///
  /// Devuelve `true` si [hour] es igual a [correctHour] Y [minute] es igual a [correctMinute].
  /// Devuelve `false` en caso contrario.
  bool isTimeCorrect(int hour, int minute, int correctHour, int correctMinute) {
    // Compara la hora (0-11) y el minuto (0-59) seleccionados con los correctos.
    return hour == correctHour && minute == correctMinute;
  }
}
