import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:namui_wam/core/models/level_model.dart';
import 'package:namui_wam/core/models/activities_state.dart';
import 'package:namui_wam/core/models/game_state.dart';
import 'package:namui_wam/core/templates/base_level_screen.dart';
import 'package:namui_wam/core/services/feedback_service.dart';
import 'package:namui_wam/core/widgets/info_bar_widget.dart';
import 'package:namui_wam/features/activity1/models/number_word.dart';
import 'package:namui_wam/features/activity1/services/activity1_service.dart';

// Clase para la pantalla de un nivel de la actividad 1
class Activity1LevelScreen extends BaseLevelScreen {
  const Activity1LevelScreen({
    super.key,
    required LevelModel level,
  }) : super(level: level, activityNumber: 1);

  // Crea el estado mutable para la clase de la pantalla de un nivel de la actividad 1
  @override
  State<Activity1LevelScreen> createState() => _Activity1LevelScreenState();
}

// Clase para el estado de la pantalla de un nivel de la actividad 1
class _Activity1LevelScreenState
    extends BaseLevelScreenState<Activity1LevelScreen> with WidgetsBindingObserver {
  NumberWord? currentNumber;
  List<int> numberOptions = [];
  final _feedbackService = GetIt.instance<FeedbackService>();
  late final Activity1Service _activity1Service;
  bool isCorrectAnswerSelected = false;
  bool isPlayingAudio = false;
  bool _isError = false;
  int remainingAttempts = 3;

  // Inicializa el estado de la pantalla de un nivel de la actividad 1
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _activity1Service = GetIt.instance<Activity1Service>();
    _initializeGame();
  }

  // Inicializa el juego de la actividad 1
  void _initializeGame() async {
    isCorrectAnswerSelected = false;
    remainingAttempts = 3;
    
    // Mostrar indicador de carga mientras se obtienen los datos
    setState(() {
      currentNumber = null;
      _isError = false;
    });
    
    // Obtener un número aleatorio para el nivel actual
    final number = await _activity1Service.getRandomNumberForLevel(widget.level.id);
    if (number == null) {
      if (mounted) {
        setState(() {
          _isError = true;
        });
      }
      return;
    }

    // Generar opciones para el número actual y mostrarlos
    final options = await _activity1Service.generateOptionsForLevel(widget.level.id, number.number);
    
    // Actualizar el estado con el número y las opciones generadas
    if (mounted) {
      setState(() {
        currentNumber = number;
        numberOptions = options;
        _isError = false;
      });
    }

    // Actualizar puntos globales en la barra de información
    if (mounted) {
      final gameState = GameState.of(context);
      setState(() {
        totalScore = gameState.globalPoints;
      });
    }
  }

  // Reproduce el audio del número actual en namtrik
  Future<void> _playAudio() async {
    if (isPlayingAudio || currentNumber == null) return;

    // Reproducir audio del número actual en namtrik y manejar errores  
    try {
      setState(() {
        isPlayingAudio = true;
      });

      // Reproducir audio y vibrar al mismo tiempo para retroalimentación
      await _feedbackService.lightHapticFeedback();
      if(currentNumber != null){
        await _activity1Service.playAudioForNumber(currentNumber!);
      }

      // Actualizar el estado después de reproducir el audio
      if (mounted) {
        setState(() {
          isPlayingAudio = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isPlayingAudio = false;
        });
      }
      debugPrint('Error reproduciendo audio: $e');
    }
  }

  // Encuentra la opción seleccionada por el usuario y maneja la respuesta
  void _handleNumberSelection(int selectedNumber) {
    if (isCorrectAnswerSelected || currentNumber == null) return;

    // Verificar si la opción seleccionada es correcta
    if (selectedNumber == currentNumber!.number) {
      _handleCorrectAnswer();
    } else {
      _handleIncorrectAnswer();
    }
  }

  // Maneja la respuesta correcta del usuario y actualiza el estado
  void _handleCorrectAnswer() async {
    if (!mounted) return;

    // Actualizar el estado para mostrar que la respuesta es correcta
    setState(() {
      isCorrectAnswerSelected = true;
    });

    // Vibrar y esperar antes de mostrar el diálogo de respuesta correcta
    await _feedbackService.heavyHapticFeedback();

    // Actualizar el estado después de la vibración y mostrar el diálogo
    if (!mounted) return;

    // Actualizar el estado del juego y mostrar el diálogo de respuesta correcta
    final activitiesState = ActivitiesState.of(context);
    // Actualizar el estado del juego y mostrar el diálogo de respuesta correcta
    final gameState = GameState.of(context);
    // Verificar si el nivel se ha completado y agregar puntos si es necesario
    final wasCompleted = gameState.isLevelCompleted(1, widget.level.id - 1);

    // Verificar si el nivel se ha completado y agregar puntos si es necesario
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

      // Mostrar diálogo de nivel completado si se agregaron puntos
      if (!mounted) return;

      // Mostrar diálogo de nivel completado si se agregaron puntos
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
                // Botón para continuar al siguiente nivel o salir
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
      
      // Mostrar diálogo de respuesta correcta si el nivel ya estaba completado
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

  // Maneja la respuesta incorrecta del usuario y actualiza el estado del juego
  void _handleIncorrectAnswer() async {
    if (!mounted) return;

    // Vibrar y mostrar un mensaje de error antes de actualizar el estado
    await _feedbackService.lightHapticFeedback();
    
    // Actualizar el estado después de la vibración y mostrar un mensaje de error
    setState(() {
      remainingAttempts--;
    });

    // Mostrar diálogo de respuesta incorrecta si se agotan los intentos restantes
    if (remainingAttempts <= 0) {
      if (!mounted) return;
      
      // Mostrar diálogo de respuesta incorrecta si se agotan los intentos
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

  // Detiene la reproducción de audio actual si la aplicación pasa a segundo plano
  Future<void> _stopAudio() async {
    try {
      await _activity1Service.stopAudio();
      if (mounted) {
        setState(() {
          isPlayingAudio = false;
        });
      }
    } catch (e) {
      debugPrint('Error deteniendo audio: $e');
    }
  }

  // Maneja los cambios en el estado de la aplicación y detiene el audio si es necesario
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      _stopAudio();
    }
  }

  // Libera los recursos de audio y elimina el observador de cambios de estado
  @override
  void dispose() {
    _stopAudio();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Construye la barra de puntuación y los intentos restantes para la actividad 1
  Widget buildScoreAndAttempts() {
    // Retornamos un widget vacío para no mostrar la barra original
    return const SizedBox.shrink();
  }

  // Construye el contenido del nivel de la actividad 1 con el número actual
  @override
  Widget buildLevelContent() {
    if (_isError) {
      return const Center(
        child: Text('Error al cargar el nivel'),
      );
    }

    // Mostrar indicador de carga mientras se obtienen los datos del nivel
    if (currentNumber == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Construir la pantalla del nivel con el número actual y las opciones
    return SafeArea(
      child: Column(
        children: [
          InfoBar(
            remainingAttempts: remainingAttempts,
            margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16, top: 8),
          ),
          // Contenedor del número en namtrik con botón de audio
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Contenedor del número en namtrik con botón de audio
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green[700]?.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        // Sombra para el contenedor del número en namtrik
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    // Columna con el número en namtrik y botón de audio
                    child: Column(
                      children: [
                        // Texto responsivo con tamaño mínimo garantizado para el número
                        LayoutBuilder(
                          builder: (context, constraints) {
                            // Calcular el tamaño base según el nivel actual
                            double baseFontSize = widget.level.id <= 2 ? 48.0 : 
                                                widget.level.id <= 4 ? 40.0 : 36.0;
                            
                            // Ajustar el tamaño base según el ancho disponible y el tamaño mínimo
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
                        // Espacio entre el número en namtrik y el botón de audio
                        const SizedBox(height: 16),
                        // Botón de audio mejorado para el número en namtrik
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
                                  // Texto para el botón de audio del número en namtrik
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
                  // Espacio entre el número en namtrik y las opciones
                  const SizedBox(height: 24),
                  // Grid responsivo de opciones para el número actual
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth > 400 ? 2 : 1;
                      // Retornar un grid con las opciones para el número actual y el usuario
                      return GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 3,
                        children: numberOptions.map((number) {
                          // Contenedor con la opción seleccionada por el usuario y su número
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
                            // Material con tinta para la opción seleccionada por el usuario
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(15),
                                onTap: isCorrectAnswerSelected
                                    ? null
                                    : () => _handleNumberSelection(number),
                                // Centro con el número de la opción seleccionada por el usuario
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
