import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:namuiwam/core/themes/app_theme.dart';
import 'package:namuiwam/core/models/activities_state.dart';
import 'package:namuiwam/core/models/level_model.dart';
import 'package:namuiwam/features/activity2/screens/activity2_level_screen.dart';

/// {@template activity2_screen}
/// Pantalla principal para la Actividad 2: "Muntsikelan pөram kusrekun" (Aprendamos a escribir los números).
///
/// Esta pantalla sirve como punto de entrada para la Actividad 2, mostrando la lista 
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
///     builder: (context) => const Activity2Screen(),
///   ),
/// );
/// ```
/// 
/// La pantalla está diseñada siguiendo el tema visual unificado de la aplicación,
/// pero utiliza colores específicos (dorados/ocres) para la identidad visual de esta actividad.
/// {@endtemplate}
class Activity2Screen extends StatelessWidget {
  /// {@macro activity2_screen}
  const Activity2Screen({super.key});

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
  /// Esta función crea una tarjeta interactiva que:
  /// - Muestra el número del nivel con un círculo distintivo
  /// - Presenta la descripción del nivel
  /// - Incluye un icono de candado (abierto/cerrado) según el estado
  /// - Adapta la apariencia visual según si el nivel está bloqueado
  /// - Responde a toques para navegar al nivel o mostrar mensaje de bloqueo
  ///
  /// La tarjeta utiliza colores específicos para la Actividad 2 (dorado/ocre),
  /// lo que ayuda a diferenciarla visualmente de otras actividades en la aplicación.
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