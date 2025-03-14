import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:namui_wam/core/models/activities_state.dart';
import 'package:namui_wam/core/templates/base_level_screen.dart';
import 'package:namui_wam/core/widgets/info_bar_widget.dart';
import 'package:namui_wam/core/models/game_state.dart';
import 'package:namui_wam/features/activity2/services/activity2_service.dart';

class Activity2LevelScreen extends BaseLevelScreen {
  const Activity2LevelScreen({
    super.key,
    required level,
  }) : super(level: level, activityNumber: 2);

  @override
  State<Activity2LevelScreen> createState() => _Activity2LevelScreenState();
}

class _Activity2LevelScreenState extends BaseLevelScreenState<Activity2LevelScreen> {
  final _activity2Service = GetIt.instance<Activity2Service>();
  final TextEditingController _answerController = TextEditingController();
  Map<String, dynamic>? currentNumber;
  int remainingAttempts = 3;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.level.id <= 7) {
        await loadNumbers();
      }
      // Actualizar puntos globales
      if (mounted) {
        final gameState = GameState.of(context);
        setState(() {
          totalScore = gameState.globalPoints;
        });
      }
    });
  }

  Future<void> loadNumbers() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      // Get a random number for this level using the Activity2Service
      final randomNumber = await _activity2Service.getRandomNumberForLevel(widget.level.id);
      
      if (!mounted) return;

      if (randomNumber == null || randomNumber.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No hay números disponibles para este nivel')),
        );
        return;
      }

      setState(() {
        currentNumber = randomNumber;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar los números: $e')),
      );
    }
  }

  Future<void> selectRandomNumber() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      // Get a random number for this level using the Activity2Service
      final randomNumber = await _activity2Service.getRandomNumberForLevel(widget.level.id);
      
      if (!mounted) return;

      if (randomNumber == null || randomNumber.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No hay números disponibles para este nivel')),
        );
        return;
      }

      setState(() {
        currentNumber = randomNumber;
        _answerController.clear();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      print('Error al seleccionar número aleatorio: $e');
    }
  }

  Future<void> checkAnswer() async {
    if (currentNumber == null || _answerController.text.isEmpty) return;

    final userAnswer = _answerController.text.trim();
    final bool isCorrect = _activity2Service.isAnswerCorrect(currentNumber!, userAnswer);

    if (isCorrect) {
      _handleCorrectAnswer();
    } else {
      _handleIncorrectAnswer();
    }
  }

  void _handleCorrectAnswer() async {
    final activitiesState = ActivitiesState.of(context);
    final gameState = GameState.of(context);
    if (!mounted) return;

    // Verificar si el nivel ya estaba completado
    final wasCompleted = gameState.isLevelCompleted(2, widget.level.id - 1);

    if (!wasCompleted) {
      // Añadir puntos solo si el nivel no estaba completado
      final pointsAdded = await gameState.addPoints(2, widget.level.id - 1, 5);
      if (pointsAdded) {
        activitiesState.completeLevel(2, widget.level.id - 1);
        if (mounted) {
          setState(() {
            totalScore = gameState.globalPoints;
          });
        }
      }

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
                  widget.level.id < 7
                      ? 'Has desbloqueado el siguiente nivel'
                      : '¡Has completado el nivel!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Text(
                  '¡Ganaste 5 puntos!',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop(); // Volver al menú de niveles
                  },
                  child: const Text(
                    'Continuar',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      // Si el nivel ya estaba completado, mostrar un mensaje diferente
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('¡Correcto!'),
          content: const Text('¡Muy bien! Has acertado nuevamente.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                selectRandomNumber(); // Mostrar nuevo número
              },
              child: const Text('Continuar'),
            ),
          ],
        ),
      );
    }
  }

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
                foregroundColor: Colors.blue,
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

  @override
  Widget buildLevelContent() {
    if (widget.level.id > 7) {
      return const Center(child: Text('Nivel en desarrollo'));
    }

    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando números...'),
          ],
        ),
      );
    }

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              InfoBar(
                remainingAttempts: remainingAttempts,
                margin: const EdgeInsets.only(bottom: 24),
              ),
              if (currentNumber != null) ...[
                Container(
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white, // Fondo blanco para el número actual
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2), // Sombra suave para el número en blanco
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    currentNumber!['number'].toString(),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _answerController,
                    decoration: InputDecoration(
                      hintText: 'Escribe el número en namuiwam',
                      hintStyle: TextStyle(
                        // Cambiar el color del hint para que sea más visible
                        color: Colors.white, // Color de texto blanco para el hint
                        fontSize: 14,
                      ),
                      filled: true,
                      // Cambiar el color de fondo del input para que sea más visible y se destaque
                      fillColor: const Color(0xFF1976D2), // 
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        // Cambiar el color del borde para que sea más visible
                        borderSide: const BorderSide(color: Colors.white, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(
                      color: Colors.white, // Color de texto blanco para el input
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                    cursorColor: Colors.white, // Color del cursor blanco para el input
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: checkAnswer,
                  style: ElevatedButton.styleFrom(
                    // Cambiar el color de fondo del botón para que se destaque
                    backgroundColor: const Color(0xFF00FFFF), // Color cyan para el botón de validación
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  child: const Text(
                    'Validar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      // Cambiar el color del texto para que sea más visible
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }
}