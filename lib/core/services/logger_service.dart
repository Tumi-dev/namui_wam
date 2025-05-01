import 'package:logger/logger.dart';

/// {@template logger_service}
/// Servicio Singleton para gestionar el logging en toda la aplicación.
///
/// Utiliza el paquete `logger` para proporcionar una salida de log formateada
/// y con niveles (debug, info, warning, error, verbose).
/// {@endtemplate}
class LoggerService {
  static final LoggerService _instance = LoggerService._internal();
  /// Obtiene la instancia única del [LoggerService].
  factory LoggerService() => _instance;
  /// Constructor interno para inicializar el logger con [PrettyPrinter].
  LoggerService._internal() {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2, // Número de llamadas de método a mostrar en el stacktrace
        errorMethodCount: 8, // Número de llamadas para errores
        lineLength: 120, // Ancho de la línea de salida
        colors: true, // Usar colores ANSI
        printEmojis: true, // Imprimir emojis para niveles de log
        printTime: true, // Incluir timestamp
      ),
    );
  }

  /// Instancia interna del logger del paquete `logger`.
  late final Logger _logger;

  /// Registra un mensaje con nivel de depuración (debug).
  ///
  /// Útil para información detallada durante el desarrollo.
  /// [message] El mensaje a registrar.
  /// [error] Un objeto de error opcional asociado.
  /// [stackTrace] Un stacktrace opcional asociado.
  void debug(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// Registra un mensaje informativo (info).
  ///
  /// Para eventos generales de la aplicación.
  /// [message] El mensaje a registrar.
  /// [error] Un objeto de error opcional asociado.
  /// [stackTrace] Un stacktrace opcional asociado.
  void info(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Registra un mensaje de advertencia (warning).
  ///
  /// Indica una situación potencialmente problemática.
  /// [message] El mensaje a registrar.
  /// [error] Un objeto de error opcional asociado.
  /// [stackTrace] Un stacktrace opcional asociado.
  void warning(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Registra un mensaje de error.
  ///
  /// Para errores críticos o excepciones capturadas.
  /// [message] El mensaje a registrar.
  /// [error] Un objeto de error opcional asociado.
  /// [stackTrace] Un stacktrace opcional asociado.
  void error(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Registra un mensaje detallado (verbose).
  ///
  /// Para información de muy bajo nivel, generalmente desactivada en producción.
  /// [message] El mensaje a registrar.
  /// [error] Un objeto de error opcional asociado.
  /// [stackTrace] Un stacktrace opcional asociado.
  void verbose(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.v(message, error: error, stackTrace: stackTrace);
  }
}
