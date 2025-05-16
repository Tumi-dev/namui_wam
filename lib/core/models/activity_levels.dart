import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'level_model.dart';

/// {@template activity_levels}
/// Gestiona el estado y la lógica de los niveles para una actividad específica.
///
/// Esta clase actúa como un contenedor para los niveles de una actividad educativa,
/// proporcionando métodos para:
/// - Acceder a niveles individuales
/// - Verificar si un nivel está accesible o completado
/// - Marcar niveles como completados 
/// - Gestionar la puntuación acumulada
/// - Reiniciar la actividad
///
/// Implementa [ChangeNotifier] para integrarse con el sistema de Provider,
/// notificando automáticamente a los widgets cuando el estado cambia.
///
/// Relaciones principales:
/// - Es gestionada por [ActivitiesState] como parte del estado global de actividades
/// - Contiene una colección de [LevelModel] que representan los niveles de la actividad
/// - Su progreso puede ser almacenado mediante [LevelStorage]
///
/// Comportamientos especiales:
/// - Las actividades 3 y 4 tienen todos los niveles desbloqueados desde el inicio
/// - Otras actividades desbloquean secuencialmente los niveles al completar el anterior
/// - Cada nivel completado otorga 5 puntos a la puntuación total de la actividad
/// {@endtemplate}
class ActivityLevels extends ChangeNotifier {
  /// La lista de modelos de nivel asociados a esta actividad.
  ///
  /// Contiene todos los [LevelModel] que forman parte de esta actividad,
  /// generalmente ordenados por su dificultad o secuencia de aprendizaje.
  final List<LevelModel> levels;
  
  /// El identificador único de esta actividad.
  ///
  /// Los IDs de actividad en la aplicación son:
  /// - 1: Muntsik mөik kөtasha sөl lau (Escoja el número correcto)
  /// - 2: Muntsikelan pөram kusrekun (Aprendamos a escribir los números)
  /// - 3: Nөsik utөwan asam kusrekun (Aprendamos a ver la hora)
  /// - 4: Anwan ashipelɵ kɵkun (Aprendamos a usar el dinero)
  /// - 5: Muntsielan namtrikmai yunөmarөpik (Convertir números en letras)
  /// - 6: Wammeran tulisha manchípik kui asamik pөrik (Diccionario)
  final int activityId;
  
  /// Puntuación total acumulada en esta actividad.
  ///
  /// Se incrementa en [pointsPerLevel] cada vez que un usuario completa
  /// un nivel por primera vez.
  int _totalPoints = 0;
  
  /// Mapa para rastrear qué niveles (por ID/índice) han sido completados.
  ///
  /// Este mapa es redundante con el estado interno de cada [LevelModel],
  /// pero se mantiene por compatibilidad con código existente.
  /// Uso futuro debería preferir consultar el estado directamente del modelo.
  final Map<int, bool> _completedLevels = {};
  
  /// Puntos otorgados por completar cada nivel.
  ///
  /// Este valor es constante para todas las actividades y niveles.
  static const int pointsPerLevel = 5;

  /// {@macro activity_levels}
  ///
  /// Ejemplo de creación:
  /// ```dart
  /// final levels = [
  ///   LevelModel(id: 0, title: 'Nivel Básico', description: 'Aprende los números del 1-5', difficulty: 1),
  ///   LevelModel(id: 1, title: 'Nivel Medio', description: 'Aprende los números del 6-10', difficulty: 2),
  ///   LevelModel(id: 2, title: 'Nivel Avanzado', description: 'Combina todos los números', difficulty: 3),
  /// ];
  /// 
  /// final activity = ActivityLevels(
  ///   activityId: 1,
  ///   levels: levels,
  /// );
  /// ```
  ///
  /// Al instanciarse, automáticamente inicializa el estado de los niveles
  /// según las reglas específicas para el [activityId].
  ///
  /// [activityId] El ID de la actividad.
  /// [levels] La lista de [LevelModel] para esta actividad.
  ActivityLevels({
    required this.activityId,
    required this.levels,
  }) {
    _initializeLevels();
  }

  /// Inicializa el estado de los niveles al crear la instancia.
  ///
  /// Aplica reglas específicas por tipo de actividad:
  /// - Para las actividades 3 y 4, todos los niveles se desbloquean inicialmente.
  /// - Para otras actividades (1, 2, etc.), solo el primer nivel se desbloquea.
  ///
  /// Esta lógica es importante para la experiencia de usuario, ya que algunas
  /// actividades están diseñadas para exploración libre, mientras que otras
  /// siguen una progresión secuencial.
  void _initializeLevels() {
    if (levels.isNotEmpty) {
      if (activityId == 3 || activityId == 4) {
        // Para actividades 3 y 4, desbloquear todos los niveles
        for (var level in levels) {
          level.unlockLevel(); // Usa el método del modelo
        }
      } else {
        // Para otras actividades, solo desbloquear el primer nivel
        levels[0].unlockLevel(); // Usa el método del modelo
      }
    }
  }

  /// Verifica si un nivel específico es accesible.
  ///
  /// La accesibilidad de un nivel está determinada por:
  /// - Para el primer nivel (id=0): Está accesible si no está bloqueado
  /// - Para otros niveles: Está accesible si el nivel anterior está completado
  ///
  /// **Nota:** La lógica podría requerir revisión para mayor claridad. Una implementación 
  /// alternativa podría simplemente verificar `levels[levelId].isUnlocked || levels[levelId].isCompleted`.
  ///
  /// Ejemplo:
  /// ```dart
  /// if (activity.canAccessLevel(levelId)) {
  ///   // Mostrar nivel seleccionable en UI
  /// } else {
  ///   // Mostrar nivel bloqueado
  /// }
  /// ```
  ///
  /// [levelId] El índice del nivel a verificar (0-based).
  /// Retorna `true` si el nivel es accesible, `false` en caso contrario.
  bool canAccessLevel(int levelId) {
    // Validación de índice
    if (levelId < 0 || levelId >= levels.length) return false;
    // Lógica actual: ¿Debería ser `levels[levelId].isUnlocked`?
    if (levelId == 0) return levels[0].status != LevelStatus.locked; // El primer nivel es accesible si está desbloqueado
    return levels[levelId - 1].isCompleted; // Lógica actual para niveles > 0
  }

  /// Verifica si un nivel específico ha sido completado.
  ///
  /// Utiliza el estado interno del [LevelModel] para determinar si el nivel
  /// ha sido completado, en lugar de usar el mapa `_completedLevels`.
  ///
  /// Ejemplo:
  /// ```dart
  /// // Mostrar indicadores de progreso
  /// for (int i = 0; i < activity.availableLevels.length; i++) {
  ///   final isCompleted = activity.isLevelCompleted(i);
  ///   return LevelTile(
  ///     level: activity.getLevel(i)!,
  ///     isCompleted: isCompleted,
  ///     // ...
  ///   );
  /// }
  /// ```
  ///
  /// [levelId] El índice del nivel a verificar (0-based).
  /// Retorna `true` si el nivel está marcado como completado, `false` en caso contrario.
  bool isLevelCompleted(int levelId) {
    // Usa el estado del LevelModel directamente
    if (levelId >= 0 && levelId < levels.length) {
      return levels[levelId].isCompleted;
    }
    return false;
    // return _completedLevels[levelId] ?? false; // Lógica anterior con mapa interno
  }

  /// Marca un nivel como completado.
  ///
  /// Este método actualiza el estado del nivel especificado:
  /// 1. Cambia su estado a completado
  /// 2. Suma [pointsPerLevel] puntos al total de la actividad
  /// 3. Desbloquea el siguiente nivel (si existe y no es actividad 3 o 4)
  /// 4. Notifica a los listeners sobre el cambio
  ///
  /// Solo procede si el nivel está actualmente desbloqueado y no completado.
  ///
  /// Ejemplo:
  /// ```dart
  /// // Cuando el usuario completa exitosamente un nivel
  /// ElevatedButton(
  ///   onPressed: () {
  ///     activity.completeLevel(currentLevelId);
  ///     // También actualizar el progreso global
  ///     gameState.addPoints(activity.activityId, currentLevelId, ActivityLevels.pointsPerLevel);
  ///   },
  ///   child: Text('Completar nivel'),
  /// )
  /// ```
  ///
  /// [levelId] El índice del nivel a completar (0-based).
  void completeLevel(int levelId) {
    if (levelId >= 0 && levelId < levels.length) {
      final level = levels[levelId];
      // Solo proceder si el nivel está desbloqueado y no completado
      if (level.status == LevelStatus.unlocked) {
        level.completeLevel(); // Actualiza el estado en el modelo
        _totalPoints += pointsPerLevel;
        // _completedLevels[levelId] = true; // Ya no es necesario si usamos el estado del modelo

        // Desbloquear el siguiente nivel si existe y no es actividad 3 o 4
        int nextLevelId = levelId + 1;
        if (nextLevelId < levels.length && activityId != 3 && activityId != 4) {
          levels[nextLevelId].unlockLevel();
        }

        notifyListeners();
      }
    }
  }

  /// Obtiene la puntuación total acumulada para esta actividad.
  ///
  /// Los puntos se acumulan únicamente al completar niveles por primera vez,
  /// a razón de [pointsPerLevel] puntos por nivel completado.
  ///
  /// Esta puntuación es local a la actividad y difiere de la puntuación global
  /// gestionada por [GameState].
  int get totalPoints => _totalPoints;

  /// Reinicia el progreso de la actividad.
  ///
  /// Este método restablece la actividad a su estado inicial:
  /// 1. Reinicia los puntos acumulados a cero
  /// 2. Limpia el registro de niveles completados
  /// 3. Restablece el estado de cada nivel según las reglas de la actividad
  /// 4. Notifica a los oyentes sobre el cambio
  ///
  /// Para las actividades 3 y 4, todos los niveles permanecen desbloqueados.
  /// Para otras actividades, solo el primer nivel queda desbloqueado.
  ///
  /// Ejemplo:
  /// ```dart
  /// // Botón de reinicio con confirmación
  /// ElevatedButton(
  ///   onPressed: () {
  ///     showDialog(
  ///       context: context,
  ///       builder: (context) => AlertDialog(
  ///         title: Text('¿Reiniciar progreso?'),
  ///         actions: [
  ///           TextButton(
  ///             onPressed: () {
  ///               Navigator.pop(context);
  ///               activity.resetActivity();
  ///               LevelStorage.saveLevels(activity.activityId, activity.levels);
  ///             },
  ///             child: Text('Confirmar'),
  ///           ),
  ///           TextButton(
  ///             onPressed: () => Navigator.pop(context),
  ///             child: Text('Cancelar'),
  ///           ),
  ///         ],
  ///       ),
  ///     );
  ///   },
  ///   child: Text('Reiniciar actividad'),
  /// )
  /// ```
  void resetActivity() {
    _totalPoints = 0;
    _completedLevels.clear(); // Limpiar el mapa si aún se usa, aunque parece redundante

    // Restablecer el estado de cada LevelModel
    for (int i = 0; i < levels.length; i++) {
      final level = levels[i];
      if (activityId == 3 || activityId == 4) {
        level.status = LevelStatus.unlocked;
      } else {
        // Para otras actividades, bloquear todos excepto el primero
        level.status = (i == 0) ? LevelStatus.unlocked : LevelStatus.locked;
      }
    }

    // No es necesario desbloquear explícitamente el primero aquí si se hizo en el bucle

    notifyListeners();
  }

  /// Obtiene el [LevelModel] para un ID (índice) de nivel específico.
  ///
  /// Método de conveniencia para acceder a un nivel específico con validación
  /// de índice, retornando `null` si el índice está fuera de rango.
  ///
  /// Ejemplo:
  /// ```dart
  /// final level = activity.getLevel(levelId);
  /// if (level != null) {
  ///   // Usar el nivel
  ///   print('Nivel: ${level.title}, Dificultad: ${level.difficulty}');
  /// } else {
  ///   print('Nivel no encontrado');
  /// }
  /// ```
  ///
  /// [levelId] El índice del nivel a obtener (0-based).
  /// Retorna el [LevelModel] o `null` si el índice está fuera de rango.
  LevelModel? getLevel(int levelId) {
    if (levelId >= 0 && levelId < levels.length) {
      return levels[levelId];
    }
    return null;
  }

  /// Obtiene una lista no modificable de todos los niveles de la actividad.
  ///
  /// Proporciona acceso seguro (inmutable) a la lista completa de niveles,
  /// útil para mostrar todos los niveles en la UI o para iteraciones.
  ///
  /// Ejemplo:
  /// ```dart
  /// // Mostrar todos los niveles disponibles
  /// ListView.builder(
  ///   itemCount: activity.availableLevels.length,
  ///   itemBuilder: (context, index) {
  ///     final level = activity.availableLevels[index];
  ///     return ListTile(
  ///       title: Text(level.title),
  ///       subtitle: Text(level.description),
  ///       trailing: level.isCompleted ? Icon(Icons.check) : null,
  ///     );
  ///   },
  /// )
  /// ```
  List<LevelModel> get availableLevels => List.unmodifiable(levels);

  /// Método estático para obtener una instancia de [ActivityLevels] a través de Provider.
  ///
  /// **Nota:** Este método está marcado como @Deprecated porque la forma recomendada
  /// de acceder a una actividad es a través de `ActivitiesState.of(context).getActivity(activityId)`.
  ///
  /// Este método asume que existe un Provider directo de [ActivityLevels] en el árbol
  /// de widgets, lo cual no es el caso habitual en la arquitectura actual.
  ///
  /// Ejemplo de la forma recomendada:
  /// ```dart
  /// final activitiesState = ActivitiesState.of(context);
  /// final activity = activitiesState.getActivity(activityId);
  /// if (activity != null) {
  ///   // Usar activity
  /// }
  /// ```
  ///
  /// [context] El BuildContext.
  /// [listen] Si el widget debe escuchar cambios (por defecto `true`).
  /// [targetActivityId] El ID de la actividad deseada.
  /// Retorna la instancia de [ActivityLevels] si se encuentra y coincide el ID, o `null`.
  @Deprecated('Consider using ActivitiesState.of(context).getActivity(activityId) instead')
  static ActivityLevels? of(BuildContext context, {bool listen = true, required int targetActivityId}) {
    try {
      // Esta línea probablemente fallará si ActivityLevels no se provee directamente.
      final provider = Provider.of<ActivityLevels>(context, listen: listen);
      // Comprueba si la instancia encontrada es la correcta.
      return provider.activityId == targetActivityId ? provider : null;
    } catch (e) {
      // Captura el error si Provider.of falla (ej. no se encontró el Provider).
      return null;
    }
  }
}