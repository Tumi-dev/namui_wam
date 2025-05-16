import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:namuiwam/core/themes/app_theme.dart';
import 'package:namuiwam/core/models/activities_state.dart';
import 'package:namuiwam/core/models/level_model.dart';
import 'package:namuiwam/features/activity4/screens/activity4_level_screen.dart';

/// {@template activity4_screen}
/// Pantalla principal para la Actividad 4: "Anwan ashipelɵ kɵkun" (Aprendamos a usar el dinero).
///
/// Esta pantalla sirve como punto de entrada a los cuatro modos de juego relacionados 
/// con el manejo del dinero en Namtrik:
/// - Nivel 1: Conozcamos el dinero Namtrik - Exploración de denominaciones
/// - Nivel 2: Escojamos el dinero correcto - Selección para comprar artículos
/// - Nivel 3: Escojamos el nombre correcto - Asociación de dinero con nombres Namtrik
/// - Nivel 4: Coloquemos el dinero correcto - Formación de valores específicos
///
/// Características principales:
/// - Visualiza los cuatro niveles como tarjetas seleccionables
/// - Presenta un icono distintivo de dinero (attach_money) que identifica temáticamente la actividad
/// - Utiliza colores rojizos terrosos (0xFFCD5C5C) específicos para esta actividad
/// - Se adapta a diferentes orientaciones y tamaños de pantalla
/// - Gestiona la navegación desde y hacia otras pantallas de la aplicación
///
/// Ejemplo de navegación a esta pantalla:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => const Activity4Screen(),
///   ),
/// );
/// ```
/// {@endtemplate}
class Activity4Screen extends StatelessWidget {
  /// {@macro activity4_screen}
  const Activity4Screen({super.key});

  /// Navega hacia la pantalla de inicio de la aplicación (la primera ruta en la pila).
  ///
  /// Este método cierra todas las pantallas en la pila de navegación 
  /// hasta llegar a la ruta inicial (la pantalla de inicio), utilizando
  /// [Navigator.popUntil] con la condición route.isFirst.
  ///
  /// Es invocado cuando el usuario presiona el botón de "Home" en el AppBar.
  void _navigateToHome(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  /// Navega hacia la pantalla del nivel específico [Activity4LevelScreen]
  /// correspondiente al [level] seleccionado.
  ///
  /// Este método crea una nueva instancia de [Activity4LevelScreen] configurada
  /// con el [level] seleccionado y utiliza [Navigator.push] para mostrarla.
  ///
  /// Según el ID del nivel, la pantalla destino mostrará:
  /// - Nivel 1: Interfaz de exploración con paginador de denominaciones
  /// - Nivel 2: Interfaz de selección de opciones para comprar artículos
  /// - Nivel 3: Interfaz de selección de nombres para grupos de denominaciones
  /// - Nivel 4: Interfaz de composición de valores mediante selección múltiple
  ///
  /// [context] El contexto de construcción para la navegación.
  /// [level] El modelo del nivel seleccionado que contiene información como ID, título y descripción.
  void _onLevelSelected(BuildContext context, LevelModel level) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Activity4LevelScreen(level: level),
      ),
    );
  }

  /// Construye la interfaz de usuario de la pantalla principal de la Actividad 4.
  ///
  /// Este método:
  /// 1. Utiliza [Consumer<ActivitiesState>] para acceder al estado actualizado de las actividades
  /// 2. Obtiene los datos específicos de la Actividad 4 del estado global
  /// 3. Construye un [Scaffold] con AppBar personalizado y fondo con gradiente
  /// 4. Muestra un icono de dinero que identifica visualmente la temática de la actividad
  /// 5. Genera una lista de tarjetas seleccionables para los cuatro niveles disponibles
  ///
  /// La interfaz se adapta a diferentes orientaciones, ajustando automáticamente
  /// el ancho de las tarjetas según la orientación de la pantalla.
  @override
  Widget build(BuildContext context) {
    return Consumer<ActivitiesState>(
      builder: (context, activitiesState, child) {
        final activity4 = activitiesState.getActivity(4);
        if (activity4 == null) return const SizedBox.shrink();

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
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: AppTheme.mainGradient,
            ),
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const Icon(
                      Icons.attach_money,
                      // Color de icono rojo terroso específico de A4
                      color: Color(0xFFCD5C5C),
                      size: 64,
                    ),
                    const SizedBox(height: 30),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isLandscape =
                              MediaQuery.of(context).orientation ==
                                  Orientation.landscape;
                          final maxButtonWidth =
                              isLandscape ? 450.0 : constraints.maxWidth;

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

  /// Construye una tarjeta interactiva ([Card] con [InkWell]) que representa
  /// un [level] individual de la actividad.
  ///
  /// Este método crea una tarjeta seleccionable con:
  /// - El número del nivel en un círculo a la izquierda
  /// - La descripción del nivel ocupando el espacio central
  /// - Un icono de flecha a la derecha indicando navegación
  ///
  /// Las tarjetas utilizan el color rojo terroso distintivo de la Actividad 4,
  /// lo que ayuda a mantener una identidad visual consistente.
  ///
  /// Al tocar cualquier parte de la tarjeta, se invoca [_onLevelSelected]
  /// para navegar a la pantalla del nivel correspondiente.
  ///
  /// [context] El contexto de construcción para manejar interacciones.
  /// [level] El modelo de nivel con datos como ID, título y descripción.
  /// Retorna un [Widget] que representa la tarjeta del nivel.
  Widget _buildLevelCard(BuildContext context, LevelModel level) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Card(
        elevation: 4,
        // Color de fondo rojo terroso específico de A4
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
                  decoration: const BoxDecoration( /// Presente #1
                    color: Color(0xFFCD5C5C),
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
                      color: Colors.white,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward,
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
