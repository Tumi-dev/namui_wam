import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:namuiwam/core/themes/app_theme.dart';
import 'package:namuiwam/core/models/activities_state.dart';
import 'package:namuiwam/core/models/level_model.dart';
import 'package:namuiwam/features/activity4/screens/activity4_level_screen.dart';

// Clase para la pantalla de la actividad 4
class Activity4Screen extends StatelessWidget {
  const Activity4Screen({super.key});

  // Navega hacia la pantalla de inicio de la aplicación al presionar el botón de inicio
  void _navigateToHome(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  // Navega hacia la pantalla de un nivel de la actividad 4 al seleccionar un nivel
  void _onLevelSelected(BuildContext context, LevelModel level) {
    // Navegar a la pantalla del nivel seleccionado de la actividad 4
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Activity4LevelScreen(level: level),
      ),
    );
  }

  // Construye la pantalla de la actividad 4 con los niveles disponibles
  @override
  Widget build(BuildContext context) {
    return Consumer<ActivitiesState>(
      builder: (context, activitiesState, child) {
        final activity4 = activitiesState.getActivity(4);
        if (activity4 == null) return const SizedBox.shrink();

        // Construir la pantalla de la actividad 4 con los niveles disponibles
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
            // Color de fondo transparente y elevación 0 para la barra de la actividad 5
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
                      // Color de icono rojo terroso para la actividad 4
                      color: Color(0xFFCD5C5C),
                      size: 64,
                    ),
                    const SizedBox(height: 30),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
                          final maxButtonWidth = isLandscape ? 450.0 : constraints.maxWidth;
                          
                          return ListView.builder(
                            itemCount: activity4.availableLevels.length,
                            itemBuilder: (context, index) {
                              final level = activity4.availableLevels[index];
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

  // Construye una tarjeta para un nivel de la actividad 4
  Widget _buildLevelCard(BuildContext context, LevelModel level) {
    // Construir una tarjeta para un nivel de la actividad 4
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Card(
        elevation: 4,
        // Color de fondo rojo terroso y texto blanco para la tarjeta del nivel
        color: const Color(0xFFCD5C5C),
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
                    color: const Color(0xFFCD5C5C),
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