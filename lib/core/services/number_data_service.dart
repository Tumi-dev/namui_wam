import 'dart:convert';
import 'dart:math'; // Import dart:math for Random
import 'package:flutter/services.dart';
import 'package:namuiwam/core/di/service_locator.dart'; // Assuming LoggerService is registered
import 'package:namuiwam/core/services/logger_service.dart';

/// {@template number_data_service}
/// Servicio especializado en cargar y acceder a los datos numéricos del idioma Namtrik.
///
/// Este servicio es fundamental para las actividades educativas relacionadas con números,
/// ya que proporciona acceso a los datos numéricos cargados desde el archivo JSON:
/// `assets/data/namuiwam_numbers.json`.
///
/// Características principales:
/// - Carga datos numéricos desde un archivo JSON local
/// - Proporciona métodos para acceder a números por valor o rango
/// - Permite obtener números aleatorios dentro de un rango específico
/// - Implementa inicialización bajo demanda para optimizar recursos
///
/// La estructura del JSON esperado es:
/// ```json
/// {
///   "numbers": {
///     "namui_wam": [
///       { "number": "1", "namtrik": "kan", "audio": "audio/path.mp3", ... },
///       { "number": "2", "namtrik": "pa", "audio": "audio/path.mp3", ... },
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
      // Asegurarse de que la estructura esperada existe
      if (_numbersData == null || !_numbersData!.containsKey('numbers') || !(_numbersData!['numbers'] is Map) || !_numbersData!['numbers'].containsKey('namui_wam') || !(_numbersData!['numbers']['namui_wam'] is List)) {
        throw Exception('Estructura JSON inválida en $_basePath');
      }

      final List<dynamic> namuiWamNumbers = _numbersData!['numbers']['namui_wam'];
      
      _allNumbers = namuiWamNumbers.map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item)).toList();
      _isInitialized = true;
      _logger.info('NumberDataService inicializado correctamente con ${_allNumbers.length} números');
    } catch (e, stackTrace) {
      _logger.error('Error cargando datos de números desde $_basePath', e, stackTrace);
      _isInitialized = false; // Marcar como no inicializado en caso de error
      // Relanzar para que el llamador sepa que la inicialización falló
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
  ///   "number": "5",        // Valor numérico (como string)
  ///   "namtrik": "tratrik", // Nombre en idioma Namtrik
  ///   "audio": "audio/namtrik_numbers/tratrik.mp3", // Ruta del audio
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
      await initialize(); // Asegura la inicialización
    }
    
    return _allNumbers.where((number) {
      // Manejo robusto de posibles valores no numéricos
      final numValue = num.tryParse(number['number']?.toString() ?? '');
      return numValue != null && numValue >= start && numValue <= end;
    }).toList();
  }

  /// Busca y devuelve un número específico basado en su valor.
  ///
  /// Localiza un número que coincida exactamente con el valor [number].
  /// Si el servicio no está inicializado, lo inicializa automáticamente.
  ///
  /// El resultado es un mapa con datos del número en Namtrik, que puede incluir:
  /// - `number`: El valor numérico (como string)
  /// - `namtrik`: La palabra en idioma Namtrik
  /// - `audio`: Ruta al archivo de audio con la pronunciación
  /// - Otras propiedades según el JSON de origen
  ///
  /// Ejemplo:
  /// ```dart
  /// // Buscar el número 5
  /// final numberFive = await numberService.getNumberByValue(5);
  /// if (numberFive != null) {
  ///   print('El número 5 en Namtrik es: ${numberFive["namtrik"]}');
  ///   print('Audio: ${numberFive["audio"]}');
  /// } else {
  ///   print('Número 5 no encontrado');
  /// }
  /// ```
  ///
  /// [number] El valor numérico a buscar.
  ///
  /// Retorna el mapa con los datos del número si se encuentra, o `null` si no existe
  /// o si ocurre un error durante la búsqueda.
  Future<Map<String, dynamic>?> getNumberByValue(int number) async {
    if (!_isInitialized) {
       _logger.warning('NumberDataService no inicializado. Llamando a initialize()...');
      await initialize();
    }
    
    try {
      // Usar firstWhereOrNull para evitar excepciones si no se encuentra
      final result = _allNumbers.firstWhere(
        (item) => int.tryParse(item['number']?.toString() ?? '') == number,
      );
      return result; // Retorna el mapa encontrado o null si no hay coincidencia
    } catch (e) {
      // Aunque firstWhereOrNull previene el StateError, capturamos otros posibles errores.
      _logger.error('Error buscando el número $number', e);
      return null;
    }
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
