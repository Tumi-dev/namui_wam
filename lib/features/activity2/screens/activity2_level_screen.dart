import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:namuiwam/core/models/activities_state.dart';
import 'package:namuiwam/core/templates/base_level_screen.dart';
import 'package:namuiwam/core/widgets/info_bar_widget.dart';
import 'package:namuiwam/core/models/game_state.dart';
import 'package:namuiwam/features/activity2/services/activity2_service.dart';
import 'package:namuiwam/core/constants/activity_descriptions.dart';
import 'package:namuiwam/core/widgets/game_description_widget.dart';
import 'package:namuiwam/core/services/feedback_service.dart';
import 'package:namuiwam/core/themes/app_theme.dart';

/// Pantalla para un nivel específico de la Actividad 2: "Muntsikelan pөram kusrekun".
///
/// Hereda de [BaseLevelScreen] pero sobrescribe el método `build` para un control
/// total del diseño. Presenta un número al usuario y un campo de texto para que
/// escriba la palabra correspondiente en Namtrik.
class Activity2LevelScreen extends BaseLevelScreen {
  /// Crea una instancia de [Activity2LevelScreen].
  ///
  /// Requiere el [level] actual y establece el [activityNumber] en 2.
  const Activity2LevelScreen({super.key, required super.level})
      : super(activityNumber: 2);

  /// Crea el estado mutable para esta pantalla.
  @override
  State<Activity2LevelScreen> createState() => _Activity2LevelScreenState();
}

/// Clase de estado para [Activity2LevelScreen].
///
/// Gestiona la lógica del juego: carga de números, validación de respuestas,
/// manejo de intentos, actualización de estado (puntos, nivel completado),
/// retroalimentación háptica y visual, y navegación.
class _Activity2LevelScreenState
    extends BaseLevelScreenState<Activity2LevelScreen> {
  /// Servicio específico para la lógica de la Actividad 2.
  final _activity2Service = GetIt.instance<Activity2Service>();
  /// Controlador para el campo de texto donde el usuario ingresa la respuesta.
  final TextEditingController _answerController = TextEditingController();
  /// Mapa que contiene el número actual a adivinar y su palabra correspondiente.
  Map<String, dynamic>? currentNumber;
  /// Indica si la pantalla está actualmente cargando datos.
  bool _isLoading = true;
  /// Color del borde del campo de texto, usado para indicar errores.
  Color? _inputBorderColor;

  /// Inicializa el estado de la pantalla.
  ///
  /// Establece los intentos iniciales, carga el primer número después de que
  /// el primer frame es dibujado y actualiza los puntos globales.
  @override
  void initState() {
    super.initState();
    remainingAttempts = 3; // Intentos iniciales
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Carga números solo si el nivel está dentro del rango implementado
      if (widget.level.id <= 7) {
        await loadNumbers();
      }
      // Actualizar puntos globales iniciales
      if (mounted) {
        final gameState = GameState.of(context);
        setState(() {
          totalScore = gameState.globalPoints;
        });
      }
    });
  }

  /// Obtiene un número aleatorio del servicio para el nivel actual.
  ///
  /// Actualiza el estado [_isLoading] y [currentNumber].
  /// Limpia el campo de respuesta si [clearAnswer] es verdadero.
  /// Muestra mensajes de error si ocurren problemas.
  Future<void> _fetchRandomNumber({bool clearAnswer = false}) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final randomNumber =
          await _activity2Service.getRandomNumberForLevel(widget.level.id);

      if (!mounted) return;

      if (randomNumber == null || randomNumber.isEmpty) {
        setState(() {
          _isLoading = false;
          // Considerar mostrar un mensaje más informativo o manejar el estado de "no más números"
          currentNumber = null; // Asegura que no se muestre contenido viejo
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No hay más números disponibles para este nivel.')),
        );
        return;
      }

      setState(() {
        currentNumber = randomNumber;
        if (clearAnswer) _answerController.clear();
        _inputBorderColor = null; // Resetea el color del borde
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        currentNumber = null; // Asegura que no se muestre contenido viejo en caso de error
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar el número: $e')),
      );
      debugPrint('Error en _fetchRandomNumber: $e');
    }
  }

  /// Carga el primer número al iniciar el nivel.
  Future<void> loadNumbers() async {
    await _fetchRandomNumber(clearAnswer: false);
  }

  /// Selecciona un nuevo número aleatorio (usado después de una respuesta, aunque no implementado actualmente).
  /// Limpia el campo de respuesta.
  Future<void> selectRandomNumber() async {
    await _fetchRandomNumber(clearAnswer: true);
  }

  /// Verifica la respuesta ingresada por el usuario.
  ///
  /// Compara la respuesta (ignorando mayúsculas/minúsculas y espacios) con la
  /// palabra correcta usando [_activity2Service.isAnswerCorrect].
  /// Llama a [_handleCorrectAnswer] o [_handleIncorrectAnswer] según el resultado.
  Future<void> checkAnswer() async {
    if (currentNumber == null || _answerController.text.isEmpty || _isLoading) return;

    final userAnswer = _answerController.text.trim();
    final bool isCorrect =
        _activity2Service.isAnswerCorrect(currentNumber!, userAnswer);

    if (isCorrect) {
      await _handleCorrectAnswer();
    } else {
      _handleIncorrectAnswer();
    }
  }

  /// Muestra un diálogo indicando que el nivel fue completado.
  ///
  /// El mensaje varía si el nivel se completó por primera vez ([wasCompleted] es falso)
  /// o si ya se había completado antes.
  void _showLevelCompletedDialog({required bool wasCompleted}) {
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
              Text(
                wasCompleted ? '¡Buen trabajo!' : '¡Felicitaciones!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                wasCompleted
                    ? 'Ya has completado este nivel anteriormente.'
                    : 'Has desbloqueado el siguiente nivel',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              // Muestra los puntos ganados solo si es la primera vez
              if (!wasCompleted) ...[
                const SizedBox(height: 16),
                const Text(
                  '¡Ganaste 5 puntos!',
                  style: TextStyle(
                    color: Color(0xFFDAA520), // Color específico A2
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              // Botón para continuar (cierra diálogo y pantalla de nivel)
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Cierra el diálogo
                  Navigator.of(context).pop(); // Cierra la pantalla del nivel
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDAA520), // Color específico A2
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text('Continuar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Muestra un diálogo indicando que el usuario se quedó sin intentos.
  ///
  /// Ofrece un botón para volver al menú de la actividad.
  void _showNoAttemptsDialog() {
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
              Navigator.of(context).pop(); // Cierra la pantalla del nivel
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFDAA520), // Color específico A2
            ),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  /// Maneja el caso cuando la respuesta del usuario es correcta.
  ///
  /// Proporciona retroalimentación háptica, actualiza el estado del juego
  /// (puntos, nivel completado si es la primera vez) y muestra el diálogo
  /// de nivel completado.
  Future<void> _handleCorrectAnswer() async {
    FeedbackService().lightHapticFeedback(); // Vibración ligera
    final activitiesState = ActivitiesState.of(context);
    final gameState = GameState.of(context);
    if (!mounted) return;

    final wasCompleted = gameState.isLevelCompleted(2, widget.level.id - 1);

    if (!wasCompleted) {
      // Primera vez completando el nivel
      final pointsAdded = await gameState.addPoints(2, widget.level.id - 1, 5);
      if (pointsAdded) {
        activitiesState.completeLevel(2, widget.level.id - 1);
        if (mounted) {
          setState(() {
            totalScore = gameState.globalPoints; // Actualiza puntos en la UI
          });
        }
      }
    }
    // Muestra el diálogo correspondiente (primera vez o ya completado)
    _showLevelCompletedDialog(wasCompleted: wasCompleted);
  }

  /// Maneja el caso cuando la respuesta del usuario es incorrecta.
  ///
  /// Proporciona retroalimentación háptica, decrementa los intentos restantes,
  /// cambia el color del borde del input a rojo. Si los intentos llegan a cero,
  /// muestra el diálogo de "sin intentos". Si quedan intentos, muestra un
  /// [SnackBar] informativo.
  Future<void> _handleIncorrectAnswer() async {
    FeedbackService().mediumHapticFeedback(); // Vibración media
    if (!mounted) return;

    if (remainingAttempts > 0) {
      setState(() {
        remainingAttempts--;
        _inputBorderColor = Colors.red; // Marca el input como erróneo
      });
    }

    if (remainingAttempts <= 0) {
      // Se acabaron los intentos
      await FeedbackService().heavyHapticFeedback(); // Vibración fuerte
      _showNoAttemptsDialog();
    } else {
      // Aún quedan intentos
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Respuesta incorrecta. Te quedan $remainingAttempts intentos.'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// Construye la interfaz de usuario principal de la pantalla.
  ///
  /// Sobrescribe el método `build` de [BaseLevelScreenState] para tener un
  /// diseño personalizado usando un [Scaffold] y llamando a [_buildContent].
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        // Manejo manual del pop si es necesario (aunque canPop: true debería ser suficiente)
        if (!didPop) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          leading: IconButton(
            icon: AppTheme.backArrowIcon, // Icono de flecha atrás
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            widget.level.description, // Título del nivel
            style: AppTheme.levelTitleStyle,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.mainGradient, // Fondo con gradiente
          ),
          child: SafeArea(
            child: _buildContent(), // Construye el contenido principal
          ),
        ),
      ),
    );
  }

  /// Construye el contenido principal desplazable de la pantalla.
  ///
  /// Muestra un mensaje si el nivel está en desarrollo, un indicador de carga,
  /// o el contenido del juego (descripción, barra de info, número, campo de texto,
  /// botón de validar) dentro de un [ListView].
  Widget _buildContent() {
    // Verifica si el nivel está implementado
    if (widget.level.id > 7) {
      return const Center(
          child: Text('Nivel en desarrollo', style: TextStyle(color: Colors.white, fontSize: 18)));
    }

    // Muestra indicador de carga si _isLoading es true
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text('Cargando número...', style: TextStyle(color: Colors.white)),
          ],
        ),
      );
    }

    // Si no está cargando pero no hay número (error o fin de números)
    if (currentNumber == null) {
       return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'No se pudo cargar el número o no hay más disponibles para este nivel.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 16)
          ),
        ),
      );
    }

    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;

    // Usa ListView para asegurar que todo sea desplazable
    return ListView(
      physics: const ClampingScrollPhysics(), // Evita rebote excesivo
      padding: const EdgeInsets.only(bottom: 20), // Padding inferior general
      children: [
        // Descripción del juego
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: GameDescriptionWidget(
                description:
                    ActivityGameDescriptions.getDescriptionForActivity(2),
              ),
            ),
          ),
        ),
        // Barra de información (intentos, puntos)
        InfoBar(
          remainingAttempts: remainingAttempts,
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        ),
        // Contenido principal del juego (solo si hay un número cargado)
        // if (currentNumber != null) ...[ // Condición ya verificada arriba
          // Número a adivinar
          Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: isLandscape ? 450.0 : screenSize.width * 0.8,
                minWidth: 120.0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              margin: const EdgeInsets.symmetric(vertical: 16.0),
              decoration: BoxDecoration(
                color: const Color(0xFFDAA520), // Color A2
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFDAA520).withOpacity(0.5),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  currentNumber!['number'].toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          // Campo de texto para la respuesta
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: TextField(
              controller: _answerController,
              decoration: InputDecoration(
                hintText: 'Yu pɵr muntsillan', // Placeholder en Namtrik
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                ),
                filled: true,
                fillColor: const Color(0xFFDAA520).withOpacity(0.8), // Color A2 con opacidad
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                // Borde cuando el campo está enfocado (puede cambiar a rojo si hay error)
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _inputBorderColor ?? const Color(0xFFDAA520), // Usa rojo si hay error
                    width: 2,
                  ),
                ),
                // Borde cuando el campo está habilitado pero no enfocado
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _inputBorderColor ?? Colors.transparent, // Usa rojo si hay error
                    width: 2,
                  ),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
              cursorColor: Colors.white,
              // Resetea el color del borde al empezar a escribir después de un error
              onChanged: (_) {
                if (_inputBorderColor != null) {
                  setState(() {
                    _inputBorderColor = null;
                  });
                }
              },
              // Permite enviar la respuesta con el botón de acción del teclado
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => checkAnswer(),
            ),
          ),
          // Botón para validar la respuesta
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: ElevatedButton(
                onPressed: _isLoading ? null : checkAnswer, // Deshabilita si está cargando
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDAA520), // Color A2
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  'Validar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        // ], // Fin del if (currentNumber != null)
      ],
    );
  }

  /// Método requerido por [BaseLevelScreenState] pero no utilizado directamente
  /// ya que `build` se sobrescribe completamente y llama a `_buildContent`.
  @override
  Widget buildLevelContent() {
    // Retorna un contenedor vacío ya que la lógica está en _buildContent
    return Container();
  }

  /// Libera los recursos al destruir el widget, específicamente el [TextEditingController].
  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }
}
