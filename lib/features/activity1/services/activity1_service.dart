import 'dart:math';
import 'package:namuiwam/core/di/service_locator.dart'; // Added for GetIt
import 'package:namuiwam/core/services/logger_service.dart'; // Added for LoggerService
import 'package:namuiwam/core/services/number_data_service.dart';
import 'package:namuiwam/core/services/audio_service.dart';
import 'package:namuiwam/features/activity1/models/number_word.dart';

/// Servicio para centralizar la lógica de la Actividad 1: "Contando con Namtrik".
///
/// Gestiona la obtención de números y palabras Namtrik según el nivel,
/// la generación de opciones para preguntas de selección múltiple,
/// y la reproducción de los audios correspondientes a los números.
class Activity1Service {
  /// Instancia del servicio de logging para registrar eventos y errores.
  final LoggerService _logger = getIt<LoggerService>(); // Added logger instance
  /// Servicio para acceder a los datos de los números (Namtrik, audio, etc.).
  final NumberDataService _numberDataService;
  /// Servicio para reproducir y detener archivos de audio.
  final AudioService _audioService;
  /// Generador de números aleatorios para la selección y mezcla.
  final Random _random = Random();

  /// Constructor de [Activity1Service].
  ///
  /// Requiere instancias de [NumberDataService] y [AudioService].
  Activity1Service(this._numberDataService, this._audioService);

  /// Obtiene los límites del rango numérico para un nivel específico.
  ///
  /// Devuelve un [Map] con las claves 'start' y 'end' representando
  /// el inicio y fin del rango para el [level] dado.
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

  /// Obtiene un [NumberWord] aleatorio para un nivel específico.
  ///
  /// Determina el rango numérico usando [_getRangeForLevel], obtiene un número
  /// aleatorio dentro de ese rango desde [_numberDataService], y construye
  /// un objeto [NumberWord] con el número, su representación Namtrik y
  /// la lista de archivos de audio asociados.
  ///
  /// Devuelve `null` si no se encuentran datos o si ocurre un error.
  Future<NumberWord?> getRandomNumberForLevel(int level) async {
    final range = _getRangeForLevel(level);
    final start = range['start']!;
    final end = range['end']!;
    
    try {
      // Get a random number in the range for this level
      final numberData = await _numberDataService.getRandomNumberInRange(start, end);
      if (numberData == null || numberData.isEmpty) {
        _logger.warning('No se encontraron datos para el nivel $level en el rango $start-$end'); // Use logger
        return null;
      }
      
      // Get audio files
      final audioFilesString = numberData['audio_files']?.toString() ?? '';
      if (audioFilesString.isEmpty) {
        _logger.warning('No se encontraron archivos de audio para el número ${numberData['number']}'); // Use logger
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
    } catch (e, stackTrace) { // Added stackTrace
      _logger.error('Error getting random number for level $level: $e', e, stackTrace); // Use logger
      return null;
    }
  }

  /// Genera una lista de opciones numéricas para una pregunta de nivel específico,
  /// incluyendo el número correcto.
  ///
  /// Obtiene el rango del nivel, busca números dentro de ese rango usando
  /// [_numberDataService], y selecciona 3 opciones incorrectas distintas
  /// además del [correctNumber]. Si no encuentra suficientes números en la base de datos,
  /// genera opciones aleatorias dentro del rango.
  ///
  /// Devuelve una lista de 4 enteros desordenada. En caso de error, genera
  /// opciones de fallback usando [_generateFallbackOptions].
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
    } catch (e, stackTrace) { // Added stackTrace
      _logger.error('Error generating options for level $level: $e', e, stackTrace); // Use logger
      
      // Fallback: generate basic options
      return _generateFallbackOptions(correctNumber, start, end);
    }
  }

  /// Genera opciones de fallback cuando la obtención de datos falla.
  ///
  /// Crea una lista simple de 4 números basada en el [correctNumber]
  /// y el rango ([start], [end]) para asegurar que siempre haya opciones.
  List<int> _generateFallbackOptions(int correctNumber, int start, int end) {
    final range = end - start + 1;
    return [
      correctNumber,
      ((correctNumber + range ~/ 4) % range) + start,
      ((correctNumber + range ~/ 2) % range) + start,
      ((correctNumber + 3 * range ~/ 4) % range) + start,
    ];
  }

  /// Calcula el retraso adecuado entre la reproducción de archivos de audio
  /// basado en el nivel y el contenido del archivo.
  ///
  /// Para niveles más altos (>= 4), introduce pausas más largas antes de
  /// "Ishik" (mil) y "Srel" (millón). Para niveles más bajos, ajusta el
  /// retraso según la posición del audio en la secuencia.
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

  /// Reproduce la secuencia de archivos de audio para un [NumberWord] dado.
  ///
  /// Itera sobre [number.audioFiles], reproduce cada archivo usando [_audioService],
  /// e inserta un retraso calculado por [_getDelayBetweenAudio] entre archivos.
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

  /// Detiene cualquier reproducción de audio en curso.
  ///
  /// Llama a [_audioService.stopAudio].
  Future<void> stopAudio() async {
    await _audioService.stopAudio();
  }

  /// Asegura que el nombre del archivo de audio tenga la ruta y extensión correctas.
  ///
  /// Verifica si el [filename] termina en ".wav" (lo añade si no)
  /// y si no comienza con "audio/", le prefija "audio/namtrik_numbers/".
  ///
  /// Devuelve la ruta del archivo formateada correctamente.
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
