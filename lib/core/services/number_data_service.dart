import 'dart:convert';
import 'package:flutter/services.dart';

/// Service to handle loading and searching numbers from the optimized data structure
class NumberDataService {
  static const String _basePath = 'assets/data/namtrik_numbers.json';
  static const String _fallbackPath = 'assets/data/activity2_number.json';
  Map<String, dynamic>? _numbersData;
  List<Map<String, dynamic>> _allNumbers = [];

  /// Initialize the service by loading the numbers data
  Future<void> initialize() async {
    try {
      final String jsonString = await rootBundle.loadString(_basePath);
      if (jsonString.isEmpty) {
        throw Exception('Numbers file is empty: $_basePath');
      }
      
      _numbersData = json.decode(jsonString);
      final List<dynamic> namuiWamNumbers = _numbersData!['numbers']['namui_wam'];
      
      _allNumbers = namuiWamNumbers.map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item)).toList();
      print('NumberDataService initialized successfully with ${_allNumbers.length} numbers');
    } catch (e) {
      print('Error loading numbers data: $e');
      try {
        // Fallback to the old structure
        await _loadFallbackData();
      } catch (fallbackError) {
        print('Error loading fallback data: $fallbackError');
        throw Exception('Failed to initialize NumberDataService: Unable to load number data from any source');
      }
    }
  }

  /// Load the fallback data from the original JSON file
  Future<void> _loadFallbackData() async {
    try {
      final String jsonString = await rootBundle.loadString(_fallbackPath);
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> misakNumbers = jsonData['numbers']['misak'];
      
      _allNumbers = misakNumbers.map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item)).toList();
      print('Fallback data loaded successfully with ${_allNumbers.length} numbers');
    } catch (e) {
      print('Error loading fallback data: $e');
      throw Exception('Failed to load fallback data: $e');
    }
  }

  /// Get numbers within a specific range
  Future<List<Map<String, dynamic>>> getNumbersInRange(int start, int end) async {
    if (_allNumbers.isEmpty) {
      await initialize();
    }
    
    return _allNumbers.where((number) {
      int value = int.tryParse(number['number'].toString()) ?? 0;
      return value >= start && value <= end;
    }).toList();
  }

  /// Get a specific number by its value
  Future<Map<String, dynamic>?> getNumberByValue(int number) async {
    if (_allNumbers.isEmpty) {
      await initialize();
    }
    
    try {
      return _allNumbers.firstWhere(
        (item) => int.tryParse(item['number'].toString()) == number,
        orElse: () => {},
      );
    } catch (e) {
      print('Error getting number $number: $e');
      return null;
    }
  }

  /// Get a random number from a specific range
  Future<Map<String, dynamic>?> getRandomNumberInRange(int start, int end) async {
    final numbers = await getNumbersInRange(start, end);
    if (numbers.isEmpty) return null;
    
    // Use dart:math to get a random number
    final random = DateTime.now().millisecondsSinceEpoch % numbers.length;
    return numbers[random];
  }
}
