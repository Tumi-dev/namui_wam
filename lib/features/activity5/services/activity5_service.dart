import 'package:namuiwam/core/services/number_data_service.dart';
import 'package:namuiwam/core/services/audio_service.dart';
import 'package:namuiwam/core/services/logger_service.dart';

/// {@template activity5_service}
/// Servicio para la Actividad 5: "Muntsielan namtrikmai yunɵmarɵpik (Convertir números en letras)".
///
/// Proporciona funcionalidades para la herramienta de conversión:
/// - Obtener la representación Namtrik escrita de un número.
/// - Obtener los archivos de audio correspondientes a un número.
/// - Reproducir la secuencia de audio para un número.
/// - Validar si un número está dentro del rango soportado (1 a 9,999,999).
/// {@endtemplate}
class Activity5Service {
  /// Servicio para acceder a los datos de los números (Namtrik, audio).
  final NumberDataService _numberDataService;
  /// Servicio para reproducir y detener archivos de audio.
  final AudioService _audioService;
  /// Instancia del servicio de logging para registrar errores.
  final LoggerService _logger = LoggerService();

  /// {@macro activity5_service}
  /// Constructor que requiere instancias de [NumberDataService] y [AudioService].
  Activity5Service(this._numberDataService, this._audioService);

  /// Obtiene la representación escrita en Namtrik para un [number] específico.
  ///
  /// Busca el número en la base de datos a través de [_numberDataService].
  /// Devuelve la cadena Namtrik correspondiente o una cadena vacía si no se encuentra.
  /// Devuelve un mensaje de error si ocurre una excepción.
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
  /// Busca el número en la base de datos. Si existe y tiene 'audio_files',
  /// procesa la cadena (separando por espacios, asegurando extensión .wav y prefijo de ruta)
  /// y devuelve una lista de rutas completas.
  /// Devuelve una lista vacía si no se encuentran audios o si ocurre un error.
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
  /// Añade '.wav' si no está presente (ignorando mayúsculas/minúsculas).
  String _ensureWavExtension(String filename) {
    // If the filename doesn't end with .wav, add it
    if (!filename.toLowerCase().endsWith('.wav')) {
      return '$filename.wav';
    }
    return filename;
  }

  /// Reproduce la secuencia de archivos de audio para un [number] específico.
  ///
  /// Obtiene la lista de archivos usando [getAudioFilesForNumber].
  /// Reproduce cada archivo en secuencia usando [_audioService], con un pequeño
  /// retraso entre archivos si hay más de uno.
  /// Devuelve `true` si la reproducción se inició (archivos encontrados),
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
  /// Llama a [_audioService.stopAudio].
  Future<void> stopAudio() async {
    await _audioService.stopAudio();
  }

  /// Verifica si un [number] es válido para la herramienta de conversión.
  ///
  /// Considera válido un número si no es nulo y está entre 1 y 9,999,999 inclusive.
  bool isValidNumber(int? number) {
    return number != null && number >= 1 && number <= 9999999;
  }
}
