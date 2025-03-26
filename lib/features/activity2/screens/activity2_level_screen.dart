import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:namui_wam/core/models/activities_state.dart';
import 'package:namui_wam/core/templates/base_level_screen.dart';
import 'package:namui_wam/core/widgets/info_bar_widget.dart';
import 'package:namui_wam/core/models/game_state.dart';
import 'package:namui_wam/features/activity2/services/activity2_service.dart';
import 'package:namui_wam/core/constants/activity_descriptions.dart';
import 'package:namui_wam/core/widgets/game_description_widget.dart';
import 'package:namui_wam/core/themes/app_theme.dart';

class Activity2LevelScreen extends BaseLevelScreen {
  const Activity2LevelScreen({
    super.key,
    required level,
  }) : super(level: level, activityNumber: 2);

  @override
  State<Activity2LevelScreen> createState() => _Activity2LevelScreenState();
}

class _Activity2LevelScreenState
    extends BaseLevelScreenState<Activity2LevelScreen> {
  final _activity2Service = GetIt.instance<Activity2Service>();
  final TextEditingController _answerController = TextEditingController();
  Map<String, dynamic>? currentNumber;
  int remainingAttempts = 3;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
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

  Future<void> loadNumbers() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Get a random number for this level using the Activity2Service
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

  Future<void> selectRandomNumber() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Get a random number for this level using the Activity2Service
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
        _answerController.clear();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      print('Error al seleccionar número aleatorio: $e');
    }
  }

  Future<void> checkAnswer() async {
    if (currentNumber == null || _answerController.text.isEmpty) return;

    final userAnswer = _answerController.text.trim();
    final bool isCorrect =
        _activity2Service.isAnswerCorrect(currentNumber!, userAnswer);

    if (isCorrect) {
      _handleCorrectAnswer();
    } else {
      _handleIncorrectAnswer();
    }
  }

  void _handleCorrectAnswer() async {
    final activitiesState = ActivitiesState.of(context);
    final gameState = GameState.of(context);
    if (!mounted) return;

    // Verificar si el nivel ya estaba completado
    final wasCompleted = gameState.isLevelCompleted(2, widget.level.id - 1);

    // Actualizar el estado para mostrar que la respuesta es correcta y restablecer los intentos restantes
    if (!wasCompleted) {
      // Añadir puntos solo si el nivel no estaba completado previamente y se agregaron puntos
      final pointsAdded = await gameState.addPoints(2, widget.level.id - 1, 5);
      if (pointsAdded) {
        activitiesState.completeLevel(2, widget.level.id - 1);
        if (mounted) {
          setState(() {
            totalScore = gameState.globalPoints;
          });
        }
      }

      // Mostrar diálogo de nivel completado si se agregaron puntos y no estaba completado
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
                    color: const Color(0xFF00FFFF),
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
                    backgroundColor: const Color(0xFF00FFFF),
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

      // Si el nivel ya estaba completado, mostrar un mensaje diferente
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
                    backgroundColor: const Color(0xFF00FFFF),
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

  void _handleIncorrectAnswer() {
    setState(() {
      remainingAttempts--;
    });

    if (remainingAttempts <= 0) {
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
                foregroundColor: const Color(0xFF1976D2),
              ),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
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
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        return false;
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
              maxWidth: 500, // Límite máximo para evitar extensión excesiva en modo horizontal
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: GameDescriptionWidget(
                description: ActivityGameDescriptions.getDescriptionForActivity(2),
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
            child: Container(
              width: isLandscape ? screenSize.width * 0.3 : screenSize.width * 0.4,
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.symmetric(vertical: 16.0),
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
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Campo de texto con padding adecuado
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: TextField(
              controller: _answerController,
              decoration: InputDecoration(
                hintText: 'Yu pɵr muntsillan',
                hintStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                filled: true,
                fillColor: const Color(0xFF1976D2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
              cursorColor: Colors.white,
            ),
          ),
          // Botón centrado con margen adecuado
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: ElevatedButton(
                onPressed: checkAnswer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00FFFF),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
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
