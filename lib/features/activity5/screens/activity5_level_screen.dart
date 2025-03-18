import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:namui_wam/core/models/level_model.dart';
import 'package:namui_wam/core/models/game_state.dart';
import 'package:namui_wam/core/models/activities_state.dart';
import 'package:namui_wam/core/templates/base_level_screen.dart';
import 'package:namui_wam/core/widgets/info_bar_widget.dart';
import 'package:namui_wam/features/activity5/services/activity5_service.dart';

// Clase para la pantalla de un nivel de la actividad 5 en desarrollo
class Activity5LevelScreen extends BaseLevelScreen {
  // Constructor de la clase que recibe el nivel de la actividad
  const Activity5LevelScreen({
    Key? key,
    required LevelModel level,
  }) : super(level: level, activityNumber: 5);

  // Crea el estado mutable para la clase de la pantalla de un nivel de la actividad 5
  @override
  State<Activity5LevelScreen> createState() => _Activity5LevelScreenState();
}

// Clase para el estado de la pantalla de un nivel de la actividad 5 en desarrollo
class _Activity5LevelScreenState extends BaseLevelScreenState<Activity5LevelScreen> {
  late Activity5Service _activity5Service;
  bool _isLoading = true;
  int remainingAttempts = 3;
  bool isCorrectAnswerSelected = false;

  // Inicializa el estado de la pantalla de un nivel de la actividad 5
  @override
  void initState() {
    super.initState();
    _activity5Service = GetIt.instance<Activity5Service>();
    _loadLevelData();
  }

  // Carga los datos del nivel de la actividad 5
  Future<void> _loadLevelData() async {
    try {
      await _activity5Service.getLevelData(widget.level);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Maneja la respuesta correcta del usuario y actualiza el estado
  // ignore: unused_element
  void _handleCorrectAnswer() async {
    if (!mounted) return;

    // Actualizar el estado para mostrar que la respuesta es correcta
    setState(() {
      isCorrectAnswerSelected = true;
    });

    // Actualizar el estado del juego y mostrar el diálogo de respuesta correcta
    final activitiesState = ActivitiesState.of(context);
    final gameState = GameState.of(context);
    
    // Verificar si el nivel se ha completado y agregar puntos si es necesario
    final wasCompleted = gameState.isLevelCompleted(5, widget.level.id - 1);

    if (!wasCompleted) {
      final pointsAdded = await gameState.addPoints(5, widget.level.id - 1, 5);
      if (pointsAdded) {
        activitiesState.completeLevel(5, widget.level.id - 1);
        if (mounted) {
          setState(() {
            totalScore = gameState.globalPoints;
          });
        }
      }

      // Mostrar diálogo de nivel completado si se agregaron puntos
      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '¡Felicitaciones!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '¡Ganaste 5 puntos!',
                  style: TextStyle(
                    color: const Color(0xFF00FF00),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    // Color de fondo lima y texto blanco para el botón de continuar
                    backgroundColor: const Color(0xFF00FF00),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: const Text('Continuar'),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      // Mostrar mensaje de nivel ya completado anteriormente
      if (!mounted) return;
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '¡Buen trabajo!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Ya has completado este nivel anteriormente.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    // Color de fondo lima y texto blanco para el botón de continuar
                    backgroundColor: const Color(0xFF00FF00),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: const Text('Continuar'),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  // Maneja la respuesta incorrecta del usuario y actualiza el estado
  // ignore: unused_element
  void _handleIncorrectAnswer() {
    setState(() {
      remainingAttempts--;
    });

    if (remainingAttempts <= 0) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('¡Sin intentos!'),
          content: const Text('Has agotado tus intentos. Volviendo al menú de actividad.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                // Color de texto verde fresco para el botón de aceptar
                foregroundColor: const Color(0xFF4CAF50),
              ),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Respuesta incorrecta. Te quedan $remainingAttempts intentos.'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // Construye el contenido específico del nivel de la actividad 5
  @override
  Widget buildLevelContent() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator(color: Colors.white))
        : Column(
            children: [
              InfoBar(
                remainingAttempts: remainingAttempts,
                margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16, top: 8),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'Nivel ${widget.level.id} - En desarrollo',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          );
  }
}
