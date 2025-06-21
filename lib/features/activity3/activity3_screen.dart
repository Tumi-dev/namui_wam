import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:namuiwam/core/themes/app_theme.dart';
import 'package:namuiwam/core/models/activities_state.dart';
import 'package:namuiwam/core/models/level_model.dart';
import 'package:namuiwam/features/activity3/screens/activity3_level_screen.dart';
import 'package:namuiwam/core/constants/activity_instructions.dart';
import 'package:namuiwam/core/widgets/help/help.dart';

/// {@template activity3_screen}
/// Pantalla principal para la Actividad 3: "Nөsik utөwan asam kusrekun" (Aprendamos a ver la hora).
///
/// Esta pantalla sirve como punto de entrada a los tres modos de juego relacionados con las horas en Namtrik:
/// - Nivel 1: Utөwan lata marөp (Emparejar la hora) - Emparejar relojes con descripciones
/// - Nivel 2: Utөwan wetөpeñ (Adivina la hora) - Selección múltiple de descripciones para un reloj
/// - Nivel 3: Utөwan malsrө (Coloca la hora) - Ajustar un reloj según una descripción textual
///
/// Características principales:
/// - Visualiza los tres niveles como tarjetas seleccionables
/// - Presenta un icono distintivo de reloj que identifica temáticamente la actividad
/// - Utiliza colores tierra/marrón específicos para esta actividad
/// - Se adapta a diferentes orientaciones y tamaños de pantalla
/// - Gestiona la navegación desde y hacia otras pantallas de la aplicación
///
/// Ejemplo de navegación a esta pantalla:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => const Activity3Screen(),
///   ),
/// );
/// ```
/// {@endtemplate}
class Activity3Screen extends StatefulWidget {
  /// {@macro activity3_screen}
  const Activity3Screen({super.key});

  @override
  State<Activity3Screen> createState() => _Activity3ScreenState();
}

class _Activity3ScreenState extends State<Activity3Screen>
    with HelpBannerMixin {
  /// Color específico de la Actividad 3 - Marrón tierra
  static const Color _activity3Color = Color(0xFF8B4513);

  /// Navega hacia la pantalla de inicio de la aplicación.
  ///
  /// Este método cierra todas las pantallas en la pila de navegación
  /// hasta llegar a la ruta inicial (la pantalla de inicio), utilizando
  /// [Navigator.popUntil] con la condición `route.isFirst`.
  ///
  /// Es invocado cuando el usuario presiona el botón de "Home" en el AppBar.
  void _navigateToHome(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  /// Navega hacia la pantalla de un nivel específico de la Actividad 3.
  ///
  /// Este método crea una nueva instancia de [Activity3LevelScreen] configurada
  /// con el [level] seleccionado y utiliza [Navigator.push] para mostrarla.
  ///
  /// Según el ID del nivel, la pantalla [Activity3LevelScreen] destino mostrará la interfaz correspondiente:
  /// - Nivel 1: Interfaz de emparejamiento de relojes con descripciones
  /// - Nivel 2: Interfaz de selección múltiple con un reloj y opciones de texto
  /// - Nivel 3: Interfaz de configuración de reloj con selectores para horas y minutos
  ///
  /// [context] El contexto de construcción para la navegación.
  /// [level] El modelo del nivel seleccionado que contiene información como ID, título y descripción.
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
  /// Este método:
  /// 1. Utiliza [Consumer<ActivitiesState>] para acceder al estado actualizado de las actividades.
  /// 2. Obtiene los datos específicos de la Actividad 3 del estado global.
  /// 3. Construye un [Scaffold] con un AppBar personalizado (título y botón de inicio) y un fondo con gradiente ([AppTheme.mainGradient]).
  /// 4. Muestra un icono de reloj ([Icons.access_time] con color temático) que identifica visualmente la actividad.
  /// 5. Genera una lista de tarjetas seleccionables (usando [_buildLevelCard]) para los niveles disponibles de la Actividad 3.
  ///
  /// La interfaz se adapta a diferentes orientaciones (vertical y horizontal),
  /// ajustando dinámicamente el ancho máximo de las tarjetas de nivel mediante [LayoutBuilder] y [MediaQuery.of(context).orientation].
  @override
  Widget build(BuildContext context) {
    return Consumer<ActivitiesState>(
      builder: (context, activitiesState, child) {
        // Obtiene los datos de la Actividad 3 del estado global.
        final activity3 = activitiesState.getActivity(3);        // Si no hay datos para la actividad 3, muestra un contenedor vacío.
        if (activity3 == null) {
          return const SizedBox.shrink();
        }
        
        // Construye la pantalla principal de la actividad.
        return Scaffold(
          extendBodyBehindAppBar:
              true, // Permite que el cuerpo se extienda detrás del AppBar.
          appBar: AppBar(
            leading: IconButton(
              icon: AppTheme.homeIcon, // Icono para volver al inicio.
              onPressed: () => _navigateToHome(context),
            ),
            title: const Text(
              'Nɵsik utɵwan asam kusrekun', // Título de la actividad en Namtrik.
              style: AppTheme.activityTitleStyle,
            ),            // Fondo transparente para la barra de la aplicación.
            backgroundColor: Colors.transparent,
            elevation: 0, // Sin sombra.
            actions: [
              IconButton(
                icon: AppTheme.questionIcon, // Icono de ayuda/información
                onPressed: showHelpBanner,
              ),
            ],          ),
          body: Stack(
            children: [
              Container(
                // Fondo con gradiente principal de la aplicación.
                decoration: BoxDecoration(
                  gradient: AppTheme.mainGradient,
                ),
                // SafeArea para evitar que el contenido se solape con elementos del sistema (barra de estado, notch).
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 20), // Espacio superior.
                        // Icono representativo de la actividad (reloj).
                        const Icon(
                          Icons.access_time,
                          color: _activity3Color, // Color marrón tierra específico de A3.
                          size: 64,
                        ),
                        const SizedBox(height: 30), // Espacio debajo del icono.
                        // Lista expandida de niveles.
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              // Determina si la orientación es horizontal para ajustar el ancho máximo.
                              final isLandscape =
                                  MediaQuery.of(context).orientation ==
                                      Orientation.landscape;
                              final maxButtonWidth =
                                  isLandscape ? 450.0 : constraints.maxWidth;

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
                                      width: double
                                          .infinity, // Ocupa el ancho disponible limitado por el Container.
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
              // Banner de ayuda usando el widget reutilizable
              HelpBannerWidget(
                isVisible: isHelpBannerVisible,
                onClose: hideHelpBanner,
                headerColor: _activity3Color,
                content: ActivityInstructions.getInstructionForActivity(3),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Construye una tarjeta interactiva ([Card] con [InkWell]) para un [LevelModel] específico.
  ///
  /// Esta tarjeta muestra la información del nivel y permite al usuario navegar
  /// hacia [Activity3LevelScreen] al ser tocada, invocando [_onLevelSelected].
  ///
  /// La tarjeta visualmente incluye:
  /// - El número del nivel ([LevelModel.id]) dentro de un círculo distintivo.
  /// - La descripción textual del nivel ([LevelModel.description]).
  /// - Un icono de flecha ([Icons.arrow_forward]) como indicador de navegabilidad.
  ///
  /// Estéticamente, las tarjetas emplean un color de fondo marrón/tierra (e.g., `Color(0xFF8B4513)`),
  /// característico de la Actividad 3, para reforzar la identidad visual temática.
  ///
  /// [context] El contexto de construcción actual, utilizado para la navegación y obtención de [MediaQuery].
  /// [level] El [LevelModel] que contiene los datos del nivel a mostrar (ID, título, descripción).
  /// Retorna un [Widget] (una [Card]) configurado para mostrar la información del nivel y manejar la interacción.
  Widget _buildLevelCard(BuildContext context, LevelModel level) {
    return Padding(
      padding: const EdgeInsets.only(
          bottom: 16.0), // Espacio debajo de cada tarjeta.
      child: Card(
        elevation: 4, // Sombra de la tarjeta.
        color: const Color(
            0xFF8B4513), // Color de fondo marrón tierra específico de A3.
        child: InkWell(
          // Hace la tarjeta interactiva al tacto.
          onTap: () => _onLevelSelected(context, level), // Acción al tocar.
          child: Container(
            height: 72, // Altura fija de la tarjeta.
            padding: const EdgeInsets.symmetric(
                horizontal: 24.0), // Padding interno horizontal.
            child: Row(
              // Organiza los elementos horizontalmente.
              children: [
                // Círculo con el número del nivel.
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(
                        0xFF8B4513), // Mismo color que la tarjeta para el círculo.
                    shape: BoxShape.circle, // Forma circular.
                  ),
                  child: Center(
                    child: Text(
                      '${level.id}', // Número del nivel.
                      style: AppTheme
                          .levelNumberStyle, // Estilo del número del nivel.
                    ),
                  ),
                ),
                const SizedBox(
                    width: 16), // Espacio entre el círculo y la descripción.
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
