import 'package:namuiwam/core/services/number_data_service.dart';
import 'package:namuiwam/core/services/logger_service.dart';

/// Service to centralize the logic for Activity 2
class Activity2Service {
  final NumberDataService _numberDataService;
  final LoggerService _logger = LoggerService();

  Activity2Service(this._numberDataService);

  /// Obtiene el rango de números para un nivel específico.
  /// Lanza ArgumentError si el nivel es inválido.
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

  /// Get a random number for a specific level
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

  /// Get all numbers for a specific level
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

  /// Check if the user's answer is correct
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

  /// Check if the user's answer matches any composition
  /// Valida que 'compositions' sea un Map antes de operar
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

  /// Check if the user's answer matches any variation
  /// Valida que 'variations' sea una lista antes de operar
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
