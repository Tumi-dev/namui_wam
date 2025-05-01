import 'dart:convert';
import 'dart:math'; // Import dart:math for Random
import 'package:flutter/services.dart';
import 'package:namuiwam/core/di/service_locator.dart'; // Assuming LoggerService is registered
import 'package:namuiwam/core/services/logger_service.dart';

/// {@template number_data_service}
/// Servicio para cargar y acceder a los datos de los números (Namui Wam)
/// desde un archivo JSON local.
///
/// Proporciona métodos para inicializar los datos, obtener números dentro
/// de un rango específico, buscar un número por su valor y obtener un número
/// aleatorio dentro de un rango.
/// {@endtemplate}
class NumberDataService {
  static const String _basePath = 'assets/data/namtrik_numbers.json';
  final LoggerService _logger = getIt<LoggerService>();

  Map<String, dynamic>? _numbersData;
  List<Map<String, dynamic>> _allNumbers = [];
  bool _isInitialized = false;
  final Random _random = Random(); // Instance of Random

  /// Indica si el servicio ha sido inicializado correctamente.
  bool get isInitialized => _isInitialized;

  /// Inicializa el servicio cargando los datos de los números desde el archivo JSON.
  ///
  /// Lee el archivo definido en [_basePath], decodifica el JSON y extrae la lista
  /// de números 'namui_wam'. Lanza una excepción si la carga falla.
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

  /// Obtiene una lista de números cuyos valores están dentro del rango especificado [start, end].
  ///
  /// Asegura que el servicio esté inicializado antes de realizar la búsqueda.
  /// Retorna una lista vacía si no se encuentran números en el rango.
  ///
  /// [start] El valor inicial del rango (inclusivo).
  /// [end] El valor final del rango (inclusivo).
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
  /// Asegura que el servicio esté inicializado.
  /// Retorna el mapa del número si se encuentra, o `null` si no existe.
  ///
  /// [number] El valor del número a buscar.
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

  /// Obtiene un número aleatorio dentro del rango especificado [start, end].
  ///
  /// Primero obtiene todos los números en el rango y luego selecciona uno
  /// aleatoriamente. Retorna `null` si no hay números en ese rango.
  ///
  /// [start] El valor inicial del rango (inclusivo).
  /// [end] El valor final del rango (inclusivo).
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
