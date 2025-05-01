import 'package:hive_flutter/hive_flutter.dart';
import 'package:namuiwam/core/models/user_progress.dart';
import 'package:namuiwam/core/services/logger_service.dart';
import 'package:get_it/get_it.dart'; // Import GetIt

/// {@template storage_service}
/// Servicio Singleton para gestionar el almacenamiento local persistente
/// utilizando Hive.
///
/// Se encarga de inicializar Hive, registrar adaptadores (como [UserProgressAdapter])
/// y proporcionar métodos para guardar, recuperar y eliminar datos, específicamente
/// el progreso del usuario ([UserProgress]).
/// {@endtemplate}
class StorageService {
  static final StorageService _instance = StorageService._internal();
  /// Obtiene la instancia única del [StorageService].
  factory StorageService() => _instance;
  StorageService._internal();

  // Obtener LoggerService desde GetIt
  final _logger = GetIt.instance<LoggerService>();
  late Box<UserProgress> _progressBox;
  bool _isInitialized = false;

  /// Nombre de la caja de Hive utilizada para almacenar el progreso.
  static const String progressBoxName = 'user_progress';

  /// Inicializa el servicio de almacenamiento.
  ///
  /// Debe llamarse antes de usar cualquier otro método del servicio.
  /// Inicializa Hive para Flutter, registra el [UserProgressAdapter] y
  /// abre la caja ([progressBoxName]) para almacenar el progreso.
  Future<void> init() async {
    if (_isInitialized) {
      _logger.info('StorageService ya está inicializado.');
      return;
    }
    try {
      _logger.info('Inicializando StorageService...');
      await Hive.initFlutter();
      // Registrar el adaptador solo si no está registrado
      if (!Hive.isAdapterRegistered(UserProgressAdapter().typeId)) {
        Hive.registerAdapter(UserProgressAdapter());
        _logger.info('UserProgressAdapter registrado.');
      }
      _progressBox = await Hive.openBox<UserProgress>(progressBoxName);
      _isInitialized = true;
      _logger.info('Storage service inicializado y caja "$progressBoxName" abierta.');
    } catch (e, stackTrace) {
      _logger.error('Error inicializando StorageService', e, stackTrace);
      _isInitialized = false;
      // Relanzar para indicar fallo crítico
      rethrow;
    }
  }

  /// Guarda el progreso de un usuario para una actividad y nivel específicos.
  ///
  /// Utiliza una clave compuesta 'activityId_levelId' para almacenar el [progress].
  /// Lanza una excepción si el servicio no está inicializado o si ocurre un error al guardar.
  ///
  /// [progress] El objeto [UserProgress] a guardar.
  Future<void> saveProgress(UserProgress progress) async {
    if (!_isInitialized) {
      _logger.error('StorageService no inicializado. Llama a init() primero.');
      throw Exception('StorageService no inicializado.');
    }
    try {
      // Usar userId si está disponible y es relevante, o una clave genérica si no hay usuarios
      // Por ahora, asumimos un solo usuario implícito.
      final key = '${progress.activityId}_${progress.levelId}';
      await _progressBox.put(key, progress);
      _logger.info('Progreso guardado para clave: $key');
    } catch (e, stackTrace) {
      _logger.error('Error guardando progreso para clave: ${progress.activityId}_${progress.levelId}', e, stackTrace);
      rethrow; // Relanzar para que el llamador maneje el error
    }
  }

  /// Obtiene el progreso guardado para una actividad y nivel específicos.
  ///
  /// Retorna el [UserProgress] si existe, o `null` si no se encuentra
  /// o si ocurre un error.
  /// Lanza una excepción si el servicio no está inicializado.
  ///
  /// [activityId] El ID de la actividad.
  /// [levelId] El ID del nivel.
  UserProgress? getProgress(int activityId, int levelId) {
    if (!_isInitialized) {
      _logger.error('StorageService no inicializado. Llama a init() primero.');
      throw Exception('StorageService no inicializado.');
    }
    try {
      final key = '${activityId}_${levelId}';
      final progress = _progressBox.get(key);
      if (progress != null) {
        _logger.info('Progreso obtenido para clave: $key');
      } else {
        _logger.info('No se encontró progreso para clave: $key');
      }
      return progress;
    } catch (e, stackTrace) {
      _logger.error('Error obteniendo progreso para clave: ${activityId}_${levelId}', e, stackTrace);
      return null; // Retornar null en caso de error
    }
  }

  /// Obtiene una lista de todos los registros de progreso guardados.
  ///
  /// Retorna una lista vacía si no hay progreso guardado o si ocurre un error.
  /// Lanza una excepción si el servicio no está inicializado.
  List<UserProgress> getAllProgress() {
    if (!_isInitialized) {
      _logger.error('StorageService no inicializado. Llama a init() primero.');
      throw Exception('StorageService no inicializado.');
    }
    try {
      final allProgress = _progressBox.values.toList();
      _logger.info('Obtenidos ${allProgress.length} registros de progreso.');
      return allProgress;
    } catch (e, stackTrace) {
      _logger.error('Error obteniendo todo el progreso', e, stackTrace);
      return []; // Retornar lista vacía en caso de error
    }
  }

  /// Elimina todos los registros de progreso de la caja.
  ///
  /// Lanza una excepción si el servicio no está inicializado o si ocurre un error.
  Future<void> clearProgress() async {
    if (!_isInitialized) {
      _logger.error('StorageService no inicializado. Llama a init() primero.');
      throw Exception('StorageService no inicializado.');
    }
    try {
      final count = await _progressBox.clear();
      _logger.info('Progreso eliminado. $count registros borrados.');
    } catch (e, stackTrace) {
      _logger.error('Error eliminando el progreso', e, stackTrace);
      rethrow; // Relanzar para que el llamador maneje el error
    }
  }

  /// Cierra la caja de Hive. Llamar al cerrar la aplicación si es necesario.
  Future<void> close() async {
     if (_isInitialized && _progressBox.isOpen) {
       await _progressBox.close();
       _isInitialized = false; // Marcar como no inicializado después de cerrar
       _logger.info('Caja "$progressBoxName" cerrada.');
     }
  }
}
