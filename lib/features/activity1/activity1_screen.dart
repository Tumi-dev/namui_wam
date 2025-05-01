import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:namuiwam/core/themes/app_theme.dart';
import 'package:namuiwam/core/models/activities_state.dart';
import 'package:namuiwam/core/models/level_model.dart';
import 'package:namuiwam/features/activity1/screens/activity1_level_screen.dart';

/// Pantalla principal para la Actividad 1: "Muntsik mɵik kɵtasha sɵl lau".
///
/// Muestra la lista de niveles disponibles para esta actividad.
/// Utiliza [Consumer<ActivitiesState>] para obtener el estado de la actividad
/// y construir la lista de niveles.
class Activity1Screen extends StatelessWidget {
  /// Crea una instancia de [Activity1Screen].
  const Activity1Screen({super.key});

  /// Navega de vuelta a la pantalla de inicio ([HomeScreen]).
  void _navigateToHome(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  /// Maneja la selección de un nivel.
  ///
  /// Si el nivel no está bloqueado, navega a [Activity1LevelScreen].
  /// Si está bloqueado, muestra un [SnackBar].
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
        builder: (context) => Activity1LevelScreen(level: level),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ActivitiesState>(
      builder: (context, activitiesState, child) {
        // Obtiene el estado específico de la Actividad 1.
        final activity1 = activitiesState.getActivity(1);
        // Si no hay datos para la actividad, muestra un widget vacío.
        if (activity1 == null) return const SizedBox.shrink();

        return Scaffold(
          extendBodyBehindAppBar: true, // Permite que el cuerpo se extienda detrás del AppBar
          appBar: AppBar(
            leading: IconButton(
              icon: AppTheme.homeIcon, // Icono para volver a inicio
              onPressed: () => _navigateToHome(context),
            ),
            title: const Text(
              'Muntsik mɵik kɵtasha sɵl lau', // Título de la actividad
              style: AppTheme.activityTitleStyle,
            ),
            backgroundColor: Colors.transparent, // AppBar transparente
            elevation: 0, // Sin sombra en el AppBar
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
                    
                    // Construye la lista de niveles
                    return ListView.builder(
                      itemCount: activity1.availableLevels.length,
                      itemBuilder: (context, index) {
                        final level = activity1.availableLevels[index];
                        // Centra cada tarjeta de nivel y limita su ancho máximo
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
  /// (abierto o cerrado) según el estado de bloqueo del nivel.
  /// El estilo visual cambia si el nivel está bloqueado.
  Widget _buildLevelCard(BuildContext context, LevelModel level) {
    final bool isLocked = level.isLocked;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Card(
        elevation: 4,
        // Cambia el color de fondo de la tarjeta según el estado de bloqueo
        color: isLocked ? Colors.grey[300] : const Color(0xFF556B2F), // Color específico para A1
        child: InkWell(
          onTap: () => _onLevelSelected(context, level), // Acción al tocar la tarjeta
          child: Container(
            height: 72, // Altura fija para la tarjeta
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                // Círculo con el número del nivel
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    // Cambia el color del círculo según el estado de bloqueo
                    color: isLocked ? Colors.grey : const Color(0xFF556B2F), // Color específico para A1
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
                    level.description, // Descripción obtenida del modelo
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      // Cambia el color del texto según el estado de bloqueo
                      color: isLocked ? Colors.grey[600] : Colors.white,
                    ),
                  ),
                ),
                // Icono de candado (abierto o cerrado)
                Icon(
                  isLocked ? Icons.lock : Icons.lock_open,
                  // Cambia el color del icono según el estado de bloqueo
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