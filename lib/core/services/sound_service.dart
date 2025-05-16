import 'package:audioplayers/audioplayers.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:namuiwam/core/services/logger_service.dart'; // Asumiendo esta ruta para LoggerService
import 'package:flutter/widgets.dart'; // 1. Importar flutter/widgets.dart

// TODO: Importar StorageService y definir las claves de almacenamiento

// TODO: Considerar obtener StorageService a través de un service locator si se usa (como GetIt)

class SoundService implements WidgetsBindingObserver { // 2. Implementar WidgetsBindingObserver
  final LoggerService _logger = GetIt.instance<LoggerService>();

  // Instancias de AudioPlayer
  late AudioPlayer _backgroundMusicPlayer;
  late AudioPlayer _correctSoundPlayer;
  late AudioPlayer _incorrectSoundPlayer;

  // Caja de Hive para configuraciones
  late Box _settingsBox;
  static const String _audioSettingsBoxName = 'audio_settings_box';

  // Claves para Hive
  static const String _keyBackgroundVolume = 'background_music_volume';
  static const String _keyBackgroundEnabled = 'background_music_enabled';
  static const String _keyEffectsVolume = 'effects_volume';
  static const String _keyEffectsEnabled = 'effects_enabled';

  // Estado y volumen para la música de fondo
  double _backgroundMusicVolume = 0.2; // Inicia con volumen bajo por defecto
  bool _isBackgroundMusicEnabled = true;

  // Estado y volumen para los sonidos de correcto/incorrecto (compartido)
  double _effectsVolume = 1.0; // Inicia con volumen alto por defecto
  bool _areEffectsEnabled = true;

  // Rutas a los archivos de audio (obtenidas del pubspec.yaml)
  static const String _correctSoundPath = 'audio/correcto_incorrecto/correcto.wav';
  static const String _incorrectSoundPath = 'audio/correcto_incorrecto/incorrecto.wav';
  static const String _backgroundMusicPath = 'audio/isik_musik.mp3';

  // TODO: Definir claves para SharedPreferences/Hive
  // static const String _keyBackgroundVolume = 'background_volume';
  // static const String _keyBackgroundEnabled = 'background_enabled';
  // static const String _keyEffectsVolume = 'effects_volume';
  // static const String _keyEffectsEnabled = 'effects_enabled';

  // ---- Singleton Setup ----
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;

  SoundService._internal() {
    _logger.info('SoundService: Internal constructor called.');
    _backgroundMusicPlayer = AudioPlayer();
    // Aplicar AudioContext específico para el reproductor de música de fondo
    _backgroundMusicPlayer.setAudioContext(
      AudioContext(
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: { AVAudioSessionOptions.mixWithOthers },
        ),
        android: AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: false,
          audioFocus: AndroidAudioFocus.gain, 
        ),
      ),
    ).then((_) {
      _logger.debug('SoundService: Specific AudioContext set for _backgroundMusicPlayer.');
    }).catchError((e, stackTrace) {
      _logger.error('SoundService: Error setting specific AudioContext for _backgroundMusicPlayer.', e, stackTrace);
    });
    _backgroundMusicPlayer.setReleaseMode(ReleaseMode.loop);

    _correctSoundPlayer = AudioPlayer();
    _correctSoundPlayer.setReleaseMode(ReleaseMode.release);
    // Aplicar AudioContext para efectos de sonido correctos
    _correctSoundPlayer.setAudioContext(AudioContext(
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback, // O .ambient
        options: { AVAudioSessionOptions.mixWithOthers },
      ),
      android: AudioContextAndroid(
        isSpeakerphoneOn: false,
        stayAwake: false,
        audioFocus: AndroidAudioFocus.gainTransientMayDuck,
      ),
    )).then((_) {
      _logger.debug('SoundService: AudioContext set for _correctSoundPlayer.');
    }).catchError((e, stackTrace) {
      _logger.error('SoundService: Error setting AudioContext for _correctSoundPlayer.', e, stackTrace);
    });

    _incorrectSoundPlayer = AudioPlayer();
    _incorrectSoundPlayer.setReleaseMode(ReleaseMode.release);
    // Aplicar AudioContext para efectos de sonido incorrectos
    _incorrectSoundPlayer.setAudioContext(AudioContext(
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback, // O .ambient
        options: { AVAudioSessionOptions.mixWithOthers },
      ),
      android: AudioContextAndroid(
        isSpeakerphoneOn: false,
        stayAwake: false,
        audioFocus: AndroidAudioFocus.gainTransientMayDuck,
      ),
    )).then((_) {
      _logger.debug('SoundService: AudioContext set for _incorrectSoundPlayer.');
    }).catchError((e, stackTrace) {
      _logger.error('SoundService: Error setting AudioContext for _incorrectSoundPlayer.', e, stackTrace);
    });
    
    // TODO: Cargar configuraciones guardadas al inicializar
    // _loadSettings(); 
  }

  Future<void> init() async {
    _logger.info('SoundService: Initializing...');
    WidgetsBinding.instance.addObserver(this); // 3. Registrar observador

    // Configurar el contexto de audio global
    // Esto es crucial para permitir que la música de fondo coexista con otros sonidos.
    final audioContext = AudioContext(
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback, // Cambiado de .ambient a .playback
        options: {
          AVAudioSessionOptions.mixWithOthers, // Mantener para permitir la mezcla
          // AVAudioSessionOptions.duckOthers, // Opcional: si quieres que otros audios bajen volumen
        },
      ),
      android: AudioContextAndroid(
        isSpeakerphoneOn: false, // Generalmente false para música
        stayAwake: false, // Solo si es necesario mantener la pantalla activa
        audioFocus: AndroidAudioFocus.gain, // Mantener un valor no nulo para audioFocus.
      ),
    );
    try {
      await AudioPlayer.global.setAudioContext(audioContext);
      _logger.info('SoundService: Global AudioContext configured.');
    } catch (e, stackTrace) {
      _logger.error('SoundService: Error setting global AudioContext.', e, stackTrace);
    }
    // Fin de la configuración del contexto de audio global

    try {
      _settingsBox = await Hive.openBox(_audioSettingsBoxName);
      _logger.info('SoundService: Box "$_audioSettingsBoxName" opened.');
      await _loadSettings();
    } catch (e, stackTrace) {
      _logger.error('SoundService: Error opening Hive box or loading settings.', e, stackTrace);
    }
    
    await _backgroundMusicPlayer.setVolume(_backgroundMusicVolume);
    await _correctSoundPlayer.setVolume(_effectsVolume);
    await _incorrectSoundPlayer.setVolume(_effectsVolume);

    if (_isBackgroundMusicEnabled) {
        // Llama a playBackgroundMusic que ahora maneja la reanudación si es necesario
        await playBackgroundMusic(); 
    } else {
        // Si no está habilitada y estaba sonando/pausada, asegúrate de que esté pausada.
        if (_backgroundMusicPlayer.state == PlayerState.playing || _backgroundMusicPlayer.state == PlayerState.paused) {
            await _backgroundMusicPlayer.pause();
            _logger.debug('SoundService: Background music ensured paused during init as it is disabled in settings.');
        }
    }
    _logger.info('SoundService: Initialization complete.');
  }

  // --- Persistencia ---
  Future<void> _loadSettings() async {
    _logger.info('SoundService: Loading settings...');
    try {
      _backgroundMusicVolume = _settingsBox.get(_keyBackgroundVolume, defaultValue: 0.2) as double;
      _isBackgroundMusicEnabled = _settingsBox.get(_keyBackgroundEnabled, defaultValue: true) as bool;
      _effectsVolume = _settingsBox.get(_keyEffectsVolume, defaultValue: 1.0) as double;
      _areEffectsEnabled = _settingsBox.get(_keyEffectsEnabled, defaultValue: true) as bool;
      _logger.info('SoundService: Settings loaded. BG Vol: $_backgroundMusicVolume, BG Enabled: $_isBackgroundMusicEnabled, FX Vol: $_effectsVolume, FX Enabled: $_areEffectsEnabled');
    } catch (e, stackTrace) {
      _logger.error('SoundService: Error loading settings from Hive. Using default values.', e, stackTrace);
      // Asegurar valores por defecto si hay error de casteo o lectura
      _backgroundMusicVolume = 0.2;
      _isBackgroundMusicEnabled = true;
      _effectsVolume = 1.0;
      _areEffectsEnabled = true;
    }
  }

  Future<void> _saveSettings() async {
    _logger.info('SoundService: Saving settings...');
    try {
      await _settingsBox.put(_keyBackgroundVolume, _backgroundMusicVolume);
      await _settingsBox.put(_keyBackgroundEnabled, _isBackgroundMusicEnabled);
      await _settingsBox.put(_keyEffectsVolume, _effectsVolume);
      await _settingsBox.put(_keyEffectsEnabled, _areEffectsEnabled);
      _logger.info('SoundService: Settings saved.');
    } catch (e, stackTrace) {
      _logger.error('SoundService: Error saving settings to Hive.', e, stackTrace);
    }
  }

  // --- Música de Fondo ---
  Future<void> playBackgroundMusic() async {
    // Asegurar que el modo loop esté establecido
    await _backgroundMusicPlayer.setReleaseMode(ReleaseMode.loop);

    if (_isBackgroundMusicEnabled) {
      if (_backgroundMusicPlayer.state == PlayerState.paused) {
        try {
          _logger.debug('SoundService: Resuming background music.');
          await _backgroundMusicPlayer.resume();
          await _backgroundMusicPlayer.setVolume(_backgroundMusicVolume); // Re-aplicar volumen por si acaso
        } catch (e, stackTrace) {
          _logger.error('SoundService: Error resuming background music.', e, stackTrace);
        }
      } else if (_backgroundMusicPlayer.state != PlayerState.playing) {
        try {
          _logger.debug('SoundService: Playing background music from source.');
          await _backgroundMusicPlayer.play(AssetSource(_backgroundMusicPath));
          await _backgroundMusicPlayer.setVolume(_backgroundMusicVolume);
        } catch (e, stackTrace) {
          _logger.error('SoundService: Error playing background music from source.', e, stackTrace);
        }
      } else {
        // Ya está sonando, solo asegurar el volumen
        _logger.debug('SoundService: Background music already playing, ensuring volume.');
        await _backgroundMusicPlayer.setVolume(_backgroundMusicVolume);
      }
    } else {
      // Si se intenta reproducir pero está deshabilitado, asegurar que esté pausado.
      if (_backgroundMusicPlayer.state == PlayerState.playing || _backgroundMusicPlayer.state == PlayerState.paused) {
          _logger.debug('SoundService: Play called but music disabled, ensuring pause.');
          await _backgroundMusicPlayer.pause();
      }
    }
  }

  Future<void> stopBackgroundMusic() async {
    try {
      _logger.info('SoundService: Stopping background music.');
      await _backgroundMusicPlayer.stop();
    } catch (e, stackTrace) {
      _logger.error('SoundService: Error stopping background music.', e, stackTrace);
    }
  }

  Future<void> setBackgroundMusicVolume(double volume) async {
    _backgroundMusicVolume = volume.clamp(0.0, 1.0);
    _logger.info('SoundService: Setting background music volume to $_backgroundMusicVolume.');
    await _backgroundMusicPlayer.setVolume(_backgroundMusicVolume);
    await _saveSettings(); 
  }

  Future<void> toggleBackgroundMusic(bool enabled) async {
    _isBackgroundMusicEnabled = enabled;
    _logger.info('SoundService: Toggling background music to $_isBackgroundMusicEnabled.');
    if (_isBackgroundMusicEnabled) {
      await playBackgroundMusic(); // playBackgroundMusic ahora maneja la reanudación
    } else {
      if (_backgroundMusicPlayer.state == PlayerState.playing || _backgroundMusicPlayer.state == PlayerState.paused) {
        await _backgroundMusicPlayer.pause(); // Usar pause en lugar de stop
        _logger.debug('SoundService: Background music paused due to toggle off.');
      }
    }
    await _saveSettings();
  }

  double get backgroundMusicVolume => _backgroundMusicVolume;
  bool get isBackgroundMusicEnabled => _isBackgroundMusicEnabled;

  // --- Sonidos de Correcto/Incorrecto ---
  Future<void> playCorrectSound() async {
    if (_areEffectsEnabled) {
      try {
        _logger.debug('SoundService: Playing correct sound.');
        // Asegurar que el player no esté ya sonando para evitar solapamientos rápidos si se llama múltiples veces
        if (_correctSoundPlayer.state == PlayerState.playing) {
            await _correctSoundPlayer.stop(); // Detener si ya está sonando para reiniciar
        }
        await _correctSoundPlayer.play(AssetSource(_correctSoundPath));
        await _correctSoundPlayer.setVolume(_effectsVolume); 
      } catch (e, stackTrace) {
        _logger.error('SoundService: Error playing correct sound.', e, stackTrace);
      }
    }
  }

  Future<void> playIncorrectSound() async {
    if (_areEffectsEnabled) {
      try {
        _logger.debug('SoundService: Playing incorrect sound.');
         if (_incorrectSoundPlayer.state == PlayerState.playing) {
            await _incorrectSoundPlayer.stop(); 
        }
        await _incorrectSoundPlayer.play(AssetSource(_incorrectSoundPath));
        await _incorrectSoundPlayer.setVolume(_effectsVolume);
      } catch (e, stackTrace) {
        _logger.error('SoundService: Error playing incorrect sound.', e, stackTrace);
      }
    }
  }

  Future<void> setEffectsVolume(double volume) async {
    _effectsVolume = volume.clamp(0.0, 1.0);
    _logger.info('SoundService: Setting effects volume to $_effectsVolume.');
    await _correctSoundPlayer.setVolume(_effectsVolume);
    await _incorrectSoundPlayer.setVolume(_effectsVolume);
    await _saveSettings();
  }

  Future<void> toggleEffects(bool enabled) async {
    _areEffectsEnabled = enabled;
    _logger.info('SoundService: Toggling effects to $_areEffectsEnabled.');
    await _saveSettings();
  }

  double get effectsVolume => _effectsVolume;
  bool get areEffectsEnabled => _areEffectsEnabled;

  // --- Limpieza ---
  Future<void> dispose() async {
    _logger.info('SoundService: Disposing...');
    WidgetsBinding.instance.removeObserver(this);
    await _backgroundMusicPlayer.dispose();
    await _correctSoundPlayer.dispose();
    await _incorrectSoundPlayer.dispose();
    if (_settingsBox.isOpen) {
      await _settingsBox.close();
      _logger.info('SoundService: Box "$_audioSettingsBoxName" closed.');
    }
    _logger.info('SoundService: Disposed.');
  }

  // 5. Implementar didChangeAppLifecycleState
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _logger.info('SoundService: App lifecycle state changed to $state');
    switch (state) {
      case AppLifecycleState.resumed:
        _logger.info('SoundService: App resumed, attempting to play/resume background music.');
        if (_isBackgroundMusicEnabled) {
           playBackgroundMusic(); 
        }
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden: 
      case AppLifecycleState.detached:
        _logger.info('SoundService: App inactive/paused/hidden/detached, pausing background music if playing. Current state: ${_backgroundMusicPlayer.state}');
        if (_backgroundMusicPlayer.state == PlayerState.playing) {
          _backgroundMusicPlayer.pause();
          _logger.debug('SoundService: Background music paused due to app state change.');
        }
        break;
    }
  }

  @override
  void didChangeAccessibilityFeatures() {
    _logger.debug('SoundService: didChangeAccessibilityFeatures');
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    _logger.debug('SoundService: didChangeLocales: $locales');
  }

  @override
  void didChangePlatformBrightness() {
    _logger.debug('SoundService: didChangePlatformBrightness');
  }

  @override
  void didChangeTextScaleFactor() {
    _logger.debug('SoundService: didChangeTextScaleFactor');
  }

  @override
  void didHaveMemoryPressure() {
    _logger.debug('SoundService: didHaveMemoryPressure');
  }

  @override
  Future<bool> didPopRoute() {
    _logger.debug('SoundService: didPopRoute');
    return Future.value(false);
  }

  @override
  Future<bool> didPushRoute(String route) {
    _logger.debug('SoundService: didPushRoute: $route');
    return Future.value(false);
  }

  @override
  Future<bool> didPushRouteInformation(RouteInformation routeInformation) {
    _logger.debug('SoundService: didPushRouteInformation: ${routeInformation.uri}');
    return Future.value(false);
  }
  
  // Optional: Flutter versions might require didChangeMetrics or have different signatures.
  // Check your specific Flutter SDK for exact WidgetsBindingObserver members.
  // @override
  // void didChangeMetrics() { // Deprecated
  //   _logger.info('SoundService: didChangeMetrics');
  // }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    _logger.warning('SoundService: Called noSuchMethod for ${invocation.memberName}. This might indicate an unimplemented method from an interface.');
    return super.noSuchMethod(invocation); 
  }
}
