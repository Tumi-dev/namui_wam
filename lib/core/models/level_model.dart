/// Define los posibles estados de un nivel de actividad.
///
/// Este enum se utiliza para rastrear el estado de progresión de un nivel,
/// permitiendo mostrar indicadores visuales apropiados en la UI y controlar
/// la lógica de acceso.
enum LevelStatus {
  /// El nivel aún no es accesible por el jugador.
  ///
  /// Un nivel bloqueado no puede seleccionarse en la UI y generalmente
  /// se muestra visualmente como inaccesible (ej. con un icono de candado).
  locked,
  
  /// El nivel es accesible pero no ha sido completado.
  ///
  /// El usuario puede seleccionar y jugar este nivel.
  /// Visualmente, se muestra como disponible pero sin la marca de completado.
  unlocked,
  
  /// El nivel ha sido completado exitosamente por el jugador.
  ///
  /// Normalmente tiene un tratamiento visual distintivo (ej. estrella, marca de verificación)
  /// y podría permitir al jugador repetirlo para mejorar su rendimiento.
  completed
}

/// Extensión para facilitar la serialización/deserialización de [LevelStatus]
/// para almacenamiento (ej. SharedPreferences, JSON).
extension LevelStatusExtension on LevelStatus {
  /// Convierte el enum [LevelStatus] a una cadena de texto para almacenamiento.
  ///
  /// Este método transforma el enum en un formato de texto estandarizado
  /// que es adecuado para almacenamiento persistente.
  ///
  /// Ejemplo:
  /// ```dart
  /// final status = LevelStatus.completed;
  /// final stored = status.toStorageString(); // 'LevelStatus.completed'
  /// ```
  ///
  /// Retorna una cadena con el formato 'LevelStatus.{value}'.
  String toStorageString() => 'LevelStatus.${toString().split('.').last}';
  
  /// Convierte una cadena de texto almacenada de vuelta a un enum [LevelStatus].
  ///
  /// Este método parsea una cadena previamente generada por [toStorageString]
  /// y la convierte nuevamente en un valor de enum.
  ///
  /// Ejemplo:
  /// ```dart
  /// final stored = 'LevelStatus.unlocked';
  /// final status = LevelStatusExtension.fromStorageString(stored);
  /// print(status); // LevelStatus.unlocked
  /// ```
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
/// Este modelo encapsula toda la información relacionada con un nivel,
/// incluyendo sus metadatos (título, descripción), su estado actual
/// (bloqueado, desbloqueado, completado) y cualquier dato específico
/// necesario para su implementación.
///
/// Se utiliza en el contexto de:
/// - [ActivityLevels] para gestionar colecciones de niveles
/// - UI de selección de niveles para mostrar el progreso
/// - Pantallas de juego para recuperar la configuración del nivel
///
/// La clase proporciona métodos para cambiar el estado del nivel
/// (desbloquear, completar) y para serialización/deserialización.
/// {@endtemplate}
class LevelModel {
  /// Identificador único del nivel dentro de su actividad.
  ///
  /// Este ID es único dentro del contexto de su actividad, comenzando
  /// típicamente desde 0 para el primer nivel.
  /// 
  /// Se utiliza para:
  /// - Identificar el nivel en la UI
  /// - Acceder al nivel en colecciones
  /// - Formar claves de almacenamiento junto con el ID de la actividad
  final int id;
  
  /// Título del nivel.
  ///
  /// Un texto corto que identifica el nivel para el usuario,
  /// como "Nivel 1" o "Aprendiendo los colores".
  final String title;
  
  /// Descripción corta del objetivo o contenido del nivel.
  ///
  /// Explica brevemente lo que el usuario aprenderá o practicará
  /// en este nivel, guiando sus expectativas.
  final String description;
  
  /// Nivel de dificultad (puede ser un valor numérico o una categoría).
  ///
  /// Típicamente:
  /// - 1: Principiante
  /// - 2: Intermedio
  /// - 3: Avanzado
  ///
  /// Se utiliza para informar al usuario de la complejidad esperada.
  final int difficulty;
  
  /// Estado actual del nivel (bloqueado, desbloqueado, completado).
  ///
  /// Este campo controla:
  /// - La visualización del nivel en la UI
  /// - La accesibilidad del nivel para el usuario
  /// - El seguimiento del progreso
  ///
  /// Cambia a través de los métodos [unlockLevel] y [completeLevel].
  LevelStatus status;
  
  /// Datos adicionales específicos para la lógica de este nivel (opcional).
  ///
  /// Este mapa permite almacenar cualquier información específica del nivel,
  /// como:
  /// - Configuración de juego (tiempo límite, intentos permitidos)
  /// - Preguntas y respuestas específicas del nivel
  /// - Rutas a recursos multimedia (imágenes, audio)
  /// - Reglas personalizadas
  ///
  /// El contenido exacto depende del tipo de actividad.
  final Map<String, dynamic>? levelData;

  /// {@macro level_model}
  ///
  /// Ejemplo de creación:
  /// ```dart
  /// final level = LevelModel(
  ///   id: 1,
  ///   title: 'Los números del 1 al 10',
  ///   description: 'Aprende los números básicos en Namtrik',
  ///   difficulty: 1,
  ///   status: LevelStatus.unlocked,
  ///   levelData: {
  ///     'timeLimit': 60,
  ///     'questions': 5,
  ///   },
  /// );
  /// ```
  ///
  /// [id] Identificador único del nivel dentro de su actividad
  /// [title] Título mostrado al usuario
  /// [description] Descripción breve del contenido o propósito
  /// [difficulty] Nivel de dificultad (1-3 típicamente)
  /// [status] Estado inicial (por defecto: bloqueado)
  /// [levelData] Datos específicos opcionales para este nivel
  LevelModel({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    this.status = LevelStatus.locked, // Por defecto, los niveles empiezan bloqueados
    this.levelData,
  });

  /// Retorna `true` si el estado actual del nivel es [LevelStatus.locked].
  ///
  /// Útil para controlar la visualización y accesibilidad del nivel en la UI.
  bool get isLocked => status == LevelStatus.locked;
  
  /// Retorna `true` si el estado actual del nivel es [LevelStatus.unlocked].
  ///
  /// Indica que el nivel está disponible para jugar pero no se ha completado.
  bool get isUnlocked => status == LevelStatus.unlocked;
  
  /// Retorna `true` si el estado actual del nivel es [LevelStatus.completed].
  ///
  /// Indica que el usuario ha completado exitosamente este nivel.
  bool get isCompleted => status == LevelStatus.completed;
  
  /// Cambia el estado del nivel a [LevelStatus.unlocked] si estaba bloqueado.
  ///
  /// Este método se utiliza cuando se cumple alguna condición que permite
  /// al usuario acceder al nivel, como completar un nivel anterior.
  ///
  /// No tiene efecto si el nivel ya está desbloqueado o completado.
  ///
  /// Ejemplo:
  /// ```dart
  /// if (previousLevel.isCompleted) {
  ///   thisLevel.unlockLevel();
  /// }
  /// ```
  void unlockLevel() {
    if (status == LevelStatus.locked) {
      status = LevelStatus.unlocked;
      // Considerar notificar cambios si este modelo es escuchado directamente
      // (aunque normalmente se gestiona a través de ActivityLevels/ActivitiesState)
    }
  }

  /// Cambia el estado del nivel a [LevelStatus.completed].
  ///
  /// Este método se llama cuando el usuario completa exitosamente el nivel.
  /// Solo funciona si el nivel estaba previamente desbloqueado o ya completado.
  /// No puede completar un nivel que está bloqueado.
  ///
  /// Ejemplo:
  /// ```dart
  /// if (userSuccessfullyCompletedLevel) {
  ///   level.completeLevel();
  ///   // Actualizar puntos, desbloquear siguiente nivel, etc.
  /// }
  /// ```
  void completeLevel() {
    // Se puede completar un nivel aunque ya estuviera completado (no cambia nada)
    // o si estaba desbloqueado.
    if (status != LevelStatus.locked) { // No se puede completar un nivel bloqueado
        status = LevelStatus.completed;
        // Considerar notificar cambios
    }
  }

  /// Convierte la instancia de [LevelModel] a un mapa JSON.
  ///
  /// Este método serializa todos los campos del nivel en un formato
  /// adecuado para almacenamiento persistente (SharedPreferences, archivos, etc.)
  /// y para transmisión (API, Firebase, etc.).
  ///
  /// Ejemplo:
  /// ```dart
  /// final levelData = level.toJson();
  /// await prefs.setString('level_${level.id}', jsonEncode(levelData));
  /// ```
  ///
  /// Retorna un mapa con todos los campos del nivel serializados.
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'difficulty': difficulty,
    'status': status.toStorageString(), // Usa la extensión para serializar el enum
    'levelData': levelData,
  };

  /// Crea una instancia de [LevelModel] desde un mapa JSON.
  ///
  /// Este constructor de fábrica deserializa datos previamente guardados
  /// con [toJson] para reconstruir un objeto [LevelModel] completo.
  ///
  /// Ejemplo:
  /// ```dart
  /// final String stored = prefs.getString('level_1') ?? '{}';
  /// final Map<String, dynamic> json = jsonDecode(stored);
  /// final level = LevelModel.fromJson(json);
  /// ```
  ///
  /// [json] El mapa JSON con los datos del nivel.
  /// Retorna una nueva instancia de [LevelModel] con los datos recuperados.
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