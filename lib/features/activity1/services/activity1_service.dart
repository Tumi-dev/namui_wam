import 'dart:math';
import 'package:namuiwam/core/di/service_locator.dart'; // Added for GetIt
import 'package:namuiwam/core/services/logger_service.dart'; // Added for LoggerService
import 'package:namuiwam/core/services/number_data_service.dart';
import 'package:namuiwam/core/services/audio_service.dart';
import 'package:namuiwam/features/activity1/models/number_word.dart';

/// {@template activity1_service}
/// Servicio para centralizar la lógica de la Actividad 1: "Escoja el número correcto".
///
/// Este servicio proporciona funcionalidades esenciales para la Actividad 1, incluyendo:
/// - Obtención de números aleatorios según el nivel de dificultad
/// - Generación de opciones múltiples para preguntas
/// - Manejo de reproducción secuencial de audios para números compuestos
/// - Tratamiento de errores y generación de opciones de fallback
///
/// Trabaja principalmente con:
/// - [NumberDataService] para acceder a los datos de números en Namtrik
/// - [AudioService] para la reproducción de archivos de audio
/// - [LoggerService] para el registro de eventos y errores
///
/// Ejemplo de uso:
/// ```dart
/// final activity1Service = getIt<Activity1Service>();
/// final numberWord = await activity1Service.getRandomNumberForLevel(3);
/// final options = await activity1Service.generateOptionsForLevel(3, numberWord.number);
/// await activity1Service.playAudioForNumber(numberWord);
/// ```
/// {@endtemplate}
class Activity1Service {
  /// Instancia del servicio de logging para registrar eventos y errores.
  ///
  /// Utilizado para registrar información de depuración, advertencias y errores
  /// durante la obtención de datos y reproducción de audio.
  final LoggerService _logger = getIt<LoggerService>(); // Added logger instance
  /// Servicio para acceder a los datos de los números (Namtrik, audio, etc.).
  ///
  /// Proporciona acceso a la base de datos de números en Namtrik almacenada en JSON,
  /// incluyendo sus representaciones, archivos de audio y otros metadatos.
  final NumberDataService _numberDataService;
  /// Servicio para reproducir y detener archivos de audio.
  ///
  /// Utilizado para reproducir las pronunciaciones de los números en Namtrik,
  /// tanto como archivos individuales como secuencias de archivos para números complejos.
  final AudioService _audioService;
  /// Generador de números aleatorios para la selección y mezcla.
  ///
  /// Utilizado para:
  /// - Seleccionar números aleatorios dentro de rangos específicos
  /// - Generar opciones de respuesta aleatorias
  /// - Mezclar las opciones para presentarlas en orden aleatorio
  final Random _random = Random();

  /// {@macro activity1_service}
  ///
  /// [_numberDataService] Instancia del servicio para acceder a los datos de números.
  /// [_audioService] Instancia del servicio para reproducir archivos de audio.
  Activity1Service(this._numberDataService, this._audioService);

  /// Obtiene los límites del rango numérico para un nivel específico.
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
  /// Este método realiza la siguiente secuencia de operaciones:
  /// 1. Determina el rango numérico para el nivel especificado
  /// 2. Solicita un número aleatorio dentro de ese rango a [_numberDataService]
  /// 3. Obtiene los metadatos del número (representación Namtrik, archivos de audio)
  /// 4. Construye y retorna un objeto [NumberWord] con todos los datos
  ///
  /// Si se produce algún error o no se encuentran datos para el nivel, 
  /// registra el error y retorna `null`.
  ///
  /// Ejemplo:
  /// ```dart
  /// final levelNumber = await activity1Service.getRandomNumberForLevel(2);
  /// if (levelNumber != null) {
  ///   print('Número: ${levelNumber.number}, Palabra: ${levelNumber.word}');
  /// }
  /// ```
  ///
  /// [level] El nivel para el cual obtener un número aleatorio.
  /// Retorna un [NumberWord] con los datos del número aleatorio, o `null` en caso de error.
  Future<NumberWord?> getRandomNumberForLevel(int level) async {
    final range = _getRangeForLevel(level);
    final start = range['start']!;
    final end = range['end']!;
    
    try {
      // Get a random number in the range for this level
      final numberData = await _numberDataService.getRandomNumberInRange(start, end);
      if (numberData == null || numberData.isEmpty) {
        _logger.warning('No se encontraron datos para el nivel $level en el rango $start-$end');
        return null;
      }
      
      // Get audio files
      final audioFilesString = numberData['audio_files']?.toString() ?? '';
      if (audioFilesString.isEmpty) {
        _logger.warning('No se encontraron archivos de audio para el número ${numberData['number']}');
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
    } catch (e, stackTrace) {
      _logger.error('Error getting random number for level $level: $e', e, stackTrace);
      return null;
    }
  }

  /// Genera una lista de opciones numéricas para una pregunta de nivel específico,
  /// incluyendo el número correcto.
  ///
  /// El proceso de generación sigue estos pasos:
  /// 1. Determina el rango de números válidos para el nivel
  /// 2. Intenta obtener números reales desde la base de datos para ese rango
  /// 3. Selecciona opciones distintas al número correcto
  /// 4. Si no hay suficientes opciones en la base de datos, genera números aleatorios
  /// 5. Devuelve una lista de 4 números en orden aleatorio, incluyendo el correcto
  ///
  /// Si se produce algún error durante el proceso, el método proporciona una lista
  /// de opciones de fallback utilizando [_generateFallbackOptions].
  ///
  /// Ejemplo:
  /// ```dart
  /// // Generar opciones para el nivel 2, donde 42 es la respuesta correcta
  /// final options = await service.generateOptionsForLevel(2, 42);
  /// // Resultado posible: [42, 37, 89, 26] (en orden aleatorio)
  /// ```
  ///
  /// [level] El nivel para el que se generan las opciones.
  /// [correctNumber] El número correcto que debe estar entre las opciones.
  /// Retorna una lista de 4 enteros (opciones), incluyendo el [correctNumber].
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
    } catch (e, stackTrace) {
      _logger.error('Error generating options for level $level: $e', e, stackTrace);
      
      // Fallback: generate basic options
      return _generateFallbackOptions(correctNumber, start, end);
    }
  }

  /// Genera opciones de fallback cuando la obtención de datos falla.
  ///
  /// Este método proporciona una solución de emergencia para garantizar que siempre
  /// haya opciones disponibles, incluso si la base de datos no es accesible. Crea
  /// cuatro opciones numéricas distribuidas uniformemente en el rango del nivel,
  /// incluyendo siempre el número correcto.
  ///
  /// Las opciones generadas se distribuyen aproximadamente en cuartos del rango,
  /// proporcionando diversidad en las opciones sin depender de la base de datos.
  ///
  /// [correctNumber] El número correcto que debe incluirse en las opciones.
  /// [start] El valor inicial del rango para el nivel.
  /// [end] El valor final del rango para el nivel.
  /// Retorna una lista de 4 enteros, incluyendo el [correctNumber].
  List<int> _generateFallbackOptions(int correctNumber, int start, int end) {
    final range = end - start + 1;
    return [
      correctNumber,
      ((correctNumber + range ~/ 4) % range) + start,
      ((correctNumber + range ~/ 2) % range) + start,
      ((correctNumber + 3 * range ~/ 4) % range) + start,
    ];
  }

//  /// Asegura que la ruta del archivo de audio tenga el formato correcto.
//  ///
//  /// Este método procesa las rutas de audio almacenadas en la base de datos
//  /// para garantizar que tengan el formato correcto para reproducción. Si la ruta
//  /// ya incluye el prefijo 'assets/', se devuelve sin cambios; de lo contrario,
//  /// se le agrega el prefijo 'assets/audio/numbers/'.
//  ///
//  /// [audioFile] La ruta del archivo de audio a procesar.
//  /// Retorna la ruta procesada y normalizada.
//  String _ensureCorrectAudioPath(String audioFile) {
//    if (audioFile.startsWith('assets/')) {
//      return audioFile;
//    }
//    return 'assets/audio/numbers/$audioFile';
//  }
//
//  /// Reproduce los archivos de audio asociados a un número en Namtrik.
//  ///
//  /// Para números simples, reproduce un solo archivo de audio. Para números
//  /// compuestos, reproduce secuencialmente todos los archivos de audio
//  /// con pausas apropiadas entre ellos, calculadas según el nivel de dificultad
//  /// y el contenido específico del audio (por ejemplo, pausas más largas
//  /// antes de "mil" o "millón").
//  ///
//  /// Ejemplo:
//  /// ```dart
//  /// // Reproducir el audio para el número "42" en Namtrik
//  /// await activity1Service.playAudioForNumber(numberWord);
//  /// ```
//  ///
//  /// [numberWord] El objeto [NumberWord] que contiene los archivos de audio a reproducir.
//  /// Lanza una excepción si hay problemas con la reproducción.
//  Future<void> playAudioForNumber(NumberWord numberWord) async {
//    try {
//      final audioFiles = numberWord.audioFiles;
//      if (audioFiles.isEmpty) {
//        _logger.warning('No audio files found for number ${numberWord.number}');
//        return;
//      }
//
//      // Para un solo archivo de audio, simplemente reproducirlo
//      if (audioFiles.length == 1) {
//        await _audioService.playAudio(audioFiles[0]);
//        return;
//      }
//
//      // Para múltiples archivos, reproducirlos secuencialmente con pausas apropiadas
//      for (int i = 0; i < audioFiles.length; i++) {
//        final audioFile = audioFiles[i];
//        
//        // Calcular la pausa adecuada según el nivel y el contenido
//        Duration delay = i == 0 
//            ? Duration.zero 
//            : _getDelayBetweenAudio(numberWord.level, audioFile, i);
//        
//        // Esperar la pausa calculada antes de reproducir el siguiente audio
//        if (i > 0) {
//          await Future.delayed(delay);
//        }
//        
//        // Reproducir el archivo de audio actual
//        await _audioService.playAudio(audioFile);
//      }
//    } catch (e, stackTrace) {
//      _logger.error('Error playing audio for number ${numberWord.number}: $e', e, stackTrace);
//      rethrow; // Propagar el error para manejo en la capa superior
//    }
//  }
//
//  /// Calcula el retraso adecuado entre la reproducción de archivos de audio
//  /// basado en el nivel y el contenido del archivo.
//  ///
//  /// Este método aplica reglas específicas para determinar las pausas entre
//  /// componentes de números compuestos:
//  /// - Para niveles más altos (≥ 4), introduce pausas más largas antes de
//  ///   términos como "mil" (Ishik) y "millón" (Srel)
//  /// - Para niveles más bajos, utiliza pausas estándar más cortas
//  ///
//  /// Estas pausas personalizadas mejoran la naturalidad de la pronunciación
//  /// y facilitan la comprensión auditiva de números complejos.
//  ///
//  /// [level] El nivel de dificultad del número.
//  /// [audioFile] La ruta del archivo de audio actual.
//  /// [position] La posición del archivo en la secuencia de reproducción.
//  /// Retorna la [Duration] de la pausa a aplicar antes de reproducir este audio.
//  Duration _getDelayBetweenAudio(int level, String audioFile, int position) {
//    if (level >= 4) {
//      if (audioFile.contains('Ishik.wav') || audioFile.contains('Srel.wav')) {
//        return const Duration(milliseconds: 1000);
//      } else {
//        return const Duration(milliseconds: 600);
//      }
//    } else {
//      return position < 2 
//          ? const Duration(milliseconds: 400) 
//          : const Duration(milliseconds: 500);
//    }
//  }
//
//  /// Detiene cualquier reproducción de audio en curso.
//  ///
//  /// Llama a [_audioService.stopAudio].
//  Future<void> stopAudio() async {
//    await _audioService.stopAudio();
//  }
//}
//


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