import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:namui_wam/core/themes/app_theme.dart';
import 'package:namui_wam/core/models/activities_state.dart';
import 'package:namui_wam/core/models/level_model.dart';
import 'package:namui_wam/features/activity4/screens/activity4_level_screen.dart';

// Clase para la pantalla de la actividad 4 en desarrollo
class Activity4Screen extends StatelessWidget {
  const Activity4Screen({super.key});

  // Navega hacia la pantalla de inicio de la aplicación al presionar el botón de inicio
  void _navigateToHome(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  // Navega hacia la pantalla de un nivel de la actividad 4 en desarrollo al seleccionar un nivel
  void _onLevelSelected(BuildContext context, LevelModel level) {
    if (level.isLocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este nivel está bloqueado')),
      );
      return;
    }

    // Navegar a la pantalla del nivel seleccionado de la actividad 4
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Activity4LevelScreen(level: level),
      ),
    );
  }

  // Construye la pantalla de la actividad 4 en desarrollo con los niveles disponibles
  @override
  Widget build(BuildContext context) {
    return Consumer<ActivitiesState>(
      builder: (context, activitiesState, child) {
        final activity4 = activitiesState.getActivity(4);
        if (activity4 == null) return const SizedBox.shrink();

        // Construir la pantalla de la actividad 4 en desarrollo con los niveles disponibles
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            leading: IconButton(
              icon: AppTheme.homeIcon,
              onPressed: () => _navigateToHome(context),
            ),
            title: const Text(
              'Nɵsik utɵwan asam kusrekun',
              style: AppTheme.activityTitleStyle,
            ),
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
                      Icons.access_time,
                      color: Colors.white,
                      size: 64,
                    ),
                    const SizedBox(height: 30),
                    Expanded(
                      child: ListView.builder(
                        itemCount: activity4.availableLevels.length,
                        itemBuilder: (context, index) {
                          final level = activity4.availableLevels[index];
                          return _buildLevelCard(context, level);
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

  // Construye una tarjeta para un nivel de la actividad 4 en desarrollo
  Widget _buildLevelCard(BuildContext context, LevelModel level) {
    final bool isLocked = level.isLocked;
    
    // Construir una tarjeta para un nivel de la actividad 4 en desarrollo
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Card(
        elevation: 4,
        color: isLocked ? Colors.grey[300] : Colors.green,
        child: InkWell(
          onTap: () => _onLevelSelected(context, level),
          child: Container(
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isLocked ? Colors.grey : Colors.green[700],
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
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isLocked ? Colors.grey[600] : Colors.white,
                    ),
                  ),
                ),
                Icon(
                  isLocked ? Icons.lock : Icons.lock_open,
                  color: isLocked ? Colors.grey[600] : Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}