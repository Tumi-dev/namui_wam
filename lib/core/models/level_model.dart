/// Define los posibles estados de un nivel de actividad.
enum LevelStatus {
  /// El nivel aún no es accesible por el jugador.
  locked,
  /// El nivel es accesible pero no ha sido completado.
  unlocked,
  /// El nivel ha sido completado exitosamente por el jugador.
  completed
}

/// Extensión para facilitar la serialización/deserialización de [LevelStatus]
/// para almacenamiento (ej. SharedPreferences, JSON).
extension LevelStatusExtension on LevelStatus {
  /// Convierte el enum [LevelStatus] a una cadena de texto para almacenamiento.
  /// Ejemplo: `LevelStatus.completed` se convierte en `'LevelStatus.completed'`.
  String toStorageString() => 'LevelStatus.${toString().split('.').last}';
  
  /// Convierte una cadena de texto almacenada de vuelta a un enum [LevelStatus].
  ///
  /// [value] La cadena almacenada (ej. `'LevelStatus.completed'`).
  /// Retorna el [LevelStatus] correspondiente, o [LevelStatus.locked] si la cadena es inválida.
  static LevelStatus fromStorageString(String value) {
    final enumName = value.replaceAll('LevelStatus.', '');
    return LevelStatus.values.firstWhere(
      (status) => status.toString().split('.').last == enumName,
      orElse: () => LevelStatus.locked // Valor por defecto en caso de error
    );
  }
}

/// {@template level_model}
/// Representa un nivel individual dentro de una actividad de aprendizaje.
///
/// Contiene información sobre el nivel como su ID, título, descripción,
/// dificultad, estado actual ([LevelStatus]) y datos específicos del nivel.
/// {@endtemplate}
class LevelModel {
  /// Identificador único del nivel dentro de su actividad.
  final int id;
  /// Título del nivel.
  final String title;
  /// Descripción corta del objetivo o contenido del nivel.
  final String description;
  /// Nivel de dificultad (puede ser un valor numérico o una categoría).
  final int difficulty;
  /// Estado actual del nivel (bloqueado, desbloqueado, completado).
  LevelStatus status;
  /// Datos adicionales específicos para la lógica de este nivel (opcional).
  /// Podría contener configuraciones, preguntas, respuestas, etc.
  final Map<String, dynamic>? levelData;

  /// {@macro level_model}
  LevelModel({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    this.status = LevelStatus.locked, // Por defecto, los niveles empiezan bloqueados
    this.levelData,
  });

  /// Retorna `true` si el estado actual del nivel es [LevelStatus.locked].
  bool get isLocked => status == LevelStatus.locked;
  /// Retorna `true` si el estado actual del nivel es [LevelStatus.unlocked].
  bool get isUnlocked => status == LevelStatus.unlocked;
  /// Retorna `true` si el estado actual del nivel es [LevelStatus.completed].
  bool get isCompleted => status == LevelStatus.completed;
  
  /// Cambia el estado del nivel a [LevelStatus.unlocked] si estaba bloqueado.
  void unlockLevel() {
    if (status == LevelStatus.locked) {
      status = LevelStatus.unlocked;
      // Considerar notificar cambios si este modelo es escuchado directamente
      // (aunque normalmente se gestiona a través de ActivityLevels/ActivitiesState)
    }
  }

  /// Cambia el estado del nivel a [LevelStatus.completed].
  void completeLevel() {
    // Se puede completar un nivel aunque ya estuviera completado (no cambia nada)
    // o si estaba desbloqueado.
    if (status != LevelStatus.locked) { // No se puede completar un nivel bloqueado
        status = LevelStatus.completed;
        // Considerar notificar cambios
    }
  }

  /// Convierte la instancia de [LevelModel] a un mapa JSON.
  /// Útil para serialización y almacenamiento.
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'difficulty': difficulty,
    'status': status.toStorageString(), // Usa la extensión para serializar el enum
    'levelData': levelData,
  };

  /// Crea una instancia de [LevelModel] desde un mapa JSON.
  /// Útil para deserialización desde almacenamiento.
  ///
  /// [json] El mapa JSON con los datos del nivel.
  factory LevelModel.fromJson(Map<String, dynamic> json) => LevelModel(
    id: json['id'] as int,
    title: json['title'] as String,
    description: json['description'] as String,
    difficulty: json['difficulty'] as int,
    // Usa la extensión para deserializar el enum desde la cadena almacenada
    status: LevelStatusExtension.fromStorageString(json['status'] as String? ?? LevelStatus.locked.toStorageString()),
    // Asegura que levelData sea un Map<String, dynamic> o null
    levelData: json['levelData'] is Map ? Map<String, dynamic>.from(json['levelData']) : null,
  );
}