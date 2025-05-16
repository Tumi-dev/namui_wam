import 'package:audioplayers/audioplayers.dart';
import 'package:namuiwam/core/di/service_locator.dart';
import 'package:namuiwam/core/services/logger_service.dart';

/// {@template audio_player_service}
/// Servicio que gestiona la reproducción de archivos de audio en la aplicación.
///
/// Este servicio encapsula todas las funcionalidades relacionadas con la reproducción
/// de audio utilizando el paquete `audioplayers`. Proporciona una interfaz simplificada
/// para:
/// - Reproducir audio desde los assets
/// - Detener la reproducción actual
/// - Monitorear el estado de reproducción
/// - Gestionar los recursos de audio
///
/// A diferencia de [AudioService] que mantiene múltiples instancias de AudioPlayer,
/// este servicio utiliza una única instancia para reproducir un audio a la vez, 
/// lo que lo hace ideal para efectos de sonido o pronunciaciones secuenciales.
/// {@endtemplate}
class AudioPlayerService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final LoggerService _logger = getIt<LoggerService>();
  bool _isPlaying = false;
  String? _currentPath;

  /// {@macro audio_player_service}
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// final audioPlayerService = getIt<AudioPlayerService>();
  /// 
  /// // Reproducir un audio
  /// await audioPlayerService.play('audio/namtrik_numbers/muntsik.mp3');
  /// 
  /// // Verificar si está reproduciendo
  /// if (audioPlayerService.isPlaying) {
  ///   print('Reproduciendo: ${audioPlayerService.currentPlayingPath}');
  /// }
  /// 
  /// // Detener la reproducción
  /// await audioPlayerService.stop();
  /// ```
  AudioPlayerService() {
    // Configurar AudioContext para efectos de sonido cortos
    // Esto permite que los sonidos de este servicio (ej. pronunciaciones del diccionario)
    // puedan mezclarse con la música de fondo y solicitar un foco de audio
    // transitorio que podría atenuar otros sonidos en Android (AndroidAudioFocus.gainTransientMayDuck).
    _audioPlayer.setAudioContext(AudioContext(
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback,
        options: {
          AVAudioSessionOptions.mixWithOthers,
        },
      ),
      android: AudioContextAndroid(
        isSpeakerphoneOn: false,
        stayAwake: false,
        audioFocus: AndroidAudioFocus.gainTransientMayDuck,
      ),
    )).then((_) {
      _logger.debug('AudioPlayerService: AudioContext set for short effects player.');
    }).catchError((e, stackTrace) {
      _logger.error('AudioPlayerService: Error setting AudioContext for short effects player.', e, stackTrace);
    });

    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      _logger.debug('AudioPlayer state changed: $state');
      _isPlaying = state == PlayerState.playing;
      if (state == PlayerState.stopped || state == PlayerState.completed || state == PlayerState.disposed) {
          _logger.info('Audio playback stopped/completed/disposed.'); 
          _currentPath = null; 
      }
      // Consider adding callbacks or state management updates here if needed
    });

    _audioPlayer.onLog.listen((String message) {
      _logger.verbose('AudioPlayer log: $message');
    }, onError: (Object e, StackTrace stackTrace) {
       _logger.error('AudioPlayer error', e, stackTrace);
       _isPlaying = false;
       _currentPath = null;
    });
  }

  /// Indica si un audio se está reproduciendo actualmente.
  ///
  /// Retorna `true` cuando hay un audio en reproducción, `false` en caso contrario.
  /// Este valor se actualiza automáticamente basado en los eventos del [AudioPlayer].
  /// 
  /// Útil para controlar la UI basada en el estado de reproducción, por ejemplo,
  /// mostrar/ocultar un indicador de reproducción.
  bool get isPlaying => _isPlaying;

  /// La ruta del asset del audio que se está reproduciendo actualmente.
  ///
  /// Retorna la ruta completa del asset en reproducción o `null` si no hay ningún
  /// audio reproduciéndose.
  /// 
  /// Esta propiedad se puede utilizar para identificar qué audio está sonando
  /// y tomar decisiones basadas en ello, como resaltar un elemento en la UI.
  String? get currentPlayingPath => _currentPath;

  /// Reproduce un archivo de audio desde la ruta del asset especificada.
  ///
  /// El comportamiento varía según el estado actual:
  /// - Si se llama con la misma ruta que ya está reproduciéndose: detiene el audio (toggle)
  /// - Si se está reproduciendo otro audio: detiene el anterior y reproduce el nuevo
  /// - Si no hay reproducción activa: inicia la reproducción del nuevo audio
  ///
  /// [assetPath] La ruta completa del asset de audio (ej. 'assets/audio/sound.wav').
  /// Si la ruta comienza con 'assets/', esta parte se quita automáticamente para
  /// compatibilidad con [AssetSource].
  ///
  /// Ejemplo:
  /// ```dart
  /// // Reproducir un audio
  /// await audioPlayerService.play('audio/dictionary/ushamera/misak.mp3');
  /// ```
  ///
  /// Lanza una excepción si hay problemas accediendo o reproduciendo el archivo.
  Future<void> play(String assetPath) async {
    if (_isPlaying && _currentPath == assetPath) {
      _logger.info('Audio already playing: $assetPath. Stopping.');
      await stop();
      return;
    } else if (_isPlaying) {
      _logger.info('Another audio is playing. Stopping previous one first.');
      await stop(); 
    }

    try {
      _logger.info('Playing audio: $assetPath');
      // AssetSource requiere la ruta relativa dentro de 'assets/'
      await _audioPlayer.play(AssetSource(assetPath.replaceFirst('assets/', ''))); 
      _currentPath = assetPath;
      _isPlaying = true; 
    } catch (e, stackTrace) {
      _logger.error('Error playing audio: $assetPath', e, stackTrace);
      _isPlaying = false;
      _currentPath = null;
      rethrow; // Relanzar para manejo por parte del llamador
    }
  }

  /// Detiene la reproducción de audio actual, si hay alguna.
  ///
  /// Si no hay reproducción activa, este método no tiene efecto.
  /// Después de detener, las propiedades [isPlaying] y [currentPlayingPath] 
  /// se actualizan automáticamente.
  ///
  /// Ejemplo:
  /// ```dart
  /// if (audioPlayerService.isPlaying) {
  ///   await audioPlayerService.stop();
  ///   print('Reproducción detenida');
  /// }
  /// ```
  Future<void> stop() async {
    if (_isPlaying) {
      _logger.info('Stopping audio playback.');
      try {
        await _audioPlayer.stop();
        _isPlaying = false;
        _currentPath = null;
      } catch (e, stackTrace) {
         _logger.error('Error stopping audio', e, stackTrace);
         _isPlaying = false;
         _currentPath = null;
         rethrow; // Relanzar para manejo por parte del llamador
      }
    }
  }

  /// Libera los recursos utilizados por el [AudioPlayer].
  ///
  /// Este método debe llamarse cuando el servicio ya no sea necesario, 
  /// típicamente durante la finalización de la aplicación o al desmontar 
  /// un widget que utiliza el servicio de forma exclusiva.
  ///
  /// Importante: Después de llamar a [dispose], este servicio no debe ser utilizado.
  /// El intento de usar [play] o [stop] después de [dispose] resultará en excepciones.
  Future<void> dispose() async {
    _logger.info('Disposing AudioPlayerService.');
    await _audioPlayer.dispose();
    _isPlaying = false;
    _currentPath = null;
  }
}
