import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

/// Servicio que maneja toda la lógica de reproducción de audio en la aplicación.
/// Implementa el patrón Singleton para asegurar una única instancia del servicio.
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  /// Cache de AudioPlayers para reutilización
  final Map<String, AudioPlayer> _audioPlayers = {};
  
  /// Cache de Source para evitar recreación innecesaria
  final Map<String, Source> _sourceCache = {};

  /// Volumen global (0.0 a 1.0)
  double _volume = 1.0;

  /// Obtener el volumen actual
  double get volume => _volume;

  /// Establecer el volumen global
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    // Actualizar volumen en todos los players activos
    for (final player in _audioPlayers.values) {
      await player.setVolume(_volume);
    }
  }

  /// Reproducir un archivo de audio
  Future<void> playAudio(String audioPath) async {
    try {
      // Obtener o crear el AudioPlayer para este audio
      final player = _getOrCreatePlayer(audioPath);
      
      // Obtener o crear el Source del audio
      final source = await AssetSource(audioPath);

      // Configurar el player
      await player.setVolume(_volume);
      await player.setReleaseMode(ReleaseMode.release);

      // Reproducir el audio
      await player.play(source);
    } catch (e) {
      debugPrint('Error reproduciendo audio $audioPath: $e');
      await stopAudio();
    }
  }

  /// Detener todos los audios en reproducción
  Future<void> stopAudio() async {
    try {
      for (final player in _audioPlayers.values) {
        await player.stop();
      }
      await dispose();
    } catch (e) {
      debugPrint('Error al detener el audio: $e');
    }
  }

  /// Liberar todos los recursos
  Future<void> dispose() async {
    try {
      for (final player in _audioPlayers.values) {
        await player.dispose();
      }
      _audioPlayers.clear();
      _sourceCache.clear();
    } catch (e) {
      debugPrint('Error al liberar recursos de audio: $e');
    }
  }

  /// Obtener un AudioPlayer existente o crear uno nuevo
  AudioPlayer _getOrCreatePlayer(String audioPath) {
    if (!_audioPlayers.containsKey(audioPath)) {
      _audioPlayers[audioPath] = AudioPlayer();
    }
    return _audioPlayers[audioPath]!;
  }
}