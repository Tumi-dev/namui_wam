import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:namui_wam/core/services/logger_service.dart';
import 'package:get_it/get_it.dart';

class FeedbackService {
  static final FeedbackService _instance = FeedbackService._internal();
  factory FeedbackService() => _instance;
  FeedbackService._internal();

  final _logger = GetIt.instance<LoggerService>();

  // Vibración corta para feedback táctil
  Future<void> lightHapticFeedback() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      _logger.warning('Error al producir feedback háptico', e);
    }
  }

  // Vibración media para acciones importantes
  Future<void> mediumHapticFeedback() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      _logger.warning('Error al producir feedback háptico', e);
    }
  }

  // Vibración fuerte para eventos significativos
  Future<void> heavyHapticFeedback() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      _logger.warning('Error al producir feedback háptico', e);
    }
  }

  // Feedback visual para éxito
  void showSuccessFeedback(BuildContext context, String message) {
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
          onPressed: () {},
        ),
      ),
    );
  }

  // Feedback visual para error
  void showErrorFeedback(BuildContext context, String message) {
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
          onPressed: () {},
        ),
      ),
    );
  }
}
