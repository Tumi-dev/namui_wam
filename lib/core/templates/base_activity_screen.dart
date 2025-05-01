import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:namuiwam/core/models/activities_state.dart';
import 'package:namuiwam/core/models/level_model.dart';
import 'package:namuiwam/core/themes/app_theme.dart';

// Base de pantalla para actividades con niveles
abstract class BaseActivityScreen extends StatelessWidget {
  final String title;
  final int activityId;
  final Widget Function(BuildContext context, LevelModel level) levelScreenBuilder;

  // Constructor de la pantalla base
  const BaseActivityScreen({
    super.key,
    required this.title,
    required this.activityId,
    required this.levelScreenBuilder,
  });

  // Navega a la pantalla de inicio
  void _navigateToHome(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  // Maneja el evento de seleccionar un nivel
  void _onLevelSelected(BuildContext context, LevelModel level) {
    if (level.isLocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este nivel está bloqueado')),
      );
      return;
    }

    // Navega a la pantalla del nivel seleccionado
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => levelScreenBuilder(context, level),
      ),
    );
  }

  // Construye el widget de un nivel para la lista de niveles
  Widget _buildLevelCard(BuildContext context, LevelModel level) {
    final bool isLocked = level.isLocked;
    
    // Retorna un widget de un nivel de la actividad  
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Card(
        elevation: 4,
        color: isLocked ? Colors.grey[300] : Colors.green, // Color gris si está bloqueado, verde si no
        child: InkWell(
          onTap: () => _onLevelSelected(context, level), // Maneja el evento de seleccionar un nivel
          child: Container(
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: 16.0), // Padding horizontal
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isLocked ? Colors.grey : Colors.green[700], // Color gris si está bloqueado, verde si no
                    shape: BoxShape.circle,
                  ),
                  // Centra el número del nivel
                  child: Center(
                    child: Text(
                      '${level.id}',
                      style: AppTheme.levelNumberStyle,
                    ),
                  ),
                ),
                // Espacio entre el número del nivel y la descripción
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    level.description, // Descripción del nivel
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isLocked ? Colors.grey[600] : Colors.white, // Color gris si está bloqueado, blanco si no
                    ),
                  ),
                ),
                // Icono de bloqueo o desbloqueo
                Icon(
                  isLocked ? Icons.lock : Icons.lock_open,
                  color: isLocked ? Colors.grey[600] : Colors.white, // Color gris si está bloqueado, blanco si no
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Construye el widget de la actividad
  @override
  Widget build(BuildContext context) {
    return Consumer<ActivitiesState>(
      builder: (context, activitiesState, child) {
        final activity = activitiesState.getActivity(activityId);
        
        // Retorna un Scaffold con el AppBar y el body de la actividad
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            leading: IconButton(
              icon: AppTheme.homeIcon,
              onPressed: () => _navigateToHome(context),
            ),
            // Título de la actividad
            title: Text(
              title,
              style: AppTheme.activityTitleStyle,
            ),
            backgroundColor: Colors.transparent, // Color transparente de la AppBar 
            elevation: 0,
          ),
          // Body de la actividad
          body: Container(
            decoration: BoxDecoration(
              gradient: AppTheme.mainGradient,
            ),
            // SafeArea para que el contenido no se vea debajo del AppBar
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: activity == null || activity.availableLevels.isEmpty
                    ? const Center(
                        child: Text(
                          'Actividad en desarrollo',
                          style: TextStyle(color: Colors.white, fontSize: 18), // Texto blanco con fuente 18 de la actividad
                        ),
                      )
                    : ListView.builder(
                        itemCount: activity.availableLevels.length,
                        itemBuilder: (context, index) {
                          final level = activity.availableLevels[index];
                          return _buildLevelCard(context, level);
                        },
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
