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
    extends BaseLevelScreenState<Activity1LevelScreen> with WidgetsBindingObserver {
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
    WidgetsBinding.instance.addObserver(this);
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
      case 6:
        return NumbersData.generateOptionsForLevel6(correctNumber);
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

      for (int i = 0; i < currentNumber!.audioFiles.length; i++) {
        if (!mounted) {
          await _stopAudio();
          return;
        }

        final audioFile = currentNumber!.audioFiles[i];
        await _audioService.playAudio('audio/activity/$audioFile');

        if (!mounted) {
          await _stopAudio();
          return;
        }

        if (i < currentNumber!.audioFiles.length - 1) {
          if (widget.level.id >= 4) {
            if (audioFile.contains('Ishik.wav') || audioFile.contains('Srel.wav')) {
              await Future.delayed(const Duration(milliseconds: 1000));
            } else {
              await Future.delayed(const Duration(milliseconds: 600));
            }
          } else {
            if (i == 0) {
              await Future.delayed(const Duration(milliseconds: 800));
            } else {
              await Future.delayed(const Duration(milliseconds: 500));
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error reproduciendo audio: $e');
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

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopAudio();
    super.dispose();
  }

  Future<void> _stopAudio() async {
    if (isPlayingAudio) {
      await _audioService.stopAudio();
      if (mounted) {
        setState(() {
          isPlayingAudio = false;
        });
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || 
        state == AppLifecycleState.inactive) {
      _stopAudio();
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget buildScoreAndAttempts() {
    // Retornamos un widget vacío para no mostrar la barra original
    return const SizedBox.shrink();
  }

  @override
  Widget buildLevelContent() {
    if (_isError) {
      return Center(
        child: Text('Error al cargar el nivel'),
      );
    }

    return SafeArea(
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
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Contenedor del número en namtrik
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    padding: const EdgeInsets.all(16),
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
                      children: [
                        // Texto responsivo con tamaño mínimo garantizado
                        LayoutBuilder(
                          builder: (context, constraints) {
                            // Calcular el tamaño base según el nivel
                            double baseFontSize = widget.level.id <= 2 ? 48.0 : 
                                                widget.level.id <= 4 ? 40.0 : 36.0;
                            
                            return SizedBox(
                              width: constraints.maxWidth,
                              child: Text(
                                currentNumber!.word,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: baseFontSize,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1.3,
                                  letterSpacing: 1,
                                  shadows: const [
                                    Shadow(
                                      color: Colors.black26,
                                      offset: Offset(2, 2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        // Botón de audio mejorado
                        Material(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(50),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(50),
                            onTap: isPlayingAudio ? null : _playAudio,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isPlayingAudio
                                        ? Icons.volume_up
                                        : Icons.volume_up_outlined,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Escuchar',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Grid responsivo de opciones
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth > 400 ? 2 : 1;
                      return GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 3,
                        children: numberOptions.map((number) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(15),
                                onTap: isCorrectAnswerSelected
                                    ? null
                                    : () => _handleNumberSelection(number),
                                child: Center(
                                  child: Text(
                                    number.toString(),
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: isCorrectAnswerSelected
                                          ? Colors.grey
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
