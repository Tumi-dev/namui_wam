import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:namuiwam/core/services/logger_service.dart';
import 'package:get_it/get_it.dart';

/// {@template feedback_service}
/// Servicio Singleton para proporcionar feedback al usuario, tanto háptico (vibración)
/// como visual (Snackbars).
///
/// Utiliza `HapticFeedback` para las vibraciones y `ScaffoldMessenger` para
/// mostrar mensajes temporales en la pantalla.
/// {@endtemplate}
class FeedbackService {
  static final FeedbackService _instance = FeedbackService._internal();
  /// Obtiene la instancia única del [FeedbackService].
  factory FeedbackService() => _instance;
  FeedbackService._internal();

  final _logger = GetIt.instance<LoggerService>();

  /// Produce una vibración corta y ligera.
  ///
  /// Útil para feedback sutil, como la selección de un elemento.
  Future<void> lightHapticFeedback() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      _logger.warning('Error al producir feedback háptico ligero', e);
    }
  }

  /// Produce una vibración de intensidad media.
  ///
  /// Adecuado para confirmar acciones importantes pero no críticas.
  Future<void> mediumHapticFeedback() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      _logger.warning('Error al producir feedback háptico medio', e);
    }
  }

  /// Produce una vibración fuerte.
  ///
  /// Indicado para eventos significativos, como completar una tarea o un error.
  Future<void> heavyHapticFeedback() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      _logger.warning('Error al producir feedback háptico fuerte', e);
    }
  }

  /// Muestra un Snackbar visual de éxito.
  ///
  /// [context] El [BuildContext] necesario para encontrar el [ScaffoldMessenger].
  /// [message] El mensaje a mostrar en el Snackbar.
  void showSuccessFeedback(BuildContext context, String message) {
    // Asegurarse de que el contexto todavía está montado
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            // Opcional: Ocultar el snackbar si se presiona OK
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Muestra un Snackbar visual de error.
  ///
  /// [context] El [BuildContext] necesario para encontrar el [ScaffoldMessenger].
  /// [message] El mensaje de error a mostrar en el Snackbar.
  void showErrorFeedback(BuildContext context, String message) {
    // Asegurarse de que el contexto todavía está montado
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            // Opcional: Ocultar el snackbar si se presiona OK
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
