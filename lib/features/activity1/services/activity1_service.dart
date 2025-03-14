import 'dart:math';
import 'package:namui_wam/core/services/number_data_service.dart';
import 'package:namui_wam/core/services/audio_service.dart';
import 'package:namui_wam/features/activity1/models/number_word.dart';

/// Service to centralize the logic for Activity 1
class Activity1Service {
  final NumberDataService _numberDataService;
  final AudioService _audioService;
  final Random _random = Random();

  Activity1Service(this._numberDataService, this._audioService);

  /// Get range limits for a specific level
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
        // Default to level 1 range
        start = 1;
        end = 9;
    }
    
    return {'start': start, 'end': end};
  }

  /// Get a random number for a specific level
  Future<NumberWord?> getRandomNumberForLevel(int level) async {
    final range = _getRangeForLevel(level);
    final start = range['start']!;
    final end = range['end']!;
    
    try {
      // Get a random number in the range for this level
      final numberData = await _numberDataService.getRandomNumberInRange(start, end);
      if (numberData == null || numberData.isEmpty) {
        print('No se encontraron datos para el nivel $level en el rango $start-$end');
        return null;
      }
      
      // Get audio files
      final audioFilesString = numberData['audio_files']?.toString() ?? '';
      if (audioFilesString.isEmpty) {
        print('No se encontraron archivos de audio para el número ${numberData['number']}');
      }
      
      final List<String> audioFiles = audioFilesString
          .split(' ')
          .where((file) => file.isNotEmpty)
          .map((file) => _ensureCorrectAudioPath(file))
          .toList();
      
      // Create a NumberWord from the data
      return NumberWord(
        number: int.parse(numberData['number'].toString()),
        word: numberData['namtrik'] ?? 'Desconocido',
        audioFiles: audioFiles,
        level: level,
      );
    } catch (e) {
      print('Error getting random number for level $level: $e');
      return null;
    }
  }

  /// Generate options for a level based on the correct number
  Future<List<int>> generateOptionsForLevel(int level, int correctNumber) async {
    final Set<int> options = {correctNumber};
    
    // Determine the range based on the level
    final range = _getRangeForLevel(level);
    final start = range['start']!;
    final end = range['end']!;
    
    try {
      // Get all numbers in the range for this level
      final numbers = await _numberDataService.getNumbersInRange(start, end);
      
      if (numbers.isNotEmpty) {
        // Shuffle the numbers to get random ones
        numbers.shuffle(_random);
        
        // Add unique numbers until we have 4 options
        for (final numberData in numbers) {
          final number = int.parse(numberData['number'].toString());
          if (number != correctNumber) {
            options.add(number);
          }
          if (options.length >= 4) break;
        }
      }
      
      // If we don't have enough options, generate random ones within the range
      while (options.length < 4) {
        final randomNumber = _random.nextInt(end - start + 1) + start;
        options.add(randomNumber);
      }
      
      final result = options.toList();
      result.shuffle(_random);
      return result;
    } catch (e) {
      print('Error generating options for level $level: $e');
      
      // Fallback: generate basic options
      return _generateFallbackOptions(correctNumber, start, end);
    }
  }

  /// Generate fallback options when database fetch fails
  List<int> _generateFallbackOptions(int correctNumber, int start, int end) {
    final range = end - start + 1;
    return [
      correctNumber,
      ((correctNumber + range ~/ 4) % range) + start,
      ((correctNumber + range ~/ 2) % range) + start,
      ((correctNumber + 3 * range ~/ 4) % range) + start,
    ];
  }

  /// Calculate delay between audio files based on level and content
  Duration _getDelayBetweenAudio(int level, String audioFile, int position) {
    if (level >= 4) {
      if (audioFile.contains('Ishik.wav') || audioFile.contains('Srel.wav')) {
        return const Duration(milliseconds: 1000);
      } else {
        return const Duration(milliseconds: 600);
      }
    } else {
      if (position == 0) {
        return const Duration(milliseconds: 800);
      } else {
        return const Duration(milliseconds: 500);
      }
    }
  }

  /// Play audio for a NumberWord
  Future<void> playAudioForNumber(NumberWord number) async {
    if (number.audioFiles.isEmpty) return;
    
    for (int i = 0; i < number.audioFiles.length; i++) {
      final audioFile = number.audioFiles[i];
      await _audioService.playAudio(audioFile);
      
      // Add delay between audio files if not the last one
      if (i < number.audioFiles.length - 1) {
        await Future.delayed(_getDelayBetweenAudio(number.level, audioFile, i));
      }
    }
  }

  /// Stop any playing audio
  Future<void> stopAudio() async {
    await _audioService.stopAudio();
  }

  /// Ensure the audio file has the correct path
  String _ensureCorrectAudioPath(String filename) {
    // Ensure the file has .wav extension
    if (!filename.toLowerCase().endsWith('.wav')) {
      filename = '$filename.wav';
    }
    
    // Add the correct path prefix if it doesn't have one
    if (!filename.startsWith('audio/')) {
      return 'audio/namtrik_numbers/$filename';
    }
    
    return filename;
  }
}
