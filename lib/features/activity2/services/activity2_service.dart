import 'package:namui_wam/core/services/number_data_service.dart';

/// Service to centralize the logic for Activity 2
class Activity2Service {
  final NumberDataService _numberDataService;

  Activity2Service(this._numberDataService);

  /// Get a random number for a specific level
  Future<Map<String, dynamic>?> getRandomNumberForLevel(int level) async {
    // Determine the range based on the level
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
        throw ArgumentError('Invalid level: $level. Level must be between 1 and 7.');
    }
    
    // Get a random number in the range for this level
    return await _numberDataService.getRandomNumberInRange(start, end);
  }

  /// Get all numbers for a specific level
  Future<List<Map<String, dynamic>>> getNumbersForLevel(int level) async {
    // Determine the range based on the level
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
        throw ArgumentError('Invalid level: $level. Level must be between 1 and 7.');
    }
    
    // Get all numbers in the range for this level
    return await _numberDataService.getNumbersInRange(start, end);
  }

  /// Check if the user's answer is correct
  bool isAnswerCorrect(Map<String, dynamic> number, String userAnswer) {
    if (number.isEmpty || userAnswer.isEmpty) return false;

    final String normalizedUserAnswer = userAnswer.trim().toLowerCase();
    
    // Check against namtrik value
    final String namtrikValue = number['namtrik'].toString().toLowerCase();
    if (namtrikValue == normalizedUserAnswer) return true;
    
    // Check against compositions
    if (number.containsKey('compositions')) {
      final Map<String, dynamic> compositions = number['compositions'];
      
      for (final composition in compositions.values) {
        if (composition.toString().toLowerCase() == normalizedUserAnswer) {
          return true;
        }
      }
    }
    
    // Check against variations if they exist
    if (number.containsKey('variations')) {
      final List<dynamic> variations = number['variations'];
      
      for (final variation in variations) {
        if (variation.toString().toLowerCase() == normalizedUserAnswer) {
          return true;
        }
      }
    }
    
    return false;
  }
}
