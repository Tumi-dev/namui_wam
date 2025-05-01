import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:namuiwam/core/themes/app_theme.dart';
import 'package:namuiwam/core/models/activities_state.dart';
import 'package:namuiwam/core/models/level_model.dart';
import 'package:namuiwam/features/activity3/screens/activity3_level_screen.dart';

/// Pantalla principal para la Actividad 3: "Nɵsik utɵwan asam kusrekun".
///
/// Muestra la lista de niveles disponibles para esta actividad.
/// Permite al usuario seleccionar un nivel para jugar o volver a la pantalla de inicio.
class Activity3Screen extends StatelessWidget {
  /// Crea una instancia de [Activity3Screen].
  const Activity3Screen({super.key});

  /// Navega hacia la pantalla de inicio de la aplicación.
  ///
  /// Utiliza [Navigator.popUntil] para cerrar todas las rutas hasta la primera.
  void _navigateToHome(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  /// Navega hacia la pantalla de un nivel específico de la Actividad 3.
  ///
  /// Recibe el [level] seleccionado y utiliza [Navigator.push] para abrir
  /// la pantalla [Activity3LevelScreen] correspondiente.
  void _onLevelSelected(BuildContext context, LevelModel level) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Activity3LevelScreen(level: level),
      ),
    );
  }

  /// Construye la interfaz de usuario de la pantalla de la Actividad 3.
  ///
  /// Utiliza un [Consumer] para acceder al estado de las actividades ([ActivitiesState]).
  /// Muestra un [Scaffold] con un [AppBar] personalizado y una lista de niveles
  /// disponibles para la Actividad 3.
  @override
  Widget build(BuildContext context) {
    return Consumer<ActivitiesState>(
      builder: (context, activitiesState, child) {
        // Obtiene los datos de la Actividad 3 del estado global.
        final activity3 = activitiesState.getActivity(3);
        // Si no hay datos para la actividad 3, muestra un contenedor vacío.
        if (activity3 == null) return const SizedBox.shrink();

        // Construye la pantalla principal de la actividad.
        return Scaffold(
          extendBodyBehindAppBar: true, // Permite que el cuerpo se extienda detrás del AppBar.
          appBar: AppBar(
            leading: IconButton(
              icon: AppTheme.homeIcon, // Icono para volver al inicio.
              onPressed: () => _navigateToHome(context),
            ),
            title: const Text(
              'Nɵsik utɵwan asam kusrekun', // Título de la actividad en Namtrik.
              style: AppTheme.activityTitleStyle,
            ),
            // Fondo transparente para la barra de la aplicación.
            backgroundColor: Colors.transparent,
            elevation: 0, // Sin sombra.
          ),
          body: Container(
            // Fondo con gradiente principal de la aplicación.
            decoration: BoxDecoration(
              gradient: AppTheme.mainGradient,
            ),
            // SafeArea para evitar que el contenido se solape con elementos del sistema (barra de estado, notch).
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20), // Espacio superior.
                    // Icono representativo de la actividad (reloj).
                    const Icon(
                      Icons.access_time,
                      color: Color(0xFF8B4513), // Color marrón tierra específico de A3.
                      size: 64,
                    ),
                    const SizedBox(height: 30), // Espacio debajo del icono.
                    // Lista expandida de niveles.
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // Determina si la orientación es horizontal para ajustar el ancho máximo.
                          final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
                          final maxButtonWidth = isLandscape ? 450.0 : constraints.maxWidth;

                          // Construye la lista de niveles usando ListView.builder.
                          return ListView.builder(
                            itemCount: activity3.availableLevels.length,
                            itemBuilder: (context, index) {
                              final level = activity3.availableLevels[index];
                              // Centra cada tarjeta de nivel y limita su ancho máximo.
                              return Center(
                                child: Container(
                                  constraints: BoxConstraints(
                                    maxWidth: maxButtonWidth,
                                  ),
                                  width: double.infinity, // Ocupa el ancho disponible limitado por el Container.
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

  /// Construye una tarjeta interactiva para un nivel específico.
  ///
  /// Muestra el número del nivel, su descripción y una flecha indicadora.
  /// Al tocar la tarjeta, navega a la pantalla de ese nivel usando [_onLevelSelected].
  ///
  /// Retorna un [Widget] que representa la tarjeta del nivel.
  Widget _buildLevelCard(BuildContext context, LevelModel level) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0), // Espacio debajo de cada tarjeta.
      child: Card(
        elevation: 4, // Sombra de la tarjeta.
        color: const Color(0xFF8B4513), // Color de fondo marrón tierra específico de A3.
        child: InkWell( // Hace la tarjeta interactiva al tacto.
          onTap: () => _onLevelSelected(context, level), // Acción al tocar.
          child: Container(
            height: 72, // Altura fija de la tarjeta.
            padding: const EdgeInsets.symmetric(horizontal: 24.0), // Padding interno horizontal.
            child: Row( // Organiza los elementos horizontalmente.
              children: [
                // Círculo con el número del nivel.
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFF8B4513), // Mismo color que la tarjeta para el círculo.
                    shape: BoxShape.circle, // Forma circular.
                  ),
                  child: Center(
                    child: Text(
                      '${level.id}', // Número del nivel.
                      style: AppTheme.levelNumberStyle, // Estilo del número del nivel.
                    ),
                  ),
                ),
                const SizedBox(width: 16), // Espacio entre el círculo y la descripción.
                // Descripción del nivel.
                Expanded(
                  child: Text(
                    level.description, // Texto de la descripción.
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Color del texto blanco.
                    ),
                  ),
                ),
                // Icono de flecha a la derecha.
                const Icon(
                  Icons.arrow_forward,
                  color: Colors.white, // Color del icono blanco.
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}