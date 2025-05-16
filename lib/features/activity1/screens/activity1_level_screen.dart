import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:namuiwam/core/models/activities_state.dart';
import 'package:namuiwam/core/models/game_state.dart';
import 'package:namuiwam/core/templates/scrollable_level_screen.dart';
import 'package:namuiwam/core/services/feedback_service.dart';
import 'package:namuiwam/core/widgets/info_bar_widget.dart';
import 'package:namuiwam/features/activity1/services/activity1_service.dart';
import 'package:namuiwam/features/activity1/models/number_word.dart';
import 'package:namuiwam/core/services/sound_service.dart';

/// Pantalla para un nivel específico de la Actividad 1.
///
/// Hereda de [ScrollableLevelScreen] para proporcionar una estructura base
/// con AppBar y fondo con gradiente.
/// Presenta un número en Namtrik (texto y audio) y opciones numéricas para
/// que el usuario seleccione la correcta.
class Activity1LevelScreen extends ScrollableLevelScreen {
  /// Crea una instancia de [Activity1LevelScreen].
  ///
  /// Requiere el [level] actual y establece el [activityNumber] en 1.
  const Activity1LevelScreen({super.key, required super.level})
      : super(activityNumber: 1);

  /// Crea el estado mutable para esta pantalla.
  @override
  State<Activity1LevelScreen> createState() => _Activity1LevelScreenState();
}

/// Clase de estado para [Activity1LevelScreen].
///
/// Gestiona la lógica del juego, incluyendo la carga de números, la reproducción
/// de audio, el manejo de respuestas, la actualización de puntos y la navegación.
/// Implementa [WidgetsBindingObserver] para manejar el ciclo de vida de la app
/// (p. ej., detener el audio si la app pasa a segundo plano).
class _Activity1LevelScreenState
    extends ScrollableLevelScreenState<Activity1LevelScreen>
    with WidgetsBindingObserver {
  /// El número current que se muestra en el juego (texto y audio).
  NumberWord? currentNumber;
  /// Lista de opciones numéricas presentadas al usuario.
  List<int> numberOptions = [];
  /// Servicio para proporcionar retroalimentación háptica.
  final _feedbackService = GetIt.instance<FeedbackService>();
  /// Servicio específico para la lógica de la Actividad 1.
  late final Activity1Service _activity1Service;
  /// Servicio para reproducir sonidos de la aplicación.
  final _soundService = GetIt.instance<SoundService>();
  /// Indica si el usuario ya seleccionó la respuesta correcta.
  bool isCorrectAnswerSelected = false;
  /// Indica si el audio se está reproduciendo actualmente.
  bool isPlayingAudio = false;
  /// Indica si ocurrió un error al cargar los datos del nivel.
  bool _isError = false;

  /// Inicializa el estado de la pantalla.
  ///
  /// Establece los intentos restantes, registra el observador del ciclo de vida,
  /// obtiene la instancia del servicio de la actividad e inicializa el juego.
  @override
  void initState() {
    super.initState();
    remainingAttempts = 3; // Número inicial de intentos
    WidgetsBinding.instance.addObserver(this);
    _activity1Service = GetIt.instance<Activity1Service>();
    _initializeGame();
  }

  /// Inicializa o reinicia el juego para el nivel actual.
  ///
  /// Restablece el estado, obtiene un nuevo número y opciones del servicio,
  /// y actualiza la UI.
  /// Maneja posibles errores durante la carga.
  void _initializeGame() async {
    isCorrectAnswerSelected = false;
    remainingAttempts = 3;

    // Mostrar indicador de carga mientras se obtienen los datos
    if (mounted) {
      setState(() {
        currentNumber = null;
        _isError = false;
      });
    }

    // Obtener un número aleatorio para el nivel actual
    final number =
        await _activity1Service.getRandomNumberForLevel(widget.level.id);
    if (!mounted) return; // Verificar si el widget sigue montado

    if (number == null) {
      setState(() {
        _isError = true;
      });
      return;
    }

    // Generar opciones para el número actual y mostrarlos
    final options = await _activity1Service.generateOptionsForLevel(
        widget.level.id, number.number);
    if (!mounted) return; // Verificar si el widget sigue montado

    // Actualizar el estado con el número y las opciones generadas
    setState(() {
      currentNumber = number;
      numberOptions = options;
      _isError = false;
    });

    // Actualizar puntos globales en la barra de información
    final gameState = GameState.of(context);
    setState(() {
      totalScore = gameState.globalPoints;
    });
  }

  /// Reproduce el audio del número actual en Namtrik.
  ///
  /// Utiliza [_activity1Service] para la reproducción y [_feedbackService]
  /// para la vibración. Actualiza [isPlayingAudio] para reflejar el estado.
  Future<void> _playAudio() async {
    if (isPlayingAudio || currentNumber == null) return;

    try {
      if (mounted) {
        setState(() {
          isPlayingAudio = true;
        });
      }

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

  /// Maneja la selección de una opción numérica por parte del usuario.
  ///
  /// Comprueba si la selección es correcta o incorrecta y llama a la función
  /// correspondiente ([_handleCorrectAnswer] o [_handleIncorrectAnswer]).
  void _handleNumberSelection(int selectedNumber) {
    if (isCorrectAnswerSelected || currentNumber == null) return;

    // Verificar si la opción seleccionada es correcta
    if (selectedNumber == currentNumber!.number) {
      _handleCorrectAnswer();
    } else {
      _handleIncorrectAnswer();
    }
  }

  /// Maneja el caso en que el usuario selecciona la respuesta correcta.
  ///
  /// Marca la respuesta como correcta, proporciona retroalimentación háptica,
  /// actualiza el estado del juego (puntos, nivel completado), y muestra un
  /// diálogo de felicitación o de nivel ya completado.
  void _handleCorrectAnswer() async {
    if (!mounted) return;

    _soundService.playCorrectSound();

    setState(() {
      isCorrectAnswerSelected = true;
    });

    await _feedbackService.lightHapticFeedback();

    if (!mounted) return;

    final activitiesState = ActivitiesState.of(context);
    final gameState = GameState.of(context);
    final wasCompleted = gameState.isLevelCompleted(1, widget.level.id - 1);

    if (!wasCompleted) {
      // Nivel completado por primera vez
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

      // Mostrar diálogo de nivel completado
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
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Cierra el diálogo
                    Navigator.of(context).pop(); // Vuelve a la pantalla de selección de nivel
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
      // Nivel ya completado anteriormente
      if (!mounted) return;

      // Mostrar diálogo de nivel ya completado
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
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Cierra el diálogo
                    Navigator.of(context).pop(); // Vuelve a la pantalla de selección de nivel
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
    }
  }

  /// Maneja el caso en que el usuario selecciona una respuesta incorrecta.
  ///
  /// Decrementa los intentos restantes, proporciona retroalimentación háptica,
  /// y muestra un [SnackBar] con los intentos restantes o un [AlertDialog]
  /// si se agotan los intentos, regresando al menú de la actividad.
  void _handleIncorrectAnswer() async {
    if (!mounted) return;

    _soundService.playIncorrectSound();

    setState(() {
      remainingAttempts--;
    });

    if (remainingAttempts <= 0) {
      // Sin intentos restantes
      await _feedbackService.heavyHapticFeedback();
      if (!mounted) return;

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
                Navigator.of(context).pop(); // Cierra el diálogo
                Navigator.of(context).pop(); // Vuelve a la pantalla de selección de nivel
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
      // Intentos restantes
      await _feedbackService.mediumHapticFeedback();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Respuesta incorrecta. Te quedan $remainingAttempts intentos.'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// Detiene la reproducción de audio actual.
  ///
  /// Utilizado principalmente cuando la aplicación pasa a segundo plano.
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

  /// Escucha los cambios en el ciclo de vida de la aplicación.
  ///
  /// Llama a [_stopAudio] si la aplicación no está en estado 'resumed'.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      _stopAudio();
    }
  }

  /// Libera los recursos al destruir el widget.
  ///
  /// Detiene el audio y elimina el observador del ciclo de vida.
  @override
  void dispose() {
    _stopAudio();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Construye el contenido principal de la pantalla del nivel.
  ///
  /// Muestra un indicador de carga, un mensaje de error, o el contenido del juego
  /// (barra de información, número en Namtrik con botón de audio, y las opciones numéricas).
  @override
  Widget buildLevelContent() {
    if (_isError) {
      return const Center(
        child: Text('Error al cargar el nivel',
            style: TextStyle(color: Colors.white)),
      );
    }

    if (currentNumber == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;

    return Column(
      children: [
        // Barra de información con intentos y puntos
        InfoBar(
          remainingAttempts: remainingAttempts,
          margin: const EdgeInsets.only(bottom: 24),
        ),
        // Contenedor del número en Namtrik y botón de audio
        Container(
          // ... (estilos del contenedor)
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF556B2F),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF556B2F).withOpacity(0.5),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Texto del número en Namtrik (responsivo)
              LayoutBuilder(
                builder: (context, constraints) {
                  // ... (cálculo del tamaño de fuente)
                  double baseFontSize = widget.level.id <= 2
                      ? 36.0
                      : widget.level.id <= 4
                          ? 30.0
                          : 28.0;
                  return SizedBox(
                    width: constraints.maxWidth,
                    child: Text(
                      currentNumber!.word,
                      textAlign: TextAlign.center,
                      // ... (estilos del texto)
                      style: TextStyle(
                        fontSize: baseFontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.3,
                        letterSpacing: 1,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            offset: Offset(2, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              // Botón para escuchar el audio
              Material(
                // ... (estilos del botón)
                color: Colors.white.withOpacity(0.2),
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
                        const Text(
                          'Escuchar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
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
        const SizedBox(height: 50),
        // Opciones numéricas
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isLandscape =
                  MediaQuery.of(context).orientation == Orientation.landscape;
              final maxButtonWidth = isLandscape ? 400.0 : constraints.maxWidth;

              return Column(
                children: numberOptions.map((number) {
                  // Botón para cada opción numérica
                  return Center(
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: maxButtonWidth,
                      ),
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 24),
                      height: 150, // Altura fija para los botones de opción
                      decoration: BoxDecoration(
                        // ... (estilos del contenedor de opción)
                        color: const Color(0xFF556B2F).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF556B2F).withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(15),
                          // Deshabilita el tap si ya se seleccionó la respuesta correcta
                          onTap: isCorrectAnswerSelected
                              ? null
                              : () => _handleNumberSelection(number),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Center(
                              child: Text(
                                number.toString(),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  // Cambia el color si la respuesta correcta ya fue seleccionada
                                  color: isCorrectAnswerSelected
                                      ? Colors.grey.withOpacity(0.7)
                                      : Colors.white,
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
        // Espacio adicional al final
        SizedBox(height: isLandscape ? 20 : 40),
      ],
    );
  }
}
