import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:namuiwam/core/themes/app_theme.dart';
import 'package:namuiwam/core/models/activities_state.dart';
import 'package:namuiwam/core/models/level_model.dart';
import 'package:namuiwam/features/activity2/screens/activity2_level_screen.dart';

/// Pantalla principal para la Actividad 2: "Muntsikelan pөram kusrekun".
///
/// Muestra la lista de niveles disponibles para esta actividad, permitiendo
/// al usuario seleccionar uno para jugar.
/// Utiliza [Consumer<ActivitiesState>] para obtener el estado de la actividad
/// y construir la lista de niveles.
class Activity2Screen extends StatelessWidget {
  /// Crea una instancia de [Activity2Screen].
  const Activity2Screen({super.key});

  /// Navega de vuelta a la pantalla de inicio ([HomeScreen]).
  void _navigateToHome(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  /// Maneja la selección de un nivel.
  ///
  /// Si el nivel no está bloqueado, navega a [Activity2LevelScreen].
  /// Si está bloqueado, muestra un [SnackBar] informativo.
  void _onLevelSelected(BuildContext context, LevelModel level) {
    if (level.isLocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este nivel está bloqueado')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Activity2LevelScreen(level: level),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ActivitiesState>(
      builder: (context, activitiesState, child) {
        // Obtiene el estado específico de la Actividad 2.
        final activity2 = activitiesState.getActivity(2);
        // Si no hay datos para la actividad, muestra un widget vacío.
        if (activity2 == null) return const SizedBox.shrink();

        return Scaffold(
          extendBodyBehindAppBar: true, // El cuerpo se extiende detrás del AppBar
          appBar: AppBar(
            leading: IconButton(
              icon: AppTheme.homeIcon, // Icono para volver a inicio
              onPressed: () => _navigateToHome(context),
            ),
            title: const Text(
              'Muntsikelan pөram kusrekun', // Título de la Actividad 2
              style: AppTheme.activityTitleStyle,
            ),
            backgroundColor: Colors.transparent, // AppBar transparente
            elevation: 0, // Sin sombra
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: AppTheme.mainGradient, // Fondo con gradiente
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Adapta el ancho máximo de los botones según la orientación
                    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
                    final maxButtonWidth = isLandscape ? 450.0 : constraints.maxWidth;
                    
                    // Construye la lista de niveles disponibles
                    return ListView.builder(
                      itemCount: activity2.availableLevels.length,
                      itemBuilder: (context, index) {
                        final level = activity2.availableLevels[index];
                        // Centra cada tarjeta de nivel y limita su ancho
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
            ),
          ),
        );
      },
    );
  }

  /// Construye un widget [Card] para representar un nivel seleccionable.
  ///
  /// Muestra el número del nivel, su descripción y un icono de candado
  /// (abierto o cerrado) según el estado de bloqueo. El estilo visual
  /// (color) es específico para la Actividad 2 y cambia si el nivel está bloqueado.
  Widget _buildLevelCard(BuildContext context, LevelModel level) {
    final bool isLocked = level.isLocked;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Card(
        elevation: 4,
        // Color de la tarjeta específico para A2, cambia si está bloqueado
        color: isLocked ? Colors.grey[300] : const Color(0xFFDAA520), // Dorado/Ocre
        child: InkWell(
          onTap: () => _onLevelSelected(context, level), // Acción al tocar
          child: Container(
            height: 72, // Altura fija
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                // Círculo con el número del nivel
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    // Color del círculo específico para A2, cambia si está bloqueado
                    color: isLocked ? Colors.grey : const Color(0xFFDAA520),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${level.id}', // Número del nivel
                      style: AppTheme.levelNumberStyle,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Descripción del nivel
                Expanded(
                  child: Text(
                    level.description, // Descripción del modelo
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      // Color del texto cambia si está bloqueado
                      color: isLocked ? Colors.grey[600] : Colors.white,
                    ),
                  ),
                ),
                // Icono de candado (abierto/cerrado)
                Icon(
                  isLocked ? Icons.lock : Icons.lock_open,
                  // Color del icono cambia si está bloqueado
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