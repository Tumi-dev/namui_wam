import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'dart:math';
import 'package:namui_wam/core/models/level_model.dart';
import 'package:namui_wam/core/models/activities_state.dart';
import 'package:namui_wam/core/models/game_state.dart';
import 'package:namui_wam/core/templates/base_level_screen.dart';
import 'package:namui_wam/core/services/feedback_service.dart';
import 'package:namui_wam/core/services/audio_service.dart';
import 'package:namui_wam/core/widgets/info_bar_widget.dart';
import 'package:namui_wam/features/activity1/data/numbers_data.dart';
import 'package:namui_wam/features/activity1/models/number_word.dart';

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
  bool isCorrectAnswerSelected = false;
  bool isPlayingAudio = false;
  bool _isError = false;
  int remainingAttempts = 3;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeGame();
  }

  void _initializeGame() {
    isCorrectAnswerSelected = false;
    remainingAttempts = 3;
    
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

    // Actualizar puntos
    if (mounted) {
      final gameState = GameState.of(context);
      setState(() {
        totalScore = gameState.globalPoints;
      });
    }
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
    if (!mounted) return;

    setState(() {
      isCorrectAnswerSelected = true;
    });

    await _feedbackService.heavyHapticFeedback();

    if (!mounted) return;

    final activitiesState = ActivitiesState.of(context);
    final gameState = GameState.of(context);
    final wasCompleted = gameState.isLevelCompleted(1, widget.level.id - 1);

    if (!wasCompleted) {
      final pointsAdded = await gameState.addPoints(1, widget.level.id - 1, 5);
      if (pointsAdded) {
        activitiesState.completeLevel(1, widget.level.id - 1);
        if (mounted) {
          setState(() {
            totalScore = gameState.globalPoints;
          });
        }
      }

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
                const Text(
                  'Has desbloqueado el siguiente nivel',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
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
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                  ),
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
      if (!mounted) return;
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('¡Correcto!'),
          content: const Text('¡Muy bien! Has acertado nuevamente.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _initializeGame();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
              ),
              child: const Text('Continuar'),
            ),
          ],
        ),
      );
    }
  }

  void _handleIncorrectAnswer() async {
    if (!mounted) return;

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

  Widget buildScoreAndAttempts() {
    // Retornamos un widget vacío para no mostrar la barra original
    return const SizedBox.shrink();
  }

  @override
  Widget buildLevelContent() {
    if (_isError) {
      return const Center(
        child: Text('Error al cargar el nivel'),
      );
    }

    return SafeArea(
      child: Column(
        children: [
          InfoBar(
            remainingAttempts: remainingAttempts,
            margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16, top: 8),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Contenedor del número en namtrik
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
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
