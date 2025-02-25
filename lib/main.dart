// Punto de entrada de la aplicación

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:namui_wam/core/themes/app_theme.dart';
import 'package:namui_wam/features/home/welcome_screen.dart';
import 'package:namui_wam/core/models/activity_levels.dart';
import 'package:namui_wam/core/models/activities_state.dart';
import 'package:namui_wam/features/activity1/data/activity1_levels.dart';
import 'package:namui_wam/features/activity2/data/activity2_levels.dart';
import 'package:namui_wam/core/di/service_locator.dart';
import 'package:namui_wam/core/services/logger_service.dart';
import 'package:namui_wam/core/models/game_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar el service locator
  await setupServiceLocator();
  final logger = getIt<LoggerService>();
  
  FlutterError.onError = (FlutterErrorDetails details) {
    logger.error('Flutter error', details.exception, details.stack);
    FlutterError.presentError(details);
  };

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final activitiesState = ActivitiesState();
    final gameState = GameState();
    
    // Inicializar actividades con sus niveles
    activitiesState.addActivity(ActivityLevels(activityId: 1, levels: List.from(activity1Levels)));
    activitiesState.addActivity(ActivityLevels(activityId: 2, levels: List.from(activity2Levels)));
    
    // Actividades en desarrollo
    for (int i = 3; i <= 6; i++) {
      activitiesState.addActivity(ActivityLevels(activityId: i, levels: []));
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ActivitiesState>.value(value: activitiesState),
        ChangeNotifierProvider<GameState>.value(value: gameState),
      ],
      child: MaterialApp(
        title: 'Namui Wam',
        theme: AppTheme.lightTheme,
        home: const WelcomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
