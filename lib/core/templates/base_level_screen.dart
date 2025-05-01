import 'package:flutter/material.dart';
import 'package:namuiwam/core/models/level_model.dart';
import 'package:namuiwam/core/themes/app_theme.dart';
import 'package:namuiwam/core/constants/activity_descriptions.dart';
import 'package:namuiwam/core/widgets/game_description_widget.dart';

// Base de la pantalla de un nivel
abstract class BaseLevelScreen extends StatefulWidget {
  final LevelModel level;
  final int activityNumber;

  // Constructor de la pantalla base
  const BaseLevelScreen({
    super.key,
    required this.level,
    required this.activityNumber,
  });
}

// Estado de la pantalla base
abstract class BaseLevelScreenState<T extends BaseLevelScreen> extends State<T> {
  int remainingAttempts = 2;
  int totalScore = 0;

  // Maneja el evento de presionar el botón de regresar
  void _handleBackButton() {
    Navigator.of(context).pop();
  }

  // Construye el contenido del nivel
  Widget buildLevelContent();

  // Construye el widget de la pantalla base
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _handleBackButton();
        return false;
      },
      // El scafold de la pantalla base
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          leading: IconButton(
            icon: AppTheme.backArrowIcon,
            onPressed: _handleBackButton,
          ),
          title: Text(
            widget.level.description,
            style: AppTheme.levelTitleStyle,
          ),
          backgroundColor: Colors.transparent, // Color transparente de la AppBar
          elevation: 0,
        ),
        // El cuerpo de la pantalla base
        body: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.mainGradient,
          ),
          // El área segura de la pantalla base
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                GameDescriptionWidget(
                  description: ActivityGameDescriptions.getDescriptionForActivity(widget.activityNumber),
                ),
                Expanded(
                  child: buildLevelContent(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}