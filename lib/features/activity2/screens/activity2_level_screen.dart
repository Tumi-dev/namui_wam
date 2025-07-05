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
import 'package:namuiwam/core/services/sound_service.dart';

/// {@template activity2_level_screen}
/// Pantalla para un nivel específico de la Actividad 2: "Muntsikelan pөram kusrekun" 
/// (Aprendamos a escribir los números).
///
/// Esta pantalla implementa la interacción principal del juego, donde el usuario debe:
/// 1. Ver un número en formato arábigo (por ejemplo, "42")
/// 2. Escribir su representación correcta en idioma Namtrik en un campo de texto
/// 3. Validar su respuesta mediante un botón
///
/// Características principales:
/// - Proporciona retroalimentación inmediata sobre la corrección de la respuesta
/// - Permite hasta tres intentos para acertar
/// - Actualiza el progreso global y desbloquea niveles cuando se completa con éxito
/// - Adapta la dificultad según el nivel seleccionado (desde unidades hasta millones)
/// - Ofrece retroalimentación visual (cambios de color) y háptica (vibración)
///
/// Hereda de [BaseLevelScreen] para mantener consistencia con otras actividades, pero
/// sobrescribe el método `build` para implementar una interfaz específica para la escritura.
///
/// Ejemplo de navegación a esta pantalla:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => Activity2LevelScreen(level: levelModel),
///   ),
/// );
/// ```
/// {@endtemplate}
class Activity2LevelScreen extends BaseLevelScreen {
  /// {@macro activity2_level_screen}
  const Activity2LevelScreen({super.key, required super.level})
      : super(activityNumber: 2);

  /// Crea el estado mutable para esta pantalla.
  @override
  State<Activity2LevelScreen> createState() => _Activity2LevelScreenState();
}

/// {@template activity2_level_screen_state}
/// Estado interno para [Activity2LevelScreen] que gestiona la lógica completa del juego.
///
/// Responsabilidades principales:
/// - Cargar y presentar números aleatorios apropiados para el nivel actual
/// - Gestionar la entrada del usuario a través del campo de texto
/// - Validar las respuestas contra múltiples formas correctas posibles
/// - Manejar el sistema de intentos y retroalimentación
/// - Actualizar el progreso y puntuación global cuando se completa un nivel
/// - Proporcionar respuesta visual y háptica a las interacciones del usuario
///
/// Dado que la escritura en Namtrik puede tener variantes, el sistema de validación
/// es especialmente sofisticado, permitiendo múltiples formas correctas.
/// {@endtemplate}
class _Activity2LevelScreenState
    extends BaseLevelScreenState<Activity2LevelScreen> {
  /// Servicio que centraliza la lógica específica de la Actividad 2.
  ///
  /// Proporciona funcionalidades para:
  /// - Obtener números aleatorios según el nivel de dificultad
  /// - Validar respuestas escritas contra múltiples formas correctas posibles
  final _activity2Service = GetIt.instance<Activity2Service>();
  /// Servicio para reproducir sonidos de la aplicación, incluyendo efectos de correcto/incorrecto.
  final _soundService = GetIt.instance<SoundService>();
  
  /// Controlador para el campo de texto donde el usuario ingresa la respuesta.
  ///
  /// Gestiona la entrada de texto del usuario, permitiendo:
  /// - Acceder al texto ingresado para validación
  /// - Limpiar el campo después de cada intento o al cargar un nuevo número
  /// - Establecer o modificar el texto para mostrar ayudas o ejemplos
  final TextEditingController _answerController = TextEditingController();
  
  /// Datos del número actual que el usuario debe escribir en Namtrik.
  ///
  /// Contiene toda la información sobre el número actual, incluyendo:
  /// - Valor numérico (ej. 42)
  /// - Palabra principal en Namtrik (ej. "pik kan ɵntrɵ metrik pala")
  /// - Posibles composiciones y variaciones aceptables
  Map<String, dynamic>? currentNumber;
  
  /// Indica si la pantalla está actualmente cargando datos.
  ///
  /// Se utiliza para:
  /// - Mostrar un indicador de carga cuando corresponde
  /// - Prevenir interacciones del usuario mientras se cargan datos
  /// - Evitar validaciones durante estados transitorios
  bool _isLoading = true;
  
  /// Color del borde del campo de texto, usado para indicar errores.
  ///
  /// Cambia a rojo cuando la respuesta es incorrecta para proporcionar
  /// retroalimentación visual inmediata al usuario, y vuelve a null (color normal)
  /// cuando se carga un nuevo número o se limpia la entrada.
  Color? _inputBorderColor;

  /// Inicializa el estado de la pantalla al crearse.
  ///
  /// Este método configura el estado inicial:
  /// 1. Establece el número de intentos inicial (3)
  /// 2. Programa la carga del primer número aleatorio después del primer frame
  /// 3. Recupera y establece la puntuación global inicial
  ///
  /// La carga de números solo se realiza si el nivel está dentro del rango
  /// implementado (1-7), como medida de seguridad.
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
  /// Este método crucial:
  /// 1. Actualiza el estado de carga para mostrar indicadores visuales
  /// 2. Solicita un número aleatorio apropiado al nivel desde el servicio
  /// 3. Maneja posibles errores o casos de falta de datos
  /// 4. Actualiza el estado con el nuevo número y reinicia la interfaz
  ///
  /// Si [clearAnswer] es verdadero, limpia el campo de entrada de texto,
  /// lo que es útil cuando se carga un nuevo número después de completar uno.
  ///
  /// Proporciona feedback al usuario en caso de error o si no hay números
  /// disponibles para el nivel seleccionado.
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
  ///
  /// Método público que inicia el juego cargando el primer número para el nivel.
  /// Al llamar a [_fetchRandomNumber] con [clearAnswer] en false, se preserva
  /// cualquier texto que pudiera haber en el campo de entrada (aunque típicamente
  /// estará vacío al inicio).
  Future<void> loadNumbers() async {
    await _fetchRandomNumber(clearAnswer: false);
  }

  /// Selecciona un nuevo número aleatorio para el juego.
  ///
  /// Utilizado normalmente después de una respuesta correcta o cuando se agotan
  /// los intentos, para presentar un nuevo desafío al usuario. A diferencia de
  /// [loadNumbers], limpia automáticamente el campo de texto para la nueva entrada.
  Future<void> selectRandomNumber() async {
    await _fetchRandomNumber(clearAnswer: true);
  }

  /// Verifica la respuesta ingresada por el usuario.
  ///
  /// Este método central para la mecánica del juego:
  /// 1. Valida precondiciones (hay número actual, hay texto ingresado, no está cargando)
  /// 2. Normaliza la respuesta del usuario (elimina espacios extra)
  /// 3. Utiliza [_activity2Service.isAnswerCorrect] para verificar contra todas las formas válidas
  /// 4. Deriva el flujo hacia [_handleCorrectAnswer] o [_handleIncorrectAnswer] según el resultado
  ///
  /// La validación es inteligente y tolera variaciones en mayúsculas/minúsculas,
  /// espacios adicionales y diferentes formas válidas de escribir el mismo número.
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

  /// Muestra un diálogo de felicitación cuando el nivel se completa.
  ///
  /// Este método construye y muestra un diálogo modal que:
  /// - Felicita al usuario por completar el nivel
  /// - Proporciona un mensaje contextual según si es la primera vez o una repetición
  /// - Muestra los puntos ganados (solo si es la primera vez)
  /// - Ofrece un botón para continuar, que cierra el diálogo y la pantalla del nivel
  ///
  /// El parámetro [wasCompleted] indica si el nivel ya había sido completado antes,
  /// lo que cambia el mensaje y la visualización de la recompensa de puntos.
  /// 
  /// El diseño visual del diálogo usa elementos específicos de la Actividad 2,
  /// como el color dorado/ocre distintivo para mantener la identidad visual.
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
  /// Reproduce el sonido de "correcto", proporciona retroalimentación háptica,
  /// actualiza el estado del juego (puntos, nivel completado si es la primera vez)
  /// y muestra el diálogo de nivel completado.
  Future<void> _handleCorrectAnswer() async {
    _soundService.playCorrectSound(); // Reproduce sonido de acierto
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
  /// Reproduce el sonido de "incorrecto", proporciona retroalimentación háptica,
  /// decrementa los intentos restantes, cambia el color del borde del input a rojo.
  /// Si los intentos llegan a cero, muestra el diálogo de "sin intentos".
  /// Si quedan intentos, muestra un [SnackBar] informativo.
  Future<void> _handleIncorrectAnswer() async {
    _soundService.playIncorrectSound(); // Reproduce sonido de error
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
                hintText: 'Yu pɵr muntsikmeran', // Placeholder en Namtrik
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
