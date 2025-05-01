import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:namuiwam/core/models/activities_state.dart';
import 'package:namuiwam/core/models/game_state.dart';
import 'package:namuiwam/core/templates/scrollable_level_screen.dart';
import 'package:namuiwam/core/services/feedback_service.dart';
import 'package:namuiwam/core/widgets/info_bar_widget.dart';
import 'package:namuiwam/features/activity1/services/activity1_service.dart';
import 'package:namuiwam/features/activity1/models/number_word.dart';

// Clase para la pantalla de un nivel de la actividad 1
class Activity1LevelScreen extends ScrollableLevelScreen {
  const Activity1LevelScreen({super.key, required super.level})
      : super(activityNumber: 1);

  // Crea el estado mutable para la clase de la pantalla de un nivel de la actividad 1
  @override
  State<Activity1LevelScreen> createState() => _Activity1LevelScreenState();
}

// Clase para el estado de la pantalla de un nivel de la actividad 1
class _Activity1LevelScreenState
    extends ScrollableLevelScreenState<Activity1LevelScreen>
    with WidgetsBindingObserver {
  NumberWord? currentNumber;
  List<int> numberOptions = [];
  final _feedbackService = GetIt.instance<FeedbackService>();
  late final Activity1Service _activity1Service;
  bool isCorrectAnswerSelected = false;
  bool isPlayingAudio = false;
  bool _isError = false;

  // Inicializa el estado de la pantalla de un nivel de la actividad 1
  @override
  void initState() {
    super.initState();
    remainingAttempts = 3; // Solo asigno el valor aquí
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
    final number =
        await _activity1Service.getRandomNumberForLevel(widget.level.id);
    if (number == null) {
      if (mounted) {
        setState(() {
          _isError = true;
        });
      }
      return;
    }

    // Generar opciones para el número actual y mostrarlos
    final options = await _activity1Service.generateOptionsForLevel(
        widget.level.id, number.number);

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
      if (currentNumber != null) {
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
    await _feedbackService.lightHapticFeedback();

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
      // Agregar puntos al estado global y marcar el nivel como completado si es necesario
      final pointsAdded = await gameState.addPoints(1, widget.level.id - 1, 5);
      if (pointsAdded) {
        activitiesState.completeLevel(1, widget.level.id - 1);
        if (mounted) {
          setState(() {
            totalScore = gameState.globalPoints;
          });
        }
      }

      // Mostrar diálogo de nivel completado si se agregaron puntos y continuar al siguiente nivel
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
                    color: const Color(0xFF556B2F),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                // Botón para continuar al siguiente nivel o salir
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF556B2F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                  ),
                  child: const Text('Continuar'),
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
                // Espacio entre el mensaje y el botón de continuar al menú
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  // Botón de continuar al menú de actividad si el nivel ya estaba completado
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF556B2F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
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

  //
  void _handleIncorrectAnswer() async {
    setState(() {
      remainingAttempts--;
    });
    // Actualizar el estado para mostrar que la respuesta es incorrecta y vibrar al mismo tiempo
    if (remainingAttempts <= 0) {
      await _feedbackService.heavyHapticFeedback();
      // Mostrar diálogo de sin intentos si el usuario ha agotado los intentos y volver al menú de actividad 1
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('¡Sin intentos!'),
          content: const Text(
              'Has agotado tus intentos. Volviendo al menú de actividad.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF556B2F),
              ),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    } else {
      // Mostrar mensaje de respuesta incorrecta y actualizar los intentos restantes
      await _feedbackService.mediumHapticFeedback();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Respuesta incorrecta. Te quedan $remainingAttempts intentos.'),
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

  // Construye el contenido del nivel de la actividad 1 con el número actual
  @override
  Widget buildLevelContent() {
    if (_isError) {
      return const Center(
        child: Text('Error al cargar el nivel',
            style: TextStyle(color: Colors.white)),
      );
    }

    // Mostrar indicador de carga mientras se obtienen los datos del nivel
    if (currentNumber == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    // Obtener el tamaño de la pantalla para diseño responsivo
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;

    // Construir la pantalla del nivel con el número actual y las opciones
    return Column(
      children: [
        InfoBar(
          remainingAttempts: remainingAttempts,
          margin: const EdgeInsets.only(bottom: 24),
        ),
        // Contenedor del número en namtrik con botón de audio
        Container(
          width: double.infinity, // Ancho máximo del contenedor del número en namtrik
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Espacio externo del contenedor
          padding: const EdgeInsets.all(16), // Espacio interno del contenedor
          decoration: BoxDecoration(
            color:
                const Color(0xFF556B2F), // Color de fondo del número en namtrik
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              // Sombra para el contenedor del número en namtrik
              BoxShadow(
                color: const Color(
                    0xFF556B2F), // Color de la sombra del número en namtrik
                blurRadius: 8,
                offset: const Offset(0, 4),
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
                  double baseFontSize = widget.level.id <= 2
                      ? 36.0 // Tamaño base para niveles 1 y 2
                      : widget.level.id <= 4 // Tamaño base para niveles 3 y 4
                          ? 30.0 // Tamaño base para niveles 3 y 4
                          : 28.0; // Tamaño base para niveles 5 y superiores

                  // Ajustar el tamaño base según el ancho disponible y el tamaño mínimo
                  return SizedBox(
                    width: constraints.maxWidth,
                    child: Text(
                      currentNumber!.word,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: baseFontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors
                            .white, // Color del texto del número en namtrik
                        height: 1.3,
                        letterSpacing: 1,
                        shadows: const [
                          Shadow(
                            color: Colors
                                .black, // Color de la sombra del texto del número en namtrik
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
              const SizedBox(height: 24),
              // Botón de audio mejorado para el número en namtrik
              Material(
                color: Colors
                    .white38, // Color de fondo del botón de audio del número en namtrik
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
                          color: Colors
                              .white, // Color del icono de audio del número en namtrik
                          size: 28, // Tamaño del icono de audio del número en namtrik
                        ),
                        // Texto para el botón de audio del número en namtrik
                        const SizedBox(
                            width: 8), // Espacio entre el icono y el texto
                        Text(
                          'Escuchar',
                          style: TextStyle(
                            color: Colors
                                .white, // Color del texto del botón de audio del número en namtrik
                            fontSize:
                                20, // Tamaño del texto del botón de audio del número en namtrik
                            fontWeight: FontWeight
                                .w500, // Peso del texto del botón de audio del número en namtrik
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
        const SizedBox(height: 50),
        // Grid responsivo de opciones para el número actual
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isLandscape =
                  MediaQuery.of(context).orientation == Orientation.landscape;
              final maxButtonWidth = isLandscape ? 400.0 : constraints.maxWidth;

              // Retornar una columna con las opciones para el número actual
              return Column(
                children: numberOptions.map((number) {
                  // Contenedor con la opción seleccionada por el usuario y su número
                  return Center(
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: maxButtonWidth,
                      ),
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 24),
                      height: 150,
                      decoration: BoxDecoration(
                        color: const Color(
                            0xFF556B2F), // Color de fondo de la opción seleccionada por el usuario
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                                0xFF556B2F), // Color de la sombra de la opción seleccionada por el usuario
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      // Material con tinta para la opción seleccionada por el usuario
                      child: Material(
                        color: Colors
                            .transparent, // Color de fondo del material de la opción seleccionada por el usuario
                        child: InkWell(
                          borderRadius: BorderRadius.circular(15),
                          onTap: isCorrectAnswerSelected
                              ? null
                              : () => _handleNumberSelection(number),
                          // Centro con el número de la opción seleccionada por el usuario
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Center(
                              child: Text(
                                number.toString(),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: isCorrectAnswerSelected
                                      ? Colors
                                          .grey // Color del texto de la opción seleccionada por el usuario
                                      : Colors
                                          .white, // Color del texto de la opción seleccionada por el usuario
                                ),
                              ),
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
        ),
        // Espacio adicional al final para asegurar que todos los elementos sean visibles en landscape
        SizedBox(height: isLandscape ? 20 : 40),
      ],
    );
  }
}
