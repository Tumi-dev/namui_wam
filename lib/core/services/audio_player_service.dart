import 'package:audioplayers/audioplayers.dart';
import 'package:namui_wam/core/di/service_locator.dart';
import 'package:namui_wam/core/services/logger_service.dart';

class AudioPlayerService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final LoggerService _logger = getIt<LoggerService>();
  bool _isPlaying = false;
  String? _currentPath;

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

  bool get isPlaying => _isPlaying;
  String? get currentPlayingPath => _currentPath;

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
      await _audioPlayer.play(AssetSource(assetPath.replaceFirst('assets/', ''))); 
      _currentPath = assetPath;
      _isPlaying = true; 
    } catch (e, stackTrace) {
      _logger.error('Error playing audio: $assetPath', e, stackTrace);
      _isPlaying = false;
      _currentPath = null;
    }
  }

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

  Future<void> dispose() async {
    _logger.info('Disposing AudioPlayerService.');
    await _audioPlayer.dispose();
  }
}
