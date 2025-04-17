// Es el archivo que contiene la pantalla de inicio de la aplicación con los botones de las actividades.
import 'package:flutter/material.dart';
import 'package:namui_wam/core/themes/app_theme.dart';
import 'package:namui_wam/features/activity1/activity1_screen.dart';
import 'package:namui_wam/features/activity2/activity2_screen.dart';
import 'package:namui_wam/features/activity3/activity3_screen.dart';
import 'package:namui_wam/features/activity4/activity4_screen.dart';
import 'package:namui_wam/features/activity5/activity5_screen.dart';
import 'package:namui_wam/features/activity6/activity6_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<String> activityDescriptions = [
    'Muntsik mɵik kɵtasha sɵl lau',
    'Muntsikelan pөram kusrekun',
    'Nɵsik utɵwan asam kusrekun',
    'Anwan ashipelɵ kɵkun',
    'Wammeran tulisha manchípik kui asamik pɵrik',
    'Muntsielan namtrikmai yunɵmarɵpik',
  ];

  // Lista de colores para los fondos de los botones
  static const List<Color> buttonColors = [
    Color(0xFFD32F2F), // Rojo suave
    Color(0xFF1976D2), // Azul medio
    Color(0xFFFFC107), // Amarillo dorado
    Color(0xFF9C27B0), // Púrpura elegante
    Color(0xFF4CAF50), // Verde fresco
    Color(0xFFFF7043), // Naranja coral
  ];
  // Lista de colores para los círculos de números
  static const List<Color> numberCircleColors = [
    Color(0xFFFF0000), // Rojo
    Color(0xFF00FFFF), // Aqua
    Color(0xFFFFFF00), // Amarillo
    Color(0xFFFF00FF), // Fucsia
    Color(0xFF00FF00), // Lima
    Color(0xFFFFA500), // Naranja
  ];

  void _navigateToActivity(BuildContext context, int activityNumber) {
    final Map<int, Widget> activities = {
      1: const Activity1Screen(),
      2: const Activity2Screen(),
      3: const Activity3Screen(),
      4: const Activity4Screen(),
      5: const Activity5Screen(),
      6: const Activity6Screen(),
    };

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => activities[activityNumber]!),
    );
  }

  // Es el override de la clase StatelessWidget para build el widget
  @override
  Widget build(BuildContext context) {
    print('*** HomeScreen build ejecutado (print directo) ***');
    final screenSize = MediaQuery.of(context).size;
    // Calculamos el tamaño del logo como un porcentaje del ancho de la pantalla
    // Esto permite que el logo se ajuste automáticamente a diferentes tamaños de pantalla
    // y proporcione una experiencia de usuario más consistente.
    final logoSize = screenSize.width * 0.3; //  30% del ancho de la pantalla

    // Es el cuerpo de la pantalla home
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.mainGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'Tsatsɵ Musik',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              // Colocamos todo el contenido en un único ListView para que todo sea scrollable
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // Logo adaptable a la pantalla home (ahora dentro del ListView)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Image.asset(
                          'assets/images/1.logo-colibri.png',
                          height: logoSize,
                          width: logoSize,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    // Botones de actividades - ahora con LayoutBuilder para adaptarse a la orientación
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
                        final maxButtonWidth = isLandscape ? 450.0 : constraints.maxWidth;
                        
                        return Column(
                          children: List.generate(
                            6,
                            (index) => Center(
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth: maxButtonWidth,
                                ),
                                width: double.infinity,
                                child: _buildActivityButton(context, index + 1),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    // Espacio adicional al final para mejor UX
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Es un widget personalizado que representa un botón de actividad con un número y una descripción
  Widget _buildActivityButton(BuildContext context, int activityNumber) {
    // Ajustamos el índice para acceder a las listas de colores (0-based)
    final colorIndex = activityNumber - 1;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16), // Aumentado el margen inferior para mejor separación
      child: Container(
        height: 70, // Altura reducida para un diseño más minimalista
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColors[colorIndex],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24), // Aumentado el padding horizontal para mejor legibilidad
          ),
          onPressed: () => _navigateToActivity(context, activityNumber),
          child: Row(
            children: [
              // Número estilizado con un fondo de color y un círculo
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: numberCircleColors[colorIndex],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$activityNumber',
                    style: AppTheme.levelNumberStyle,
                  ),
                ),
              ),
              const SizedBox(width: 12), // Aumentado el espacio para mejor legibilidad
              // Descripción de la actividad con un estilo y un número de actividad
              Expanded(
                child: Text(
                  activityDescriptions[activityNumber - 1],
                  style: AppTheme.buttonTextStyle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Flecha indicativa para indicar que es un botón de actividad
              AppTheme.levelArrowIcon,
            ],
          ),
        ),
      ),
    );
  }
}
