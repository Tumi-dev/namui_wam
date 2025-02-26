import 'dart:convert';
import 'package:flutter/services.dart';

/// Service to handle loading and searching numbers from the optimized data structure
class NumberDataService {
  static const String _basePath = 'assets/data/avtivity_numbers_1-999999_json';
  static const String _fallbackPath = 'assets/data/activity2_number.json';
  Map<String, dynamic>? _indexData;
  final Map<String, List<Map<String, dynamic>>> _cachedChunks = {};
  bool _useOptimizedStructure = true;
  List<Map<String, dynamic>> _fallbackNumbers = [];

  /// Initialize the service by loading the index file
  Future<void> initialize() async {
    try {
      final String indexPath = '$_basePath/index.json';
      final String indexJson = await rootBundle.loadString(indexPath);
      if (indexJson.isEmpty) {
        throw Exception('Index file is empty: $indexPath');
      }
      _indexData = json.decode(indexJson);
      _useOptimizedStructure = true;
      print('NumberDataService initialized successfully with optimized structure');
    } catch (e) {
      print('Error loading optimized number index: $e');
      print('Falling back to legacy number format');
      
      try {
        // Fallback to the old structure
        _useOptimizedStructure = false;
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
      
      _fallbackNumbers = misakNumbers.map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item)).toList();
      print('Fallback data loaded successfully with ${_fallbackNumbers.length} numbers');
    } catch (e) {
      print('Error loading fallback data: $e');
      throw Exception('Failed to load fallback data: $e');
    }
  }

  /// Get the file information for a specific number
  Map<String, dynamic>? _getFileInfoForNumber(int number) {
    if (_indexData == null) return null;
    
    final List<dynamic> files = _indexData!['files'];
    for (final fileInfo in files) {
      final int start = fileInfo['start'];
      final int end = fileInfo['end'];
      
      if (number >= start && number <= end) {
        return Map<String, dynamic>.from(fileInfo);
      }
    }
    
    return null;
  }

  /// Load a specific chunk file
  Future<List<Map<String, dynamic>>?> _loadChunk(String fileName) async {
    if (_cachedChunks.containsKey(fileName)) {
      return _cachedChunks[fileName];
    }
    
    try {
      final String chunkJson = await rootBundle.loadString('$_basePath/$fileName');
      final Map<String, dynamic> data = json.decode(chunkJson);
      final List<dynamic> numbers = data['numbers']['namui_wam'];
      
      final List<Map<String, dynamic>> result = numbers
          .map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item))
          .toList();
      
      _cachedChunks[fileName] = result;
      return result;
    } catch (e) {
      print('Error loading chunk $fileName: $e');
      return null;
    }
  }

  /// Get numbers within a specific range
  Future<List<Map<String, dynamic>>> getNumbersInRange(int start, int end) async {
    if (_indexData == null && _useOptimizedStructure) {
      await initialize();
    }
    
    // If we're using the fallback data, filter it based on the range
    if (!_useOptimizedStructure) {
      return _fallbackNumbers.where((number) {
        int value = int.tryParse(number['number'].toString()) ?? 0;
        return value >= start && value <= end;
      }).toList();
    }
    
    List<Map<String, dynamic>> result = [];
    
    // Find all files that contain numbers in the range
    final List<dynamic> files = _indexData!['files'];
    final List<String> filesToLoad = [];
    
    for (final fileInfo in files) {
      final int fileStart = fileInfo['start'];
      final int fileEnd = fileInfo['end'];
      
      // Check if this file contains numbers in our range
      if ((fileStart <= end && fileEnd >= start)) {
        filesToLoad.add(fileInfo['file']);
      }
    }
    
    // Load all required chunks
    for (final fileName in filesToLoad) {
      final numbers = await _loadChunk(fileName);
      if (numbers != null) {
        // Filter numbers in the requested range
        final filteredNumbers = numbers.where((number) {
          final int value = int.tryParse(number['number'].toString()) ?? 0;
          return value >= start && value <= end;
        }).toList();
        
        result.addAll(filteredNumbers);
      }
    }
    
    return result;
  }

  /// Get a specific number by its value
  Future<Map<String, dynamic>?> getNumberByValue(int number) async {
    if (_indexData == null && _useOptimizedStructure) {
      await initialize();
    }
    
    // If we're using the fallback data, find the number directly
    if (!_useOptimizedStructure) {
      return _fallbackNumbers.firstWhere(
        (item) => int.tryParse(item['number'].toString()) == number,
        orElse: () => {},
      );
    }
    
    final fileInfo = _getFileInfoForNumber(number);
    if (fileInfo == null) return null;
    
    final numbers = await _loadChunk(fileInfo['file']);
    if (numbers == null) return null;
    
    return numbers.firstWhere(
      (item) => int.tryParse(item['number'].toString()) == number,
      orElse: () => {},
    );
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
