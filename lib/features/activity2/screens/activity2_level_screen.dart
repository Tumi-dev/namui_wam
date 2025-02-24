import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:namui_wam/core/models/level_model.dart';
import 'package:namui_wam/core/models/activities_state.dart';
import 'package:namui_wam/core/templates/base_level_screen.dart';
import 'package:namui_wam/core/services/audio_service.dart';

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
    totalScore = 0;
    if (widget.level.id == 1) {
      loadNumbers();
    }
  }

  Future<void> loadNumbers() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/activity2_number.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> misakNumbers = jsonData['numbers']['misak'];
      
      // Filtrar solo los números del 1 al 9
      numbers = misakNumbers
          .where((number) => number['number'] >= 1 && number['number'] <= 9)
          .map((e) => e as Map<String, dynamic>)
          .toList();
      
      selectRandomNumber();
    } catch (e) {
      print('Error loading numbers: $e');
    }
  }

  void selectRandomNumber() {
    if (numbers.isEmpty) {
      return;
    }
    
    final random = Random();
    final index = random.nextInt(numbers.length);
    
    setState(() {
      currentNumber = numbers[index];
    });
  }

  void checkAnswer() {
    if (currentNumber == null || _answerController.text.isEmpty) {
      return;
    }

    final userAnswer = _answerController.text.toLowerCase().trim();
    final bool isCorrect = currentNumber!['variations'].any(
      (variation) => variation.toString().toLowerCase() == userAnswer
    );

    if (isCorrect) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('¡Correcto!'),
          content: const Text('Has acertado. +5 puntos'),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  totalScore += 5;
                  _answerController.clear();
                  selectRandomNumber();
                });
                Navigator.of(context).pop();
                final activitiesState = ActivitiesState.of(context);
                activitiesState.completeLevel(2, widget.level.id - 1);
                Navigator.of(context).pop(); // Volver al menú de niveles
              },
              child: const Text('Continuar'),
            ),
          ],
        ),
      );
    } else {
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
  }

  @override
  Widget buildLevelContent() {
    if (widget.level.id != 1) {
      return const Center(child: Text('Nivel en desarrollo'));
    }

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.shade700,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.refresh, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          'Intentos: $remainingAttempts',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber),
                        const SizedBox(width: 8),
                        Text(
                          'Puntos: $totalScore',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (currentNumber != null)
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
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _answerController,
                  decoration: InputDecoration(
                    hintText: 'Escribe el número en Namtrik',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(color: Colors.green.shade700),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: checkAnswer,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  backgroundColor: Colors.green.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Validar',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
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