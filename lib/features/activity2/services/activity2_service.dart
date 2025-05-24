import 'dart:math'; // Import Random

import 'package:namuiwam/core/services/number_data_service.dart';
import 'package:namuiwam/core/services/logger_service.dart';

/// {@template activity2_service}
/// Servicio que centraliza la lógica de negocio para la Actividad 2: "Muntsikelan pөram kusrekun" 
/// (Aprendamos a escribir los números).
///
/// Este servicio proporciona funcionalidades esenciales para gestionar:
/// - Obtención de números aleatorios específicos para cada nivel de dificultad,
///   incluyendo soporte completo para el Nivel 7 (1,000,000 a 9,999,999)
///   mediante el uso de `NumberDataService` y su capacidad de composición dinámica.
/// - Definición de los rangos numéricos correspondientes a cada nivel.
/// - Validación inteligente de respuestas escritas con tolerancia a variaciones,
///   que funciona con números base y números compuestos dinámicamente.
///
/// La validación de respuestas es especialmente sofisticada, ya que compara
/// la entrada del usuario con múltiples formas válidas:
/// - La forma principal en Namtrik
/// - Composiciones alternativas (formas descompuestas)
/// - Variaciones dialectales o de escritura
///
/// Ejemplo de uso:
/// ```dart
/// final activity2Service = GetIt.instance<Activity2Service>();
/// 
/// // Obtener un número aleatorio para el nivel 2
/// final numberData = await activity2Service.getRandomNumberForLevel(2);
/// 
/// // Verificar si la respuesta "pik kan" es correcta para el número 42
/// if (numberData != null) {
///   final isCorrect = activity2Service.isAnswerCorrect(numberData, "pik kan");
///   print(isCorrect ? "¡Correcto!" : "Incorrecto, intenta de nuevo");
/// }
/// ```
/// {@endtemplate}
class Activity2Service {
  /// Servicio para acceder a los datos de los números (Namtrik, composiciones, etc.).
  final NumberDataService _numberDataService;
  /// Instancia del servicio de logging para registrar errores.
  final LoggerService _logger = LoggerService();
  /// Instance of Random for generating random numbers.
  final Random _random = Random();

  /// {@macro activity2_service}
  Activity2Service(this._numberDataService);

  /// Obtiene los límites del rango numérico para un nivel específico de la Actividad 2.
  ///
  /// Cada nivel de la actividad cubre un rango específico de números, definido
  /// por esta función. Los niveles siguen una progresión exponencial:
  /// - Nivel 1: Unidades (1-9)
  /// - Nivel 2: Decenas (10-99)
  /// - Nivel 3: Centenas (100-999)
  /// - Nivel 4: Millares (1000-9999)
  /// - Nivel 5: Decenas de millar (10000-99999)
  /// - Nivel 6: Centenas de millar (100000-999999)
  /// - Nivel 7: Millones (1000000-9999999)
  ///
  /// [level] El número de nivel para el cual se desea obtener el rango.
  /// Retorna un [Map] con claves 'start' y 'end' que definen el rango numérico.
  /// Lanza un [ArgumentError] si el nivel está fuera del rango válido (1-7).
  Map<String, int> _getRangeForLevel(int level) {
    int start = 1;
    int end = 9;

    switch (level) {
      case 1:
        start = 1;
        end = 9;
        break;
      case 2:
        start = 10;
        end = 99;
        break;
      case 3:
        start = 100;
        end = 999;
        break;
      case 4:
        start = 1000;
        end = 9999;
        break;
      case 5:
        start = 10000;
        end = 99999;
        break;
      case 6:
        start = 100000;
        end = 999999;
        break;
      case 7:
        start = 1000000;
        end = 9999999;
        break;
      default:
        throw ArgumentError(
            'Invalid level: $level. Level must be between 1 and 7.');
    }

    return {'start': start, 'end': end};
  }

  /// Obtiene los datos de un número aleatorio para un nivel específico.
  ///
  /// Este método realiza la siguiente secuencia de operaciones:
  /// 1. Determina el rango numérico para el nivel especificado
  /// 2. Solicita un número aleatorio dentro de ese rango a [_numberDataService]
  /// 3. Retorna los metadatos completos del número seleccionado
  ///
  /// La estructura de datos retornada contiene:
  /// - 'number': El valor numérico (int)
  /// - 'namtrik': La palabra principal en Namtrik (String)
  /// - 'compositions': Formas alternativas compuestas (Map, opcional)
  /// - 'variations': Variaciones dialectales o de escritura (List, opcional)
  ///
  /// Ejemplo:
  /// ```dart
  /// final numberData = await activity2Service.getRandomNumberForLevel(1);
  /// if (numberData != null) {
  ///   final number = int.parse(numberData['number'].toString());
  ///   final namtrikWord = numberData['namtrik'].toString();
  ///   print('El número $number en Namtrik es: $namtrikWord');
  /// }
  /// ```
  ///
  /// [level] El nivel para el cual obtener un número aleatorio (1-7).
  /// Para el Nivel 7, genera un número aleatorio entre 1,000,000 y 9,999,999 y
  /// obtiene sus datos (potencialmente compuestos) usando `NumberDataService.getNumberByValue`.
  /// Para otros niveles, utiliza `NumberDataService.getRandomNumberInRange`.
  /// Retorna un [Map<String, dynamic>] con los datos del número, o `null` en caso de error.
  Future<Map<String, dynamic>?> getRandomNumberForLevel(int level) async {
    try {
      final range = _getRangeForLevel(level);
      final int min = range['start']!;
      final int max = range['end']!;

      if (level == 7) { 
        // Generate a random integer N between 1,000,000 and 9,999,999 inclusive.
        int randomNumberValue = min + _random.nextInt(max - min + 1);
        
        var numberData = await _numberDataService.getNumberByValue(randomNumberValue);
        
        if (numberData == null) {
            _logger.warning('Could not retrieve data for randomly generated number $randomNumberValue in level 7. Retrying once...');
            // Retry once to handle potential rare case of a non-composable number selected
            randomNumberValue = min + _random.nextInt(max - min + 1);
            numberData = await _numberDataService.getNumberByValue(randomNumberValue);
            if (numberData == null) {
               _logger.error('Failed to get number data for level 7 after retry with $randomNumberValue.');
               // Consider what to do here: throw, return specific error, or null
               return null; 
            }
        }
        return numberData;

      } else { // For levels 1-6, the existing logic is fine
        return await _numberDataService.getRandomNumberInRange(min, max);
      }
    } catch (e, stackTrace) {
      _logger.error(
          'Error getting random number for level $level', e, stackTrace);
      return null;
    }
  }

  /// Obtiene todos los números disponibles para un nivel específico.
  ///
  /// A diferencia de [getRandomNumberForLevel], este método devuelve una lista
  /// con todos los números dentro del rango del nivel especificado. Esto puede
  /// ser útil para:
  /// - Mostrar una lista completa de opciones
  /// - Crear ejercicios personalizados con todos los números de un nivel
  /// - Implementar modos de práctica estructurada
  ///
  /// Ejemplo:
  /// ```dart
  /// final allNumbers = await activity2Service.getNumbersForLevel(1);
  /// print('Hay ${allNumbers.length} números en el nivel 1');
  /// for (final numData in allNumbers) {
  ///   print('${numData['number']} → ${numData['namtrik']}');
  /// }
  /// ```
  ///
  /// [level] El nivel para el cual obtener todos los números (1-7).
  /// Retorna una [List<Map<String, dynamic>>] con los datos de todos los números,
  /// o una lista vacía en caso de error.
  Future<List<Map<String, dynamic>>> getNumbersForLevel(int level) async {
    try {
      final range = _getRangeForLevel(level);
      return await _numberDataService.getNumbersInRange(
          range['start']!, range['end']!);
    } catch (e, stackTrace) {
      _logger.error('Error getting numbers for level $level', e, stackTrace);
      return [];
    }
  }

  /// Verifica si la respuesta escrita por el usuario es correcta para un número.
  ///
  /// Este método implementa una validación inteligente con tolerancia a:
  /// - Diferencias de mayúsculas/minúsculas
  /// - Espacios extra al inicio o final
  /// - Diferentes formas válidas de escribir el mismo número
  ///
  /// El proceso de validación comprueba la coincidencia con:
  /// 1. La palabra principal en Namtrik ('namtrik')
  /// 2. Formas alternativas compuestas ('compositions')
  /// 3. Variaciones dialectales o de escritura ('variations')
  ///
  /// Ejemplo:
  /// ```dart
  /// final numberData = await activity2Service.getRandomNumberForLevel(1);
  /// if (numberData != null) {
  ///   // Podría ser correcto incluso con espacios, mayúsculas o siendo una variación
  ///   final isCorrect = activity2Service.isAnswerCorrect(numberData, "  Kan  ");
  ///   print(isCorrect ? "¡Correcto!" : "Incorrecto");
  /// }
  /// ```
  ///
  /// [number] Mapa con los datos del número a verificar.
  /// [userAnswer] La respuesta ingresada por el usuario.
  /// Retorna `true` si la respuesta coincide con alguna forma válida, `false` en caso contrario.
  bool isAnswerCorrect(Map<String, dynamic> number, String userAnswer) {
    if (number.isEmpty || userAnswer.isEmpty) return false;

    final String normalizedUserAnswer = userAnswer.trim().toLowerCase();

    // Check against namtrik value
    final String namtrikValue = number['namtrik'].toString().toLowerCase();
    if (namtrikValue == normalizedUserAnswer) return true;

    // Check against compositions
    if (_checkCompositions(number, normalizedUserAnswer)) return true;

    // Check against variations if they exist
    if (_checkVariations(number, normalizedUserAnswer)) return true;

    return false;
  }

  /// Verifica si la respuesta coincide con alguna composición alternativa del número.
  ///
  /// Las composiciones son formas alternativas de expresar un número, generalmente
  /// descomponiendo la palabra en sus componentes. Por ejemplo, "cuarenta y dos"
  /// sería una composición de "42" en español.
  ///
  /// Este método busca coincidencias en el campo 'compositions' del [number],
  /// que debe ser un mapa donde los valores son las diferentes composiciones.
  ///
  /// [number] Mapa con los datos del número, incluyendo sus composiciones.
  /// [normalizedUserAnswer] La respuesta normalizada del usuario (minúsculas, sin espacios extra).
  /// Retorna `true` si hay coincidencia con alguna composición, `false` en caso contrario.
  bool _checkCompositions(
      Map<String, dynamic> number, String normalizedUserAnswer) {
    if (!number.containsKey('compositions')) return false;
    final compositionsRaw = number['compositions'];
    if (compositionsRaw is! Map) return false;
    final Map<dynamic, dynamic> compositions = compositionsRaw;
    for (final composition in compositions.values) {
      if (composition.toString().toLowerCase() == normalizedUserAnswer) {
        return true;
      }
    }
    return false;
  }

  /// Verifica si la respuesta coincide con alguna variación del número.
  ///
  /// Las variaciones representan formas alternativas válidas de escribir el mismo
  /// número, que pueden deberse a:
  /// - Diferencias dialectales
  /// - Grafías alternativas 
  /// - Formas abreviadas o expandidas
  ///
  /// Este método busca coincidencias en el campo 'variations' del [number],
  /// que debe ser una lista de cadenas con las diferentes variaciones.
  ///
  /// [number] Mapa con los datos del número, incluyendo sus variaciones.
  /// [normalizedUserAnswer] La respuesta normalizada del usuario (minúsculas, sin espacios extra).
  /// Retorna `true` si hay coincidencia con alguna variación, `false` en caso contrario.
  bool _checkVariations(
      Map<String, dynamic> number, String normalizedUserAnswer) {
    if (!number.containsKey('variations')) return false;
    final variationsRaw = number['variations'];
    if (variationsRaw is! List) return false;
    final List<dynamic> variations = variationsRaw;
    for (final variation in variations) {
      if (variation.toString().toLowerCase() == normalizedUserAnswer) {
        return true;
      }
    }
    return false;
  }
}
