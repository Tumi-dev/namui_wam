import 'package:hive/hive.dart';

// Indica que este archivo es parte de la generación de código de Hive
// y que el archivo generado se llamará 'user_progress.g.dart'.
part 'user_progress.g.dart';

/// {@template user_progress}
/// Modelo de datos para almacenar el progreso del usuario en un nivel específico.
///
/// Esta clase representa el progreso de un usuario en un nivel particular de una actividad,
/// guardando información como:
/// - La actividad y nivel relacionados
/// - La puntuación obtenida
/// - La fecha y hora de finalización
///
/// El modelo está diseñado para trabajar con Hive como sistema de persistencia local,
/// lo que permite guardar y recuperar el progreso entre sesiones de la aplicación.
///
/// Se utiliza principalmente por:
/// - [StorageService] para gestionar la persistencia
/// - [GameState] para rastrear el progreso global
/// - Pantallas de actividades para mostrar y actualizar el progreso
///
/// Ejemplo de estructura almacenada:
/// ```
/// UserProgress(
///   activityId: 1,
///   levelId: 3,
///   score: 85,
///   completedAt: 2023-05-15 14:30:00
/// )
/// ```
/// {@endtemplate}
@HiveType(typeId: 0) // Identificador único para este tipo en Hive
class UserProgress extends HiveObject {
  /// ID de la actividad a la que pertenece este progreso.
  ///
  /// Junto con [levelId], forma la clave compuesta que identifica
  /// el nivel específico en el contexto de todas las actividades.
  /// Los valores típicos son 1-6, correspondientes a las seis actividades principales.
  @HiveField(0) // Índice único para este campo en Hive
  final int activityId;

  /// ID del nivel completado dentro de la actividad.
  ///
  /// Identifica un nivel específico dentro de una actividad.
  /// Comienza en 0 para el primer nivel de cada actividad.
  /// Junto con [activityId], forma la clave compuesta para identificar el nivel.
  @HiveField(1)
  final int levelId;

  /// Puntuación obtenida al completar el nivel.
  ///
  /// Representa el desempeño del usuario en el nivel.
  /// Los valores típicos dependen de la actividad, pero generalmente:
  /// - Rangos entre 0-100
  /// - 5 puntos por nivel completado es común
  /// - Puntos adicionales pueden otorgarse por rendimiento excepcional
  @HiveField(2)
  final int score;

  /// Fecha y hora en que se completó el nivel.
  ///
  /// Almacena la marca de tiempo UTC cuando el usuario completó el nivel.
  /// Útil para:
  /// - Ordenar intentos por recencia
  /// - Análisis de patrones de uso
  /// - Mostrar historial de actividad
  @HiveField(3)
  final DateTime completedAt;

  /// {@macro user_progress}
  ///
  /// Ejemplo de creación:
  /// ```dart
  /// final progress = UserProgress(
  ///   activityId: 2,
  ///   levelId: 1,
  ///   score: 100,
  ///   completedAt: DateTime.now(),
  /// );
  /// ```
  ///
  /// [activityId] El ID de la actividad (1-6)
  /// [levelId] El ID del nivel dentro de la actividad (0-based)
  /// [score] La puntuación obtenida por el usuario
  /// [completedAt] La fecha y hora de finalización
  UserProgress({
    required this.activityId,
    required this.levelId,
    required this.score,
    required this.completedAt,
  });
  
  /// Convierte el objeto a un mapa para serialización manual (si es necesario).
  ///
  /// Aunque Hive maneja la serialización automáticamente, este método
  /// es útil para depuración o para integración con otros sistemas
  /// que requieran formato JSON/mapa.
  ///
  /// Ejemplo:
  /// ```dart
  /// final progressMap = progress.toMap();
  /// print(progressMap); // {activityId: 2, levelId: 1, score: 100, ...}
  /// ```
  Map<String, dynamic> toMap() {
    return {
      'activityId': activityId,
      'levelId': levelId,
      'score': score,
      'completedAt': completedAt.toIso8601String(),
    };
  }
  
  /// Crea una instancia a partir de un mapa de valores.
  ///
  /// Útil para deserialización manual cuando no se utiliza Hive,
  /// o para crear instancias desde datos provenientes de API o similar.
  ///
  /// Ejemplo:
  /// ```dart
  /// final map = {
  ///   'activityId': 2,
  ///   'levelId': 1,
  ///   'score': 100,
  ///   'completedAt': '2023-06-15T14:30:00Z',
  /// };
  /// final progress = UserProgress.fromMap(map);
  /// ```
  factory UserProgress.fromMap(Map<String, dynamic> map) {
    return UserProgress(
      activityId: map['activityId'] as int,
      levelId: map['levelId'] as int,
      score: map['score'] as int,
      completedAt: DateTime.parse(map['completedAt'] as String),
    );
  }
}
