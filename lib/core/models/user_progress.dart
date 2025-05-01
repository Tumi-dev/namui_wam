import 'package:hive/hive.dart';

// Indica que este archivo es parte de la generación de código de Hive
// y que el archivo generado se llamará 'user_progress.g.dart'.
part 'user_progress.g.dart';

/// {@template user_progress}
/// Modelo de datos para almacenar el progreso del usuario en un nivel específico.
///
/// Utiliza Hive para la persistencia local. Cada instancia representa la finalización
/// de un nivel, registrando la actividad, el nivel, la puntuación obtenida y
/// la fecha y hora de finalización.
///
/// Se requiere ejecutar `flutter packages pub run build_runner build` para generar
/// el archivo `user_progress.g.dart` necesario para Hive.
/// {@endtemplate}
@HiveType(typeId: 0) // Identificador único para este tipo en Hive
class UserProgress extends HiveObject {
  /// ID de la actividad a la que pertenece este progreso.
  @HiveField(0) // Índice único para este campo en Hive
  final int activityId;

  /// ID del nivel completado dentro de la actividad.
  @HiveField(1)
  final int levelId;

  /// Puntuación obtenida al completar el nivel.
  @HiveField(2)
  final int score;

  /// Fecha y hora en que se completó el nivel.
  @HiveField(3)
  final DateTime completedAt;

  /// {@macro user_progress}
  UserProgress({
    required this.activityId,
    required this.levelId,
    required this.score,
    required this.completedAt,
  });
}
