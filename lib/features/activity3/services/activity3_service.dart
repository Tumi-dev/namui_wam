import 'package:namui_wam/core/services/number_data_service.dart';
import 'package:namui_wam/core/services/audio_service.dart';

/// Service to centralize the logic for Activity 3
class Activity3Service {
  final NumberDataService _numberDataService;
  final AudioService _audioService;

  Activity3Service(this._numberDataService, this._audioService);

  /// Get the namtrik representation for a specific number
  Future<String> getNamtrikForNumber(int number) async {
    try {
      final numberData = await _numberDataService.getNumberByValue(number);
      return numberData?['namtrik'] ?? '';
    } catch (e) {
      return 'Error: $e';
    }
  }

  /// Get the audio files for a specific number
  Future<List<String>> getAudioFilesForNumber(int number) async {
    try {
      final numberData = await _numberDataService.getNumberByValue(number);
      if (numberData == null || !numberData.containsKey('audio_files')) {
        return [];
      }
      
      final audioFiles = numberData['audio_files'].toString();
      // If audio_files contains multiple files (space-separated), split them
      if (audioFiles.contains(' ')) {
        // Ensure all audio files have the correct extension
        return audioFiles.split(' ')
            .map((file) => 'audio/namtrik_numbers/${_ensureWavExtension(file)}')
            .toList();
      } else {
        // Single audio file
        return ['audio/namtrik_numbers/${_ensureWavExtension(audioFiles)}'];
      }
    } catch (e) {
      print('Error getting audio files: $e');
      return [];
    }
  }

  /// Ensure the file has .wav extension
  String _ensureWavExtension(String filename) {
    // If the filename doesn't end with .wav, add it
    if (!filename.toLowerCase().endsWith('.wav')) {
      return '$filename.wav';
    }
    return filename;
  }

  /// Play audio for a specific number
  Future<bool> playAudioForNumber(int number) async {
    try {
      final audioFiles = await getAudioFilesForNumber(number);
      if (audioFiles.isEmpty) {
        return false;
      }

      // Play each audio file in sequence
      for (int i = 0; i < audioFiles.length; i++) {
        await _audioService.playAudio(audioFiles[i]);
        
        // Add a small delay between audio files if there are multiple
        if (i < audioFiles.length - 1) {
          await Future.delayed(const Duration(milliseconds: 600));
        }
      }
      return true;
    } catch (e) {
      print('Error playing audio: $e');
      return false;
    }
  }

  /// Stop any playing audio
  Future<void> stopAudio() async {
    await _audioService.stopAudio();
  }

  /// Check if a number is valid (between 1 and 9999999)
  bool isValidNumber(int? number) {
    return number != null && number >= 1 && number <= 9999999;
  }
}
