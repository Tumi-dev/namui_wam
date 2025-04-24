import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:namui_wam/core/models/game_state.dart';
import 'package:namui_wam/core/models/activities_state.dart';
import 'package:namui_wam/core/templates/scrollable_level_screen.dart';
import 'package:namui_wam/core/widgets/info_bar_widget.dart';
import 'package:namui_wam/features/activity3/services/activity3_service.dart';
import 'package:namui_wam/features/activity3/widgets/selectable_item.dart';
import 'package:namui_wam/core/services/feedback_service.dart';
import 'dart:math';

// Clase para la pantalla de un nivel de la actividad 3
class Activity3LevelScreen extends ScrollableLevelScreen {
  // Constructor de la clase que recibe el nivel de la actividad
  const Activity3LevelScreen({super.key, required super.level})
      : super(activityNumber: 3);

  // Crea el estado mutable para la clase de la pantalla de un nivel de la actividad 3
  @override
  State<Activity3LevelScreen> createState() => _Activity3LevelScreenState();
}

// Clase para el estado de la pantalla de un nivel de la actividad 3
class _Activity3LevelScreenState
    extends ScrollableLevelScreenState<Activity3LevelScreen> {
  late Activity3Service _activity3Service;
  bool _isLoading = true;
  List<Map<String, dynamic>> _gameItems = [];

  // Variables para el juego del nivel 1
  String? _selectedClockId;
  String? _selectedNamtrikId;
  final Map<String, String> _matchedPairs = {};
  bool _showErrorAnimation = false;

  // Listas desordenadas para mostrar los elementos del juego nivel 1
  List<Map<String, dynamic>> _shuffledClocks = [];
  List<Map<String, dynamic>> _shuffledNamtrik = [];

  // Variables para el juego del nivel 2
  String? _clockImage;
  List<Map<String, dynamic>> _options = [];

  // Variables para el juego del nivel 3
  String? _hourNamtrik;
  String? _clockImageLevel3;
  int? _correctHour;
  int? _correctMinute;
  int _selectedHour = 0;
  int _selectedMinute = 0;
  bool _showSuccessAnimation = false;
  bool _showErrorAnimationLevel3 = false;

  // Inicializa el estado de la pantalla de un nivel de la actividad 3
  @override
  void initState() {
    super.initState();
    _activity3Service = GetIt.instance<Activity3Service>();
    _loadLevelData();
  }

  // Carga los datos del nivel de la actividad 3
  Future<void> _loadLevelData() async {
    try {
      final levelData = await _activity3Service.getLevelData(widget.level);

      if (widget.level.id == 1) {
        final items = levelData['items'] as List<Map<String, dynamic>>;

        // Crear copias desordenadas para las imágenes y textos en namtrik nivel 1
        final List<Map<String, dynamic>> clocksCopy = List.from(items);
        final List<Map<String, dynamic>> namtrikCopy = List.from(items);

        // Desordenar las listas de relojes y textos en namtrik nivel 1
        clocksCopy.shuffle();
        namtrikCopy.shuffle();

        if (mounted) {
          setState(() {
            _gameItems = items;
            _shuffledClocks = clocksCopy;
            _shuffledNamtrik = namtrikCopy;
            _isLoading = false;
          });
        }
      } else if (widget.level.id == 2) {
        if (mounted) {
          setState(() {
            _clockImage = levelData['clock_image'];
            _options = List<Map<String, dynamic>>.from(levelData['options']);
            _isLoading = false;
          });
        }
      } else if (widget.level.id == 3) {
        if (mounted) {
          setState(() {
            _hourNamtrik = levelData['hour_namtrik'];
            _clockImageLevel3 = levelData['clock_image'];
            _correctHour = levelData['correct_hour'];
            _correctMinute = levelData['correct_minute'];
            // Inicializar con valores aleatorios para no dar pistas
            _selectedHour = _getRandomHourDifferentFrom(_correctHour!);
            _selectedMinute = _getRandomMinuteDifferentFrom(_correctMinute!);
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar datos: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Genera una hora aleatoria diferente a la correcta para el nivel 3
  int _getRandomHourDifferentFrom(int correctHour) {
    final random = Random();
    int randomHour;
    do {
      randomHour = random.nextInt(12); // 0-11
    } while (randomHour == correctHour);
    return randomHour;
  }

  // Genera un minuto aleatorio diferente al correcto para el nivel 3
  int _getRandomMinuteDifferentFrom(int correctMinute) {
    final random = Random();
    int randomMinute;
    do {
      randomMinute = random.nextInt(60); // 0-59
    } while (randomMinute == correctMinute);
    return randomMinute;
  }

  // Maneja la selección de la hora en el nivel 3
  void _handleHourChanged(int? hour) {
    if (hour != null) {
      setState(() {
        _selectedHour = hour;
        // Reset animations if any
        _showSuccessAnimation = false;
        _showErrorAnimationLevel3 = false;
      });
    }
  }

  // Maneja la selección del minuto en el nivel 3
  void _handleMinuteChanged(int? minute) {
    if (minute != null) {
      setState(() {
        _selectedMinute = minute;
        // Reset animations if any
        _showSuccessAnimation = false;
        _showErrorAnimationLevel3 = false;
      });
    }
  }

  // Verifica si la hora seleccionada es correcta para el nivel 3
  void _checkTimeCorrect() {
    final isCorrect = _activity3Service.isTimeCorrect(
        _selectedHour, _selectedMinute, _correctHour!, _correctMinute!);

    if (isCorrect) {
      // Mostrar animación de éxito y avanzar al siguiente nivel
      setState(() {
        _showSuccessAnimation = true;
      });

      // Esperar un momento antes de mostrar el diálogo de éxito y avanzar al siguiente nivel
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          _handleLevelComplete();
        }
      });
    } else {
      // Vibración media al fallar
      FeedbackService().mediumHapticFeedback();
      // Mostrar animación de error y reducir intentos
      setState(() {
        _showErrorAnimationLevel3 = true;
      });

      // Reducir intentos restantes
      remainingAttempts--;

      // Mostrar mensaje de error en la parte inferior de la pantalla de nivel 3
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Hora incorrecta. Te quedan $remainingAttempts intentos.'),
          duration: const Duration(seconds: 2),
        ),
      );

      // Resetear animación después de un breve retraso en nivel 3
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            _showErrorAnimationLevel3 = false;
          });
        }
      });

      // Verificar si se han agotado los intentos en nivel 3
      if (remainingAttempts <= 0) {
        _handleOutOfAttempts();
      } else {
        // Cargar nuevos datos para una nueva ronda en nivel 3
        _loadLevelData();
      }
    }
  }

  // Maneja la selección de un reloj en el nivel 1
  void _handleClockSelected(String id) {
    if (_matchedPairs.containsKey(id)) return;

    setState(() {
      // Si ya había un reloj seleccionado, lo deseleccionamos en nivel 1
      if (_selectedClockId != null && _selectedClockId != id) {
        _selectedClockId = id;
      } else {
        _selectedClockId = _selectedClockId == id ? null : id;
      }

      // Si hay un reloj y un texto seleccionados, verificamos si coinciden en nivel 1
      if (_selectedClockId != null && _selectedNamtrikId != null) {
        _checkMatch();
      }
    });
  }

  // Maneja la selección de un texto en namtrik en el nivel 1
  void _handleNamtrikSelected(String id) {
    if (_matchedPairs.values.contains(id)) return;

    setState(() {
      // Si ya había un texto seleccionado, lo deseleccionamos en nivel 1
      if (_selectedNamtrikId != null && _selectedNamtrikId != id) {
        _selectedNamtrikId = id;
      } else {
        _selectedNamtrikId = _selectedNamtrikId == id ? null : id;
      }

      // Si hay un reloj y un texto seleccionados, verificamos si coinciden en nivel 1
      if (_selectedClockId != null && _selectedNamtrikId != null) {
        _checkMatch();
      }
    });
  }

  // Maneja la selección de una opción en el nivel 2
  void _handleOptionSelected(String id, bool isCorrect) {
    if (isCorrect) {
      _handleLevelComplete();
    } else {
      // Vibración media al fallar
      FeedbackService().mediumHapticFeedback();
      // Reducir intentos restantes y mostrar mensaje de error en nivel 2
      remainingAttempts--;

      // Mostrar mensaje de error en la parte inferior de la pantalla de nivel 2
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Respuesta incorrecta. Te quedan $remainingAttempts intentos.'),
          duration: const Duration(seconds: 2),
        ),
      );

      // Verificar si se han agotado los intentos en nivel 2
      if (remainingAttempts <= 0) {
        _handleOutOfAttempts();
      } else {
        // Cargar nuevos datos para una nueva ronda en nivel 2
        _loadLevelData();
      }
    }
  }

  // Verifica si la combinación seleccionada es correcta en el nivel 1
  void _checkMatch() {
    if (_selectedClockId == null || _selectedNamtrikId == null) return;

    final isMatch = _activity3Service.isMatchCorrect(
        _selectedClockId!, _selectedNamtrikId!);

    if (isMatch) {
      // Añadir a pares coincidentes y resetear selección en nivel 1
      setState(() {
        _matchedPairs[_selectedClockId!] = _selectedNamtrikId!;
        _selectedClockId = null;
        _selectedNamtrikId = null;
      });

      // Verificar si se han encontrado todos los pares en nivel 1
      if (_matchedPairs.length == _gameItems.length) {
        _handleLevelComplete();
      }
    } else {
      // Vibración media al fallar
      FeedbackService().mediumHapticFeedback();
      // Mostrar animación de error y reducir intentos en nivel 1
      setState(() {
        _showErrorAnimation = true;
      });

      // Reducir intentos restantes en nivel 1
      remainingAttempts--;

      // Mostrar mensaje de error en la parte inferior de la pantalla de nivel 1
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Combinación incorrecta. Te quedan $remainingAttempts intentos.'),
          duration: const Duration(seconds: 2),
        ),
      );

      // Resetear selección después de un breve retraso en nivel 1
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            _showErrorAnimation = false;
            _selectedClockId = null;
            _selectedNamtrikId = null;
          });
        }
      });

      // Verificar si se han agotado los intentos en nivel 1
      if (remainingAttempts <= 0) {
        _handleOutOfAttempts();
      }
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
              if (!wasCompleted)
                Text(
                  '¡Ganaste 5 puntos!',
                  style: const TextStyle(
                    color: Color(0xFFFFFF00),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                )
              else
                const Text(
                  'Ya has completado este nivel anteriormente.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFFF00),
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
              foregroundColor: const Color(0xFFFFC107),
            ),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  // Maneja el evento cuando se completa el nivel con éxito
  void _handleLevelComplete() async {
    // Vibración corta al completar el nivel correctamente
    FeedbackService().lightHapticFeedback();
    final activitiesState = ActivitiesState.of(context);
    final gameState = GameState.of(context);
    final wasCompleted = gameState.isLevelCompleted(3, widget.level.id - 1);
    if (!wasCompleted) {
      final pointsAdded = await gameState.addPoints(3, widget.level.id - 1, 5);
      if (pointsAdded) {
        activitiesState.completeLevel(3, widget.level.id - 1);
        if (mounted) {
          setState(() {
            totalScore = gameState.globalPoints;
          });
        }
      }
    }
    if (!mounted) return;
    _showLevelCompletedDialog(wasCompleted: wasCompleted);
  }

  // Maneja el evento cuando se agotan los intentos en un nivel
  void _handleOutOfAttempts() async {
    await FeedbackService().heavyHapticFeedback();
    _showNoAttemptsDialog();
  }

  // Construye el contenido específico del nivel de la actividad 4
  @override
  Widget buildLevelContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (widget.level.id == 1) {
      return Column(
        children: [
          InfoBar(
            remainingAttempts: remainingAttempts,
            margin: const EdgeInsets.only(bottom: 24),
          ),
          _buildLevel1Content(),
        ],
      );
    } else if (widget.level.id == 2) {
      return Column(
        children: [
          InfoBar(
            remainingAttempts: remainingAttempts,
            margin: const EdgeInsets.only(bottom: 24),
          ),
          _buildLevel2Content(),
        ],
      );
    } else if (widget.level.id == 3) {
      return Column(
        children: [
          InfoBar(
            remainingAttempts: remainingAttempts,
            margin: const EdgeInsets.only(bottom: 24),
          ),
          _buildLevel3Content(),
        ],
      );
    } else {
      return Column(
        children: [
          InfoBar(
            remainingAttempts: remainingAttempts,
            margin: const EdgeInsets.only(bottom: 24),
          ),
          SizedBox(
            height: 300,
            child: Center(
              child: Text(
                'Nivel ${widget.level.id}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    }
  }

  // Construye el contenido específico del nivel 1
  Widget _buildLevel1Content() {
    // Obtener tamaño de pantalla para diseño responsivo en nivel 1
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width >
        screenSize.height; // true si es landscape, false si es portrait

    // Calcular tamaño de los elementos según la orientación en nivel 1
    final double clockSize = isLandscape
        ? screenSize.width * 0.15
        : screenSize.width *
            0.35; // 15% en landscape, 35% en portrait de los relojes

    // Determinar el número de elementos por fila según orientación en nivel 1
    final int clocksPerRow =
        isLandscape ? 4 : 2; // 4 en landscape, 2 en portrait de los relojes

    return Column(
      children: [
        // Sección de relojes y textos en namtrik (sin el título que fue eliminado) nivel 1
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Center(
            child: Text(
              'Empareja reloj y hora en namtrik',
              style: const TextStyle(
                color: Colors
                    .white, // Color del texto de instrucción para el usuario
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),

        // Grid de relojes en nivel 1
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: clocksPerRow,
            childAspectRatio: 1.0,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: _shuffledClocks.length,
          itemBuilder: (context, index) {
            final item = _shuffledClocks[index];
            final id = item['id'];
            final isMatched = _matchedPairs.containsKey(id);
            final isSelected = _selectedClockId == id;
            final isError = _showErrorAnimation && isSelected;

            // Determinar el estado de selección en nivel 1
            SelectionState state = SelectionState.unselected;
            if (isMatched) {
              state = SelectionState.matched;
            } else if (isError) {
              state = SelectionState.error;
            } else if (isSelected) {
              state = SelectionState.selected;
            }

            // Construir elemento seleccionable con imagen de reloj en nivel 1
            return LayoutBuilder(
              builder: (context, constraints) {
                return SelectableItem(
                  id: id,
                  state: state,
                  isImage: true,
                  isEnabled: !isMatched,
                  onTap: () => _handleClockSelected(id),
                  child: Image.asset(
                    'assets/images/clocks/${item['clock_image']}',
                    fit: BoxFit.contain,
                    width: clockSize,
                    height: clockSize,
                  ),
                );
              },
            );
          },
        ),

        // Espacio adicional entre secciones de relojes y textos en namtrik nivel 1
        const SizedBox(height: 16),

        // Grid de textos en namtrik nivel 1
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount:
                clocksPerRow, // Hace referencia a la cantidad de relojes por fila
            childAspectRatio:
                1.5, // Hace referencia a la proporción de la altura al ancho de los textos
            crossAxisSpacing:
                2, // Hace referencia al espaciado entre los textos en el eje horizontal
            mainAxisSpacing:
                2, // Hace referencia al espaciado entre los textos en el eje vertical
          ),
          // Construir elementos seleccionables con texto de namtrik en nivel 1
          itemCount: _shuffledNamtrik.length,
          itemBuilder: (context, index) {
            final item = _shuffledNamtrik[index];
            final id = item['id'];
            final isMatched = _matchedPairs.values
                .contains(id); // Determina si el texto ya ha sido emparejado
            final isSelected = _selectedNamtrikId ==
                id; // Determina si el texto actual ha sido seleccionado
            final isError = _showErrorAnimation &&
                isSelected; // Determina si hay un error en la selección

            // Determinar el estado de selección en nivel 1
            SelectionState state = SelectionState.unselected;
            if (isMatched) {
              state = SelectionState.matched;
            } else if (isError) {
              state = SelectionState.error;
            } else if (isSelected) {
              state = SelectionState.selected;
            }

            // Construir elemento seleccionable con texto de namtrik en nivel 1
            return SelectableItem(
              id: id,
              state: state,
              isEnabled: !isMatched,
              onTap: () => _handleNamtrikSelected(id),
              child: Center(
                child: Text(
                  item['hour_namtrik'],
                  style: TextStyle(
                    // Estilo de los textos en namtrik (color blanco, negrita, tamaño 16) nivel 1
                    color: Colors.white,
                    fontSize: isLandscape
                        ? 16
                        : 16, // Tamaño del texto en namtrik (16 en landscape, 16 en portrait)
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2, // Máximo 2 líneas de texto
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          },
        ),

        // Espacio adicional al final de la pantalla nivel 1
        const SizedBox(height: 24),
      ],
    );
  }

  // Construye el contenido específico del nivel 2
  Widget _buildLevel2Content() {
    // Obtener tamaño de pantalla para diseño responsivo en nivel 2
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;

    // Calcular tamaños según orientación - consistente con nivel 1
    final double clockImageSize =
        isLandscape ? screenSize.width * 0.25 : screenSize.width * 0.7;

    // Calcular número de botones por fila según orientación
    final int optionsPerRow =
        isLandscape ? 4 : 2; // 4 en landscape, 2 en portrait

    return Column(
      children: [
        // Instrucción para el usuario
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Text(
            'Selecciona la hora correcta en namtrik',
            style: const TextStyle(
              // Estilo de la instrucción para el usuario (color blanco, negrita, tamaño 18)
              color: Colors.white,
              fontSize: 18, // Tamaño 18 para la instrucción
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // Imagen del reloj con fondo transparente
        Container(
          margin: const EdgeInsets.symmetric(vertical: 20.0),
          child: Image.asset(
            'assets/images/clocks/$_clockImage',
            width: clockImageSize,
            height: clockImageSize,
            fit: BoxFit.contain,
          ),
        ),

        // Espacio adicional entre la imagen del reloj y las opciones de respuesta (sin el título que fue eliminado) nivel 2
        const SizedBox(height: 16),

        // Opciones de respuesta (sin el título que fue eliminado) nivel 2
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: optionsPerRow,
            childAspectRatio: 2.5,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: _options.length,
          itemBuilder: (context, index) {
            final option = _options[index];
            final id = option['id'];
            final isCorrect = option['is_correct'];

            // Construir botón elevado con texto de la opción de respuesta en nivel 2
            return ElevatedButton(
              onPressed: () => _handleOptionSelected(id, isCorrect),
              style: ElevatedButton.styleFrom(
                // Botón púrpura elegante con bordes redondeados para las opciones de respuesta
                backgroundColor: const Color(0xFFFFC107),
                // Texto blanco en negrita y tamaño 16 con padding interno para las opciones de respuesta
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(
                    8), // Padding 8 para las opciones de respuesta
              ),
              // Texto de la opción de respuesta en nivel 2
              child: Text(
                option['hour_namtrik'],
                style: TextStyle(
                  fontSize: isLandscape
                      ? 16
                      : 16, // Tamaño 16 en landscape, 16 en portrait
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            );
          },
        ),

        // Espacio adicional al final de la pantalla nivel 2
        const SizedBox(height: 24),
      ],
    );
  }

  // Construye el contenido específico del nivel 3
  Widget _buildLevel3Content() {
    // Obtener tamaño de pantalla para diseño responsivo
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;

    // Calcular tamaños según orientación - consistente con nivel 2
    final double instructionFontSize = isLandscape ? 18.0 : 20.0;
    final double namtrikHourFontSize = isLandscape ? 22.0 : 26.0;
    final EdgeInsets contentPadding = isLandscape
        ? const EdgeInsets.symmetric(horizontal: 48.0)
        : const EdgeInsets.symmetric(horizontal: 16.0);

    // Calcular tamaño del reloj igual que en nivel 2
    final double clockImageSize =
        isLandscape ? screenSize.width * 0.25 : screenSize.width * 0.7;

    // Generar listas de horas y minutos para los selectores
    final List<int> hours = List.generate(12, (index) => index);
    final List<int> minutes = List.generate(60, (index) => index);

    return Column(
      children: [
        // Texto de instrucción para el usuario
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Text(
            'Ajusta el reloj para indicar la hora',
            style: TextStyle(
              color: Colors
                  .white, // Color del texto de instrucción para el usuario
              fontSize: instructionFontSize,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // Imagen del reloj primero (encima) - usando el mismo estilo y tamaño que en nivel 2
        if (_clockImageLevel3 != null)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 20.0),
            child: Image.asset(
              'assets/images/clocks/$_clockImageLevel3',
              width: clockImageSize,
              height: clockImageSize,
              fit: BoxFit.contain,
            ),
          ),

        // Espacio adicional entre la imagen del reloj y el texto de la hora en namtrik nivel 3
        const SizedBox(height: 16),

        // Texto de la hora en namtrik debajo de la imagen del reloj
        Container(
          margin: const EdgeInsets.only(bottom: 24.0),
          padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 12.0), // Tamaño del texto de la hora en namtrik
          decoration: BoxDecoration(
            // Fondo púrpura elegante con bordes redondeados y sombra suave para el texto de la hora en namtrik
            color: const Color(0xFFFFC107), //
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                // Sombra suave con opacidad 30% y desplazamiento de 3 puntos hacia abajo
                color: const Color(0xFFFFFF00),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            _hourNamtrik ?? '',
            style: TextStyle(
              // Estilo del texto de la hora en namtrik (blanco, negrita, tamaño 22)
              color: Colors.white,
              fontSize: namtrikHourFontSize,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // Selectores de hora y minuto del nivel 3
        Padding(
          padding: contentPadding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment
                .center, // Alinea los selectores de hora y minuto
            children: [
              // Selector de hora
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'Hora',
                      style: TextStyle(
                        // Color del texto de la hora (blanco, negrita, tamaño 18)
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Espacio entre el texto y el selector de hora nivel 3
                    const SizedBox(height: 4),
                    // Contenedor con bordes redondeados para el selector de hora
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal:
                              12.0), // Padding interno para el selector de hora nivel 3
                      decoration: BoxDecoration(
                        // Fondo púrpura elegante con bordes redondeados para el selector de hora
                        color: const Color(
                            0xFFFFC107), // Fondo púrpura elegante para el selector de hora
                        borderRadius: BorderRadius.circular(
                            8.0), // Bordes redondeados para el selector de hora
                      ),
                      // Selector de hora con lista de horas y controlador de selección
                      child: DropdownButton<int>(
                        value: _selectedHour, // Hora seleccionada por defecto
                        isExpanded: true, // Expansión del selector de hora
                        icon: const Icon(Icons.arrow_drop_down,
                            color: Colors
                                .white), // Icono de flecha hacia abajo en color blanco
                        iconSize: 34, // Tamaño del icono de flecha hacia abajo
                        elevation: 16, // Elevación del menú desplegable
                        dropdownColor: const Color(0xFFFFC107),
                        // Estilo del texto de la hora seleccionado
                        style: const TextStyle(
                          // Color del texto de la hora seleccionada
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        // Controlador de selección de hora
                        onChanged: _handleHourChanged,
                        items: hours.map<DropdownMenuItem<int>>((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text(
                              value.toString().padLeft(2,
                                  '0'), // Asegura que la hora tenga 2 dígitos
                              style: TextStyle(
                                // Estilo del texto de la hora seleccionada (rojo si hay error)
                                color: _showErrorAnimationLevel3
                                    ? Colors.red
                                    : Colors.white,
                              ),
                            ),
                          );
                        }).toList(), // Lista de horas para el selector
                      ),
                    ),
                  ],
                ),
              ),

              // Separator
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  ':',
                  style: TextStyle(
                    // Color del separador de hora y minuto (blanco, negrita, tamaño 32)
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Selector de minutos
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'Minuto',
                      style: TextStyle(
                        color: Colors
                            .white, // Color del texto del minuto (blanco, negrita, tamaño 18)
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Espacio entre el texto y el selector de minuto nivel 3
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      decoration: BoxDecoration(
                        // Fondo púrpura elegante con bordes redondeados para el selector de minuto
                        color: const Color(
                            0xFFFFC107), // Fondo púrpura elegante para el selector de minuto
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      // Selector de minuto con lista de minutos y controlador de selección
                      child: DropdownButton<int>(
                        value: _selectedMinute,
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down,
                            color: Colors
                                .white), // Icono de flecha hacia abajo en color blanco
                        iconSize: 34,
                        elevation: 16,
                        dropdownColor: const Color(0xFFFFC107),
                        style: const TextStyle(
                          // Estilo del texto del minuto seleccionado (negro, tamaño 18)
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        // Controlador de selección de minutos
                        onChanged: _handleMinuteChanged,
                        items: minutes.map<DropdownMenuItem<int>>((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text(
                              value.toString().padLeft(2, '0'),
                              style: TextStyle(
                                // Estilo del texto del minuto seleccionado (rojo si hay error)
                                color: _showErrorAnimationLevel3
                                    ? Colors.red
                                    : Colors.white,
                              ),
                            ),
                          );
                        }).toList(), // Lista de minutos para el selector
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Espacio adicional con el botón de confirmar la hora seleccionada nivel 3
        const SizedBox(height: 40),

        // Botón de confirmar la hora seleccionada nivel 3
        ElevatedButton(
          onPressed: _checkTimeCorrect,
          style: ElevatedButton.styleFrom(
            // Botón verde con texto blanco y bordes redondeados para confirmar la hora seleccionada en nivel 3
            backgroundColor:
                _showSuccessAnimation ? Color(0xFF4CAF50) : Color(0xFFFFFF00),
            // Texto blanco en negrita y tamaño 18 con padding interno para confirmar la hora seleccionada en nivel 3
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 5, // Elevación del botón para resaltar sobre el fondo
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _showSuccessAnimation
                  // Icono de éxito si la hora es correcta (círculo verde con marca de verificación)
                  ? const Icon(Icons.check_circle_outline,
                      color: Colors.white) // Icono de éxito si es correcto
                  // Icono de reloj si no se ha confirmado (círculo blanco con reloj)
                  : const Icon(Icons.access_time,
                      color: Colors
                          .white), // Icono de reloj si no se ha confirmado
              // Espacio adicional entre el icono y el texto del botón de confirmar la hora seleccionada en nivel 3
              const SizedBox(width: 8),
              const Text(
                'Confirmar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // Espacio adicional al final de la pantalla nivel 3
        const SizedBox(height: 24),
      ],
    );
  }
}
