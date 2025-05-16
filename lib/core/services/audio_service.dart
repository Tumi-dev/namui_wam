import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

/// {@template audio_service}
/// Servicio Singleton que maneja toda la lógica de reproducción de audio en la aplicación.
///
/// Utiliza el paquete `audioplayers` para reproducir sonidos desde los assets.
/// Mantiene un caché de `AudioPlayer` y `Source` para optimizar la reproducción
/// y permite controlar un volumen global para todos los sonidos.
/// {@endtemplate}
class AudioService {
  static final AudioService _instance = AudioService._internal();
  /// Obtiene la instancia única del [AudioService].
  factory AudioService() => _instance;
  AudioService._internal();

  /// Cache de AudioPlayers para reutilización. La clave es la ruta del asset.
  final Map<String, AudioPlayer> _audioPlayers = {};
  
  /// Cache de Source para evitar recreación innecesaria. La clave es la ruta del asset.
  final Map<String, Source> _sourceCache = {};

  /// Volumen global para todos los audios (rango de 0.0 a 1.0).
  double _volume = 1.0;

  /// Obtiene el volumen global actual.
  double get volume => _volume;

  /// Establece el volumen global para todos los [AudioPlayer] gestionados.
  ///
  /// El valor se ajusta automáticamente entre 0.0 y 1.0.
  /// Actualiza el volumen en todos los reproductores activos.
  ///
  /// [volume] El nuevo nivel de volumen (0.0 a 1.0).
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    // Actualizar volumen en todos los players activos
    for (final player in _audioPlayers.values) {
      // Podría haber un error si el player ya fue disposed, aunque la lógica actual
      // intenta prevenirlo. Considerar manejo de errores si es necesario.
      try {
        await player.setVolume(_volume);
      } catch (e) {
        debugPrint('Error setting volume for a player: $e');
      }
    }
  }

  /// Reproduce un archivo de audio desde la ruta del asset especificada.
  ///
  /// Obtiene o crea un [AudioPlayer] para la ruta dada, configura su volumen
  /// y modo de liberación, y luego inicia la reproducción.
  /// Si ocurre un error, se imprime en consola y se detienen todos los audios.
  ///
  /// [audioPath] La ruta del asset de audio relativa a la carpeta 'assets' (ej. 'audio/sound.wav').
  Future<void> playAudio(String audioPath) async {
    try {
      // Obtener o crear el AudioPlayer para este audio
      final player = _getOrCreatePlayer(audioPath);
      
      // Obtener o crear el Source del audio desde el caché o crearlo nuevo
      final source = _sourceCache.putIfAbsent(audioPath, () => AssetSource(audioPath));

      // Configurar el player
      await player.setVolume(_volume);
      // ReleaseMode.release libera recursos cuando el audio termina
      await player.setReleaseMode(ReleaseMode.release);

      // Reproducir el audio
      await player.play(source);
    } catch (e) {
      debugPrint('Error reproduciendo audio $audioPath: $e');
      // Considerar si realmente se deben detener todos los audios en caso de error
      // await stopAudio(); 
    }
  }

  /// Detiene la reproducción de todos los audios gestionados por el servicio.
  ///
  /// Itera sobre todos los [AudioPlayer] activos y llama a `stop()` en cada uno.
  /// Luego, llama a `dispose()` para limpiar los recursos.
  Future<void> stopAudio() async {
    try {
      for (final player in _audioPlayers.values) {
        // Verificar si el player aún es válido antes de detener
        // (Aunque `stop` debería manejarlo internamente)
        await player.stop();
      }
      // Disponer después de detener podría ser redundante si ReleaseMode.release funciona
      // pero asegura la limpieza en caso de interrupción manual.
      await dispose(); 
    } catch (e) {
      debugPrint('Error al detener el audio: $e');
    }
  }

  /// Libera todos los recursos asociados con los [AudioPlayer] gestionados.
  ///
  /// Llama a `dispose()` en cada [AudioPlayer] y limpia los cachés internos.
  /// Es importante llamar a este método cuando el servicio ya no se necesita
  /// (ej. al cerrar la aplicación) para evitar fugas de memoria.
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

  /// Obtiene un [AudioPlayer] existente del caché o crea uno nuevo si no existe.
  ///
  /// [audioPath] La ruta del asset utilizada como clave en el caché.
  /// Retorna el [AudioPlayer] asociado a la ruta.
  /// Si se crea un nuevo [AudioPlayer], se configura su [AudioContext]
  /// para permitir la mezcla con otros sonidos y solicitar un foco de audio
  /// transitorio que puede atenuar otros sonidos en Android ([AndroidAudioFocus.gainTransientMayDuck]).
  AudioPlayer _getOrCreatePlayer(String audioPath) {
    // Si ya existe y está en un estado inválido (ej. disposed), crea uno nuevo.
    // Nota: audioplayers no expone fácilmente un estado 'isDisposed'.
    // Se asume que si está en el caché, es potencialmente reutilizable.
    // Si play() falla, se manejará en playAudio.
    if (!_audioPlayers.containsKey(audioPath)) {
      debugPrint('Creando nuevo AudioPlayer para: $audioPath');
      final newPlayer = AudioPlayer();
      // Configurar AudioContext para efectos de sonido cortos/Namtrik
      newPlayer.setAudioContext(AudioContext(
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: { AVAudioSessionOptions.mixWithOthers },
        ),
        android: AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: false,
          audioFocus: AndroidAudioFocus.gainTransientMayDuck,
        ),
      )).then((_) {
        debugPrint('AudioService: AudioContext set for new player: $audioPath');
      }).catchError((e) {
        debugPrint('AudioService: Error setting AudioContext for new player $audioPath: $e');
      });
      _audioPlayers[audioPath] = newPlayer;
      // Opcional: Configurar ID del player para logging
      // _audioPlayers[audioPath]!.setPlayerId('player_$audioPath');
    }
    return _audioPlayers[audioPath]!;
  }
}