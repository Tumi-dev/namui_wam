import 'dart:convert';
import 'dart:math'; // Import dart:math for Random
import 'package:flutter/services.dart';
import 'package:namuiwam/core/di/service_locator.dart'; // Assuming LoggerService is registered
import 'package:namuiwam/core/services/logger_service.dart';

/// {@template number_data_service}
/// Servicio especializado en cargar y acceder a los datos numéricos del idioma Namtrik.
///
/// Este servicio es fundamental para las actividades educativas relacionadas con números,
/// ya que proporciona acceso a los datos numéricos cargados desde el archivo JSON
/// (`assets/data/namuiwam_numbers.json`) y capacidad de composición dinámica.
///
/// Características principales:
/// - Carga datos numéricos desde un archivo JSON local.
/// - Proporciona métodos para acceder a números por valor o rango.
/// - Permite obtener números aleatorios dentro de un rango específico.
/// - Implementa inicialización bajo demanda para optimizar recursos.
/// - **Soporta la composición dinámica de números de 7 dígitos (1,000,001 - 9,999,999)**
///   que no son múltiplos exactos de un millón, combinando datos existentes.
///
/// La estructura del JSON esperado es:
/// ```json
/// {
///   "numbers": {
///     "namui_wam": [
///       { "number": 1, "namtrik": "kan", "audio_files": "kan.wav", ... },
///       ...
///     ]
///   }
/// }
/// ```
///
/// Este servicio es utilizado principalmente por:
/// - Actividad 1 (Escoja el número correcto)
/// - Actividad 2 (Aprendamos a escribir los números)
/// - Actividad 5 (Convertir números en letras)
/// {@endtemplate}
class NumberDataService {
  static const String _basePath = 'assets/data/namuiwam_numbers.json';
  final LoggerService _logger = getIt<LoggerService>();

  Map<String, dynamic>? _numbersData;
  List<Map<String, dynamic>> _allNumbers = [];
  bool _isInitialized = false;
  final Random _random = Random(); // Instance of Random

  /// Indica si el servicio ha sido inicializado correctamente.
  ///
  /// Puede utilizarse para verificar si los datos están listos antes
  /// de intentar acceder a ellos, evitando inicializaciones innecesarias.
  ///
  /// Ejemplo:
  /// ```dart
  /// if (!numberDataService.isInitialized) {
  ///   await numberDataService.initialize();
  /// }
  /// ```
  bool get isInitialized => _isInitialized;

  /// Inicializa el servicio cargando los datos de los números desde el archivo JSON.
  ///
  /// Este método realiza las siguientes operaciones:
  /// 1. Verifica si el servicio ya está inicializado para evitar cargas duplicadas
  /// 2. Carga el contenido del archivo JSON desde los assets
  /// 3. Parsea el JSON y valida su estructura
  /// 4. Extrae la lista de números y la almacena en memoria
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// final numberService = getIt<NumberDataService>();
  /// try {
  ///   await numberService.initialize();
  ///   print('Datos numéricos cargados correctamente');
  /// } catch (e) {
  ///   print('Error al cargar datos: $e');
  /// }
  /// ```
  ///
  /// Lanza una [Exception] si ocurre algún error durante la carga o si el archivo
  /// tiene un formato incorrecto. Los errores específicos incluyen:
  /// - Archivo vacío
  /// - Estructura JSON inválida
  /// - Falta de claves esperadas en el JSON
  Future<void> initialize() async {
    if (_isInitialized) {
      _logger.info('NumberDataService ya está inicializado.');
      return;
    }
    try {
      _logger.info('Inicializando NumberDataService...');
      final String jsonString = await rootBundle.loadString(_basePath);
      if (jsonString.isEmpty) {
        throw Exception('El archivo de números está vacío: $_basePath');
      }
      
      _numbersData = json.decode(jsonString);
      if (_numbersData == null || !_numbersData!.containsKey('numbers') || !(_numbersData!['numbers'] is Map) || !_numbersData!['numbers'].containsKey('namui_wam') || !(_numbersData!['numbers']['namui_wam'] is List)) {
        throw Exception('Estructura JSON inválida en $_basePath');
      }

      final List<dynamic> namuiWamNumbers = _numbersData!['numbers']['namui_wam'];
      
      // Ensure numbers are correctly typed, especially the 'number' field to be int.
      _allNumbers = namuiWamNumbers.map<Map<String, dynamic>>((item) {
        final Map<String, dynamic> mappedItem = Map<String, dynamic>.from(item);
        if (mappedItem.containsKey('number') && mappedItem['number'] is String) {
          mappedItem['number'] = int.tryParse(mappedItem['number'] as String) ?? mappedItem['number'];
        } else if (mappedItem.containsKey('number') && mappedItem['number'] is num) {
          // Ensure it's an int if it's a num (like double 1.0 from json)
           mappedItem['number'] = (mappedItem['number'] as num).toInt();
        }
        return mappedItem;
      }).toList();

      _isInitialized = true;
      _logger.info('NumberDataService inicializado correctamente con ${_allNumbers.length} números');
    } catch (e, stackTrace) {
      _logger.error('Error cargando datos de números desde $_basePath', e, stackTrace);
      _isInitialized = false;
      throw Exception('Fallo al inicializar NumberDataService: $e');
    }
  }

  /// Obtiene una lista de números cuyos valores están dentro del rango especificado `[start, end]`.
  ///
  /// Este método retorna todos los números que tienen un valor numérico
  /// entre [start] y [end], ambos inclusive. Si el servicio no está inicializado,
  /// lo inicializa automáticamente.
  ///
  /// Los elementos retornados son mapas con la estructura:
  /// ```dart
  /// {
  ///   "number": 5,        // Valor numérico (como int)
  ///   "namtrik": "Trattrø", // Nombre en idioma Namtrik
  ///   "audio_files": "trattrø.wav", // Ruta del audio (nombre cambiado desde "audio")
  ///   // Otras propiedades posibles...
  /// }
  /// ```
  ///
  /// Ejemplo:
  /// ```dart
  /// // Obtener números del 1 al 10
  /// final numbers = await numberService.getNumbersInRange(1, 10);
  /// for (final number in numbers) {
  ///   print('${number["number"]} en Namtrik: ${number["namtrik"]}');
  /// }
  /// ```
  ///
  /// [start] El valor inicial del rango (inclusivo).
  /// [end] El valor final del rango (inclusivo).
  ///
  /// Retorna una lista vacía si no se encuentran números en el rango especificado
  /// o si ocurre un error durante la inicialización.
  Future<List<Map<String, dynamic>>> getNumbersInRange(int start, int end) async {
    if (!_isInitialized) {
      _logger.warning('NumberDataService no inicializado. Llamando a initialize()...');
      await initialize(); 
    }
    
    return _allNumbers.where((number) {
      final numValue = number['number']; // Should be int after improved initialization
      return numValue is int && numValue >= start && numValue <= end;
    }).toList();
  }

  // Helper function for direct lookup in _allNumbers
  Map<String, dynamic>? _findInMemory(int valueToFind) {
    for (var item in _allNumbers) {
      final numFromJson = item['number'];
      // Ensure 'number' is an int before comparison
      if (numFromJson is int && numFromJson == valueToFind) {
        return item;
      }
    }
    return null;
  }

  /// Busca y devuelve un número específico basado en su valor.
  ///
  /// Primero, intenta una búsqueda directa en los datos cargados desde el JSON.
  /// Si no se encuentra y el `numberValue` está en el rango de 1,000,001 a 9,999,999
  /// (y no es un millón exacto), intenta construirlo dinámicamente.
  /// La composición se realiza combinando los datos del millón base (ej., 2,000,000)
  /// con los datos del residuo (ej., 500,623 para formar 2,500,623).
  ///
  /// Si el servicio no está inicializado, lo inicializa automáticamente.
  ///
  /// El resultado es un mapa con datos del número en Namtrik, incluyendo `namtrik`,
  /// `compositions`, `audio_files`, y un flag `is_composed: true` si fue dinámico.
  ///
  /// [numberValue] El valor numérico (entero) a buscar.
  ///
  /// Retorna el mapa con los datos del número si se encuentra o se compone,
  /// o `null` si no existe, no se puede componer, o si ocurre un error.
  Future<Map<String, dynamic>?> getNumberByValue(int numberValue) async {
    if (!_isInitialized) {
       _logger.warning('NumberDataService no inicializado. Llamando a initialize()...');
      await initialize();
    }
    
    var result = _findInMemory(numberValue);

    if (result != null) {
      return result;
    }

    // Attempt composition for numbers > 1,000,000 and < 10,000,000,
    // excluding exact millions (which should be found by _findInMemory if they exist).
    if (numberValue > 1000000 && numberValue < 10000000 && numberValue % 1000000 != 0) {
      _logger.info('Number $numberValue not found directly, attempting composition...');
      int millionPartValue = (numberValue ~/ 1000000) * 1000000;
      int remainderPartValue = numberValue % 1000000;

      // Remainder should not be zero here, as exact millions are handled by _findInMemory.
      // If remainderPartValue is 0, it implies an issue or an unexpected case.
      if (remainderPartValue == 0) {
          _logger.warning('Composition attempt for $numberValue resulted in zero remainder. '
                          'This number should have been found directly if it is an exact million.');
          return null; 
      }

      // Recursively call getNumberByValue for components.
      final Map<String, dynamic>? millionData = await getNumberByValue(millionPartValue);
      final Map<String, dynamic>? remainderData = await getNumberByValue(remainderPartValue);

      if (millionData != null && remainderData != null) {
        final millionCompositions = millionData['compositions'] as Map<String, dynamic>? ?? <String, dynamic>{};
        final remainderCompositions = remainderData['compositions'] as Map<String, dynamic>? ?? <String, dynamic>{};

        final String millionNamtrik = millionData['namtrik']?.toString() ?? '';
        final String remainderNamtrik = remainderData['namtrik']?.toString() ?? '';
        
        final String millionCompOne = millionCompositions['one']?.toString() ?? '';
        final String remainderCompOne = remainderCompositions['one']?.toString() ?? '';

        final String millionCompTwo = millionCompositions['two']?.toString() ?? '';
        final String remainderCompTwo = remainderCompositions['two']?.toString() ?? '';

        final String millionAudio = millionData['audio_files']?.toString() ?? '';
        final String remainderAudio = remainderData['audio_files']?.toString() ?? '';

        // Concatenate parts, ensuring a single space and trimming excess.
        // If a part is empty, it won't add extra spaces.
        return {
          'number': numberValue,
          'namtrik': '$millionNamtrik $remainderNamtrik'.trim(),
          'compositions': {
            'one': '$millionCompOne $remainderCompOne'.trim(),
            'two': '$millionCompTwo $remainderCompTwo'.trim(),
          },
          'audio_files': '$millionAudio $remainderAudio'.trim(),
          'is_composed': true // Flag to indicate this data was dynamically composed
        };
      } else {
        _logger.warning('Could not find components for $numberValue: '
                        'millionData ($millionPartValue) is ${millionData == null ? "null" : "found"}, '
                        'remainderData ($remainderPartValue) is ${remainderData == null ? "null" : "found"}.');
        return null;
      }
    }
    _logger.info('Number $numberValue not found by direct lookup or composition rules.');
    return null; 
  }

  /// Obtiene un número aleatorio dentro del rango especificado `[start, end]`.
  ///
  /// Este método es útil para generar preguntas o ejercicios con
  /// números aleatorios dentro de un rango controlado. Primero obtiene
  /// todos los números en el rango y luego selecciona uno aleatorio.
  ///
  /// La selección aleatoria se realiza utilizando un generador seguro [Random].
  ///
  /// Ejemplo:
  /// ```dart
  /// // Obtener un número aleatorio entre 1 y 20
  /// final randomNumber = await numberService.getRandomNumberInRange(1, 20);
  /// if (randomNumber != null) {
  ///   print('Número aleatorio: ${randomNumber["number"]}');
  ///   print('En Namtrik: ${randomNumber["namtrik"]}');
  /// } else {
  ///   print('No hay números disponibles en ese rango');
  /// }
  /// ```
  ///
  /// [start] El valor inicial del rango (inclusivo).
  /// [end] El valor final del rango (inclusivo).
  ///
  /// Retorna un mapa con los datos del número aleatorio seleccionado,
  /// o `null` si no hay números en el rango especificado.
  Future<Map<String, dynamic>?> getRandomNumberInRange(int start, int end) async {
    final numbersInRange = await getNumbersInRange(start, end);
    if (numbersInRange.isEmpty) {
      _logger.warning('No se encontraron números en el rango [$start, $end] para seleccionar uno aleatorio.');
      return null;
    }
    
    // Usa la instancia _random para obtener un índice aleatorio seguro
    final randomIndex = _random.nextInt(numbersInRange.length);
    return numbersInRange[randomIndex];
  }
}
