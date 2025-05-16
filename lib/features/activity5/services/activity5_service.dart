import 'package:namuiwam/core/services/number_data_service.dart';
import 'package:namuiwam/core/services/audio_service.dart';
import 'package:namuiwam/core/services/logger_service.dart';

/// {@template activity5_service}
/// Servicio para la Actividad 5: "Muntsielan namtrikmai yunɵmarɵpik (Convertir números en letras)".
///
/// Proporciona la lógica central para la herramienta de conversión de números arábigos
/// a su representación escrita en Namtrik, con las siguientes responsabilidades:
///
/// - Validar que los números estén dentro del rango soportado (1 a 9,999,999)
/// - Obtener la representación textual en Namtrik de cualquier número válido
/// - Gestionar la obtención y reproducción de archivos de audio asociados
/// - Manejar errores durante la conversión y reproducción
///
/// Actúa como intermediario entre la interfaz de usuario ([Activity5Screen]) y los servicios
/// centrales de datos ([NumberDataService]) y audio ([AudioService]), implementando
/// la lógica específica de la Actividad 5.
///
/// Ejemplo de uso:
/// ```dart
/// final service = Activity5Service(numberDataService, audioService);
///
/// // Obtener representación Namtrik de un número
/// final namtrikText = await service.getNamtrikForNumber(42);
/// // → "pik pa tap"
///
/// // Reproducir la secuencia de audio
/// final success = await service.playAudioForNumber(42);
/// // → Reproduce secuencialmente: "pik.wav", "pa.wav", "tap.wav"
/// ```
/// {@endtemplate}
class Activity5Service {
  /// Servicio para acceder a los datos de los números (Namtrik, audio).
  ///
  /// Proporciona acceso a la base de datos de números que contiene:
  /// - Valores numéricos
  /// - Sus equivalentes escritos en Namtrik
  /// - Referencias a archivos de audio para pronunciación
  final NumberDataService _numberDataService;
  
  /// Servicio para reproducir y detener archivos de audio.
  ///
  /// Gestiona la reproducción secuencial de múltiples archivos,
  /// permitiendo controlar el estado de reproducción (iniciar/detener).
  final AudioService _audioService;
  
  /// Instancia del servicio de logging para registrar errores.
  ///
  /// Registra excepciones y errores durante:
  /// - La obtención de datos de números
  /// - La carga y reproducción de archivos de audio
  final LoggerService _logger = LoggerService();

  /// {@macro activity5_service}
  /// Constructor que requiere instancias de [NumberDataService] y [AudioService].
  Activity5Service(this._numberDataService, this._audioService);

  /// Obtiene la representación escrita en Namtrik para un [number] específico.
  ///
  /// Consulta la base de datos a través de [_numberDataService] para encontrar
  /// el valor Namtrik correspondiente al número. El proceso incluye:
  /// 1. Validación implícita del número (debe existir en la base de datos)
  /// 2. Obtención del mapeo desde el servicio de datos
  /// 3. Extracción de la propiedad 'namtrik' del resultado
  ///
  /// Ejemplo:
  /// ```dart
  /// final result = await getNamtrikForNumber(42);
  /// print(result); // "pik pa tap"
  /// ```
  ///
  /// [number] El número arábigo para convertir (debe estar entre 1 y 9,999,999)
  /// Retorna la cadena Namtrik correspondiente, cadena vacía si no se encuentra,
  /// o un mensaje de error si ocurre una excepción.
  Future<String> getNamtrikForNumber(int number) async {
    try {
      final numberData = await _numberDataService.getNumberByValue(number);
      return numberData?['namtrik'] ?? '';
    } catch (e) {
      return 'Error: $e';
    }
  }

  /// Obtiene la lista de rutas de archivos de audio para un [number] específico.
  ///
  /// Este método:
  /// 1. Consulta la base de datos para el número especificado
  /// 2. Extrae la lista de nombres de archivos de audio desde la propiedad 'audio_files'
  /// 3. Procesa cada nombre para asegurar que tenga la extensión .wav
  /// 4. Construye la ruta completa para cada archivo de audio
  ///
  /// Ejemplo:
  /// ```dart
  /// final audioFiles = await getAudioFilesForNumber(42);
  /// // → ['audio/namtrik_numbers/pik.wav', 'audio/namtrik_numbers/pa.wav', 'audio/namtrik_numbers/tap.wav']
  /// ```
  ///
  /// [number] El número para el cual obtener los archivos de audio
  /// Retorna una lista de rutas de archivos de audio, o lista vacía si no hay archivos
  /// o si ocurre un error.
  Future<List<String>> getAudioFilesForNumber(int number) async {
    try {
      final numberData = await _numberDataService.getNumberByValue(number);
      if (numberData == null || !numberData.containsKey('audio_files')) {
        return [];
      }
      final audioFiles = numberData['audio_files'].toString();
      // Si hay varios archivos, los separamos, limpiamos y filtramos vacíos
      final files = audioFiles
          .split(' ')
          .map((file) => file.trim())
          .where((file) => file.isNotEmpty)
          .map((file) => 'audio/namtrik_numbers/${_ensureWavExtension(file)}')
          .toList();
      return files;
    } catch (e, stackTrace) {
      _logger.error('Error getting audio files', e, stackTrace);
      return [];
    }
  }

  /// Asegura que el nombre de archivo termine con la extensión '.wav'.
  ///
  /// Método utilitario interno para normalizar los nombres de archivo de audio.
  /// Si el nombre ya termina con '.wav' (ignorando mayúsculas/minúsculas), 
  /// lo deja sin cambios; de lo contrario, añade la extensión.
  ///
  /// [filename] El nombre de archivo a normalizar
  /// Retorna el nombre de archivo con la extensión .wav garantizada
  String _ensureWavExtension(String filename) {
    // If the filename doesn't end with .wav, add it
    if (!filename.toLowerCase().endsWith('.wav')) {
      return '$filename.wav';
    }
    return filename;
  }

  /// Reproduce la secuencia de archivos de audio para un [number] específico.
  ///
  /// Implementa la lógica para reproducir secuencialmente todos los componentes
  /// de audio necesarios para pronunciar un número en Namtrik:
  /// 1. Obtiene la lista de archivos de audio usando [getAudioFilesForNumber]
  /// 2. Para cada archivo en la secuencia:
  ///    - Reproduce el archivo actual
  ///    - Espera a que termine más un pequeño retraso entre archivos (600ms)
  ///    - Pasa al siguiente archivo
  ///
  /// Ejemplo:
  /// ```dart
  /// final success = await playAudioForNumber(42);
  /// // → Reproduce secuencialmente: "pik.wav", "pa.wav", "tap.wav"
  /// ```
  ///
  /// [number] El número para el cual reproducir el audio
  /// Retorna `true` si la reproducción se inició exitosamente (al menos un archivo encontrado),
  /// `false` si no se encontraron archivos o si ocurrió un error.
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
    } catch (e, stackTrace) {
      _logger.error('Error playing audio', e, stackTrace);
      return false;
    }
  }

  /// Detiene cualquier reproducción de audio en curso.
  ///
  /// Método de utilidad que interrumpe inmediatamente cualquier reproducción
  /// de audio actual. Útil en casos como:
  /// - El usuario navega fuera de la pantalla
  /// - La aplicación pasa a segundo plano
  /// - El usuario solicita detener explícitamente el audio
  Future<void> stopAudio() async {
    await _audioService.stopAudio();
  }

  /// Verifica si un [number] es válido para la herramienta de conversión.
  ///
  /// Implementa la validación de reglas de negocio específicas para determinar
  /// si un número puede ser convertido a Namtrik en esta actividad:
  /// - Debe ser un valor no nulo
  /// - Debe ser mayor o igual a 1
  /// - Debe ser menor o igual a 9,999,999
  ///
  /// Ejemplo:
  /// ```dart
  /// print(isValidNumber(42)); // true
  /// print(isValidNumber(0)); // false
  /// print(isValidNumber(10000000)); // false
  /// print(isValidNumber(null)); // false
  /// ```
  ///
  /// [number] El número a validar, puede ser nulo
  /// Retorna `true` si el número es válido según las reglas, `false` en caso contrario
  bool isValidNumber(int? number) {
    return number != null && number >= 1 && number <= 9999999;
  }
}
