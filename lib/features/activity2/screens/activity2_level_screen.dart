import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:namui_wam/core/models/level_model.dart';
import 'package:namui_wam/core/models/activities_state.dart';
import 'package:namui_wam/core/templates/base_level_screen.dart';
import 'package:namui_wam/core/services/audio_service.dart';
import 'package:namui_wam/core/widgets/info_bar_widget.dart';
import 'package:namui_wam/core/models/game_state.dart';
import 'package:namui_wam/core/services/number_data_service.dart';

class Activity2LevelScreen extends BaseLevelScreen {
  const Activity2LevelScreen({
    super.key,
    required LevelModel level,
  }) : super(level: level, activityNumber: 2);

  @override
  State<Activity2LevelScreen> createState() => _Activity2LevelScreenState();
}

class _Activity2LevelScreenState extends BaseLevelScreenState<Activity2LevelScreen> {
  final _audioService = GetIt.instance<AudioService>();
  final _numberDataService = GetIt.instance<NumberDataService>();
  bool isPlayingAudio = false;
  final TextEditingController _answerController = TextEditingController();
  Map<String, dynamic>? currentNumber;
  List<Map<String, dynamic>> numbers = [];
  int remainingAttempts = 3;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.level.id <= 7) { // Modificado para incluir niveles 6 y 7
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
      
      // Determine the range based on the level
      int start = 1;
      int end = 9;
      
      if (widget.level.id == 1) {
        start = 1;
        end = 9;
      } else if (widget.level.id == 2) {
        start = 10;
        end = 99;
      } else if (widget.level.id == 3) {
        start = 100;
        end = 999;
      } else if (widget.level.id == 4) {
        start = 1000;
        end = 9999;
      } else if (widget.level.id == 5) {
        start = 10000;
        end = 99999;
      } else if (widget.level.id == 6) {
        start = 100000;
        end = 999999;
      } else if (widget.level.id == 7) {
        // For future expansion, when more numbers are added
        start = 1000000;
        end = 9999999;
      }
      
      // Load numbers for this level
      final levelNumbers = await _numberDataService.getNumbersInRange(start, end);
      
      if (!mounted) return;

      if (levelNumbers.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No hay números disponibles para este nivel')),
        );
        return;
      }

      setState(() {
        numbers = levelNumbers;
        _isLoading = false;
        selectRandomNumber();
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

  void selectRandomNumber() {
    if (numbers.isEmpty) {
      print('No hay números disponibles para el nivel ${widget.level.id}');
      return;
    }

    final random = Random();
    final selectedNumber = numbers[random.nextInt(numbers.length)];
    
    if (mounted) {
      setState(() {
        currentNumber = selectedNumber;
        _answerController.clear();
      });
    }
  }

  Future<void> checkAnswer() async {
    if (currentNumber == null || _answerController.text.isEmpty) return;

    final userAnswer = _answerController.text.trim().toLowerCase();
    final List<String> allValidAnswers = [
      currentNumber!['namtrik'].toString().toLowerCase(),
      ...(currentNumber!['variations'] as List<dynamic>).map((v) => v.toString().toLowerCase())
    ];

    final bool isCorrect = allValidAnswers.any((answer) => answer == userAnswer);

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
                  widget.level.id < 7  // Modificado para incluir nivel 6
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
    if (widget.level.id > 7) { // Modificado para permitir hasta el nivel 7
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
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
                        color: Colors.green[50], // Verde mucho más pálido para el hint
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: const Color(0xFF1B5E20), // Verde más oscuro para el fondo
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                    cursorColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: checkAnswer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF66BB6A), // Verde más suave similar al del logo
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
                      color: Colors.white,
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
    if (isPlayingAudio) {
      _audioService.stopAudio();
    }
    super.dispose();
  }
}