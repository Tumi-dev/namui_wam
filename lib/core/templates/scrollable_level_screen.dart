import 'package:flutter/material.dart';
import 'package:namui_wam/core/constants/activity_descriptions.dart';
import 'package:namui_wam/core/models/level_model.dart';
import 'package:namui_wam/core/themes/app_theme.dart';
import 'package:namui_wam/core/widgets/game_description_widget.dart';

/// Plantilla reutilizable para pantallas de nivel con desplazamiento completo
/// Extiende esta clase para crear pantallas de nivel que permitan desplazamiento
/// de todo el contenido, incluyendo la descripción del juego y los elementos de UI
abstract class ScrollableLevelScreen extends StatefulWidget {
  final LevelModel level;
  final int activityNumber;

  // Constructor de la pantalla de nivel con desplazamiento
  const ScrollableLevelScreen({
    super.key,
    required this.level,
    required this.activityNumber,
  });
}

// Estado de la pantalla de nivel con desplazamiento
abstract class ScrollableLevelScreenState<T extends ScrollableLevelScreen> extends State<T> {
  int remainingAttempts = 3;
  int totalScore = 0;
  final ScrollController scrollController = ScrollController();

  // Maneja el evento de presionar el botón de regresar 
  void _handleBackButton() {
    Navigator.of(context).pop();
  }

  /// Método abstracto que debe ser implementado por las subclases
  /// para proporcionar el contenido específico del nivel
  Widget buildLevelContent();

  // Limpia los controladores al desmontar el widget  
  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  // Construye el widget de la pantalla de nivel con desplazamiento
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _handleBackButton();
        return false;
      },
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
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.mainGradient,
          ),
          // Asegurar que el contenido sea accesible para los usuarios de lectores de pantalla
          child: SafeArea(
            // Permitir desplazamiento del contenido completo
            child: SingleChildScrollView(
              controller: scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              // Alinear el contenido al centro 
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                // Contenido del nivel
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center, // Alinear el contenido al centro
                  children: [
                    const SizedBox(height: 20),
                    // Descripción del juego para el nivel actual
                    GameDescriptionWidget(
                      description: ActivityGameDescriptions.getDescriptionForActivity(widget.activityNumber),
                    ),
                    const SizedBox(height: 20),
                    buildLevelContent(),
                    // Espacio adicional al final para asegurar que todo el contenido sea accesible
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
