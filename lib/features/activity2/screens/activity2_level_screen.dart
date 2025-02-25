import 'dart:convert';
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
  bool isPlayingAudio = false;
  final TextEditingController _answerController = TextEditingController();
  Map<String, dynamic>? currentNumber;
  List<Map<String, dynamic>> numbers = [];
  int remainingAttempts = 3;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.level.id <= 5) { // Modificado para incluir nivel 5
        loadNumbers();
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
      final String jsonString = await rootBundle.loadString('assets/data/activity2_number.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> misakNumbers = jsonData['numbers']['misak'];
      
      if (!mounted) return;

      setState(() {
        numbers = misakNumbers.map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item)).toList();
        selectRandomNumber();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al cargar los números')),
      );
    }
  }

  void selectRandomNumber() {
    if (numbers.isEmpty) return;

    List<Map<String, dynamic>> levelNumbers;
    if (widget.level.id == 1) {
      levelNumbers = numbers.where((number) {
        int value = int.tryParse(number['number'].toString()) ?? 0;
        return value >= 1 && value <= 9;
      }).toList();
    } else if (widget.level.id == 2) {
      levelNumbers = numbers.where((number) {
        int value = int.tryParse(number['number'].toString()) ?? 0;
        return value >= 10 && value <= 99;
      }).toList();
    } else if (widget.level.id == 3) {
      levelNumbers = numbers.where((number) {
        int value = int.tryParse(number['number'].toString()) ?? 0;
        return value >= 100 && value <= 999;
      }).toList();
    } else if (widget.level.id == 4) {
      levelNumbers = numbers.where((number) {
        int value = int.tryParse(number['number'].toString()) ?? 0;
        return value >= 1000 && value <= 9999;
      }).toList();
    } else if (widget.level.id == 5) {
      levelNumbers = numbers.where((number) {
        int value = int.tryParse(number['number'].toString()) ?? 0;
        return value >= 10000 && value <= 99999;
      }).toList();
    } else {
      levelNumbers = numbers;
    }

    if (levelNumbers.isEmpty) {
      print('No hay números disponibles para el nivel ${widget.level.id}');
      return;
    }

    final random = Random();
    final selectedNumber = levelNumbers[random.nextInt(levelNumbers.length)];
    
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
                  widget.level.id < 6  // Modificado para incluir nivel 5
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
    if (widget.level.id > 6) { // Modificado para permitir hasta el nivel 6
      return const Center(child: Text('Nivel en desarrollo'));
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