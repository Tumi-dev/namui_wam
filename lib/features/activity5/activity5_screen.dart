import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:namui_wam/core/themes/app_theme.dart';
import 'package:namui_wam/core/models/activities_state.dart';
import 'package:namui_wam/core/models/level_model.dart';
import 'package:namui_wam/features/activity5/screens/activity5_level_screen.dart';

// Clase para la pantalla de la actividad 5 en desarrollo
class Activity5Screen extends StatelessWidget {
  const Activity5Screen({super.key});

  // Navega hacia la pantalla de inicio de la aplicación al presionar el botón de inicio
  void _navigateToHome(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  // Navega hacia la pantalla de un nivel de la actividad 5 en desarrollo al seleccionar un nivel
  void _onLevelSelected(BuildContext context, LevelModel level) {
    // Navegar a la pantalla del nivel seleccionado de la actividad 5
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Activity5LevelScreen(level: level),
      ),
    );
  }

  // Construye la pantalla de la actividad 5 en desarrollo con los niveles disponibles
  @override
  Widget build(BuildContext context) {
    return Consumer<ActivitiesState>(
      builder: (context, activitiesState, child) {
        final activity5 = activitiesState.getActivity(5);
        if (activity5 == null) return const SizedBox.shrink();

        // Construir la pantalla de la actividad 5 en desarrollo con los niveles disponibles
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            leading: IconButton(
              icon: AppTheme.homeIcon,
              onPressed: () => _navigateToHome(context),
            ),
            title: const Text(
              'Anwan ashipelɵ kɵkun',
              style: AppTheme.activityTitleStyle,
            ),
            // Color de fondo transparente y elevación 0 para la barra de la actividad 5 en desarrollo
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: AppTheme.mainGradient,
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const Icon(
                      Icons.attach_money,
                      // Color de icono blanco para la actividad 5 en desarrollo
                      color: Color(0xFF4CAF50),
                      size: 64,
                    ),
                    const SizedBox(height: 30),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
                          final maxButtonWidth = isLandscape ? 450.0 : constraints.maxWidth;
                          
                          return ListView.builder(
                            itemCount: activity5.availableLevels.length,
                            itemBuilder: (context, index) {
                              final level = activity5.availableLevels[index];
                              return Center(
                                child: Container(
                                  constraints: BoxConstraints(
                                    maxWidth: maxButtonWidth,
                                  ),
                                  width: double.infinity,
                                  child: _buildLevelCard(context, level),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Construye una tarjeta para un nivel de la actividad 5 en desarrollo
  Widget _buildLevelCard(BuildContext context, LevelModel level) {
    // Construir una tarjeta para un nivel de la actividad 5 en desarrollo
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Card(
        elevation: 4,
        // Color de fondo verde y texto blanco para la tarjeta del nivel
        color: const Color(0xFF4CAF50),
        child: InkWell(
          onTap: () => _onLevelSelected(context, level),
          child: Container(
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    // Forma circular para el número del nivel en la tarjeta
                    color: const Color(0xFF00FF00),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${level.id}',
                      style: AppTheme.levelNumberStyle,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    level.description,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      // Color de texto blanco para la descripción del nivel
                      color: Colors.white,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward,
                  // Color de la flecha blanca para la tarjeta del nivel
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}