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
/// - Obtención de números aleatorios según el nivel de dificultad, incluyendo soporte
///   completo para el Nivel 7 (1,000,000 a 9,999,999) mediante composición dinámica.
/// - Generación de opciones múltiples (incluyendo distractores válidos para el Nivel 7)
///   para las preguntas.
/// - Manejo de reproducción secuencial de audios (asegurando que cada parte termine
///   antes de la siguiente) para números compuestos, utilizando `AudioService.playAudioAndWait`.
/// - Tratamiento de errores y generación de opciones de fallback.
///
/// Trabaja principalmente con:
/// - [NumberDataService] para acceder a los datos de números en Namtrik (incluyendo compuestos).
/// - [AudioService] para la reproducción de archivos de audio.
/// - [LoggerService] para el registro de eventos y errores.
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
  /// - Nivel 1: Unidades (0-9)
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
    int start = 0;
    int end = 9;
    
    switch (level) {
      case 1:
        start = 0;
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
        start = 0;
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
  /// Para el Nivel 7, genera un número aleatorio entre 1,000,000 y 9,999,999 y
  /// obtiene sus datos (potencialmente compuestos) usando `NumberDataService.getNumberByValue`.
  /// Para otros niveles, utiliza `NumberDataService.getRandomNumberInRange`.
  /// Retorna un [NumberWord] con los datos del número aleatorio, o `null` en caso de error.
  Future<NumberWord?> getRandomNumberForLevel(int level) async {
    final range = _getRangeForLevel(level);
    final int min = range['start']!;
    final int max = range['end']!;
    Map<String, dynamic>? numberData;

    try {
      if (level == 7) {
        int attempts = 0;
        // Retry a few times if getNumberByValue returns null for a randomly picked number.
        // This might happen if a number in the 1M-9.99M range somehow can't be composed
        // (e.g. missing a base component, though NumberDataService tries to be robust).
        while (numberData == null && attempts < 10) { // Increased retry attempts
          int randomNumberValue = min + _random.nextInt(max - min + 1);
          numberData = await _numberDataService.getNumberByValue(randomNumberValue);
          if (numberData == null) {
            _logger.warning('Attempt ${attempts + 1}: Could not retrieve data for randomly generated number $randomNumberValue in level 7.');
          }
          attempts++;
        }
        if (numberData == null) {
           _logger.error('Failed to get number data for level 7 after $attempts attempts. Cannot generate question.');
           return null; // Cannot proceed if no valid number is found
        }
      } else {
        // For levels 1-6, use getRandomNumberInRange as these ranges are expected
        // to be fully covered by the JSON and this method is simpler.
        numberData = await _numberDataService.getRandomNumberInRange(min, max);
      }

      if (numberData == null || numberData.isEmpty) {
        _logger.warning('No data found for level $level in range $min-$max');
        return null;
      }

      final audioFilesString = numberData['audio_files']?.toString() ?? '';
      // Assuming _ensureCorrectAudioPath is a valid method in this class
      final List<String> audioFiles = audioFilesString
          .split(' ')
          .where((file) => file.isNotEmpty)
          .map((file) => _ensureCorrectAudioPath(file)) 
          .toList();
      
      final currentNumberFromData = numberData['number'];
      if (currentNumberFromData == null || currentNumberFromData is! int) {
        _logger.error('Number field is missing or not an int in data for level $level: $currentNumberFromData');
        return null;
      }
      final int currentNumber = currentNumberFromData;

      return NumberWord(
        number: currentNumber,
        word: numberData['namtrik']?.toString() ?? 'Desconocido',
        audioFiles: audioFiles,
        level: level,
        // Optionally pass compositions if NumberWord model supports it and UI needs it
        // compositions: numberData['compositions'] as Map<String, dynamic>?,
      );
    } catch (e, stackTrace) {
      _logger.error('Error getting random number for level $level: $e', e, stackTrace);
      return null;
    }
  }

  /// Genera una lista de opciones numéricas para una pregunta de nivel específico,
  /// incluyendo el número correcto.
  ///
  /// Para el Nivel 7, se esfuerza por generar distractores válidos (que existan o puedan
  /// ser compuestos por `NumberDataService`) dentro del rango 1,000,000 a 9,999,999.
  /// Para otros niveles, utiliza una combinación de números existentes y generación aleatoria.
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
  /// Retorna una lista de 4 enteros (opciones), incluyendo el [correctNumber],
  /// o una lista de fallback si la generación principal falla.
  Future<List<int>> generateOptionsForLevel(int level, int correctNumber) async {
    final Set<int> options = {correctNumber};
    final range = _getRangeForLevel(level);
    final int min = range['start']!;
    final int max = range['end']!;
    const int numberOfOptions = 4; // Typically 4 options including the correct one
    const int maxAttemptsPerDistractor = 20; // Max attempts to find a single valid distractor

    if (level == 7) {
      int totalAttempts = 0;
      final int overallMaxAttempts = numberOfOptions * maxAttemptsPerDistractor * 2; // Safety break for the outer loop

      while (options.length < numberOfOptions && totalAttempts < overallMaxAttempts) {
        int potentialOption = min + _random.nextInt(max - min + 1);
        if (!options.contains(potentialOption)) {
          final optionData = await _numberDataService.getNumberByValue(potentialOption);
          if (optionData != null) {
            options.add(potentialOption);
          } else {
            _logger.info('Level 7 distractor $potentialOption could not be validated by NumberDataService. Will retry for another distractor.');
          }
        }
        totalAttempts++;
      }

      if (options.length < numberOfOptions) {
        _logger.warning('Could not generate enough *validated* distractors for level 7 after $totalAttempts attempts. Filling with random (potentially unvalidated) numbers from range.');
        while (options.length < numberOfOptions) {
            // Add random numbers from the range, even if not explicitly validated by getNumberByValue,
            // to ensure we have 4 options. This is a fallback.
            int fallbackOption = min + _random.nextInt(max - min + 1);
            options.add(fallbackOption); // Set will handle uniqueness
        }
      }
    } else { // Logic for levels 1-6
      // Try to get actual numbers from the service first for levels 1-6
      final List<Map<String, dynamic>> numbersInLevelData = await _numberDataService.getNumbersInRange(min, max);
      final List<int> availableDistractors = numbersInLevelData
          .map((item) => item['number'] as int) // Assuming 'number' is int
          .where((num) => num != correctNumber)
          .toList();
      
      availableDistractors.shuffle(_random);

      for (int distractor in availableDistractors) {
        if (options.length < numberOfOptions) {
          options.add(distractor);
        } else {
          break;
        }
      }

      // If not enough options from existing numbers, fill with random numbers in range
      int fillAttempts = 0;
      while (options.length < numberOfOptions && fillAttempts < 50) {
        int randomOption = min + _random.nextInt(max - min + 1);
        // options.add will ensure uniqueness
        options.add(randomOption);
        fillAttempts++;
      }
    }

    final List<int> finalOptions = options.toList();
    // Shuffle one last time to ensure correct answer isn't always first if added first
    finalOptions.shuffle(_random);
    
    // If, after all efforts, we don't have enough (e.g. range is too small and all numbers are the same)
    // use a generic fallback. This is an extreme edge case.
    if (finalOptions.length < numberOfOptions) {
        _logger.error('Critically failed to generate $numberOfOptions options for level $level. Using simple fallback.');
        return _generateFallbackOptions(correctNumber, min, max, numberOfOptions);
    }
    
    // Ensure exactly numberOfOptions are returned, even if set had more due to fallback logic complexities.
    return finalOptions.take(numberOfOptions).toList();
  }

  // Fallback option generator (can be kept simple or made more robust based on needs)
  List<int> _generateFallbackOptions(int correctNumber, int min, int max, int count) {
      final Set<int> options = {correctNumber};
      int attempts = 0;
      // Ensure min and max can actually produce 'count' unique numbers if range is tiny.
      // max - min + 1 gives the total unique numbers possible in the range.
      final int possibleUniqueNumbers = (max - min + 1);

      if (possibleUniqueNumbers < count) {
        _logger.warning('Fallback: Range $min-$max cannot produce $count unique numbers. Will return duplicates or fewer if necessary.');
        // Add all available unique numbers from range if less than count
        for (int i = 0; i <= (max-min); ++i) {
            options.add(min+i);
            if(options.length >= count) break;
        }
      } else {
        while (options.length < count && attempts < 100) { // attempt limit
            int randomNum = min + _random.nextInt(max - min + 1);
            options.add(randomNum);
            attempts++;
        }
      }
      // If still not enough, just fill with correctNumber or 1 up to count (very basic)
      while(options.length < count){
        options.add(options.length + min); // or just add correctNumber repeatedly
      }

      final List<int> finalOptionsList = options.toList();
      finalOptionsList.shuffle(_random);
      return finalOptionsList.take(count).toList();
  }

  /// Calculate delay between audio files based on level and content
  ///
  /// Ajusta las pausas para mejorar la naturalidad de la pronunciación de números complejos.
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
  ///
  /// Utiliza `AudioService.playAudioAndWait` para asegurar que cada archivo de audio
  /// termine antes de que comience el siguiente, aplicando pausas intermedias
  /// calculadas por `_getDelayBetweenAudio` para mejorar la cadencia.
  /// Se detiene cualquier audio previo antes de iniciar una nueva secuencia.
  Future<void> playAudioForNumber(NumberWord number) async {
    try {
      await stopAudio(); // Stop any currently playing audio first

      final audioFiles = number.audioFiles;
      if (audioFiles.isEmpty) {
        _logger.warning('No audio files found for number ${number.number} in Activity1Service');
        return;
      }

      if (audioFiles.length == 1) {
        // For a single file, use playAudioAndWait directly.
        await _audioService.playAudioAndWait(audioFiles[0]);
        return;
      }

      // For multiple files, play them sequentially with custom delays.
      for (int i = 0; i < audioFiles.length; i++) {
        final audioFile = audioFiles[i];
        
        // Calculate delay *before* playing the current sound (if not the first sound)
        if (i > 0) {
          Duration delay = _getDelayBetweenAudio(number.level, audioFile, i);
          await Future.delayed(delay);
        }
        
        // Play the current audio file and wait for it to complete
        await _audioService.playAudioAndWait(audioFile);
      }
    } catch (e, stackTrace) {
      _logger.error('Error playing audio for number ${number.number} in Activity1Service: $e', e, stackTrace);
      // Optionally rethrow or handle as needed by the UI
      // rethrow; 
    }
  }

  /// Stop any playing audio
  Future<void> stopAudio() async {
    try {
      await _audioService.stopAudio();
    } catch (e, stackTrace) {
      _logger.error('Error stopping audio in Activity1Service', e, stackTrace);
    }
  }

  /// Ensure the audio file has the correct path
  String _ensureCorrectAudioPath(String fileName) {
    // Ensure the file has .wav extension
    if (!fileName.toLowerCase().endsWith('.wav')) {
      fileName = '$fileName.wav';
    }
    
    // Add the correct path prefix if it doesn't have one
    if (!fileName.startsWith('audio/')) {
      return 'audio/namtrik_numbers/$fileName';
    }
    
    return fileName;
  }
}