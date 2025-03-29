import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:namui_wam/core/models/level_model.dart';
import 'package:namui_wam/core/models/game_state.dart';
import 'package:namui_wam/core/models/activities_state.dart';
import 'package:namui_wam/core/templates/scrollable_level_screen.dart';
import 'package:namui_wam/core/widgets/info_bar_widget.dart';
import 'package:namui_wam/features/activity5/services/activity5_service.dart';
import 'package:namui_wam/features/activity5/models/namtrik_money_model.dart';
import 'package:namui_wam/features/activity5/models/namtrik_article_model.dart';

// Cambiado para usar ScrollableLevelScreen en lugar de BaseLevelScreen
class Activity5LevelScreen extends ScrollableLevelScreen {
  // Constructor de la clase que recibe el nivel de la actividad
  const Activity5LevelScreen({
    Key? key,
    required LevelModel level,
  }) : super(level: level, activityNumber: 5);

  // Crea el estado mutable para la clase de la pantalla de un nivel de la actividad 5
  @override
  State<Activity5LevelScreen> createState() => _Activity5LevelScreenState();
}

// Clase para el estado de la pantalla de un nivel de la actividad 5
class _Activity5LevelScreenState
    extends ScrollableLevelScreenState<Activity5LevelScreen> {
  late Activity5Service _activity5Service;
  bool _isLoading = true;
  bool isCorrectAnswerSelected = false;
  List<NamtrikMoneyModel> _moneyItems = [];
  NamtrikArticleModel? _currentArticle;
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  // Variables para el nivel 2 con opciones de dinero
  List<List<NamtrikMoneyModel>> _moneyOptions = [];
  int _correctOptionIndex = -1;
  int? _selectedOptionIndex;
  bool _optionsGenerated = false;
  bool _showFeedback = false;

  // Estado para controlar la reproducción de audio y el cambio de icono
  bool _isPlayingAudio = false;

  // Mapa para controlar qué imagen se muestra para cada denominación (true = segunda imagen, false = primera imagen)
  Map<int, bool> _showingSecondImage = {};

  // Variables para el nivel 3 con nombres en namtrik
  String _correctNamtrikName = '';
  List<String> _incorrectNamtrikNames = [];
  List<String> _shuffledNamtrikNames = [];
  int _correctNameIndex = -1;
  int? _selectedNameIndex;
  bool _showNameFeedback = false;

  // Inicializa el estado de la pantalla de un nivel de la actividad 5
  @override
  void initState() {
    super.initState();
    _activity5Service = GetIt.instance<Activity5Service>();
    _loadLevelData();
  }

  // Carga los datos del nivel de la actividad 5
  Future<void> _loadLevelData() async {
    try {
      // Cargar datos según el nivel
      if (widget.level.id == 1) {
        _moneyItems = await _activity5Service.getLevelData(widget.level);

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
        _currentArticle = await _activity5Service.getRandomArticle();
        
        // Generar opciones de dinero para el nivel 2
        if (_currentArticle != null && !_optionsGenerated) {
          _moneyOptions = await _activity5Service.generateOptionsForLevel2(_currentArticle!);
          _correctOptionIndex = _activity5Service.findCorrectOptionIndex(
              _moneyOptions, 
              _currentArticle!.numberMoneyImages
          );
          _optionsGenerated = true;
        }
        
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      } else if (widget.level.id == 3) {
        // Para el nivel 3, cargar datos sincronizados (imágenes y nombres en namtrik)
        final syncData = await _activity5Service.getSynchronizedLevel3Data();
        
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
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      debugPrint('Error cargando datos del nivel: $e');
    }
  }

  // Maneja la selección de una opción en el nivel 2
  void _handleOptionSelection(int index) {
    if (_showFeedback) return; // No permitir cambios durante el feedback
    
    setState(() {
      _selectedOptionIndex = index;
      _showFeedback = true;
      
      // Actualizar el número de intentos restantes si la respuesta es incorrecta
      if (index != _correctOptionIndex) {
        decrementAttempts();
      } else {
        isCorrectAnswerSelected = true;
      }
    });
    
    // Programar el reinicio del feedback después de un tiempo
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showFeedback = false;
          
          if (index == _correctOptionIndex) {
            // Respuesta correcta - mostrar diálogo y registrar puntos
            _handleLevelComplete();
          } else {
            // Respuesta incorrecta - cargar nueva imagen y opciones o mostrar diálogo de sin intentos
            if (remainingAttempts <= 0) {
              _handleOutOfAttempts();
            } else {
              // Cargar un nuevo artículo y opciones
              _resetLevel2();
            }
          }
        });
      }
    });
  }
  
  // Maneja cuando se agotan los intentos
  void _handleOutOfAttempts() {
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
              foregroundColor: const Color(0xFF4CAF50), // Verde fresco
            ),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }
  
  // Maneja cuando el usuario completa el nivel correctamente
  void _handleLevelComplete() async {
    // Actualizar el estado del juego y mostrar el diálogo de respuesta correcta
    final activitiesState = ActivitiesState.of(context);
    final gameState = GameState.of(context);

    // Verificar si el nivel se ha completado y agregar puntos si es necesario
    final wasCompleted = gameState.isLevelCompleted(5, widget.level.id - 1);

    if (!wasCompleted) {
      final pointsAdded = await gameState.addPoints(5, widget.level.id - 1, 5);
      if (pointsAdded) {
        activitiesState.completeLevel(5, widget.level.id - 1);
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
                    color: const Color(0xFF00FF00), // Lima
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
                    backgroundColor: const Color(0xFF00FF00), // Lima
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
                    backgroundColor: const Color(0xFF00FF00), // Lima
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
  
  // Reinicia el nivel 2 con un nuevo artículo
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
    _currentArticle = await _activity5Service.getRandomArticle();
    
    // Generar nuevas opciones
    if (_currentArticle != null) {
      _moneyOptions = await _activity5Service.generateOptionsForLevel2(_currentArticle!);
      _correctOptionIndex = _activity5Service.findCorrectOptionIndex(
          _moneyOptions, 
          _currentArticle!.numberMoneyImages
      );
      _optionsGenerated = true;
    }
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Maneja la selección de un nombre en namtrik en el nivel 3
  void _handleNameSelection(int index) {
    if (_showNameFeedback) return; // No permitir cambios durante el feedback
    
    setState(() {
      _selectedNameIndex = index;
      _showNameFeedback = true;
      
      // Actualizar el número de intentos restantes si la respuesta es incorrecta
      if (index != _correctNameIndex) {
        decrementAttempts();
      } else {
        isCorrectAnswerSelected = true;
      }
    });
    
    // Programar el reinicio del feedback después de un tiempo
    Future.delayed(Duration(seconds: 2), () {
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
  
  // Reinicia el nivel 3 con nuevas imágenes y nombres
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
    final syncData = await _activity5Service.getSynchronizedLevel3Data();
    
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

  // Método para disminuir el número de intentos
  void decrementAttempts() {
    if (remainingAttempts > 0) {
      setState(() {
        remainingAttempts--;
      });
    }
  }
  
  // Método para restablecer el número de intentos al valor inicial
  void resetAttempts() {
    setState(() {
      remainingAttempts = 3;
    });
  }

  // Alterna entre las dos imágenes disponibles para la moneda/billete actual
  void _toggleImage(int index) {
    if (_moneyItems[index].moneyImages.length < 2)
      return; // No hacer nada si no hay segunda imagen

    setState(() {
      _showingSecondImage[index] = !(_showingSecondImage[index] ?? false);
    });
  }

  // Obtiene la imagen actual a mostrar basado en el estado
  String _getCurrentImage(int index) {
    if (_moneyItems[index].moneyImages.isEmpty) return '';

    if (_showingSecondImage[index] == true &&
        _moneyItems[index].moneyImages.length > 1) {
      return _moneyItems[index].moneyImages[1]; // Segunda imagen
    } else {
      return _moneyItems[index].moneyImages[0]; // Primera imagen
    }
  }

  // Reproduce los audios para el valor del dinero actual
  Future<void> _playMoneyAudio() async {
    if (_currentIndex >= _moneyItems.length) return;

    // Cambiar estado para actualizar el icono
    setState(() {
      _isPlayingAudio = true;
    });

    try {
      // Reproducir los audios del valor monetario actual
      final audiosNamtrik = _moneyItems[_currentIndex].audiosNamtrik;
      await _activity5Service.playAudioForMoneyNamtrik(audiosNamtrik);
    } finally {
      // Restaurar el estado del icono cuando termine la reproducción
      if (mounted) {
        setState(() {
          _isPlayingAudio = false;
        });
      }
    }
  }

  // Widget para mostrar la imagen del dinero nivel 1
  Widget _buildMoneyImage(int index) {
    String imageName = _getCurrentImage(index);

    return GestureDetector(
      onTap: () => _toggleImage(index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.transparent, // Color de fondo
          boxShadow: [
            BoxShadow(color: Colors.transparent), // Color de sombra
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              _activity5Service.getMoneyImagePath(imageName),
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
  
  // Widget para mostrar una opción de dinero nivel 2
  Widget _buildMoneyOption(List<NamtrikMoneyModel> option, int optionIndex) {
    // Determinar el estilo de la opción basado en si está seleccionada y si es correcta
    Color borderColor = const Color(0xFF4CAF50); // Color del borde
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
    
    // Generar el widget de la opción con las imágenes del dinero
    return GestureDetector(
      onTap: () {
        if (_selectedOptionIndex == null || !_showFeedback) {
          _handleOptionSelection(optionIndex);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 2),
          borderRadius: BorderRadius.circular(12),
          color: bgColor,
        ),
        child: Column(
          children: [
            // Imágenes de las monedas en filas horizontales con un espacio entre ellas en el nivel 2
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: option.map((item) {
                return Container(
                  width: 80,
                  height: 80,
                  child: Image.asset(
                    _activity5Service.getMoneyImagePath(item.moneyImages[0]),
                    fit: BoxFit.contain,
                  ),
                );
              }).toList(),
            ),
            
            // Icono de feedback si corresponde para la opción seleccionada del artículo del nivel 2
            if (_showFeedback && _selectedOptionIndex == optionIndex && feedbackIcon != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Icon(
                  feedbackIcon,
                  color: optionIndex == _correctOptionIndex ? Colors.green : Colors.red,
                  size: 24,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Widget para mostrar el artículo del nivel 2
  Widget _buildArticleWidget() {
    if (_currentArticle == null) {
      return const Center(
        child: Text('No se encontró ningún artículo',
            style: TextStyle(color: Colors.white, fontSize: 18)),
      );
    }

    // Obtener el tamaño de la pantalla para adaptar la imagen del artículo en el nivel 2
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;

    // Widget Column para el artículo del nivel 2
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InfoBar(
          remainingAttempts: remainingAttempts,
          margin: const EdgeInsets.only(bottom: 16),
        ),
        // Imagen del artículo del nivel 2
        Container(
          width: double.infinity,
          height: isLandscape ? screenSize.height * 0.4 : screenSize.height * 0.35,
          padding: const EdgeInsets.all(16),
          // Color transparente de la imagen del artículo del nivel 2
          decoration: BoxDecoration(
            color: Colors.transparent,
          ),
          // Stack para colocar la lupa sobre la imagen
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Imagen del artículo del nivel 2
              Image.asset(
                _activity5Service.getArticleImagePath(_currentArticle!.imageArticle),
                fit: BoxFit.contain,
              ),
              // Botón de lupa (visible en ambos modos) del artículo del nivel 2
              Positioned(
                bottom: 10,
                right: 10,
                child: InkWell(
                  onTap: () => _showEnlargedImage(_currentArticle!.imageArticle),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
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
        const SizedBox(height: 12),
        // Nombre del artículo en Namtrik (solo lectura) nivel 2
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          // Color verde fresco de la caja del nombre del artículo en Namtrik (solo lectura) nivel 2
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50), // Verde fresco
            borderRadius: BorderRadius.circular(12),
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
        SizedBox(height: 16),
        
        // Opciones de dinero (solo lectura) nivel 3
        if (_moneyOptions.isNotEmpty)
          ..._moneyOptions.asMap().entries.map((entry) {
            return _buildMoneyOption(entry.value, entry.key);
          }).toList(),
      ],
    );
  }
  
  // Widget para construir la cuadrícula de imágenes de dinero para el nivel 3
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
                color: const Color(0xFF4CAF50),
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
                  itemWidth = (containerWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount;
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
                        onTap: () {
                          // Al tocar la imagen, mostrarla ampliada (solo lectura) nivel 3
                          _showEnlargedMoneyImage(item.moneyImages[0]);
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Imagen del dinero (solo cara A) (solo lectura) nivel 3
                            Image.asset(
                              _activity5Service.getMoneyImagePath(item.moneyImages[0]),
                              fit: BoxFit.contain,
                            ),
                            // Indicador visual para que el usuario sepa que puede tocar la imagen (solo lectura) nivel 3
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
                                  Icons.zoom_in,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
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
  
  // Método para construir los 4 recuadros del nivel 3
  List<Widget> _buildEmptyBoxes(bool isLandscape) {
    // Lista para almacenar los recuadros del nivel 3
    List<Widget> boxes = [];
    
    // Calcular el ancho máximo para los recuadros en modo horizontal
    final screenWidth = MediaQuery.of(context).size.width;
    final boxWidth = isLandscape ? 450.0 : screenWidth - 32; // 32 = margen horizontal total
    
    // Crear 4 recuadros con nombres en namtrik del nivel 3
    for (int i = 0; i < 4; i++) {
      // Determinar el estilo del recuadro basado en si está seleccionado y si es correcto
      Color borderColor = Colors.transparent;
      Color bgColor = const Color(0xFF4CAF50);
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
              margin: const EdgeInsets.only(bottom: 16), // Espacio entre los recuadros de nombres
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
                      _shuffledNamtrikNames.isNotEmpty ? _shuffledNamtrikNames[i] : '',
                      style: TextStyle(
                        color: Colors.white, // Color del texto del nombre
                        fontSize: 18, // Tamaño del texto del nombre
                        fontWeight: FontWeight.w500, // Grosor del texto del nombre
                      ),
                      textAlign: TextAlign.center, // Alineación del texto del nombre
                    ),
                  ),
                  
                  // Icono de feedback si corresponde (solo para el nombre seleccionado) nivel 3
                  if (_showNameFeedback && _selectedNameIndex == i && feedbackIcon != null)
                    Icon(
                      feedbackIcon,
                      color: i == _correctNameIndex ? Colors.green : Colors.red, // Color del icono de feedback correcto (verde) o incorrecto (rojo)
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

  // Widget para mostrar las imágenes en un PageView (reemplazando el carrusel) nivel 3
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
                    : Colors.white.withOpacity(0.4), // Opacidad del círculo no actual
              ),
            );
          }).toList(),
        ),
        // Espacio entre el indicador de página y el nombre del artículo nivel 2
        const SizedBox(height: 20),
        if (_currentIndex < _moneyItems.length)
          Column(
            mainAxisSize: MainAxisSize
                .min, // Para evitar que ocupe más espacio del necesario
            children: [
              // Nombre del artículo en Namtrik (solo lectura)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                // Color verde fresco de la caja del nombre del artículo en Namtrik (solo lectura)
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50), // Verde fresco
                  borderRadius: BorderRadius.circular(12),
                ),
                // Texto del valor del artículo en Namtrik (solo lectura)
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
                onPressed: _isPlayingAudio ? null : _playMoneyAudio, // Deshabilitar el botón si se está reproduciendo el audio
                // Deshabilitar el botón visualmente mientras se reproduce el audio
                style: ElevatedButton.styleFrom(
                  // Color lima del botón
                  backgroundColor: const Color(0xFF00FF00), // Color lima
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // Bordes redondeados del botón
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  // Deshabilitar el botón visualmente mientras se reproduce el audio
                  disabledBackgroundColor:
                      const Color(0xFF00FF00).withOpacity(0.7),
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
                  : _buildMoneyGrid(),
    );
  }

  // Método para mostrar la imagen ampliada con sombra del artículo en el nivel 2
  void _showEnlargedImage(String imagePath) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85), // Fondo más oscuro
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black.withOpacity(0.7), // Fondo oscuro para la imagen
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
                    _activity5Service.getArticleImagePath(imagePath),
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

  // Método para mostrar la imagen ampliada de dinero nivel 3
  void _showEnlargedMoneyImage(String imagePath) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black.withOpacity(0.7),
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
                    _activity5Service.getMoneyImagePath(imagePath),
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
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
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
}
