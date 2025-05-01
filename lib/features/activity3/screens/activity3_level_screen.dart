import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:namuiwam/core/models/game_state.dart';
import 'package:namuiwam/core/models/activities_state.dart';
import 'package:namuiwam/core/templates/scrollable_level_screen.dart';
import 'package:namuiwam/core/widgets/info_bar_widget.dart';
import 'package:namuiwam/features/activity3/services/activity3_service.dart';
import 'package:namuiwam/features/activity3/widgets/selectable_item.dart';
import 'package:namuiwam/core/services/feedback_service.dart';
import 'dart:math';

/// Pantalla para un nivel específico de la Actividad 3: "Nɵsik utɵwan asam kusrekun".
///
/// Hereda de [ScrollableLevelScreen] y adapta su contenido según el ID del nivel.
/// - Nivel 1: Emparejar imágenes de relojes con horas escritas en Namtrik.
/// - Nivel 2: Seleccionar la hora correcta en Namtrik para una imagen de reloj dada.
/// - Nivel 3: Ajustar un reloj digital a la hora indicada en Namtrik.
class Activity3LevelScreen extends ScrollableLevelScreen {
  /// Crea una instancia de [Activity3LevelScreen].
  ///
  /// Requiere el [level] actual y establece el [activityNumber] en 3.
  const Activity3LevelScreen({super.key, required super.level})
      : super(activityNumber: 3);

  /// Crea el estado mutable para esta pantalla.
  @override
  State<Activity3LevelScreen> createState() => _Activity3LevelScreenState();
}

/// Clase de estado para [Activity3LevelScreen].
///
/// Gestiona la lógica específica de cada nivel de la Actividad 3:
/// - Carga de datos del nivel ([_loadLevelData]).
/// - Manejo de interacciones del usuario (selección de elementos, ajuste de hora).
/// - Validación de respuestas ([_checkMatch], [_handleOptionSelected], [_checkTimeCorrect]).
/// - Actualización del estado del juego (intentos, puntos, nivel completado).
/// - Retroalimentación visual y háptica.
/// - Construcción de la interfaz de usuario específica para cada nivel ([buildLevelContent], [_buildLevel1Content], etc.).
class _Activity3LevelScreenState
    extends ScrollableLevelScreenState<Activity3LevelScreen> {
  /// Servicio específico para la lógica de la Actividad 3.
  late Activity3Service _activity3Service;
  /// Indica si la pantalla está actualmente cargando datos.
  bool _isLoading = true;
  /// Lista de elementos del juego (usada principalmente en el nivel 1).
  List<Map<String, dynamic>> _gameItems = [];

  // --- Variables Nivel 1: Emparejamiento ---
  /// ID del reloj seleccionado actualmente.
  String? _selectedClockId;
  /// ID del texto Namtrik seleccionado actualmente.
  String? _selectedNamtrikId;
  /// Mapa que almacena los pares correctamente emparejados (ID reloj -> ID Namtrik).
  final Map<String, String> _matchedPairs = {};
  /// Controla la animación de error para selecciones incorrectas.
  bool _showErrorAnimation = false;
  /// Lista desordenada de relojes para mostrar en la interfaz.
  List<Map<String, dynamic>> _shuffledClocks = [];
  /// Lista desordenada de textos Namtrik para mostrar en la interfaz.
  List<Map<String, dynamic>> _shuffledNamtrik = [];

  // --- Variables Nivel 2: Selección Múltiple ---
  /// Ruta de la imagen del reloj a mostrar.
  String? _clockImage;
  /// Lista de opciones de respuesta (textos Namtrik).
  List<Map<String, dynamic>> _options = [];

  // --- Variables Nivel 3: Ajustar Hora ---
  /// Texto de la hora objetivo en Namtrik.
  String? _hourNamtrik;
  /// Ruta de la imagen del reloj (puede ser usada como referencia visual).
  String? _clockImageLevel3;
  /// Hora correcta (0-11).
  int? _correctHour;
  /// Minuto correcto (0-59).
  int? _correctMinute;
  /// Hora seleccionada por el usuario en el selector.
  int _selectedHour = 0;
  /// Minuto seleccionado por el usuario en el selector.
  int _selectedMinute = 0;
  /// Controla la animación de éxito al ajustar la hora correctamente.
  bool _showSuccessAnimation = false;
  /// Controla la animación de error al ajustar la hora incorrectamente.
  bool _showErrorAnimationLevel3 = false;

  /// Inicializa el estado de la pantalla.
  ///
  /// Obtiene la instancia del servicio [Activity3Service] y carga los datos
  /// iniciales del nivel llamando a [_loadLevelData].
  @override
  void initState() {
    super.initState();
    _activity3Service = GetIt.instance<Activity3Service>();
    _loadLevelData();
  }

  /// Carga los datos específicos para el nivel actual desde [Activity3Service].
  ///
  /// Actualiza el estado [_isLoading] y las variables correspondientes al nivel
  /// ([_gameItems], [_shuffledClocks], [_shuffledNamtrik] para nivel 1;
  /// [_clockImage], [_options] para nivel 2; [_hourNamtrik], [_clockImageLevel3],
  /// [_correctHour], [_correctMinute] para nivel 3).
  /// Maneja posibles errores durante la carga y muestra un [SnackBar].
  Future<void> _loadLevelData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      // Resetea estados específicos de niveles anteriores si es necesario
      _selectedClockId = null;
      _selectedNamtrikId = null;
      _matchedPairs.clear();
      _showErrorAnimation = false;
      _showSuccessAnimation = false;
      _showErrorAnimationLevel3 = false;
    });

    try {
      final levelData = await _activity3Service.getLevelData(widget.level);

      if (!mounted) return;

      // Carga de datos según el ID del nivel.
      if (widget.level.id == 1) {
        final items = levelData['items'] as List<Map<String, dynamic>>;
        final List<Map<String, dynamic>> clocksCopy = List.from(items);
        final List<Map<String, dynamic>> namtrikCopy = List.from(items);
        clocksCopy.shuffle();
        namtrikCopy.shuffle();

        setState(() {
          _gameItems = items;
          _shuffledClocks = clocksCopy;
          _shuffledNamtrik = namtrikCopy;
          _isLoading = false;
        });
      } else if (widget.level.id == 2) {
        setState(() {
          _clockImage = levelData['clock_image'];
          _options = List<Map<String, dynamic>>.from(levelData['options']);
          _isLoading = false;
        });
      } else if (widget.level.id == 3) {
        setState(() {
          _hourNamtrik = levelData['hour_namtrik'];
          _clockImageLevel3 = levelData['clock_image'];
          _correctHour = levelData['correct_hour'];
          _correctMinute = levelData['correct_minute'];
          // Inicializar selectores con valores aleatorios diferentes a la respuesta
          _selectedHour = _getRandomHourDifferentFrom(_correctHour!);
          _selectedMinute = _getRandomMinuteDifferentFrom(_correctMinute!);
          _isLoading = false;
        });
      } else {
        // Manejo para niveles no implementados o futuros.
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar datos del nivel: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
      debugPrint('Error en _loadLevelData: $e');
    }
  }

  /// Genera una hora aleatoria (0-11) diferente a la [correctHour] dada.
  /// Usado para inicializar el selector de hora en el nivel 3.
  int _getRandomHourDifferentFrom(int correctHour) {
    final random = Random();
    int randomHour;
    do {
      randomHour = random.nextInt(12); // 0-11
    } while (randomHour == correctHour);
    return randomHour;
  }

  /// Genera un minuto aleatorio (0-59) diferente al [correctMinute] dado.
  /// Usado para inicializar el selector de minutos en el nivel 3.
  int _getRandomMinuteDifferentFrom(int correctMinute) {
    final random = Random();
    int randomMinute;
    do {
      randomMinute = random.nextInt(60); // 0-59
    } while (randomMinute == correctMinute);
    return randomMinute;
  }

  /// Maneja el cambio de valor en el selector de hora (Nivel 3).
  /// Actualiza [_selectedHour] y resetea las animaciones de éxito/error.
  void _handleHourChanged(int? hour) {
    if (hour != null) {
      setState(() {
        _selectedHour = hour;
        _showSuccessAnimation = false;
        _showErrorAnimationLevel3 = false;
      });
    }
  }

  /// Maneja el cambio de valor en el selector de minutos (Nivel 3).
  /// Actualiza [_selectedMinute] y resetea las animaciones de éxito/error.
  void _handleMinuteChanged(int? minute) {
    if (minute != null) {
      setState(() {
        _selectedMinute = minute;
        _showSuccessAnimation = false;
        _showErrorAnimationLevel3 = false;
      });
    }
  }

  /// Verifica si la hora seleccionada por el usuario en el Nivel 3 es correcta.
  ///
  /// Compara [_selectedHour] y [_selectedMinute] con [_correctHour] y [_correctMinute].
  /// Si es correcta:
  ///   - Muestra animación de éxito ([_showSuccessAnimation]).
  ///   - Llama a [_handleLevelComplete] después de un retraso.
  /// Si es incorrecta:
  ///   - Proporciona retroalimentación háptica.
  ///   - Muestra animación de error ([_showErrorAnimationLevel3]).
  ///   - Decrementa [remainingAttempts].
  ///   - Muestra un [SnackBar] con los intentos restantes.
  ///   - Resetea la animación de error después de un retraso.
  ///   - Si se agotan los intentos, llama a [_handleOutOfAttempts].
  void _checkTimeCorrect() {
    if (_correctHour == null || _correctMinute == null) return;

    final isCorrect = _activity3Service.isTimeCorrect(
        _selectedHour, _selectedMinute, _correctHour!, _correctMinute!);

    if (isCorrect) {
      setState(() {
        _showSuccessAnimation = true;
      });
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          _handleLevelComplete();
        }
      });
    } else {
      FeedbackService().mediumHapticFeedback();
      setState(() {
        _showErrorAnimationLevel3 = true;
        if (remainingAttempts > 0) {
          remainingAttempts--;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Hora incorrecta. Te quedan $remainingAttempts intentos.'),
          duration: const Duration(seconds: 2),
        ),
      );

      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            _showErrorAnimationLevel3 = false;
          });
        }
      });

      if (remainingAttempts <= 0) {
        _handleOutOfAttempts();
      }
      // No recargamos datos aquí para que el usuario pueda corregir su selección.
      // else {
      //   _loadLevelData(); // Considerar si recargar o permitir corregir
      // }
    }
  }

  /// Maneja la selección de una imagen de reloj en el Nivel 1.
  ///
  /// Actualiza [_selectedClockId]. Si ya hay un texto Namtrik seleccionado
  /// ([_selectedNamtrikId]), llama a [_checkMatch] para verificar la pareja.
  /// Ignora la selección si el reloj ya está emparejado.
  void _handleClockSelected(String id) {
    if (_matchedPairs.containsKey(id)) return; // Ignora si ya está emparejado

    setState(() {
      // Deselecciona si se toca el mismo reloj, o selecciona el nuevo.
      _selectedClockId = (_selectedClockId == id) ? null : id;
      // Resetea animación de error al seleccionar algo nuevo.
      _showErrorAnimation = false;
    });

    // Si ambos (reloj y texto) están seleccionados, verifica la coincidencia.
    if (_selectedClockId != null && _selectedNamtrikId != null) {
      _checkMatch();
    }
  }

  /// Maneja la selección de un texto Namtrik en el Nivel 1.
  ///
  /// Actualiza [_selectedNamtrikId]. Si ya hay un reloj seleccionado
  /// ([_selectedClockId]), llama a [_checkMatch] para verificar la pareja.
  /// Ignora la selección si el texto ya está emparejado.
  void _handleNamtrikSelected(String id) {
    if (_matchedPairs.values.contains(id)) return; // Ignora si ya está emparejado

    setState(() {
      // Deselecciona si se toca el mismo texto, o selecciona el nuevo.
      _selectedNamtrikId = (_selectedNamtrikId == id) ? null : id;
      // Resetea animación de error al seleccionar algo nuevo.
      _showErrorAnimation = false;
    });

    // Si ambos (reloj y texto) están seleccionados, verifica la coincidencia.
    if (_selectedClockId != null && _selectedNamtrikId != null) {
      _checkMatch();
    }
  }

  /// Maneja la selección de una opción de respuesta en el Nivel 2.
  ///
  /// Si la opción [isCorrect] es verdadera, llama a [_handleLevelComplete].
  /// Si es falsa:
  ///   - Proporciona retroalimentación háptica.
  ///   - Decrementa [remainingAttempts].
  ///   - Muestra un [SnackBar] con los intentos restantes.
  ///   - Si se agotan los intentos, llama a [_handleOutOfAttempts].
  ///   - Si quedan intentos, recarga los datos del nivel ([_loadLevelData]) para una nueva pregunta.
  void _handleOptionSelected(String id, bool isCorrect) {
    if (isCorrect) {
      _handleLevelComplete();
    } else {
      FeedbackService().mediumHapticFeedback();
      setState(() {
        if (remainingAttempts > 0) {
          remainingAttempts--;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Respuesta incorrecta. Te quedan $remainingAttempts intentos.'),
          duration: const Duration(seconds: 2),
        ),
      );

      if (remainingAttempts <= 0) {
        _handleOutOfAttempts();
      } else {
        // Carga una nueva pregunta para la siguiente ronda.
        _loadLevelData();
      }
    }
  }

  /// Verifica si el reloj ([_selectedClockId]) y el texto Namtrik ([_selectedNamtrikId])
  /// seleccionados en el Nivel 1 forman una pareja correcta usando [Activity3Service.isMatchCorrect].
  ///
  /// Si es correcta:
  ///   - Añade la pareja a [_matchedPairs].
  ///   - Resetea [_selectedClockId] y [_selectedNamtrikId].
  ///   - Si todos los pares están completos, llama a [_handleLevelComplete].
  /// Si es incorrecta:
  ///   - Proporciona retroalimentación háptica.
  ///   - Activa la animación de error ([_showErrorAnimation]).
  ///   - Decrementa [remainingAttempts].
  ///   - Muestra un [SnackBar] con los intentos restantes.
  ///   - Resetea la selección y la animación de error después de un retraso.
  ///   - Si se agotan los intentos, llama a [_handleOutOfAttempts].
  void _checkMatch() {
    if (_selectedClockId == null || _selectedNamtrikId == null) return;

    final isMatch = _activity3Service.isMatchCorrect(
        _selectedClockId!, _selectedNamtrikId!);

    if (isMatch) {
      FeedbackService().lightHapticFeedback(); // Feedback para acierto
      setState(() {
        _matchedPairs[_selectedClockId!] = _selectedNamtrikId!;
        _selectedClockId = null;
        _selectedNamtrikId = null;
      });

      if (_matchedPairs.length == _gameItems.length) {
        _handleLevelComplete();
      }
    } else {
      FeedbackService().mediumHapticFeedback();
      setState(() {
        _showErrorAnimation = true;
        if (remainingAttempts > 0) {
          remainingAttempts--;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Combinación incorrecta. Te quedan $remainingAttempts intentos.'),
          duration: const Duration(seconds: 2),
        ),
      );

      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            _showErrorAnimation = false;
            // Mantenemos la selección visible durante el error, pero la reseteamos lógicamente
            // para que el usuario deba volver a seleccionar.
            // _selectedClockId = null; // Comentado para que el borde rojo persista
            // _selectedNamtrikId = null; // Comentado para que el borde rojo persista
          });
        }
      });

      if (remainingAttempts <= 0) {
        _handleOutOfAttempts();
      }
    }
  }

  /// Muestra un diálogo indicando que el nivel fue completado.
  ///
  /// El mensaje varía si el nivel se completó por primera vez ([wasCompleted] es falso)
  /// o si ya se había completado antes. Incluye un botón para continuar que cierra
  /// el diálogo y la pantalla del nivel.
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
                    : 'Has desbloqueado el siguiente nivel', // Mensaje actualizado
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              // Muestra los puntos ganados solo si es la primera vez
              if (!wasCompleted) ...[
                const SizedBox(height: 16),
                const Text(
                  '¡Ganaste 5 puntos!',
                  style: TextStyle(
                    color: Color(0xFF8B4513), // Color específico A3
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              // Botón para continuar
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Cierra el diálogo
                  Navigator.of(context).pop(); // Cierra la pantalla del nivel
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B4513), // Color específico A3
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
  /// Ofrece un botón "Aceptar" para cerrar el diálogo y la pantalla del nivel.
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
              foregroundColor: const Color(0xFF8B4513), // Color específico A3
            ),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  /// Maneja la lógica de finalización exitosa de un nivel.
  ///
  /// - Proporciona retroalimentación háptica ligera.
  /// - Obtiene el estado del juego y de las actividades.
  /// - Verifica si el nivel ya había sido completado.
  /// - Si es la primera vez:
  ///   - Añade puntos al estado global del juego ([GameState.addPoints]).
  ///   - Marca el nivel como completado en el estado de las actividades ([ActivitiesState.completeLevel]).
  ///   - Actualiza el puntaje total mostrado en la UI.
  /// - Muestra el diálogo de nivel completado ([_showLevelCompletedDialog]).
  void _handleLevelComplete() async {
    FeedbackService().lightHapticFeedback();
    final activitiesState = ActivitiesState.of(context);
    final gameState = GameState.of(context);
    if (!mounted) return;

    final wasCompleted = gameState.isLevelCompleted(3, widget.level.id - 1);

    if (!wasCompleted) {
      final pointsAdded = await gameState.addPoints(3, widget.level.id - 1, 5);
      if (pointsAdded) {
        activitiesState.completeLevel(3, widget.level.id - 1);
        if (mounted) {
          setState(() {
            totalScore = gameState.globalPoints; // Actualiza puntos en InfoBar
          });
        }
      }
    }
    if (!mounted) return;
    _showLevelCompletedDialog(wasCompleted: wasCompleted);
  }

  /// Maneja la lógica cuando el jugador se queda sin intentos.
  ///
  /// - Proporciona retroalimentación háptica pesada.
  /// - Muestra el diálogo de "sin intentos" ([_showNoAttemptsDialog]).
  void _handleOutOfAttempts() async {
    await FeedbackService().heavyHapticFeedback();
    if (!mounted) return;
    _showNoAttemptsDialog();
  }

  /// Construye el contenido principal de la pantalla del nivel.
  ///
  /// Muestra un indicador de carga si [_isLoading] es true.
  /// De lo contrario, construye el contenido específico del nivel actual
  /// (1, 2 o 3) llamando a los métodos `_buildLevelXContent` correspondientes.
  /// Incluye la [InfoBar] con los intentos restantes y puntos.
  /// Para niveles no implementados, muestra un mensaje genérico.
  @override
  Widget buildLevelContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    // Contenido base que incluye la InfoBar
    Widget levelContent;
    if (widget.level.id == 1) {
      levelContent = _buildLevel1Content();
    } else if (widget.level.id == 2) {
      levelContent = _buildLevel2Content();
    } else if (widget.level.id == 3) {
      levelContent = _buildLevel3Content();
    } else {
      // Contenido para niveles futuros o no implementados
      levelContent = SizedBox(
        height: 300, // Altura fija para centrar el texto
        child: Center(
          child: Text(
            'Nivel ${widget.level.id} en desarrollo',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    // Envuelve el contenido específico del nivel con la InfoBar
    return Column(
      children: [
        InfoBar(
          remainingAttempts: remainingAttempts,
          margin: const EdgeInsets.only(bottom: 24),
        ),
        levelContent, // Contenido específico del nivel
      ],
    );
  }

  /// Construye la interfaz de usuario para el Nivel 1 (Emparejamiento).
  ///
  /// Muestra una instrucción, una cuadrícula de imágenes de relojes ([_shuffledClocks])
  /// y una cuadrícula de textos Namtrik ([_shuffledNamtrik]).
  /// Utiliza [SelectableItem] para los elementos interactivos, manejando los
  /// estados de selección, emparejamiento y error.
  /// Adapta el diseño (tamaño de elementos, elementos por fila) según la
  /// orientación del dispositivo (horizontal/vertical).
  Widget _buildLevel1Content() {
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;
    // Ajustar tamaño para que quepan mejor, especialmente en landscape
    final double itemSize = isLandscape ? screenSize.width * 0.1 : screenSize.width * 0.25;
    final int itemsPerRow = isLandscape ? 5 : 3; // Más items por fila
    final double textItemAspectRatio = isLandscape ? 2.2 : 1.8; // Ajustar para mejor visualización

    return Column(
      children: [
        // Instrucción
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Center(
            child: Text(
              'Empareja reloj y hora en namtrik',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),

        // Grid de Relojes
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: itemsPerRow,
            childAspectRatio: 1.0, // Relojes cuadrados
            crossAxisSpacing: 8, // Menor espaciado
            mainAxisSpacing: 8,
          ),
          itemCount: _shuffledClocks.length,
          itemBuilder: (context, index) {
            final item = _shuffledClocks[index];
            final id = item['id'];
            final isMatched = _matchedPairs.containsKey(id);
            final isSelected = _selectedClockId == id;
            // Error si este reloj está seleccionado Y hubo un error (showErrorAnimation es true)
            final isError = _showErrorAnimation && isSelected;

            // Usar el SelectionState importado
            SelectionState state = SelectionState.unselected;
            if (isMatched) {
              state = SelectionState.matched;
            } else if (isError) {
              state = SelectionState.error;
            } else if (isSelected) {
              state = SelectionState.selected;
            }

            return SelectableItem(
              id: id,
              state: state, // Ahora usa el tipo correcto
              isImage: true,
              isEnabled: !isMatched,
              onTap: () => _handleClockSelected(id),
              child: Padding(
                padding: const EdgeInsets.all(2.0), // Padding mínimo
                child: Image.asset(
                  'assets/images/clocks/${item['clock_image']}',
                  fit: BoxFit.contain,
                  width: itemSize,
                  height: itemSize,
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 20), // Espacio ajustado

        // Grid de Textos Namtrik
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: itemsPerRow,
            childAspectRatio: textItemAspectRatio,
            crossAxisSpacing: 6, // Menor espaciado
            mainAxisSpacing: 6,
          ),
          itemCount: _shuffledNamtrik.length,
          itemBuilder: (context, index) {
            final item = _shuffledNamtrik[index];
            final id = item['id'];
            final isMatched = _matchedPairs.containsValue(id);
            final isSelected = _selectedNamtrikId == id;
            // Error si este texto está seleccionado Y hubo un error
            final isError = _showErrorAnimation && isSelected;

            // Usar el SelectionState importado
            SelectionState state = SelectionState.unselected;
            if (isMatched) {
              state = SelectionState.matched;
            } else if (isError) {
              state = SelectionState.error;
            } else if (isSelected) {
              state = SelectionState.selected;
            }

            return SelectableItem(
              id: id,
              state: state, // Ahora usa el tipo correcto
              isEnabled: !isMatched,
              onTap: () => _handleNamtrikSelected(id),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0), // Padding mínimo
                  child: Text(
                    item['hour_namtrik'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isLandscape ? 13 : 14, // Tamaño de fuente ajustado
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  /// Construye la interfaz de usuario para el Nivel 2 (Selección Múltiple).
  ///
  /// Muestra una instrucción, la imagen del reloj ([_clockImage]) y una
  /// cuadrícula de botones con las opciones de respuesta en Namtrik ([_options]).
  /// Adapta el diseño (tamaño de imagen, botones por fila) según la orientación.
  Widget _buildLevel2Content() {
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;
    final double clockImageSize = isLandscape ? screenSize.width * 0.25 : screenSize.width * 0.6;
    final int optionsPerRow = isLandscape ? 4 : 2;
    final double optionAspectRatio = isLandscape ? 3.5 : 2.8; // Ajustar aspect ratio para más espacio vertical

    return Column(
      children: [
        // Instrucción
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Text(
            'Selecciona la hora correcta en namtrik',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // Imagen del Reloj
        Container(
          margin: const EdgeInsets.symmetric(vertical: 20.0),
          child: Image.asset(
            'assets/images/clocks/$_clockImage',
            width: clockImageSize,
            height: clockImageSize,
            fit: BoxFit.contain,
          ),
        ),

        const SizedBox(height: 24),

        // Opciones de Respuesta
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: optionsPerRow,
            childAspectRatio: optionAspectRatio,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: _options.length,
          itemBuilder: (context, index) {
            final option = _options[index];
            final id = option['id'];
            final isCorrect = option['is_correct'];

            return ElevatedButton(
              onPressed: () => _handleOptionSelected(id, isCorrect),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B4513), // Color A3
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              ),
              child: Text(
                option['hour_namtrik'],
                style: TextStyle(
                  fontSize: isLandscape ? 15 : 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            );
          },
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  /// Construye la interfaz de usuario para el Nivel 3 (Ajustar Hora).
  ///
  /// Muestra una instrucción, la hora objetivo en Namtrik ([_hourNamtrik]),
  /// opcionalmente una imagen de referencia del reloj ([_clockImageLevel3]),
  /// dos selectores ([DropdownButton]) para la hora y los minutos, y un botón
  /// para validar la selección.
  /// Utiliza animaciones ([_showSuccessAnimation], [_showErrorAnimationLevel3])
  /// en los selectores y el botón para dar retroalimentación.
  Widget _buildLevel3Content() {
    // --- Definiciones movidas al inicio --- 
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;
    final double instructionFontSize = isLandscape ? 18.0 : 20.0;
    final double namtrikHourFontSize = isLandscape ? 20.0 : 24.0;
    final EdgeInsets contentPadding = isLandscape
        ? const EdgeInsets.symmetric(horizontal: 60.0)
        : const EdgeInsets.symmetric(horizontal: 24.0);
    final double clockImageSize = isLandscape ? screenSize.width * 0.20 : screenSize.width * 0.5;
    final List<int> hours = List.generate(12, (index) => index); // 0 a 11
    final List<int> minutes = List.generate(60, (index) => index); // 0 a 59

    // Determina el color del borde basado en el estado de error/éxito
    Color dropdownBorderColor = Colors.transparent; // Color por defecto
    if (_showErrorAnimationLevel3) {
      dropdownBorderColor = Colors.red.shade700;
    } else if (_showSuccessAnimation) {
      dropdownBorderColor = Colors.green.shade700;
    }
    // --- Fin de definiciones movidas --- 

    return Column(
      children: [
        // Instrucción
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Text(
            'Ajusta el reloj para indicar la hora',
            style: TextStyle(
              color: Colors.white,
              fontSize: instructionFontSize,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // Imagen del Reloj (Opcional)
        if (_clockImageLevel3 != null)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 16.0),
            child: Image.asset(
              'assets/images/clocks/$_clockImageLevel3',
              width: clockImageSize,
              height: clockImageSize,
              fit: BoxFit.contain,
            ),
          ),

        // Hora en Namtrik
        Container(
          margin: const EdgeInsets.only(bottom: 24.0, left: 16, right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: const Color(0xFF8B4513), // Color A3
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B4513).withOpacity(0.5),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            _hourNamtrik ?? 'Cargando hora...',
            style: TextStyle(
              color: Colors.white,
              fontSize: namtrikHourFontSize, // Usar variable definida arriba
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // Selectores de Hora y Minuto
        Padding(
          padding: contentPadding, // Usar variable definida arriba
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selector Hora
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'Hora',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B4513),
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: dropdownBorderColor, width: 2),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _selectedHour,
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                          iconSize: 30,
                          elevation: 16,
                          dropdownColor: const Color(0xFF8B4513),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          onChanged: _handleHourChanged,
                          items: hours.map<DropdownMenuItem<int>>((int value) { // Usar variable definida arriba
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Center(
                                child: Text(
                                  value.toString().padLeft(2, '0'),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Separador ':'
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0).copyWith(top: 28),
                child: const Text(
                  ':',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Selector Minutos
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'Minuto',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B4513),
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: dropdownBorderColor, width: 2),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _selectedMinute,
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                          iconSize: 30,
                          elevation: 16,
                          dropdownColor: const Color(0xFF8B4513),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          onChanged: _handleMinuteChanged,
                          items: minutes.map<DropdownMenuItem<int>>((int value) { // Usar variable definida arriba
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Center(
                                child: Text(
                                  value.toString().padLeft(2, '0'),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Botón Validar
        ElevatedButton(
          onPressed: _checkTimeCorrect,
          style: ElevatedButton.styleFrom(
            backgroundColor: _showSuccessAnimation ? Colors.green : const Color(0xFF8B4513),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 5,
          ),
          child: const Text(
            'Validar Hora',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    ); // Cierre del Column principal
  }
}
