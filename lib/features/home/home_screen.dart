// Es el archivo que contiene la pantalla de inicio de la aplicación con los botones de las actividades.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:namui_wam/core/models/game_state.dart';
import 'package:namui_wam/core/themes/app_theme.dart';
import 'package:namui_wam/features/activity1/activity1_screen.dart';
import 'package:namui_wam/features/activity2/activity2_screen.dart';
import 'package:namui_wam/features/activity3/activity3_screen.dart';
import 'package:namui_wam/features/activity4/activity4_screen.dart';
import 'package:namui_wam/features/activity5/activity5_screen.dart';
import 'package:namui_wam/features/activity6/activity6_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _alertShownSinceLastReset = false;
  GameState? _gameState; // To store gameState reference

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final gameState = Provider.of<GameState>(context);

    // Store gameState for use in _showAlert
    if (_gameState == null) {
      _gameState = gameState;
      // Listen for changes to show the alert
      _gameState!.addListener(_handleGameStateChange);
    }

    // Initial check in case dependencies change after 100 points reached
    // but before listener was added or triggered
    _checkAndShowAlertIfNeeded(gameState);
  }

  @override
  void dispose() {
    _gameState?.removeListener(_handleGameStateChange);
    super.dispose();
  }

  void _handleGameStateChange() {
    // Ensure gameState is not null and context is still mounted
    if (_gameState != null && mounted) {
        _checkAndShowAlertIfNeeded(_gameState!);
        // We also need to trigger a rebuild if the button state changes
        setState(() {});
    }
  }

  void _checkAndShowAlertIfNeeded(GameState gameState) {
      if (gameState.canManuallyReset && !_alertShownSinceLastReset) {
        _alertShownSinceLastReset = true;
        // Use addPostFrameCallback to show dialog after the build phase
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) { // Check if the widget is still in the tree
            _showResetReadyAlert();
          }
        });
      }
      // If points are 0, reset the alert flag (assuming reset always sets points to 0)
      // Note: This might reset the flag if the game starts at 0 initially.
      // A more robust solution might involve a flag in GameState set during reset.
      if (gameState.globalPoints == 0 && _alertShownSinceLastReset) {
         print("Resetting alert flag because global points are 0.");
         _alertShownSinceLastReset = false;
      }
  }

  void _showResetReadyAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('¡Objetivo Alcanzado!'),
          content: const Text(
              'Has obtenido los 100 puntos. Puedes reiniciar el progreso de las actividades 1 a 4 usando el botón de reinicio.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Entendido'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

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

  // Dialog to show when the reset button is enabled and tapped
  void _showConfirmationResetDialog() {
    final gameState = Provider.of<GameState>(context, listen: false);
    showDialog(
      context: context,
      barrierDismissible: false, // User must choose an action
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('¡Alerta!'),
          content: const Text(
              'Estás a punto de reiniciar el progreso y los puntos de las actividades 1 a 4. Esta acción no se puede deshacer. ¿Deseas continuar?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Aceptar'),
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog first
                print('Manual reset confirmed by user.');
                await gameState.requestManualReset();
                // Reset the flag after successful manual reset
                _alertShownSinceLastReset = false;
                print('Alert flag reset after manual reset confirmation.');
                // No need for setState here as gameState.requestManualReset notifies listeners
              },
            ),
          ],
        );
      },
    );
  }

  // Dialog to show when the disabled reset button is tapped
  void _showDisabledInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Botón Desactivado'),
          content: const Text(
              'El botón de reinicio se activará automáticamente cuando acumules 100 puntos globales completando niveles de las actividades 1 a 4. ¡Sigue jugando!'),
          actions: <Widget>[
            TextButton(
              child: const Text('Entendido'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch for changes in GameState to update UI (like button state)
    final gameState = context.watch<GameState>();

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
                          height: 150,
                          width: 150,
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
                    // Add the manual reset button
                    InkWell(
                      onTap: () {
                        // Call appropriate dialog based on state
                        if (gameState.canManuallyReset) {
                          _showConfirmationResetDialog();
                        } else {
                          _showDisabledInfoDialog();
                        }
                      },
                      borderRadius: BorderRadius.circular(40.0), // Make it circular for splash effect
                      child: CircleAvatar(
                        radius: 45, // Adjust size of the circle
                        backgroundColor: gameState.canManuallyReset
                            ? Theme.of(context).colorScheme.primary // Enabled background
                            : Colors.grey.shade300, // Disabled background
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.refresh,
                              size: 30, // Icon size
                              color: gameState.canManuallyReset
                                  ? Colors.white // Enabled icon color
                                  : Colors.grey.shade500, // Disabled icon color
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Reiniciar",
                              style: TextStyle(
                                fontSize: 11, // Text size
                                fontWeight: FontWeight.bold,
                                color: gameState.canManuallyReset
                                    ? Colors.white // Enabled text color
                                    : Colors.grey.shade500, // Disabled text color
                              ),
                            ),
                          ],
                        ),
                      ),
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
