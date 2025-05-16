import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:namuiwam/core/models/level_model.dart';
import 'package:namuiwam/core/models/game_state.dart';
import 'package:namuiwam/core/models/activities_state.dart';
import 'package:namuiwam/core/templates/scrollable_level_screen.dart';
import 'package:namuiwam/core/widgets/info_bar_widget.dart';
import 'package:namuiwam/features/activity4/services/activity4_service.dart';
import 'package:namuiwam/features/activity4/models/namtrik_money_model.dart';
import 'package:namuiwam/features/activity4/models/namtrik_article_model.dart';
import 'dart:math';
import 'package:namuiwam/core/services/feedback_service.dart';
import 'package:namuiwam/core/services/sound_service.dart';

/// {@template activity4_level_screen}
/// Pantalla que muestra el contenido y la lógica para un nivel específico
/// de la Actividad 4: "Anwan ashipelɵ kɵkun" (Aprendamos a usar el dinero).
///
/// Implementa cuatro interfaces de juego diferentes según el nivel:
/// - Nivel 1: Conozcamos el dinero Namtrik - Exploración de denominaciones monetarias
///   con visualización de frente/reverso y reproducción de audio.
/// - Nivel 2: Escojamos el dinero correcto - Selección del conjunto correcto de 
///   denominaciones para completar el precio de un artículo mostrado.
/// - Nivel 3: Escojamos el nombre correcto - Emparejamiento de conjuntos de 
///   denominaciones con su nombre correcto en Namtrik.
/// - Nivel 4: Coloquemos el dinero correcto - Composición de una cantidad objetivo
///   seleccionando las denominaciones correctas de una cuadrícula.
///
/// Características comunes a todos los niveles:
/// - Sistema de puntuación y registro de progreso
/// - Retroalimentación visual y háptica
/// - Límite de intentos por nivel
/// - Adaptación a diferentes orientaciones y tamaños de pantalla
/// - Transiciones entre estados del juego (carga, juego, éxito, fracaso)
///
/// Hereda de [ScrollableLevelScreen] para mantener consistencia con otras actividades
/// y reutilizar la lógica común de gestión de niveles.
/// {@endtemplate}
class Activity4LevelScreen extends ScrollableLevelScreen {
  /// {@macro activity4_level_screen}
  const Activity4LevelScreen({
    Key? key,
    required LevelModel level,
  }) : super(level: level, activityNumber: 4);

  /// Crea el estado mutable para esta pantalla.
  ///
  /// Retorna una instancia de [_Activity4LevelScreenState] que gestiona:
  /// - El estado de la interfaz de usuario específica de cada nivel
  /// - La carga y procesamiento de datos desde [Activity4Service]
  /// - Las interacciones del usuario específicas para cada nivel
  /// - La gestión del ciclo de vida del nivel (inicio, juego, finalización)
  @override
  State<Activity4LevelScreen> createState() => _Activity4LevelScreenState();
}

/// Clase de estado para [Activity4LevelScreen].
///
/// Gestiona la lógica específica de cada nivel de la Actividad 4:
/// - Carga de datos del nivel ([_loadLevelData]).
/// - Manejo de interacciones del usuario (selección de opciones, nombres, billetes).
/// - Validación de respuestas ([_handleOptionSelection], [_handleNameSelection], [_validateLevel4Selection]).
/// - Actualización del estado del juego (intentos, puntos, nivel completado).
/// - Retroalimentación visual y háptica.
/// - Construcción de la interfaz de usuario específica para cada nivel ([buildLevelContent], [_buildLevel1Content], etc.).
///
/// Mantiene variables de estado separadas para cada uno de los cuatro niveles,
/// activando solo las necesarias según el nivel actual, lo que optimiza el uso de memoria.
class _Activity4LevelScreenState
    extends ScrollableLevelScreenState<Activity4LevelScreen> {
  /// Servicio para obtener datos y lógica de la Actividad 4.
  ///
  /// Esta instancia se inicializa en [initState] y proporciona:
  /// - Carga de datos desde archivos JSON
  /// - Métodos para generar opciones y validar respuestas
  /// - Reproducción de audio para nombres Namtrik
  /// - Cálculo de valores monetarios totales
  late Activity4Service _activity4Service;
  final SoundService _soundService = GetIt.instance<SoundService>();

  /// Indica si los datos del nivel se están cargando.
  ///
  /// Controla la visualización de un indicador de carga mientras
  /// se obtienen los datos necesarios desde [_activity4Service].
  bool _isLoading = true;

  /// Indica si se ha seleccionado la respuesta correcta.
  ///
  /// Utilizado para el control de flujo y prevenir acciones adicionales
  /// después de que el usuario ha seleccionado correctamente la respuesta.
  bool isCorrectAnswerSelected = false;

  /// Lista de modelos de dinero (billetes/monedas) para el nivel actual.
  ///
  /// Utilizado principalmente en:
  /// - Nivel 1: Para mostrar todas las denominaciones disponibles
  /// - Nivel 3: Para mostrar un conjunto específico que debe ser nombrado
  List<NamtrikMoneyModel> _moneyItems = [];

  /// El artículo actual a mostrar en el Nivel 2.
  ///
  /// Contiene la información del artículo, incluyendo:
  /// - Imagen
  /// - Precio numérico
  /// - Nombre del precio en Namtrik
  /// - Lista de denominaciones requeridas para pagarlo
  NamtrikArticleModel? _currentArticle;

  /// Índice del elemento actual en PageView (Nivel 1).
  ///
  /// Controla qué denominación se está mostrando actualmente
  /// en el paginador horizontal del Nivel 1.
  int _currentIndex = 0;

  /// Controlador para el PageView del Nivel 1.
  ///
  /// Permite:
  /// - Navegar programáticamente entre páginas
  /// - Capturar eventos de cambio de página
  /// - Aplicar animaciones al cambiar de página
  final PageController _pageController = PageController();

  // --- Variables Nivel 2 ---
  /// Lista de opciones (cada opción es una lista de billetes/monedas) para el Nivel 2.
  List<List<NamtrikMoneyModel>> _moneyOptions = [];

  /// Índice de la opción correcta en [_moneyOptions].
  int _correctOptionIndex = -1;

  /// Índice de la opción seleccionada por el usuario.
  int? _selectedOptionIndex;

  /// Indica si las opciones para el Nivel 2 ya se generaron.
  bool _optionsGenerated = false;

  /// Controla si se debe mostrar feedback (colores/iconos) en las opciones.
  bool _showFeedback = false;

  /// Indica si se está reproduciendo un audio actualmente.
  bool _isPlayingAudio = false;

  /// Mapa para rastrear qué imagen (primera o segunda) se muestra para cada item en Nivel 1.
  ///
  /// La clave es el índice del elemento en [_moneyItems] y el valor es un booleano:
  /// - false: Muestra la primera imagen (anverso)
  /// - true: Muestra la segunda imagen (reverso, si está disponible)
  Map<int, bool> _showingSecondImage = {};

  // --- Variables Nivel 3 ---
  /// El nombre Namtrik correcto para el conjunto de dinero actual.
  String _correctNamtrikName = '';

  /// Lista de nombres Namtrik incorrectos para generar opciones.
  List<String> _incorrectNamtrikNames = [];

  /// Lista de nombres Namtrik (correcto + incorrectos) desordenados para mostrar como opciones.
  List<String> _shuffledNamtrikNames = [];

  /// Índice del nombre correcto en [_shuffledNamtrikNames].
  int _correctNameIndex = -1;

  /// Índice del nombre seleccionado por el usuario.
  int? _selectedNameIndex;

  /// Controla si se debe mostrar feedback (colores/iconos) en las opciones de nombres.
  bool _showNameFeedback = false;

  // --- Variables Nivel 4 ---
  /// Indica si los datos específicos del Nivel 4 (nombres Namtrik) se han cargado.
  bool _level4DataLoaded = false;

  /// Lista de todos los nombres Namtrik de dinero disponibles para el Nivel 4.
  List<String> _level4NamtrikNames = [];

  /// El nombre Namtrik del valor objetivo actual para el Nivel 4.
  String _currentLevel4NamtrikName = '';

  /// Lista de rutas a todas las imágenes de billetes/monedas disponibles.
  List<String> _moneyImages = [];

  /// Indica si las imágenes de dinero para el Nivel 4 se han cargado.
  bool _moneyImagesLoaded = false;

  /// Índices de los billetes/monedas seleccionados por el usuario en la cuadrícula.
  List<int> _selectedMoneyIndices = [];

  /// Valor total actual de los billetes/monedas seleccionados.
  int _currentTotalValue = 0;

  /// Valor total objetivo que el usuario debe alcanzar.
  int _targetTotalValue = 0;

  /// Mapa que asocia el índice de un billete/moneda en [_moneyImages] con su valor numérico.
  Map<int, int> _numberIndexToValue = {};

  /// Lista de los valores numéricos de los billetes/monedas que componen el valor objetivo.
  List<int> _targetMoneyNumbers = [];

  /// Controla si se debe mostrar feedback (correcto/incorrecto) para la selección del Nivel 4.
  bool _showLevel4Feedback = false;

  /// Indica si la selección actual del usuario para el Nivel 4 es correcta.
  bool _isCorrectLevel4Answer = false;

  /// Indica si ya se han ganado puntos por la respuesta correcta en Nivel 4 (evita sumar puntos múltiples veces).
  bool _hasEarnedPointsLevel4 = false;

  @override
  void initState() {
    super.initState();
    _activity4Service = GetIt.instance<Activity4Service>();
    _loadLevelData();
  }

  /// Carga los datos necesarios según el ID del nivel actual ([widget.level.id]).
  ///
  /// Obtiene datos del [_activity4Service] y actualiza el estado (_isLoading, etc.).
  /// Maneja la carga específica para cada uno de los 4 niveles.
  Future<void> _loadLevelData() async {
    try {
      // Cargar datos según el nivel
      if (widget.level.id == 1) {
        _moneyItems = await _activity4Service.getLevelData(widget.level);

        // Inicializar todas las denominaciones para mostrar la primera imagen
        if (mounted) {
          setState(() {
            for (var i = 0; i < _moneyItems.length; i++) {
              _showingSecondImage[i] = false;
            }
            _isLoading = false;
          });
        }
      } else if (widget.level.id == 2) {
        // Para el nivel 2, cargar un artículo aleatorio
        _currentArticle = await _activity4Service.getRandomArticle();

        // Generar opciones de dinero para el nivel 2
        if (_currentArticle != null && !_optionsGenerated) {
          _moneyOptions = await _activity4Service
              .generateOptionsForLevel2(_currentArticle!);
          _correctOptionIndex = _activity4Service.findCorrectOptionIndex(
              _moneyOptions, _currentArticle!.numberMoneyImages);
          _optionsGenerated = true;
        }

        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      } else if (widget.level.id == 3) {
        // Para el nivel 3, cargar datos sincronizados (imágenes y nombres en namtrik)
        final syncData = await _activity4Service.getSynchronizedLevel3Data();

        // Actualizar los datos del nivel 3
        _moneyItems = List<NamtrikMoneyModel>.from(syncData['moneyItems']);
        _correctNamtrikName = syncData['correctName'];
        _incorrectNamtrikNames = List<String>.from(syncData['incorrectNames']);

        // Mezclar los nombres para mostrarlos en los 4 recuadros
        _shuffledNamtrikNames = [
          _correctNamtrikName,
          ..._incorrectNamtrikNames
        ];
        _shuffledNamtrikNames.shuffle();
        _correctNameIndex = _shuffledNamtrikNames.indexOf(_correctNamtrikName);

        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      } else if (widget.level.id == 4) {
        // Para el nivel 4, cargar datos de nombres en namtrik del archivo JSON
        final level4NamtrikNames =
            await _activity4Service.getLevel4NamtrikNames();
        _level4NamtrikNames = level4NamtrikNames;

        // Seleccionar un nombre aleatorio
        _selectRandomLevel4Name();

        // Cargar imágenes de dinero
        _moneyImages = await _activity4Service.getAllMoneyImages();
        _moneyImagesLoaded = true;

        if (mounted) {
          setState(() {
            _level4DataLoaded = true;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      debugPrint('Error cargando datos del nivel: $e');
    }
  }

  /// Maneja la selección de una opción de conjunto de dinero en el Nivel 2.
  ///
  /// Actualiza el estado para mostrar feedback, decrementa intentos si es incorrecto,
  /// y programa la transición al siguiente estado (nivel completado o reintento).
  void _handleOptionSelection(int index) async {
    if (_showFeedback) return;

    setState(() {
      _selectedOptionIndex = index;
      _showFeedback = true;
      if (index != _correctOptionIndex) {
        decrementAttempts();
      } else {
        isCorrectAnswerSelected = true;
      }
    });

    // Feedback háptico fuera de setState
    if (index != _correctOptionIndex) {
      _soundService.playIncorrectSound(); // Reproduce sonido de error
      await FeedbackService().mediumHapticFeedback();
    } else {
      _soundService.playCorrectSound(); // Reproduce sonido de acierto
      await FeedbackService().lightHapticFeedback();
    }

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showFeedback = false;
          if (index == _correctOptionIndex) {
            _handleLevelComplete();
          } else {
            if (remainingAttempts <= 0) {
              _handleOutOfAttempts();
            } else {
              _resetLevel2();
            }
          }
        });
      }
    });
  }

  /// Muestra un diálogo indicando que se agotaron los intentos y navega hacia atrás.
  void _handleOutOfAttempts() async {
    await FeedbackService().heavyHapticFeedback();
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
              foregroundColor: const Color(0xFFCD5C5C), // Rojo terroso
            ),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  /// Maneja la lógica de finalización exitosa de un nivel.
  ///
  /// Otorga puntos si es la primera vez, actualiza el estado global del juego,
  /// y muestra un diálogo de felicitaciones o de nivel ya completado.
  void _handleLevelComplete() async {
    // Vibración corta al completar el nivel correctamente
    await FeedbackService().lightHapticFeedback();
    // Actualizar el estado del juego y mostrar el diálogo de respuesta correcta
    final activitiesState = ActivitiesState.of(context);
    final gameState = GameState.of(context);

    // Verificar si el nivel se ha completado y agregar puntos si es necesario
    final wasCompleted = gameState.isLevelCompleted(4, widget.level.id - 1);

    if (!wasCompleted) {
      final pointsAdded = await gameState.addPoints(4, widget.level.id - 1, 5);
      if (pointsAdded) {
        activitiesState.completeLevel(4, widget.level.id - 1);
        if (mounted) {
          setState(() {
            totalScore = gameState.globalPoints;
          });
        }
      }

      // Mostrar diálogo de nivel completado si se agregaron puntos con éxito
      if (!mounted) return;

      // Mostrar mensaje de éxito con puntos ganados si es la primera vez que se completa el nivel
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
                // Espacio entre el texto y el botón
                const SizedBox(height: 16),
                Text(
                  '¡Ganaste 5 puntos!',
                  style: TextStyle(
                    color: const Color(0xFFCD5C5C), // Rojo terroso
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                // Espacio entre el texto y el botón
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCD5C5C), // Rojo terroso
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
      // Mostrar mensaje de nivel ya completado anteriormente si no se agregaron puntos
      if (!mounted) return;

      // Mostrar mensaje de éxito si el nivel ya se ha completado anteriormente
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
                  'Ya habías completado este nivel anteriormente.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCD5C5C), // Rojo terroso
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

  /// Reinicia el estado del Nivel 2 para presentar un nuevo artículo y opciones.
  Future<void> _resetLevel2() async {
    setState(() {
      _isLoading = true;
      _selectedOptionIndex = null;
      _optionsGenerated = false;
      isCorrectAnswerSelected = false;

      // Reiniciar intentos solo si se seleccionó la respuesta correcta
      if (isCorrectAnswerSelected) {
        resetAttempts();
      }
    });

    // Cargar un nuevo artículo aleatorio
    _currentArticle = await _activity4Service.getRandomArticle();

    // Generar nuevas opciones
    if (_currentArticle != null) {
      _moneyOptions =
          await _activity4Service.generateOptionsForLevel2(_currentArticle!);
      _correctOptionIndex = _activity4Service.findCorrectOptionIndex(
          _moneyOptions, _currentArticle!.numberMoneyImages);
      _optionsGenerated = true;
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Maneja la selección de una opción de nombre Namtrik en el Nivel 3.
  ///
  /// Similar a [_handleOptionSelection], actualiza el estado, gestiona intentos
  /// y programa la transición al siguiente estado.
  void _handleNameSelection(int index) async {
    if (_showNameFeedback) return;

    setState(() {
      _selectedNameIndex = index;
      _showNameFeedback = true;
      if (index != _correctNameIndex) {
        decrementAttempts();
      } else {
        isCorrectAnswerSelected = true;
      }
    });

    // Feedback háptico fuera de setState
    if (index != _correctNameIndex) {
      _soundService.playIncorrectSound(); // Reproduce sonido de error
      await FeedbackService().mediumHapticFeedback();
    } else {
      _soundService.playCorrectSound(); // Reproduce sonido de acierto
      await FeedbackService().lightHapticFeedback();
    }

    // Programar el reinicio del feedback después de un tiempo
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showNameFeedback = false;

          if (index == _correctNameIndex) {
            // Respuesta correcta - mostrar diálogo y registrar puntos
            _handleLevelComplete();
          } else {
            // Respuesta incorrecta - cargar nuevas imágenes y nombres o mostrar diálogo de sin intentos
            if (remainingAttempts <= 0) {
              _handleOutOfAttempts();
            } else {
              // Cargar nuevas imágenes y nombres
              _resetLevel3();
            }
          }
        });
      }
    });
  }

  /// Reinicia el estado del Nivel 3 para presentar un nuevo conjunto de dinero y opciones de nombres.
  Future<void> _resetLevel3() async {
    setState(() {
      _isLoading = true;
      _selectedNameIndex = null;
      isCorrectAnswerSelected = false;

      // Reiniciar intentos solo si se seleccionó la respuesta correcta
      if (isCorrectAnswerSelected) {
        resetAttempts();
      }
    });

    // Cargar datos sincronizados para el nivel 3
    final syncData = await _activity4Service.getSynchronizedLevel3Data();

    // Actualizar los datos del nivel 3
    _moneyItems = List<NamtrikMoneyModel>.from(syncData['moneyItems']);
    _correctNamtrikName = syncData['correctName'];
    _incorrectNamtrikNames = List<String>.from(syncData['incorrectNames']);

    // Mezclar los nombres para mostrarlos en los 4 recuadros
    _shuffledNamtrikNames = [_correctNamtrikName, ..._incorrectNamtrikNames];
    _shuffledNamtrikNames.shuffle();
    _correctNameIndex = _shuffledNamtrikNames.indexOf(_correctNamtrikName);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Disminuye el contador de intentos restantes.
  void decrementAttempts() {
    if (remainingAttempts > 0) {
      setState(() {
        remainingAttempts--;
      });
    }
  }

  /// Restablece el contador de intentos a su valor inicial (3).
  void resetAttempts() {
    setState(() {
      remainingAttempts = 3;
    });
  }

  /// Alterna la imagen mostrada para un item de dinero en Nivel 1 (si tiene dos imágenes).
  void _toggleImage(int index) {
    if (_moneyItems[index].moneyImages.length < 2)
      return; // No hacer nada si no hay segunda imagen

    setState(() {
      _showingSecondImage[index] = !(_showingSecondImage[index] ?? false);
    });
  }

  /// Obtiene la ruta de la imagen actual (primera o segunda) para un item en Nivel 1.
  String _getCurrentImage(int index) {
    if (_moneyItems[index].moneyImages.isEmpty) return '';

    if (_showingSecondImage[index] == true &&
        _moneyItems[index].moneyImages.length > 1) {
      return _moneyItems[index].moneyImages[1]; // Segunda imagen
    } else {
      return _moneyItems[index].moneyImages[0]; // Primera imagen
    }
  }

  /// Reproduce el audio correspondiente al valor Namtrik del item actual en Nivel 1.
  Future<void> _playMoneyAudio() async {
    if (_currentIndex >= _moneyItems.length) return;

    // Cambiar estado para actualizar el icono
    setState(() {
      _isPlayingAudio = true;
    });

    try {
      // Reproducir los audios del valor monetario actual
      final audiosNamtrik = _moneyItems[_currentIndex].audiosNamtrik;
      await _activity4Service.playAudioForMoneyNamtrik(audiosNamtrik);
    } finally {
      // Restaurar el estado del icono cuando termine la reproducción
      if (mounted) {
        setState(() {
          _isPlayingAudio = false;
        });
      }
    }
  }

  /// Construye el widget que muestra la imagen del dinero para el Nivel 1 (en el PageView).
  ///
  /// Incluye un [GestureDetector] para [_toggleImage] y un indicador visual.
  Widget _buildMoneyImage(int index) {
    String imageName = _getCurrentImage(index);

    return GestureDetector(
      onTap: () => _toggleImage(index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.transparent, // Color de fondo
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              _activity4Service.getMoneyImagePath(imageName),
              fit: BoxFit.contain,
            ),
            // Indicador visual sutil para que el usuario sepa que puede tocar la imagen
            Positioned(
              bottom: 5,
              right: 5,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.touch_app,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye el widget para una opción de conjunto de dinero en el Nivel 2.
  ///
  /// Muestra las imágenes de los billetes/monedas y aplica estilos (borde, fondo, icono)
  /// según el estado de selección y feedback.
  Widget _buildMoneyOption(List<NamtrikMoneyModel> option, int optionIndex) {
    // Determinar el estilo de la opción basado en si está seleccionada y si es correcta
    Color borderColor = const Color(0xFFCD5C5C); // Color del borde
    Color bgColor = Colors.transparent; // Color de fondo
    IconData? feedbackIcon;

    // Si se muestra la retroalimentación y la opción seleccionada es correcta o incorrecta
    if (_showFeedback && _selectedOptionIndex == optionIndex) {
      if (optionIndex == _correctOptionIndex) {
        borderColor = const Color(0xFF00FF00);
        bgColor = Color(0xFF00FF00).withOpacity(0.2);
        feedbackIcon = Icons.check_circle;
      } else {
        borderColor = const Color(0xFFFF0000);
        bgColor = Color(0xFFFF0000).withOpacity(0.2);
        feedbackIcon = Icons.cancel;
      }
    } else if (_selectedOptionIndex == optionIndex) {
      borderColor = Colors.white;
      bgColor = Colors.white.withOpacity(0.1);
    }

    // Obtener el tamaño de la pantalla para diseño responsivo
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;
    final maxContainerWidth = isLandscape ? 450.0 : screenSize.width * 0.9;

    // Calcular el tamaño óptimo para las imágenes basado en la orientación
    // y el número de elementos en la opción
    final int itemCount = option.length;
    final double imageSize = isLandscape
        ? (itemCount <= 2
            ? 100.0
            : itemCount <= 4
                ? 90.0
                : 80.0)
        : (itemCount <= 2
            ? 110.0
            : itemCount <= 4
                ? 100.0
                : 90.0);

    // Generar el widget de la opción con las imágenes del dinero nivel 2
    return Center(
      child: GestureDetector(
        onTap: () {
          if (_selectedOptionIndex == null || !_showFeedback) {
            _handleOptionSelection(optionIndex);
          }
        },
        // GestureDetector para manejar el evento de tap
        child: Container(
          constraints: BoxConstraints(
            maxWidth: maxContainerWidth,
          ),
          width: double.infinity,
          margin: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal:
                  16), // Espacio vertical y horizontal entre las opciones
          padding: const EdgeInsets.all(16), // Espacio interno del contenedor
          decoration: BoxDecoration(
            border: Border.all(
                color: borderColor, width: 2), // Borde del contenedor
            borderRadius: BorderRadius.circular(12), // Bordes redondeados
            color: bgColor, // Color de fondo del contenedor
          ),
          // Columna principal para organizar el contenido del contenedor
          child: Column(
            children: [
              // Imágenes de las monedas en filas horizontales con un espacio entre ellas en el nivel 2
              Wrap(
                alignment: WrapAlignment
                    .center, // Alineación horizontal de las imágenes
                spacing: 8, // Espacio entre las imágenes
                runSpacing: 8, // Espacio entre las filas
                // Generar las imágenes de las monedas en el nivel 2
                children: option.map((item) {
                  return Container(
                    width:
                        imageSize, // Tamaño de las imágenes dirección horizontal
                    height:
                        imageSize, // Tamaño de las imágenes dirección vertical
                    // ClipRRect para redondear las imágenes
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        _activity4Service
                            .getMoneyImagePath(item.moneyImages[0]),
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                }).toList(),
              ),

              // Icono de feedback si corresponde para la opción seleccionada del artículo del nivel 2
              if (_showFeedback &&
                  _selectedOptionIndex == optionIndex &&
                  feedbackIcon != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16), // Espacio superior
                  child: Icon(
                    feedbackIcon, // Icono de feedback
                    color: optionIndex == _correctOptionIndex
                        ? const Color(0xFF00FF00)
                        : const Color(
                            0xFFFF0000), // Color del icono (verde para correcto, rojo para incorrecto)
                    size: 32, // Tamaño del icono
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye el widget principal para el Nivel 2.
  ///
  /// Muestra la [InfoBar], la imagen y nombre Namtrik del artículo,
  /// y las opciones de dinero construidas con [_buildMoneyOption].
  Widget _buildArticleWidget() {
    if (_currentArticle == null) {
      return const Center(
        child: Text('No se encontró ningún artículo',
            style: TextStyle(color: Colors.white, fontSize: 18)),
      );
    }

    // Obtener el tamaño de la pantalla para diseño responsivo
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;
    final maxContainerWidth = isLandscape ? 450.0 : screenSize.width * 0.9;

    // Widget Column para el artículo del nivel 2
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InfoBar(
            remainingAttempts: remainingAttempts,
            margin: const EdgeInsets.only(bottom: 16),
          ),
          // Imagen del artículo del nivel 2
          Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: maxContainerWidth,
                maxHeight: isLandscape
                    ? screenSize.height * 0.4
                    : screenSize.height * 0.35,
              ),
              width: double.infinity,
              padding: const EdgeInsets.all(
                  1), // Ajustar el padding para que la imagen no se vea tan grande
              // Stack para colocar la lupa sobre la imagen del artículo del nivel 2
              child: Stack(
                alignment: Alignment
                    .center, // Alineación central de los elementos del Stack
                children: [
                  // Imagen del artículo del nivel 2
                  Image.asset(
                    _activity4Service.getArticleImagePath(_currentArticle!
                        .imageArticle), // Ruta de la imagen del artículo del nivel 2
                    fit: BoxFit
                        .contain, // Tamaño de la imagen del artículo del nivel 2
                  ),
                  // Botón de lupa (visible en ambos modos) del artículo del nivel 2
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: InkWell(
                      onTap: () =>
                          _showEnlargedImage(_currentArticle!.imageArticle),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        // Sombra suave alrededor del botón para mejorar el contraste
                        child: const Icon(
                          Icons.zoom_in,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Nombre del artículo en Namtrik (solo lectura) nivel 2
          Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: maxContainerWidth,
              ),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              // Color rojo terroso de la caja del nombre del artículo en Namtrik (solo lectura) nivel 2
              decoration: BoxDecoration(
                color: const Color(0xFFCD5C5C), // Rojo terroso
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(
                        0xFFCD5C5C), // Sombra rojo terroso de la caja del nombre del artículo en Namtrik (solo lectura) nivel 2
                    blurRadius: 8, // Radio de la sombra
                    offset: const Offset(0,
                        4), // Desplazamiento de la sombra 10 para x y 0 para y
                  ),
                ],
              ),
              // Texto del valor del artículo en Namtrik (solo lectura) nivel 2
              child: Text(
                _currentArticle!.namePriceNamtrik,
                style: TextStyle(
                  color: Colors.white, // Color blanco
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(height: 20),

          // Opciones de dinero (solo lectura) nivel 3
          if (_moneyOptions.isNotEmpty)
            ..._moneyOptions.asMap().entries.map((entry) {
              return _buildMoneyOption(entry.value, entry.key);
            }).toList(),
        ],
      ),
    );
  }

  /// Construye el widget principal para el Nivel 3.
  ///
  /// Muestra la [InfoBar], la cuadrícula con las imágenes del conjunto de dinero,
  /// y los 4 recuadros con las opciones de nombres Namtrik.
  Widget _buildMoneyGrid() {
    if (_moneyItems.isEmpty) {
      return const Center(
        child: Text('No se encontraron datos',
            style: TextStyle(color: Colors.white, fontSize: 18)),
      );
    }

    // Obtener el tamaño de la pantalla para diseño responsivo
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Barra de información con intentos
          InfoBar(
            remainingAttempts: remainingAttempts,
            margin: const EdgeInsets.only(bottom: 16),
          ),

          // Contenedor único que muestra las imágenes de dinero (solo lectura) nivel 3
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFCD5C5C),
                width: 1,
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Determinar el tamaño de las imágenes basado en la orientación
                final double containerWidth = constraints.maxWidth;

                // En landscape, mostrar en una sola fila; en portrait, mostrar en 2x2
                final int crossAxisCount = isLandscape ? _moneyItems.length : 2;
                final double spacing = 12;

                // Calcular el ancho de cada elemento basado en la orientación
                double itemWidth;
                if (isLandscape) {
                  // En landscape, dividir el ancho entre el número de elementos
                  itemWidth =
                      (containerWidth - (spacing * (crossAxisCount - 1))) /
                          crossAxisCount;
                } else {
                  // En portrait, mantener 2 columnas
                  itemWidth = (containerWidth - spacing) / 2;
                }

                // Ajustar la altura para mantener la proporción
                final double itemHeight = itemWidth * 0.6;

                // Widget para construir la cuadrícula de imágenes de dinero (solo lectura) nivel 3
                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  alignment: WrapAlignment.center,
                  children: _moneyItems.map((item) {
                    return Container(
                      width: itemWidth,
                      height: itemHeight,
                      child: GestureDetector(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Imagen del dinero (solo cara A) (solo lectura) nivel 3
                            Image.asset(
                              _activity4Service
                                  .getMoneyImagePath(item.moneyImages[0]),
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),

          // Espacio entre el contenedor de imágenes y los recuadros
          SizedBox(height: 24),

          // 4 recuadros del nivel 3
          ..._buildEmptyBoxes(isLandscape),
        ],
      ),
    );
  }

  /// Construye el widget principal para el Nivel 1.
  ///
  /// Muestra la [InfoBar], un [PageView] con las imágenes del dinero ([_buildMoneyImage]),
  /// indicadores de página, y el nombre/valor Namtrik con botón de audio.
  Widget _buildPageView() {
    if (_moneyItems.isEmpty) {
      return const Center(
        child: Text('No se encontraron datos',
            style: TextStyle(color: Colors.white, fontSize: 18)),
      );
    }

    // Obtener el tamaño de la pantalla para diseño responsivo
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;

    // Ajustar altura del contenedor según la orientación
    final double imageContainerHeight = isLandscape
        ? screenSize.height * 0.4 // 40% de la altura en landscape
        : screenSize.height * 0.35; // 35% de la altura en portrait

    return Column(
      mainAxisSize:
          MainAxisSize.min, // Para evitar que ocupe más espacio del necesario
      children: [
        // InfoBar ahora se incluye aquí en lugar de en buildLevelContent
        InfoBar(
          remainingAttempts: remainingAttempts,
          margin: const EdgeInsets.only(bottom: 16),
        ),

        // Contenedor principal para mostrar imágenes
        Container(
          height: imageContainerHeight,
          constraints: BoxConstraints(
            maxHeight: isLandscape ? 200 : 250,
          ),
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: _moneyItems.length,
            itemBuilder: (context, index) {
              return _buildMoneyImage(index);
            },
          ),
        ),
        // Espacio entre el contenedor de imágenes y el indicador de página personalizado nivel 2
        const SizedBox(height: 20),
        // Indicador de página personalizado nivel 2
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _moneyItems.asMap().entries.map((entry) {
            return Container(
              width: 10.0,
              height: 10.0,
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // Color del círculo de la indicación de página
                color: _currentIndex == entry.key
                    ? Colors.white // Color del círculo actual
                    : Colors.white
                        .withOpacity(0.4), // Opacidad del círculo no actual
              ),
            );
          }).toList(),
        ),
        // Espacio entre el indicador de página y el nombre del dinero nivel 1
        const SizedBox(height: 20),
        if (_currentIndex < _moneyItems.length)
          Column(
            mainAxisSize: MainAxisSize
                .min, // Para evitar que ocupe más espacio del necesario
            children: [
              // Nombre del dinero en namtrik (solo lectura) nivel 1
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                // Color rojo terroso de la caja del nombre del dinero en namtrik (solo lectura) nivel 1
                decoration: BoxDecoration(
                  color: const Color(0xFFCD5C5C), // Rojo terroso
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFCD5C5C),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                // Texto del valor del dinero en namtrik (solo lectura) nivel 1
                child: Text(
                  _moneyItems[_currentIndex].moneyNamtrik,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              // Espacio adicional para asegurar que no haya espacio blanco en portrait
              const SizedBox(height: 20),
              // Botón de Escuchar del nivel 1
              ElevatedButton(
                onPressed: _isPlayingAudio
                    ? null
                    : _playMoneyAudio, // Deshabilitar el botón si se está reproduciendo el audio
                // Deshabilitar el botón visualmente mientras se reproduce el audio
                style: ElevatedButton.styleFrom(
                  // Color rojo terroso del botón
                  backgroundColor:
                      const Color(0xFFCD5C5C), // Color rojo terroso
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        30), // Bordes redondeados del botón
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  // Deshabilitar el botón visualmente mientras se reproduce el audio
                  disabledBackgroundColor:
                      const Color(0xFFCD5C5C).withOpacity(0.7),
                  disabledForegroundColor: Colors.white.withOpacity(0.7),
                ),
                // Texto del botón de escuchar del nivel 1
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icono de volumen que cambia según el estado de reproducción
                    Icon(
                      _isPlayingAudio ? Icons.volume_up : Icons.volume_down,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Escuchar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Espacio adicional para asegurar que no haya espacio blanco en portrait
              SizedBox(height: isLandscape ? 20 : 40),
            ],
          ),
      ],
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Construye el contenido específico del nivel de la actividad 5
  @override
  Widget buildLevelContent() {
    // Obtener el tamaño de la pantalla para diseño responsivo
    final screenSize = MediaQuery.of(context).size;

    return Container(
      // Asegurar que el contenido ocupe al menos toda la altura disponible en portrait
      constraints: BoxConstraints(
        minHeight: screenSize.height -
            220, // Restar altura aproximada de la descripción y appbar
      ),
      child: _isLoading
          ? const SizedBox(
              height: 300,
              child:
                  Center(child: CircularProgressIndicator(color: Colors.white)),
            )
          : widget.level.id == 1
              ? _buildPageView()
              : widget.level.id == 2
                  ? _buildArticleWidget()
                  : widget.level.id == 3
                      ? _buildMoneyGrid()
                      : _level4DataLoaded
                          ? _buildLevel4Content()
                          : const Center(
                              child: Text(
                                'Cargando datos...',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
    );
  }

  // Método para construir el contenido del nivel 4 con dos recuadros
  Widget _buildLevel4Content() {
    // Obtener el tamaño de la pantalla para diseño responsivo
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;

    // Definir el ancho máximo para los recuadros en modo horizontal
    final double containerWidth = isLandscape
        ? 450.0 // Ancho máximo fijo en landscape
        : screenSize.width -
            32; // Ancho completo disponible en portrait (con margen)

    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Barra de información con intentos y puntos (nivel 4)
            InfoBar(
              remainingAttempts: remainingAttempts,
              margin: const EdgeInsets.only(bottom: 16),
            ),

            // Primer recuadro (nivel 4)
            Container(
              width: containerWidth,
              margin: const EdgeInsets.only(
                  bottom: 16), // Margen inferior para separación
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 16), // Padding horizontal aumentado
              decoration: BoxDecoration(
                color: const Color(0xFFCD5C5C),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFCD5C5C),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              // Mostrar el texto en namtrik seleccionado aleatoriamente
              child: Center(
                child: Text(
                  _currentLevel4NamtrikName,
                  style: const TextStyle(
                    color: Colors.white, // Color del texto
                    fontSize:
                        24, // Tamaño del texto aumentado para mejor visibilidad
                    fontWeight:
                        FontWeight.bold, // Texto en negrita para destacar
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            // Segundo recuadro (nivel 4)
            Container(
              width: containerWidth,
              margin: const EdgeInsets.only(
                  bottom: 16), // Margen inferior para separación
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 16), // Padding horizontal aumentado
              decoration: BoxDecoration(
                color: _showLevel4Feedback
                    ? (_isCorrectLevel4Answer
                        ? const Color(0xFF00FF00).withOpacity(
                            0.2) // Lima transparente para respuesta correcta
                        : const Color(0xFFFF0000).withOpacity(
                            0.2)) // Rojo transparente para respuesta incorrecta
                    : const Color(0xFFCD5C5C), // Rojo terroso por defecto
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _showLevel4Feedback
                      ? (_isCorrectLevel4Answer
                          ? const Color(
                              0xFF00FF00) // Lima para respuesta correcta
                          : const Color(
                              0xFFFF0000)) // Rojo para respuesta incorrecta
                      : Colors.transparent, // Transparente por defecto
                ),
              ),
              child: SizedBox(
                height: 50,
                child: Center(
                  child: Text(
                    _currentTotalValue > 0 ? '$_currentTotalValue' : '',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            // Imágenes de dinero en una cuadrícula (nivel 4)
            if (_moneyImagesLoaded)
              Container(
                width: containerWidth,
                margin: const EdgeInsets.only(bottom: 24, top: 16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        3, // 3 imágenes por fila para mejor visualización
                    childAspectRatio:
                        1.2, // Proporción para que las imágenes no se vean estiradas
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _moneyImages.length,
                  itemBuilder: (context, index) {
                    // Determinar si esta imagen está seleccionada
                    final isSelected =
                        _selectedMoneyIndices.contains(index + 1);

                    return GestureDetector(
                      onTap: () {
                        if (!_showLevel4Feedback) {
                          _handleMoneyImageTap(index);
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFCD5C5C).withOpacity(
                                  0.3) // Color de selección (Rojo terroso) con 30% de opacidad
                              : Colors
                                  .transparent, // Color transparente por defecto fondo de la imagen
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? const Color(
                                    0xFFCD5C5C) // Borde de selección (Rojo terroso)
                                : const Color(
                                    0xFFCD5C5C), // Color de borde (Rojo terroso)
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        // Padding para dar espacio entre las imágenes
                        padding: const EdgeInsets.all(1),
                        child: Stack(
                          children: [
                            // Imagen del dinero
                            Positioned.fill(
                              child: Image.asset(
                                _activity4Service
                                    .getMoneyImagePath(_moneyImages[index]),
                                fit: BoxFit.contain,
                              ),
                            ),

                            // Indicador de selección (opcional)
                            if (isSelected)
                              Positioned(
                                top: 4,
                                right: 4,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFCD5C5C),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Método para manejar el tap en una imagen de dinero para el nivel 4
  void _handleMoneyImageTap(int index) {
    if (_showLevel4Feedback)
      return; // No permitir interacción durante el feedback

    // Obtener el número correspondiente a esta imagen
    final moneyNumber = index +
        1; // El índice es 0-based, pero los números en el JSON son 1-based

    setState(() {
      // Permitir seleccionar la misma imagen múltiples veces
      // Agregar el índice a la lista de seleccionados
      _selectedMoneyIndices.add(moneyNumber);

      // Agregar el valor correspondiente a la suma
      final valueToAdd = _numberIndexToValue[moneyNumber] ?? 0;
      _currentTotalValue += valueToAdd;

      // Verificar si el usuario ha excedido el valor objetivo
      if (_currentTotalValue > _targetTotalValue) {
        // Sobrepasó el valor total
        _showLevel4Feedback = true;
        _isCorrectLevel4Answer = false;

        _soundService.playIncorrectSound(); // SONIDO INCORRECTO
        // Reproducir alerta de audio
        _activity4Service.playAlertAudio('valor_excedido');

        // Decrementar intentos
        decrementAttempts();

        // Después de un tiempo, reiniciar el nivel con un nuevo nombre aleatorio
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _showLevel4Feedback = false;

              // Verificar si quedan intentos
              if (remainingAttempts <= 0) {
                _handleOutOfAttempts();
              } else {
                // Reiniciar con un nuevo nombre aleatorio
                _selectRandomLevel4Name();
              }
            });
          }
        });
      } else if (_currentTotalValue == _targetTotalValue) {
        // Verificar si la selección del usuario corresponde con los valores objetivo
        // Este paso verifica que se hayan seleccionado todos los elementos necesarios
        bool hasCorrectCombination = true;

        // Crear mapas de frecuencia para comparar las selecciones con los objetivos
        Map<int, int> selectedFrequency = {};
        Map<int, int> targetFrequency = {};

        // Contar frecuencia de cada número en las selecciones del usuario
        for (int num in _selectedMoneyIndices) {
          selectedFrequency[num] = (selectedFrequency[num] ?? 0) + 1;
        }

        // Contar frecuencia de cada número en los objetivos
        for (int num in _targetMoneyNumbers) {
          targetFrequency[num] = (targetFrequency[num] ?? 0) + 1;
        }

        // Comparar los mapas de frecuencia
        // Para cada número en el objetivo, verificar que aparezca la misma cantidad de veces en las selecciones
        for (int key in targetFrequency.keys) {
          if ((selectedFrequency[key] ?? 0) != targetFrequency[key]) {
            hasCorrectCombination = false;
            break;
          }
        }

        // También verificar que no haya números adicionales en las selecciones
        for (int key in selectedFrequency.keys) {
          if ((targetFrequency[key] ?? 0) != selectedFrequency[key]) {
            hasCorrectCombination = false;
            break;
          }
        }

        _showLevel4Feedback = true;
        _isCorrectLevel4Answer = hasCorrectCombination;

        if (hasCorrectCombination) {
          _soundService.playCorrectSound(); // SONIDO CORRECTO
          // La respuesta es correcta - mostrar diálogo de éxito
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              // Verificar si ya se han ganado puntos para este nivel
              final activitiesState = ActivitiesState.of(context);
              final gameState = GameState.of(context);
              final wasCompleted =
                  gameState.isLevelCompleted(4, widget.level.id - 1);

              if (!wasCompleted && !_hasEarnedPointsLevel4) {
                // Primera vez que completa correctamente - otorgar 5 puntos
                gameState
                    .addPoints(4, widget.level.id - 1, 5)
                    .then((pointsAdded) {
                  if (pointsAdded) {
                    activitiesState.completeLevel(4, widget.level.id - 1);
                    setState(() {
                      totalScore = gameState.globalPoints;
                      _hasEarnedPointsLevel4 = true;
                    });

                    // Mostrar diálogo de felicitación con puntos ganados
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
                              Text(
                                '¡Ganaste 5 puntos!',
                                style: TextStyle(
                                  color:
                                      const Color(0xFFCD5C5C), // Rojo terroso
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  // Reiniciar con un nuevo nombre aleatorio
                                  setState(() {
                                    _showLevel4Feedback = false;
                                    _selectRandomLevel4Name();
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color(0xFFCD5C5C), // Rojo terroso
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
                });
              } else {
                // Ya ha completado el nivel anteriormente - sólo mostrar mensaje de buen trabajo
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
                            'Ya habías completado este nivel anteriormente.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              // Reiniciar con un nuevo nombre aleatorio
                              setState(() {
                                _showLevel4Feedback = false;
                                _selectRandomLevel4Name();
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFFCD5C5C), // Rojo terroso
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 12),
                            ),
                            child: const Text('Aceptar'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
            }
          });
        } else {
          // La combinación no es correcta, pero el valor total está bien
          _soundService.playIncorrectSound(); // SONIDO INCORRECTO
          // Reproducir alerta de audio (opcional)
          _activity4Service.playAlertAudio('combinacion_incorrecta');

          // Decrementar intentos
          decrementAttempts();

          // Después de un tiempo, reiniciar el nivel
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                _showLevel4Feedback = false;

                // Verificar si quedan intentos
                if (remainingAttempts <= 0) {
                  _handleOutOfAttempts();
                } else {
                  // Reiniciar la selección pero mantener el mismo nombre
                  _selectedMoneyIndices = [];
                  _currentTotalValue = 0;
                }
              });
            }
          });
        }
      }
    });
  }

  // --- Métodos y Widgets Nivel 4 ---

  /// Selecciona aleatoriamente un nombre Namtrik de la lista cargada para el Nivel 4
  /// y calcula el valor numérico objetivo correspondiente.
  void _selectRandomLevel4Name() {
    if (_level4NamtrikNames.isNotEmpty) {
      setState(() {
        // Limpiar selecciones anteriores
        _selectedMoneyIndices = [];
        _currentTotalValue = 0;
        _showLevel4Feedback = false;
        _isCorrectLevel4Answer = false;

        // Seleccionar un nombre aleatorio del nivel 4
        final randomIndex = Random().nextInt(_level4NamtrikNames.length);
        _currentLevel4NamtrikName = _level4NamtrikNames[randomIndex];

        // Cargar los valores objetivo de la base de datos
        _loadTargetMoneyValues();
      });
    }
  }

  // Método para cargar los valores objetivo del nombre seleccionado del nivel 4
  Future<void> _loadTargetMoneyValues() async {
    try {
      // Obtener los datos del nivel 4 para el nombre seleccionado
      final targetData = await _activity4Service
          .getLevel4MoneyValuesForName(_currentLevel4NamtrikName);

      if (targetData != null) {
        setState(() {
          _targetTotalValue = targetData['total_money'];
          _targetMoneyNumbers =
              List<int>.from(targetData['number_money_images']);
        });
      }

      // Cargar mapeo de índices de número a valores monetarios
      await _loadMoneyValueMapping();
    } catch (e) {
      debugPrint('Error cargando valores objetivo: $e');
    }
  }

  // Método para cargar el mapeo de índices de número a valores monetarios del nivel 4
  Future<void> _loadMoneyValueMapping() async {
    try {
      final moneyItems = await _activity4Service.getAllMoneyItems();

      if (moneyItems.isNotEmpty) {
        setState(() {
          _numberIndexToValue = {};
          for (var item in moneyItems) {
            _numberIndexToValue[item.number] = item.valueMoney;
          }
        });
      }
    } catch (e) {
      debugPrint('Error cargando mapeo de valores: $e');
    }
  }

  /// Muestra un diálogo con la imagen ampliada con sombra del artículo en el nivel 2
  void _showEnlargedImage(String imagePath) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85), // Fondo más oscuro
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor:
              Colors.black.withOpacity(0.7), // Fondo oscuro para la imagen
          insetPadding: EdgeInsets.all(20),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Imagen ampliada con sombra
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  // Sombra suave alrededor de la imagen para mejorar el contraste
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    _activity4Service.getArticleImagePath(imagePath),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              // Botón para cerrar
              Positioned(
                top: 0,
                right: 0,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  // Sombra suave alrededor del botón para mejorar el contraste
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                    // Sombra suave alrededor del botón para mejorar el contraste
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Construye los 4 recuadros interactivos para las opciones de nombres en Nivel 3.
  List<Widget> _buildEmptyBoxes(bool isLandscape) {
    // Lista para almacenar los recuadros del nivel 3
    List<Widget> boxes = [];

    // Calcular el ancho máximo para los recuadros en modo horizontal
    final screenWidth = MediaQuery.of(context).size.width;
    final boxWidth =
        isLandscape ? 450.0 : screenWidth - 32; // 32 = margen horizontal total

    // Crear 4 recuadros con nombres en namtrik del nivel 3
    for (int i = 0; i < 4; i++) {
      // Determinar el estilo del recuadro basado en si está seleccionado y si es correcto
      Color borderColor = Colors.transparent;
      Color bgColor = const Color(0xFFCD5C5C);
      IconData? feedbackIcon;

      // Si se muestra la retroalimentación y el nombre seleccionado es el correcto o incorrecto nivel 3
      if (_showNameFeedback && _selectedNameIndex == i) {
        if (i == _correctNameIndex) {
          borderColor = const Color(0xFF00FF00);
          bgColor = Color(0xFF00FF00).withOpacity(0.2);
          feedbackIcon = Icons.check_circle;
        } else {
          borderColor = const Color(0xFFFF0000);
          bgColor = Color(0xFFFF0000).withOpacity(0.2);
          feedbackIcon = Icons.cancel;
        }
      } else if (_selectedNameIndex == i) {
        borderColor = Colors.white;
        bgColor = Colors.white.withOpacity(0.1);
      }

      // Agregar el recuadro al contenedor del nivel 3
      boxes.add(
        Center(
          child: GestureDetector(
            onTap: () {
              if (_selectedNameIndex == null || !_showNameFeedback) {
                _handleNameSelection(i);
              }
            },
            // Recuadro de nombres del nivel 3
            child: Container(
              width: boxWidth,
              margin: const EdgeInsets.only(
                  bottom: 16), // Espacio entre los recuadros de nombres
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: borderColor,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Texto del nombre en namtrik nivel 3
                  Expanded(
                    child: Text(
                      _shuffledNamtrikNames.isNotEmpty
                          ? _shuffledNamtrikNames[i]
                          : '',
                      style: TextStyle(
                        color: Colors.white, // Color del texto del nombre
                        fontSize: 18, // Tamaño del texto del nombre
                        fontWeight:
                            FontWeight.w500, // Grosor del texto del nombre
                      ),
                      textAlign:
                          TextAlign.center, // Alineación del texto del nombre
                    ),
                  ),

                  // Icono de feedback si corresponde (solo para el nombre seleccionado) nivel 3
                  if (_showNameFeedback &&
                      _selectedNameIndex == i &&
                      feedbackIcon != null)
                    Icon(
                      feedbackIcon,
                      color: i == _correctNameIndex
                          ? Colors.green
                          : Colors
                              .red, // Color del icono de feedback correcto (verde) o incorrecto (rojo)
                      size: 24, // Tamaño del icono de feedback
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return boxes;
  }
}
