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
  /// [audioPath] debe ser la ruta relativa al archivo en assets
  /// [loop] indica si el audio debe reproducirse en bucle
  Future<void> playAudio(String audioPath, {bool loop = false}) async {
    try {
      // Obtener o crear el AudioPlayer para este audio
      final player = _getOrCreatePlayer(audioPath);
      
      // Obtener o crear el Source del audio
      final source = _getOrCreateSource(audioPath);

      // Configurar el player
      await player.setVolume(_volume);
      if (loop) {
        await player.setReleaseMode(ReleaseMode.loop);
      } else {
        await player.setReleaseMode(ReleaseMode.release);
      }

      // Reproducir el audio
      await player.play(source);
    } catch (e) {
      debugPrint('Error reproduciendo audio $audioPath: $e');
      rethrow;
    }
  }

  /// Pausar la reproducción de un audio específico
  Future<void> pauseAudio(String audioPath) async {
    final player = _audioPlayers[audioPath];
    if (player != null) {
      await player.pause();
    }
  }

  /// Detener la reproducción de un audio específico
  Future<void> stopAudio(String audioPath) async {
    final player = _audioPlayers[audioPath];
    if (player != null) {
      await player.stop();
    }
  }

  /// Detener todos los audios en reproducción
  Future<void> stopAllAudio() async {
    for (final player in _audioPlayers.values) {
      await player.stop();
    }
  }

  /// Liberar recursos de un audio específico
  Future<void> disposeAudio(String audioPath) async {
    final player = _audioPlayers.remove(audioPath);
    if (player != null) {
      await player.dispose();
    }
    _sourceCache.remove(audioPath);
  }

  /// Liberar todos los recursos
  Future<void> dispose() async {
    for (final player in _audioPlayers.values) {
      await player.dispose();
    }
    _audioPlayers.clear();
    _sourceCache.clear();
  }

  /// Obtener un AudioPlayer existente o crear uno nuevo
  AudioPlayer _getOrCreatePlayer(String audioPath) {
    if (!_audioPlayers.containsKey(audioPath)) {
      _audioPlayers[audioPath] = AudioPlayer();
    }
    return _audioPlayers[audioPath]!;
  }

  /// Obtener un Source existente o crear uno nuevo
  Source _getOrCreateSource(String audioPath) {
    if (!_sourceCache.containsKey(audioPath)) {
      _sourceCache[audioPath] = AssetSource(audioPath);
    }
    return _sourceCache[audioPath]!;
  }
}