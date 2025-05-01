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

class Activity2LevelScreen extends BaseLevelScreen {
  const Activity2LevelScreen({super.key, required super.level})
      : super(activityNumber: 2);

  @override
  State<Activity2LevelScreen> createState() => _Activity2LevelScreenState();
}

class _Activity2LevelScreenState
    extends BaseLevelScreenState<Activity2LevelScreen> {
  final _activity2Service = GetIt.instance<Activity2Service>();
  final TextEditingController _answerController = TextEditingController();
  Map<String, dynamic>? currentNumber;
  bool _isLoading = true;
  Color? _inputBorderColor;

  @override
  void initState() {
    super.initState();
    remainingAttempts = 3; // Cambia el valor inicial solo aquí
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.level.id <= 7) {
        await loadNumbers();
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

  Future<void> _fetchRandomNumber({bool clearAnswer = false}) async {
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
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No hay números disponibles para este nivel')),
        );
        return;
      }

      setState(() {
        currentNumber = randomNumber;
        if (clearAnswer) _answerController.clear();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar los números: $e')),
      );
    }
  }

  Future<void> loadNumbers() async {
    await _fetchRandomNumber(clearAnswer: false);
  }

  Future<void> selectRandomNumber() async {
    await _fetchRandomNumber(clearAnswer: true);
  }

  Future<void> checkAnswer() async {
    if (currentNumber == null || _answerController.text.isEmpty) return;

    final userAnswer = _answerController.text.trim();
    final bool isCorrect =
        _activity2Service.isAnswerCorrect(currentNumber!, userAnswer);

    if (isCorrect) {
      await _handleCorrectAnswer();
    } else {
      _handleIncorrectAnswer();
    }
  }

  void _showLevelCompletedDialog({required bool wasCompleted}) {
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
              if (!wasCompleted) ...[
                const SizedBox(height: 16),
                const Text(
                  '¡Ganaste 5 puntos!',
                  style: TextStyle(
                    color: Color(0xFFDAA520),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDAA520),
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

  void _showNoAttemptsDialog() {
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
              foregroundColor: const Color(0xFFDAA520),
            ),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCorrectAnswer() async {
    // Vibración corta al acertar
    FeedbackService().lightHapticFeedback();
    final activitiesState = ActivitiesState.of(context);
    final gameState = GameState.of(context);
    if (!mounted) return;

    final wasCompleted = gameState.isLevelCompleted(2, widget.level.id - 1);

    if (!wasCompleted) {
      final pointsAdded = await gameState.addPoints(2, widget.level.id - 1, 5);
      if (pointsAdded) {
        activitiesState.completeLevel(2, widget.level.id - 1);
        if (mounted) {
          setState(() {
            totalScore = gameState.globalPoints;
          });
        }
      }
    }
    _showLevelCompletedDialog(wasCompleted: wasCompleted);
  }

  Future<void> _handleIncorrectAnswer() async {
    // Vibración media al fallar
    FeedbackService().mediumHapticFeedback();
    if (remainingAttempts > 0) {
      setState(() {
        remainingAttempts--;
        _inputBorderColor = Colors.red;
      });
    }
    if (remainingAttempts <= 0) {
      await FeedbackService().heavyHapticFeedback();
      _showNoAttemptsDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Respuesta incorrecta. Te quedan $remainingAttempts intentos.'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sobrescribimos completamente el método build para tener control total del layout
    // Esto evita la duplicación de la descripción del juego
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          leading: IconButton(
            icon: AppTheme.backArrowIcon,
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            widget.level.description,
            style: AppTheme.levelTitleStyle,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.mainGradient,
          ),
          child: SafeArea(
            child: _buildContent(),
          ),
        ),
      ),
    );
  }

  // Método privado para construir el contenido principal con scroll
  Widget _buildContent() {
    if (widget.level.id > 7) {
      return const Center(child: Text('Nivel en desarrollo'));
    }

    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando números...'),
          ],
        ),
      );
    }

    // Obtenemos el tamaño de la pantalla para adaptarnos a diferentes orientaciones
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;

    // SOLUCIÓN ESTABLE: Usamos ListView para que todo sea desplazable
    return ListView(
      // Desactivamos el efecto de rebote para evitar problemas
      physics: const ClampingScrollPhysics(),
      children: [
        // Descripción del juego (ahora solo aparece una vez)
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth:
                  500, // Límite máximo para evitar extensión excesiva en modo horizontal
            ),
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
        InfoBar(
          remainingAttempts: remainingAttempts,
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        ),
        if (currentNumber != null) ...[
          // Centrar el contenido horizontalmente
          Center(
            // Contenedor del número en namtrik
            child: Container(
              constraints: BoxConstraints(
                maxWidth: isLandscape ? 450.0 : screenSize.width * 0.8,
                minWidth: 120.0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              margin: const EdgeInsets.symmetric(vertical: 16.0),
              decoration: BoxDecoration(
                color: const Color(
                    0xFFDAA520), // Color de fondo amarillo ocre del contenedor
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFDAA520), // Sombra del contenedor
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              // Texto del número en namtrik
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  currentNumber!['number'].toString(), // Número en namtrik
                  style: const TextStyle(
                    color: Colors.white, // Color del texto
                    fontSize: 48, // Tamaño del texto base
                    fontWeight: FontWeight.bold, // Texto en negrita
                  ),
                  textAlign: TextAlign.center, // Alineación del texto
                ),
              ),
            ),
          ),
          // Campo de texto con padding adecuado
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: TextField(
              controller: _answerController,
              decoration: InputDecoration(
                hintText: 'Yu pɵr muntsillan',
                hintStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                filled: true,
                fillColor: const Color(
                    0xFFDAA520), // Color de fondo del campo de texto
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _inputBorderColor ?? const Color(0xFFDAA520),
                    width: 2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _inputBorderColor ?? Colors.transparent,
                    width: 2,
                  ),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              // Estilo del texto del campo de texto
              style: const TextStyle(
                color: Colors.white, // Color del texto del campo de texto
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
              cursorColor: Colors.white, // Color del cursor del campo de texto
              onChanged: (_) {
                if (_inputBorderColor != null) {
                  setState(() {
                    _inputBorderColor = null;
                  });
                }
              },
            ),
          ),
          // Botón centrado con margen adecuado
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: ElevatedButton(
                onPressed: checkAnswer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDAA520),
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
          // Espacio adicional al final para mejor experiencia de desplazamiento
          const SizedBox(height: 40),
        ],
      ],
    );
  }

  @override
  Widget buildLevelContent() {
    // Método requerido por BaseLevelScreen pero no lo usamos
    // En su lugar usamos nuestra propia implementación en _buildContent()
    return Container();
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }
}
