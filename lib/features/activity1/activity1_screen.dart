import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:namuiwam/core/themes/app_theme.dart';
import 'package:namuiwam/core/models/activities_state.dart';
import 'package:namuiwam/core/models/level_model.dart';
import 'package:namuiwam/features/activity1/screens/activity1_level_screen.dart';

/// {@template activity1_screen}
/// Pantalla principal para la Actividad 1: "Muntsik mɵik kɵtasha sɵl lau" (Escoja el número correcto).
///
/// Esta pantalla sirve como punto de entrada para la Actividad 1, mostrando la lista 
/// de niveles disponibles y permitiendo al usuario seleccionar uno para jugar.
/// Implementa la siguiente funcionalidad:
/// - Muestra los niveles organizados como tarjetas, con indicación visual de su estado
/// - Gestiona la navegación hacia la pantalla de juego para el nivel seleccionado
/// - Impide la selección de niveles bloqueados con feedback apropiado
/// - Se adapta a diferentes orientaciones y tamaños de pantalla
///
/// Utiliza [Consumer<ActivitiesState>] para acceder al estado actualizado de los niveles
/// y reaccionar automáticamente a cambios en el progreso del usuario.
///
/// Ejemplo de navegación a esta pantalla:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => const Activity1Screen(),
///   ),
/// );
/// ```
/// 
/// La pantalla está diseñada siguiendo el tema visual unificado de la aplicación,
/// definido en [AppTheme].
/// {@endtemplate}
class Activity1Screen extends StatelessWidget {
  /// {@macro activity1_screen}
  const Activity1Screen({super.key});

  /// Navega de vuelta a la pantalla de inicio ([HomeScreen]).
  ///
  /// Utiliza [Navigator.popUntil] para volver a la primera ruta en la pila
  /// de navegación, que corresponde a la pantalla de inicio.
  void _navigateToHome(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  /// Maneja la selección de un nivel por parte del usuario.
  ///
  /// Este método implementa la lógica para:
  /// - Verificar si el nivel está desbloqueado
  /// - Mostrar un mensaje de error si está bloqueado
  /// - Navegar a la pantalla de juego si está disponible
  ///
  /// [context] El contexto de construcción para mostrar mensajes y navegar.
  /// [level] El nivel seleccionado ([LevelModel]).
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
  /// Esta función crea una tarjeta interactiva que:
  /// - Muestra el número del nivel con un círculo distintivo
  /// - Presenta la descripción del nivel
  /// - Incluye un icono de candado (abierto/cerrado) según el estado
  /// - Adapta la apariencia visual según si el nivel está bloqueado
  /// - Responde a toques para navegar al nivel o mostrar mensaje de bloqueo
  ///
  /// [context] El contexto de construcción para manejar interacciones.
  /// [level] El modelo de nivel ([LevelModel]) a representar.
  /// Retorna un widget [Card] personalizado dentro de un [Padding].
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