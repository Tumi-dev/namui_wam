// Librería principal de la aplicación que inicializa el service locator y los providers de las actividades y el estado del juego.
import 'package:flutter/material.dart';
import 'package:namui_wam/features/home/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:namui_wam/core/themes/app_theme.dart';
import 'package:namui_wam/core/models/activity_levels.dart';
import 'package:namui_wam/core/models/activities_state.dart';
import 'package:namui_wam/features/activity1/data/activity1_levels.dart';
import 'package:namui_wam/features/activity2/data/activity2_levels.dart';
import 'package:namui_wam/features/activity3/data/activity3_levels.dart';
import 'package:namui_wam/features/activity4/data/activity4_levels.dart';
import 'package:namui_wam/core/di/service_locator.dart';
import 'package:namui_wam/core/services/logger_service.dart';
import 'package:namui_wam/core/models/game_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar el service locator
  await setupServiceLocator();
  final logger = getIt<LoggerService>();

  // Configurar el logger para que imprima los errores en la consola
  FlutterError.onError = (FlutterErrorDetails details) {
    logger.error('Flutter error', details.exception, details.stack);
    FlutterError.presentError(details);
  };

  runApp(const MainApp());
}

/// Sincroniza el estado del juego guardado con el estado de las actividades
/// Restaura los niveles completados y desbloqueados basado en GameState
Future<void> syncGameStateWithActivities(
    ActivitiesState activitiesState, GameState gameState) async {
  // Esperar a que GameState termine de cargar sus datos
  await Future.delayed(const Duration(milliseconds: 500));

  // Obtener el logger del service locator
  final logger = getIt<LoggerService>();
  logger.info('Iniciando sincronización de estados guardados');

  // Para cada actividad en el estado de actividades
  // (1 a 6, ya que la actividad 3 no tiene niveles y la 4 y 5 son especiales)
  for (var activityId = 1; activityId <= 6; activityId++) {
    var activity = activitiesState.getActivity(activityId);
    if (activity == null) continue;

    // Ignorar actividades especiales que tienen todos los niveles desbloqueados
    if (activityId == 4 || activityId == 5) continue;

    // Para cada nivel en la actividad
    for (var levelId = 0;
        levelId < activity.availableLevels.length;
        levelId++) {
      // Si está completado en GameState, marcarlo como completado
      if (gameState.isLevelCompleted(activityId, levelId)) {
        logger.info(
            'Restaurando nivel completado: Actividad $activityId, Nivel $levelId');
        activity.completeLevel(levelId);
      }
    }

    // Verificar si hay niveles que deberían estar desbloqueados pero no completados
    // Por ejemplo, si el nivel 1 y 2 están completados, el nivel 3 debe estar desbloqueado
    for (var levelId = 0;
        levelId < activity.availableLevels.length;
        levelId++) {
      var level = activity.getLevel(levelId);
      if (level == null) continue;

      // Si el nivel anterior está completado pero este nivel está bloqueado, desbloquearlo
      if (levelId > 0) {
        var prevLevel = activity.getLevel(levelId - 1);
        if (prevLevel != null && prevLevel.isCompleted && level.isLocked) {
          logger.info(
              'Desbloqueando nivel siguiente: Actividad $activityId, Nivel $levelId');
          level.unlockLevel();
        }
      }
    }
  }

  // Para la actividad 3, desbloquear todos los niveles
  logger.info('Sincronización de estados completada');
}

// Clase principal de la aplicación
// Inicializa el estado de las actividades y el estado del juego
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  // Método build que construye la aplicación
  @override
  Widget build(BuildContext context) {
    final activitiesState = ActivitiesState();
    final gameState = GameState(activitiesState);

    // Inicializar actividades con sus niveles correspondientes
    // Actividades con niveles predefinidos
    activitiesState.addActivity(
        ActivityLevels(activityId: 1, levels: List.from(activity1Levels)));
    activitiesState.addActivity(
        ActivityLevels(activityId: 2, levels: List.from(activity2Levels)));
    activitiesState.addActivity(ActivityLevels(activityId: 6, levels: []));
    activitiesState.addActivity(
        ActivityLevels(activityId: 3, levels: List.from(activity3Levels)));
    activitiesState.addActivity(
        ActivityLevels(activityId: 4, levels: List.from(activity4Levels)));

    // Actividades en desarrollo o no definidas
    // Aquí se pueden agregar actividades que no tienen niveles predefinidos
    for (int i = 6; i <= 6; i++) {
      activitiesState.addActivity(ActivityLevels(activityId: i, levels: []));
    }

    // Sincronizar estado después de inicialización
    // Esto asegura que el estado de las actividades se sincronice con el estado del juego
    WidgetsBinding.instance.addPostFrameCallback((_) {
      syncGameStateWithActivities(activitiesState, gameState);
    });

    // Registrar el estado de las actividades y el estado del juego en el service locator
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ActivitiesState>.value(value: activitiesState),
        ChangeNotifierProvider<GameState>.value(value: gameState),
      ],
      // Crear la aplicación MaterialApp
      // Establecer el título y el tema de la aplicación
      child: MaterialApp(
        title: 'Namui Wam',
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
        debugShowCheckedModeBanner: true,
      ),
    );
  }
}
