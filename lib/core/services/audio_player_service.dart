import 'package:audioplayers/audioplayers.dart';
import 'package:namuiwam/core/di/service_locator.dart';
import 'package:namuiwam/core/services/logger_service.dart';

/// {@template audio_player_service}
/// Un servicio para gestionar la reproducción de archivos de audio utilizando el paquete `audioplayers`.
///
/// Proporciona funcionalidades para reproducir, detener y monitorear el estado
/// de la reproducción de audio desde los assets de la aplicación.
/// {@endtemplate}
class AudioPlayerService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final LoggerService _logger = getIt<LoggerService>();
  bool _isPlaying = false;
  String? _currentPath;

  /// {@macro audio_player_service}
  AudioPlayerService() {
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

  /// Devuelve `true` si un audio se está reproduciendo actualmente.
  bool get isPlaying => _isPlaying;

  /// Devuelve la ruta del asset del audio que se está reproduciendo actualmente,
  /// o `null` si no se está reproduciendo nada.
  String? get currentPlayingPath => _currentPath;

  /// Reproduce un archivo de audio desde la ruta del asset especificada.
  ///
  /// Si ya se está reproduciendo el mismo audio, lo detiene.
  /// Si se está reproduciendo un audio diferente, detiene el anterior antes
  /// de iniciar la nueva reproducción.
  ///
  /// [assetPath] La ruta completa del asset de audio (ej. 'assets/audio/sound.wav').
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
    }
  }

  /// Detiene la reproducción de audio actual, si hay alguna.
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
      }
    }
  }

  /// Libera los recursos utilizados por el [AudioPlayer].
  ///
  /// Debe llamarse cuando el servicio ya no sea necesario para evitar fugas de memoria.
  Future<void> dispose() async {
    _logger.info('Disposing AudioPlayerService.');
    await _audioPlayer.dispose();
  }
}
