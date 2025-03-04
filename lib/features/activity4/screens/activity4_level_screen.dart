import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:namui_wam/core/models/level_model.dart';
import 'package:namui_wam/core/models/game_state.dart';
import 'package:namui_wam/core/models/activities_state.dart';
import 'package:namui_wam/core/templates/scrollable_level_screen.dart';
import 'package:namui_wam/core/widgets/info_bar_widget.dart';
import 'package:namui_wam/features/activity4/services/activity4_service.dart';
import 'package:namui_wam/features/activity4/widgets/selectable_item.dart';

// Clase para la pantalla de un nivel de la actividad 4
class Activity4LevelScreen extends ScrollableLevelScreen {
  // Constructor de la clase que recibe el nivel de la actividad
  const Activity4LevelScreen({
    Key? key,
    required LevelModel level,
  }) : super(level: level, activityNumber: 4);

  // Crea el estado mutable para la clase de la pantalla de un nivel de la actividad 4
  @override
  State<Activity4LevelScreen> createState() => _Activity4LevelScreenState();
}

// Clase para el estado de la pantalla de un nivel de la actividad 4
class _Activity4LevelScreenState extends ScrollableLevelScreenState<Activity4LevelScreen> {
  late Activity4Service _activity4Service;
  bool _isLoading = true;
  List<Map<String, dynamic>> _gameItems = [];
  
  // Variables para el juego del nivel 1
  String? _selectedClockId;
  String? _selectedNamtrikId;
  Map<String, String> _matchedPairs = {};
  bool _showErrorAnimation = false;
  
  // Listas desordenadas para mostrar
  List<Map<String, dynamic>> _shuffledClocks = [];
  List<Map<String, dynamic>> _shuffledNamtrik = [];

  // Variables para el juego del nivel 2
  String? _clockImage;
  List<Map<String, dynamic>> _options = [];

  // Inicializa el estado de la pantalla de un nivel de la actividad 4
  @override
  void initState() {
    super.initState();
    _activity4Service = GetIt.instance<Activity4Service>();
    _loadLevelData();
  }

  // Carga los datos del nivel de la actividad 4
  Future<void> _loadLevelData() async {
    try {
      final levelData = await _activity4Service.getLevelData(widget.level);
      
      if (widget.level.id == 1) {
        final items = levelData['items'] as List<Map<String, dynamic>>;
        
        // Crear copias desordenadas para las imágenes y textos
        final List<Map<String, dynamic>> clocksCopy = List.from(items);
        final List<Map<String, dynamic>> namtrikCopy = List.from(items);
        
        // Desordenar las listas
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

  // Maneja la selección de un reloj
  void _handleClockSelected(String id) {
    if (_matchedPairs.containsKey(id)) return;
    
    setState(() {
      // Si ya había un reloj seleccionado, lo deseleccionamos
      if (_selectedClockId != null && _selectedClockId != id) {
        _selectedClockId = id;
      } else {
        _selectedClockId = _selectedClockId == id ? null : id;
      }
      
      // Si hay un reloj y un texto seleccionados, verificamos si coinciden
      if (_selectedClockId != null && _selectedNamtrikId != null) {
        _checkMatch();
      }
    });
  }

  // Maneja la selección de un texto en namtrik
  void _handleNamtrikSelected(String id) {
    if (_matchedPairs.values.contains(id)) return;
    
    setState(() {
      // Si ya había un texto seleccionado, lo deseleccionamos
      if (_selectedNamtrikId != null && _selectedNamtrikId != id) {
        _selectedNamtrikId = id;
      } else {
        _selectedNamtrikId = _selectedNamtrikId == id ? null : id;
      }
      
      // Si hay un reloj y un texto seleccionados, verificamos si coinciden
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
      // Reducir intentos
      remainingAttempts--;
      
      // Mostrar mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Respuesta incorrecta. Te quedan $remainingAttempts intentos.'),
          duration: const Duration(seconds: 2),
        ),
      );
      
      // Verificar si se han agotado los intentos
      if (remainingAttempts <= 0) {
        _handleOutOfAttempts();
      } else {
        // Cargar nuevos datos para una nueva ronda
        _loadLevelData();
      }
    }
  }

  // Verifica si la combinación seleccionada es correcta
  void _checkMatch() {
    if (_selectedClockId == null || _selectedNamtrikId == null) return;
    
    final isMatch = _activity4Service.isMatchCorrect(_selectedClockId!, _selectedNamtrikId!);
    
    if (isMatch) {
      // Añadir a pares coincidentes
      setState(() {
        _matchedPairs[_selectedClockId!] = _selectedNamtrikId!;
        _selectedClockId = null;
        _selectedNamtrikId = null;
      });
      
      // Verificar si se han encontrado todos los pares
      if (_matchedPairs.length == _gameItems.length) {
        _handleLevelComplete();
      }
    } else {
      // Mostrar animación de error
      setState(() {
        _showErrorAnimation = true;
      });
      
      // Reducir intentos
      remainingAttempts--;
      
      // Mostrar mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Combinación incorrecta. Te quedan $remainingAttempts intentos.'),
          duration: const Duration(seconds: 2),
        ),
      );
      
      // Resetear selección después de un breve retraso
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            _showErrorAnimation = false;
            _selectedClockId = null;
            _selectedNamtrikId = null;
          });
        }
      });
      
      // Verificar si se han agotado los intentos
      if (remainingAttempts <= 0) {
        _handleOutOfAttempts();
      }
    }
  }

  // Maneja el evento cuando se completa el nivel
  void _handleLevelComplete() async {
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

      // Mostrar diálogo de nivel completado si se agregaron puntos
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
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: const Text('Continuar'),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      // Mostrar mensaje de nivel ya completado anteriormente
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
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
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

  // Maneja el evento cuando se agotan los intentos
  void _handleOutOfAttempts() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('¡Sin intentos!'),
        content: const Text('Has agotado tus intentos. Volviendo al menú de actividad.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue,
            ),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  // Construye el contenido específico del nivel de la actividad 4
  @override
  Widget buildLevelContent() {
    if (_isLoading) {
      return const SizedBox(
        height: 300,
        child: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
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
                'Nivel ${widget.level.id} - En desarrollo',
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
    // Obtener tamaño de pantalla para diseño responsivo
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;
    
    // Calcular tamaño de los elementos según la orientación
    final double clockSize = isLandscape 
        ? screenSize.width * 0.15
        : screenSize.width * 0.35;
    
    // Determinar el número de elementos por fila según orientación
    final int clocksPerRow = isLandscape ? 4 : 2;
    
    return Column(
      children: [
        // Sección de relojes
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Center(
            child: Text(
              'Selecciona reloj u hora en namtrik',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        
        // Grid de relojes
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
            
            // Determinar el estado de selección
            SelectionState state = SelectionState.unselected;
            if (isMatched) {
              state = SelectionState.matched;
            } else if (isError) {
              state = SelectionState.error;
            } else if (isSelected) {
              state = SelectionState.selected;
            }
            
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
        
        const SizedBox(height: 30),
        
        // Grid de textos en namtrik (sin el título que fue eliminado)
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: clocksPerRow,
            childAspectRatio: 1.5,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: _shuffledNamtrik.length,
          itemBuilder: (context, index) {
            final item = _shuffledNamtrik[index];
            final id = item['id'];
            final isMatched = _matchedPairs.values.contains(id);
            final isSelected = _selectedNamtrikId == id;
            final isError = _showErrorAnimation && isSelected;
            
            // Determinar el estado de selección
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
              state: state,
              isEnabled: !isMatched,
              onTap: () => _handleNamtrikSelected(id),
              child: Center(
                child: Text(
                  item['hour_namtrik'],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isLandscape ? 14 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          },
        ),
        
        // Espacio adicional al final
        const SizedBox(height: 40),
      ],
    );
  }
  
  // Construye el contenido específico del nivel 2
  Widget _buildLevel2Content() {
    // Obtener tamaño de pantalla para diseño responsivo
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;
    
    // Calcular tamaños según orientación
    final double clockImageSize = isLandscape 
        ? screenSize.width * 0.25
        : screenSize.width * 0.7;
        
    // Calcular número de botones por fila según orientación
    final int optionsPerRow = isLandscape ? 4 : 2;
    
    return Column(
      children: [
        // Instrucción para el usuario
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
        
        const SizedBox(height: 20),
        
        // Opciones de respuesta (sin el título que fue eliminado)
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
            
            return ElevatedButton(
              onPressed: () => _handleOptionSelected(id, isCorrect),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(8),
              ),
              child: Text(
                option['hour_namtrik'],
                style: TextStyle(
                  fontSize: isLandscape ? 14 : 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            );
          },
        ),
        
        // Espacio adicional al final
        const SizedBox(height: 40),
      ],
    );
  }
}
