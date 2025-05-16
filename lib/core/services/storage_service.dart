import 'package:hive_flutter/hive_flutter.dart';
import 'package:namuiwam/core/models/user_progress.dart';
import 'package:namuiwam/core/services/logger_service.dart';
import 'package:get_it/get_it.dart'; // Import GetIt

/// {@template storage_service}
/// Servicio Singleton para gestionar el almacenamiento local persistente utilizando Hive.
///
/// Este servicio proporciona una interfaz unificada para:
/// - Inicializar el sistema de almacenamiento local
/// - Guardar el progreso de los usuarios en las actividades
/// - Recuperar datos guardados anteriormente
/// - Gestionar el ciclo de vida del almacenamiento
///
/// Implementa el patrón Singleton para garantizar una única instancia de acceso
/// al almacenamiento en toda la aplicación.
///
/// Internamente utiliza [Hive](https://pub.dev/packages/hive) como motor de
/// almacenamiento, aprovechando su velocidad y facilidad de uso para
/// guardar objetos [UserProgress] serializados.
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
  ///
  /// Este nombre identifica la colección de datos en Hive. El contenido
  /// de esta caja persiste entre sesiones de la aplicación.
  static const String progressBoxName = 'user_progress';

  /// Inicializa el servicio de almacenamiento.
  ///
  /// Debe llamarse antes de usar cualquier otro método del servicio,
  /// típicamente durante el inicio de la aplicación.
  /// 
  /// Este método realiza las siguientes operaciones:
  /// 1. Inicializa Hive para Flutter
  /// 2. Registra el adaptador [UserProgressAdapter] para serialización
  /// 3. Abre la caja [progressBoxName] para almacenar el progreso
  ///
  /// Si el servicio ya está inicializado, simplemente retorna sin hacer nada.
  /// 
  /// Ejemplo:
  /// ```dart
  /// final storageService = getIt<StorageService>();
  /// await storageService.init();
  /// print('Almacenamiento inicializado correctamente');
  /// ```
  ///
  /// Lanza una excepción si ocurre un error durante la inicialización.
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
  /// Este método almacena un objeto [UserProgress] en Hive utilizando
  /// una clave compuesta basada en [activityId] y [levelId].
  /// 
  /// Si ya existe un progreso guardado para la misma actividad y nivel,
  /// será sobrescrito con los nuevos datos.
  ///
  /// Ejemplo:
  /// ```dart
  /// final progress = UserProgress(
  ///   activityId: 1,
  ///   levelId: 2,
  ///   score: 85,
  ///   completed: true,
  ///   timestamp: DateTime.now(),
  /// );
  /// 
  /// await storageService.saveProgress(progress);
  /// ```
  ///
  /// [progress] El objeto [UserProgress] a guardar.
  ///
  /// Lanza una excepción si el servicio no está inicializado o si ocurre un error al guardar.
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
  /// Busca en el almacenamiento un objeto [UserProgress] guardado
  /// previamente para la combinación de [activityId] y [levelId].
  ///
  /// Retorna:
  /// - El objeto [UserProgress] si existe
  /// - `null` si no hay datos guardados para esa combinación o si ocurre un error
  ///
  /// Ejemplo:
  /// ```dart
  /// final progress = storageService.getProgress(1, 2);
  /// if (progress != null) {
  ///   print('Puntuación anterior: ${progress.score}');
  ///   print('Completado: ${progress.completed}');
  /// } else {
  ///   print('No hay progreso guardado para esta actividad y nivel');
  /// }
  /// ```
  ///
  /// [activityId] El ID de la actividad.
  /// [levelId] El ID del nivel.
  ///
  /// Lanza una excepción si el servicio no está inicializado.
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
  /// Recupera todos los objetos [UserProgress] almacenados en la caja,
  /// independientemente de su clave.
  ///
  /// Esta función es útil para:
  /// - Mostrar un resumen del progreso del usuario
  /// - Generar estadísticas generales de uso
  /// - Realizar copias de seguridad del progreso
  ///
  /// Ejemplo:
  /// ```dart
  /// final allProgress = storageService.getAllProgress();
  /// print('Total de registros: ${allProgress.length}');
  /// 
  /// // Encontrar niveles completados
  /// final completedLevels = allProgress
  ///   .where((progress) => progress.completed)
  ///   .length;
  /// print('Niveles completados: $completedLevels');
  /// ```
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

  /// Elimina todos los registros de progreso almacenados.
  ///
  /// Este método borra completamente el contenido de la caja,
  /// eliminando todo el progreso guardado. Esta operación no se puede deshacer.
  ///
  /// Utilizar con precaución, típicamente en casos como:
  /// - Reiniciar el progreso del usuario
  /// - Implementar una función de "borrar datos"
  /// - Gestionar situaciones de error crítico
  ///
  /// Ejemplo:
  /// ```dart
  /// await storageService.clearProgress();
  /// print('Todo el progreso ha sido eliminado');
  /// ```
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

  /// Cierra la caja de Hive y libera recursos.
  ///
  /// Debe llamarse cuando el servicio ya no sea necesario,
  /// típicamente durante el cierre de la aplicación para
  /// garantizar que todos los datos han sido guardados correctamente
  /// y que los recursos han sido liberados.
  ///
  /// Si la caja no está abierta o el servicio no está inicializado,
  /// este método no tiene efecto.
  ///
  /// Ejemplo:
  /// ```dart
  /// // Al finalizar la aplicación
  /// await storageService.close();
  /// ```
  Future<void> close() async {
     if (_isInitialized && _progressBox.isOpen) {
       await _progressBox.close();
       _isInitialized = false; // Marcar como no inicializado después de cerrar
       _logger.info('Caja "$progressBoxName" cerrada.');
     }
  }
}
