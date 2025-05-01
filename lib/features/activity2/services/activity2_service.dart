import 'package:namuiwam/core/services/number_data_service.dart';
import 'package:namuiwam/core/services/logger_service.dart';

/// Servicio para centralizar la lógica de la Actividad 2: "Escribiendo con Namtrik".
///
/// Gestiona la obtención de números según el nivel y la validación
/// de las respuestas escritas por el usuario, comparándolas con
/// la representación Namtrik principal, sus composiciones y variaciones.
class Activity2Service {
  /// Servicio para acceder a los datos de los números (Namtrik, composiciones, etc.).
  final NumberDataService _numberDataService;
  /// Instancia del servicio de logging para registrar errores.
  final LoggerService _logger = LoggerService();

  /// Constructor de [Activity2Service].
  ///
  /// Requiere una instancia de [NumberDataService].
  Activity2Service(this._numberDataService);

  /// Obtiene los límites del rango numérico para un nivel específico de la Actividad 2.
  ///
  /// Devuelve un [Map] con las claves 'start' y 'end'.
  /// Lanza un [ArgumentError] si el [level] es inválido (fuera de 1-7).
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
  /// Utiliza [_getRangeForLevel] para determinar el rango y luego llama a
  /// [_numberDataService.getRandomNumberInRange] para obtener los datos.
  ///
  /// Devuelve un [Future] que resuelve a un [Map<String, dynamic>] con los datos
  /// del número (incluyendo 'number', 'namtrik', 'compositions', 'variations', etc.),
  /// o `null` si ocurre un error.
  Future<Map<String, dynamic>?> getRandomNumberForLevel(int level) async {
    try {
      final range = _getRangeForLevel(level);
      return await _numberDataService.getRandomNumberInRange(
          range['start']!, range['end']!);
    } catch (e, stackTrace) {
      _logger.error(
          'Error getting random number for level $level', e, stackTrace);
      return null;
    }
  }

  /// Obtiene los datos de todos los números para un nivel específico.
  ///
  /// Utiliza [_getRangeForLevel] para determinar el rango y luego llama a
  /// [_numberDataService.getNumbersInRange].
  ///
  /// Devuelve un [Future] que resuelve a una [List<Map<String, dynamic>>]
  /// con los datos de todos los números en el rango del nivel,
  /// o una lista vacía si ocurre un error.
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

  /// Verifica si la respuesta escrita por el usuario es correcta para un número dado.
  ///
  /// Compara la [userAnswer] (normalizada a minúsculas y sin espacios extra)
  /// con el valor principal 'namtrik', las 'compositions' y las 'variations'
  /// presentes en los datos del [number].
  ///
  /// Devuelve `true` si la respuesta coincide con alguna de las formas válidas,
  /// `false` en caso contrario o si los datos de entrada son inválidos.
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

  /// Verifica si la respuesta del usuario coincide con alguna de las composiciones del número.
  ///
  /// Comprueba que el campo 'compositions' exista en [number], sea un [Map],
  /// y que alguno de sus valores (convertidos a cadena y minúsculas)
  /// sea igual a [normalizedUserAnswer].
  ///
  /// Devuelve `true` si hay coincidencia, `false` en caso contrario.
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

  /// Verifica si la respuesta del usuario coincide con alguna de las variaciones del número.
  ///
  /// Comprueba que el campo 'variations' exista en [number], sea una [List],
  /// y que alguno de sus elementos (convertidos a cadena y minúsculas)
  /// sea igual a [normalizedUserAnswer].
  ///
  /// Devuelve `true` si hay coincidencia, `false` en caso contrario.
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
