import 'package:namui_wam/core/services/number_data_service.dart';

/// Service to centralize the logic for Activity 3
class Activity3Service {
  final NumberDataService _numberDataService;

  Activity3Service(this._numberDataService);

  /// Get the namtrik representation for a specific number
  Future<String> getNamtrikForNumber(int number) async {
    try {
      final numberData = await _numberDataService.getNumberByValue(number);
      return numberData?['namtrik'] ?? '';
    } catch (e) {
      return 'Error: $e';
    }
  }

  /// Check if a number is valid (between 1 and 9999999)
  bool isValidNumber(int? number) {
    return number != null && number >= 1 && number <= 9999999;
  }
}
