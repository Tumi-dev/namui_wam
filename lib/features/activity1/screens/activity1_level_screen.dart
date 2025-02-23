import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'dart:math';
import 'package:namui_wam/core/models/level_model.dart';
import 'package:namui_wam/core/models/activities_state.dart';
import 'package:namui_wam/core/templates/base_level_screen.dart';
import 'package:namui_wam/core/services/feedback_service.dart';
import 'package:namui_wam/core/services/audio_service.dart';
import 'package:namui_wam/features/activity1/data/numbers_data.dart';
import 'package:namui_wam/features/activity1/models/number_word.dart';
import 'package:namui_wam/features/activity1/models/game_state.dart';

class Activity1LevelScreen extends BaseLevelScreen {
  const Activity1LevelScreen({
    super.key,
    required LevelModel level,
  }) : super(level: level, activityNumber: 1);

  @override
  State<Activity1LevelScreen> createState() => _Activity1LevelScreenState();
}

class _Activity1LevelScreenState
    extends BaseLevelScreenState<Activity1LevelScreen> {
  NumberWord? currentNumber;
  List<int> numberOptions = [];
  final _feedbackService = GetIt.instance<FeedbackService>();
  final _audioService = GetIt.instance<AudioService>();
  final _gameState = Activity1GameState();
  bool isCorrectAnswerSelected = false;
  bool isPlayingAudio = false;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _initializeGame();
    totalScore = _gameState.totalScore;
  }

  void _initializeGame() {
    final number = NumbersData.getRandomNumber(level: widget.level.id);
    if (number == null) {
      setState(() {
        _isError = true;
      });
      return;
    }

    setState(() {
      currentNumber = number;
      numberOptions = _generateOptionsForLevel(number.number);
      _isError = false;
    });
  }

  List<int> _generateOptionsForLevel(int correctNumber) {
    switch (widget.level.id) {
      case 1:
        return _generateLevel1Options(correctNumber);
      case 2:
        return NumbersData.generateOptionsForLevel2(correctNumber);
      case 3:
        return NumbersData.generateOptionsForLevel3(correctNumber);
      case 4:
        return NumbersData.generateOptionsForLevel4(correctNumber);
      case 5:
        return NumbersData.generateOptionsForLevel5(correctNumber);
      default:
        return _generateLevel1Options(correctNumber); // fallback al nivel 1
    }
  }

  List<int> _generateLevel1Options(int correctNumber) {
    final random = Random();
    final Set<int> options = {correctNumber};

    while (options.length < 4) {
      final randomNumber = random.nextInt(9) + 1;
      options.add(randomNumber);
    }

    final result = options.toList();
    result.shuffle(random);
    return result;
  }

  Future<void> _playAudio() async {
    if (isPlayingAudio || currentNumber == null) return;

    try {
      setState(() {
        isPlayingAudio = true;
      });

      await _feedbackService.lightHapticFeedback();

      // Reproducir la secuencia de audios con pausas específicas
      for (int i = 0; i < currentNumber!.audioFiles.length; i++) {
        final audioFile = currentNumber!.audioFiles[i];

        // Reproducir el audio actual
        await _audioService.playAudio('audio/activity/$audioFile');

        // Agregar pausas estratégicas basadas en el nivel y la posición del audio
        if (i < currentNumber!.audioFiles.length - 1) {
          if (widget.level.id >= 4) {
            // Para niveles 4 y 5, pausas más largas después de "ishik" y "srel"
            if (audioFile.contains('Ishik.wav') || audioFile.contains('Srel.wav')) {
              await Future.delayed(const Duration(milliseconds: 1000));
            } else {
              await Future.delayed(const Duration(milliseconds: 600));
            }
          } else {
            // Para niveles 1-3, mantener las pausas anteriores
            if (i == 0) {
              await Future.delayed(const Duration(milliseconds: 800));
            } else {
              await Future.delayed(const Duration(milliseconds: 500));
            }
          }
        }
      }
    } catch (e) {
      if (!mounted) return;
      _feedbackService.showErrorFeedback(
        context,
        'Error al reproducir el audio',
      );
    } finally {
      if (mounted) {
        setState(() {
          isPlayingAudio = false;
        });
      }
    }
  }

  void _handleNumberSelection(int selectedNumber) {
    if (isCorrectAnswerSelected || currentNumber == null) return;

    if (selectedNumber == currentNumber!.number) {
      _handleCorrectAnswer();
    } else {
      _handleIncorrectAnswer();
    }
  }

  void _handleCorrectAnswer() async {
    setState(() {
      isCorrectAnswerSelected = true;
    });

    await _feedbackService.heavyHapticFeedback();

    if (!mounted) return;

    if (!_gameState.isLevelCompleted(widget.level.id)) {
      final activitiesState = ActivitiesState.of(context);
      activitiesState.completeLevel(1, widget.level.id - 1);

      setState(() {
        totalScore = _gameState.totalScore + Activity1GameState.maxLevelScore;
      });

      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('¡Felicitaciones!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Has desbloqueado el siguiente nivel'),
              const SizedBox(height: 8),
              Text(
                '¡Ganaste ${Activity1GameState.maxLevelScore} puntos!',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _gameState.unlockNextLevel(widget.level.id);
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Continuar'),
            ),
          ],
        ),
      );
    } else {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('¡Muy bien!'),
          content: const Text('Has completado el nivel correctamente'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Continuar'),
            ),
          ],
        ),
      );
    }
  }

  void _handleIncorrectAnswer() async {
    await _feedbackService.lightHapticFeedback();
    setState(() {
      remainingAttempts--;
    });

    if (remainingAttempts <= 0) {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('¡Game Over!'),
          content: const Text('Has agotado tus intentos. Inténtalo de nuevo.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Volver a intentar'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildNumberOption(int number) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: isCorrectAnswerSelected
            ? null
            : () => _handleNumberSelection(number),
        child: Text(
          number.toString(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget buildLevelContent() {
    if (_isError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Ha ocurrido un error al cargar el nivel',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _initializeGame();
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (currentNumber == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Column(
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.green[700]?.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currentNumber!.word,
                        style: const TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(2, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      IconButton(
                        icon: Icon(
                          isPlayingAudio
                              ? Icons.volume_up
                              : Icons.volume_up_outlined,
                          color: Colors.white,
                          size: 32,
                        ),
                        onPressed: isPlayingAudio ? null : _playAudio,
                        tooltip: 'Escuchar pronunciación',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  runSpacing: 16,
                  children: numberOptions.map(_buildNumberOption).toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
