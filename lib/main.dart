// Punto de entrada de la aplicación

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:namui_wam/core/themes/app_theme.dart';
import 'package:namui_wam/features/home/welcome_screen.dart';
import 'package:namui_wam/core/models/activity_levels.dart';
import 'package:namui_wam/features/activity1/data/activity1_levels.dart';
import 'package:namui_wam/features/activity2/data/activity2_levels.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ActivityLevels>.value(
          value: ActivityLevels(
            activityId: 1,
            levels: List.from(activity1Levels),
          ),
        ),
        ChangeNotifierProvider<ActivityLevels>.value(
          value: ActivityLevels(
            activityId: 2,
            levels: List.from(activity2Levels),
          ),
        ),
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
