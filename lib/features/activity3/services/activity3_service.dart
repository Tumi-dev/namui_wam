import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:namuiwam/core/models/level_model.dart';
import 'package:namuiwam/core/services/logger_service.dart';

/// {@template activity3_service}
/// Servicio que centraliza la lógica y datos para la Actividad 3: "Nөsik utөwan asam kusrekun" 
/// (Aprendamos a ver la hora).
///
/// Especializado en la gestión de tres modalidades diferentes de juego:
/// - Nivel 1: Emparejar relojes con sus descripciones en Namtrik
/// - Nivel 2: Seleccionar la descripción correcta para un reloj dado
/// - Nivel 3: Ajustar un reloj para que coincida con una descripción en Namtrik
///
/// Gestiona la carga y transformación de datos desde el archivo JSON, 
/// seleccionando y formateando elementos apropiados para cada nivel.
/// También proporciona métodos para validar las respuestas del usuario.
///
/// Ejemplo de uso:
/// ```dart
/// final activity3Service = GetIt.instance<Activity3Service>();
///
/// // Obtener datos para el nivel de emparejamiento
/// final levelData = await activity3Service.getLevelData(levelModel);
/// final items = levelData['items'] as List<Map<String, dynamic>>;
///
/// // Los datos incluyen información como ID, imagen del reloj y texto en Namtrik
/// for (final item in items) {
///   print('ID: ${item['id']}, Hora en Namtrik: ${item['hour_namtrik']}');
/// }
/// ```
/// {@endtemplate}
class Activity3Service {
  /// {@macro activity3_service}
  const Activity3Service();
  
  /// Instancia del servicio de logging para registrar errores.
  ///
  /// Utilizado para capturar y documentar problemas durante:
  /// - La carga de archivos JSON
  /// - El procesamiento de datos
  /// - La generación de contenido para los niveles
  static final LoggerService _logger = LoggerService();

  /// Obtiene los datos configurados para un nivel específico de la Actividad 3.
  ///
  /// Este método de entrada determina qué tipo de datos necesita preparar según el nivel:
  /// - Para el Nivel 1 (Emparejar): Genera pares de relojes y descripciones a emparejar
  /// - Para el Nivel 2 (Adivinar): Prepara un reloj y opciones de texto para selección
  /// - Para el Nivel 3 (Ajustar): Configura una descripción y la hora/minuto correctos
  ///
  /// Para otros niveles futuros, retorna datos básicos de identificación.
  ///
  /// Ejemplo:
  /// ```dart
  /// final levelData = await service.getLevelData(LevelModel(id: 1, ...));
  /// final items = levelData['items'];
  /// // Trabajar con los items...
  /// ```
  ///
  /// [level] El modelo de nivel que contiene el ID y la descripción.
  /// Retorna un mapa con los datos específicos para el nivel, cuya estructura
  /// depende del ID del nivel.
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

  /// Prepara los datos para el Nivel 1: Utөwan lata marөp (Emparejar la hora).
  ///
  /// Este método:
  /// 1. Carga el archivo JSON con datos de horas en Namtrik
  /// 2. Selecciona aleatoriamente 4 elementos distintos del conjunto
  /// 3. Formatea los datos para incluir ID, imagen del reloj y texto en Namtrik
  ///
  /// El resultado es un mapa con:
  /// - 'levelId': ID del nivel (1)
  /// - 'description': Descripción del nivel
  /// - 'items': Lista de 4 elementos, cada uno con:
  ///   - 'id': Identificador único (valor numérico de la hora)
  ///   - 'clock_image': Ruta a la imagen del reloj
  ///   - 'hour_namtrik': Texto en Namtrik que describe la hora
  ///
  /// La pantalla del nivel utilizará estos datos para crear dos grupos
  /// (relojes y textos) que el usuario deberá emparejar correctamente.
  ///
  /// Ejemplo de elemento en 'items':
  /// ```json
  /// {
  ///   "id": "1:30",
  ///   "clock_image": "assets/images/clocks/clock_01_30.png",
  ///   "hour_namtrik": "pik unan oraisku tsik yam"
  /// }
  /// ```
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

  /// Prepara los datos para el Nivel 2: Utөwan wetөpeñ (Adivina la hora).
  ///
  /// Este método:
  /// 1. Carga el archivo JSON con datos de horas en Namtrik
  /// 2. Selecciona aleatoriamente una hora como respuesta correcta
  /// 3. Selecciona otras 3 horas diferentes como opciones incorrectas
  /// 4. Mezcla las 4 opciones para no revelar la posición de la respuesta correcta
  ///
  /// El resultado es un mapa con:
  /// - 'levelId': ID del nivel (2)
  /// - 'description': Descripción del nivel
  /// - 'clock_image': Ruta a la imagen del reloj de la hora correcta
  /// - 'correct_id': ID único de la respuesta correcta
  /// - 'correct_hour': Texto en Namtrik de la respuesta correcta
  /// - 'options': Lista de 4 opciones (1 correcta, 3 incorrectas), cada una con:
  ///   - 'id': Identificador único
  ///   - 'hour_namtrik': Texto en Namtrik
  ///   - 'is_correct': Booleano que indica si es la respuesta correcta
  ///
  /// La pantalla utiliza estos datos para mostrar un reloj y 4 opciones
  /// textuales entre las que el usuario debe seleccionar la correcta.
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

  /// Prepara los datos para el Nivel 3: Utөwan malsrө (Coloca la hora).
  ///
  /// Este método:
  /// 1. Carga el archivo JSON con datos de horas en Namtrik
  /// 2. Selecciona aleatoriamente una hora del conjunto
  /// 3. Extrae la hora y los minutos de la imagen del reloj (ej: "clock_08_15.png" → 8:15)
  /// 4. Prepara los datos para que el usuario pueda ajustar un reloj a esa hora
  ///
  /// El resultado es un mapa con:
  /// - 'levelId': ID del nivel (3)
  /// - 'description': Descripción del nivel
  /// - 'hour_namtrik': Texto en Namtrik que describe la hora objetivo
  /// - 'clock_image': Ruta a la imagen del reloj (como referencia o ayuda visual)
  /// - 'correct_hour': Valor de la hora correcta (0-11)
  /// - 'correct_minute': Valor del minuto correcto (0-59)
  /// - 'item_id': ID único del elemento seleccionado
  ///
  /// La pantalla usa estos datos para mostrar el texto Namtrik y permitir
  /// al usuario ajustar los selectores de hora y minuto hasta que coincidan
  /// con la hora descrita.
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

      // Extraer hora y minuto de la ruta de la imagen del reloj
      // Por ejemplo, de "clock_08_15.png" extraemos hora=8, minuto=15
      int correctHour = 0;
      int correctMinute = 0;

      try {
        final String clockImagePath = selectedItem['clocks_images'];
        // Usamos regex para extraer la hora y minuto de patrones como "clock_08_15.png"
        final RegExp clockRegex = RegExp(r'clock_(\d+)_(\d+)');
        final match = clockRegex.firstMatch(clockImagePath);
        
        if (match != null && match.groupCount >= 2) {
          correctHour = int.parse(match.group(1)!);
          correctMinute = int.parse(match.group(2)!);
        }
      } catch (e) {
        _logger.warning('Error al extraer hora y minuto de la imagen: $e');
        // En caso de error, usar valores predeterminados
        correctHour = 12;
        correctMinute = 0;
      }

      return {
        'levelId': 3,
        'description': 'Nivel 3',
        'hour_namtrik': selectedItem['hours_namtrik'],
        'clock_image': selectedItem['clocks_images'],
        'correct_hour': correctHour,
        'correct_minute': correctMinute,
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
