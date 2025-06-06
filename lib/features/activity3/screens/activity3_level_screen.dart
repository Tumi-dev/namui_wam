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
import 'package:namuiwam/core/services/sound_service.dart';

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
  //============================================================================
  // Servicios y Estado General Compartido
  //============================================================================
  late Activity3Service _activity3Service;
  final _soundService = GetIt.instance<SoundService>();
  bool _isLoading = true;
  List<Map<String, dynamic>> _gameItems = []; // Usada principalmente en Nivel 1

  //================ END OF SERVICIOS Y ESTADO GENERAL COMPARTIDO ================

  //============================================================================
  // Nivel 1: Emparejamiento
  //============================================================================
  // --- Variables Nivel 1 ---
  String? _selectedClockId;
  String? _selectedNamtrikId;
  final Map<String, String> _matchedPairs = {};
  bool _showErrorAnimation = false;
  List<Map<String, dynamic>> _shuffledClocks = [];
  List<Map<String, dynamic>> _shuffledNamtrik = [];

  // --- Métodos Nivel 1 ---
  void _handleClockSelected(String id) {
    if (_matchedPairs.containsKey(id)) return; // Ignora si ya está emparejado

    setState(() {
      // Si ya había un reloj seleccionado, lo deseleccionamos en nivel 1
      if (_selectedClockId != null && _selectedClockId != id) {
        _selectedClockId = id;
      } else {
        _selectedClockId = _selectedClockId == id ? null : id;
      }

      // Si ambos (reloj y texto) están seleccionados, verifica la coincidencia.
      if (_selectedClockId != null && _selectedNamtrikId != null) {
        _checkMatch();
      }
    });
  }

  void _handleNamtrikSelected(String id) {
    if (_matchedPairs.values.contains(id))
      return; // Ignora si ya está emparejado

    setState(() {
      // Si ya había un texto seleccionado, lo deseleccionamos en nivel 1
      if (_selectedNamtrikId != null && _selectedNamtrikId != id) {
        _selectedNamtrikId = id;
      } else {
        _selectedNamtrikId = _selectedNamtrikId == id ? null : id;
      }

      // Si ambos (reloj y texto) están seleccionados, verifica la coincidencia.
      if (_selectedClockId != null && _selectedNamtrikId != null) {
        _checkMatch();
      }
    });
  }

  void _checkMatch() {
    if (_selectedClockId == null || _selectedNamtrikId == null) return;

    final isMatch = _activity3Service.isMatchCorrect(
        _selectedClockId!, _selectedNamtrikId!);

    if (isMatch) {
      _soundService.playCorrectSound(); // Reproduce sonido de acierto
      setState(() {
        _matchedPairs[_selectedClockId!] = _selectedNamtrikId!;
        _selectedClockId = null;
        _selectedNamtrikId = null;
      });

      if (_matchedPairs.length == _gameItems.length) {
        _handleLevelComplete();
      }
    } else {
      _soundService.playIncorrectSound(); // Reproduce sonido de error
      FeedbackService().mediumHapticFeedback();
      setState(() {
        _showErrorAnimation = true;
      });

      // Reducir intentos restantes en nivel 1
      remainingAttempts--;

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

            _selectedClockId = null;
            _selectedNamtrikId = null;
          });
        }
      });

      if (remainingAttempts <= 0) {
        _handleOutOfAttempts();
      }
    }
  }

  // --- Widget Constructor UI Nivel 1 ---
  Widget _buildLevel1Content() {
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;
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
            crossAxisCount: clocksPerRow,
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

        const SizedBox(height: 16), // Espacio ajustado

        // Grid de Textos Namtrik
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: clocksPerRow,
            childAspectRatio: 1.5,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
          ),
          itemCount: _shuffledNamtrik.length,
          itemBuilder: (context, index) {
            final item = _shuffledNamtrik[index];
            final id = item['id'];
            final isMatched = _matchedPairs.values
                .contains(id); // Determina si el texto ya ha sido emparejado
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

        const SizedBox(height: 24),
      ],
    );
  }
  //================ END OF NIVEL 1 SECTION ====================================

  //============================================================================
  // Nivel 2: Selección Múltiple
  //============================================================================
  // --- Variables Nivel 2 ---
  String? _clockImage;
  List<Map<String, dynamic>> _options = [];

  // --- Métodos Nivel 2 ---
  void _handleOptionSelected(String id, bool isCorrect) {
    if (isCorrect) {
      _soundService.playCorrectSound(); // Reproduce sonido de acierto
      _handleLevelComplete();
    } else {
      _soundService.playIncorrectSound(); // Reproduce sonido de error
      FeedbackService().mediumHapticFeedback();

      remainingAttempts--;

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

  // --- Widget Constructor UI Nivel 2 ---
  Widget _buildLevel2Content() {
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;
    final double clockImageSize =
        isLandscape ? screenSize.width * 0.25 : screenSize.width * 0.7;
    final int optionsPerRow = isLandscape ? 4 : 2;

    return Column(
      children: [
        // Instrucción
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Text(
            'Selecciona la hora correcta en namuiwam',
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

        const SizedBox(height: 16),

        // Opciones de Respuesta
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
                backgroundColor: const Color(0xFF8B4513), // Color A3
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),

                padding: const EdgeInsets.all(
                    8), // Padding 8 para las opciones de respuesta
              ),
              child: Text(
                option['hour_namtrik'],
                style: TextStyle(
                  fontSize: isLandscape ? 16 : 16,
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
  //================ END OF NIVEL 2 SECTION ====================================

  //============================================================================
  // Nivel 3: Ajustar Hora
  //============================================================================
  // --- Variables Nivel 3 ---
  String? _hourNamtrik;
  String? _clockImageLevel3;
  int? _correctHour;
  int? _correctMinute;
  int _selectedHour = 0;
  int _selectedMinute = 0;
  bool _showSuccessAnimation = false;
  bool _showErrorAnimationLevel3 = false;

  // --- Métodos Nivel 3 ---
  int _getRandomHourDifferentFrom(int correctHour) {
    final random = Random();
    int randomHour;
    do {
      randomHour = random.nextInt(12); // 0-11
    } while (randomHour == correctHour);
    return randomHour;
  }

  int _getRandomMinuteDifferentFrom(int correctMinute) {
    final random = Random();
    int randomMinute;
    do {
      randomMinute = random.nextInt(60); // 0-59
    } while (randomMinute == correctMinute);
    return randomMinute;
  }

  void _handleHourChanged(int? hour) {
    if (hour != null) {
      setState(() {
        _selectedHour = hour;
        _showSuccessAnimation = false;
        _showErrorAnimationLevel3 = false;
      });
    }
  }

  void _handleMinuteChanged(int? minute) {
    if (minute != null) {
      setState(() {
        _selectedMinute = minute;
        _showSuccessAnimation = false;
        _showErrorAnimationLevel3 = false;
      });
    }
  }

  void _checkTimeCorrect() {
    final isCorrect = _activity3Service.isTimeCorrect(
        _selectedHour, _selectedMinute, _correctHour!, _correctMinute!);

    if (isCorrect) {
      _soundService.playCorrectSound(); // Reproduce sonido de acierto
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
      _soundService.playIncorrectSound(); // Reproduce sonido de error
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

  // --- Widget Constructor UI Nivel 3 ---
  Widget _buildLevel3Content() {
    // --- Definiciones movidas al inicio ---
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;
    final double instructionFontSize = isLandscape ? 18.0 : 20.0;
    final double namtrikHourFontSize = isLandscape ? 22.0 : 26.0;
    final EdgeInsets contentPadding = isLandscape
        ? const EdgeInsets.symmetric(horizontal: 48.0)
        : const EdgeInsets.symmetric(horizontal: 16.0);
    final double clockImageSize =
        isLandscape ? screenSize.width * 0.25 : screenSize.width * 0.7;
    final List<int> hours = List.generate(12, (index) => index); // 0 a 11
    final List<int> minutes = List.generate(60, (index) => index); // 0 a 59

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

        // Hora en Namtrik
        Container(
          margin: const EdgeInsets.only(bottom: 24.0),
          padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 12.0), // Tamaño del texto de la hora en namtrik
          decoration: BoxDecoration(
            // Fondo marrón tierra con bordes redondeados y sombra suave para el texto de la hora en namtrik
            color: const Color(0xFF8B4513), //
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                // Sombra suave con opacidad 30% y desplazamiento de 3 puntos hacia abajo
                color: const Color(0xFF8B4513),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            _hourNamtrik ?? '',
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
            children: [
              // Selector Hora
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'Hora',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal:
                              12.0), // Padding interno para el selector de hora nivel 3
                      decoration: BoxDecoration(
                        // Fondo marrón tierra con bordes redondeados para el selector de hora
                        color: const Color(
                            0xFF8B4513), // Fondo marrón tierra para el selector de hora
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
                        dropdownColor: const Color(0xFF8B4513),
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

              // Separador ':'
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

              // Selector Minutos
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'Minuto',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      decoration: BoxDecoration(
                        // Fondo marrón tierra con bordes redondeados para el selector de minuto
                        color: const Color(
                            0xFF8B4513), // Fondo marrón tierra para el selector de minuto
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
                        dropdownColor: const Color(0xFF8B4513),
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

        const SizedBox(height: 40),

        // Botón de confirmar la hora seleccionada nivel 3
        ElevatedButton(
          onPressed: _checkTimeCorrect,
          style: ElevatedButton.styleFrom(
            // Botón verde con texto blanco y bordes redondeados para confirmar la hora seleccionada en nivel 3
            backgroundColor:
                _showSuccessAnimation ? Color(0xFF00FF00) : Color(0xFF8B4513),
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
    ); // Cierre del Column principal
  }
  //================ END OF NIVEL 3 SECTION ====================================

  //============================================================================
  // Métodos Comunes del Juego / Ciclo de Vida del State
  //============================================================================
  @override
  void initState() {
    super.initState();
    _activity3Service = GetIt.instance<Activity3Service>();
    _loadLevelData();
  }

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

  void _handleLevelComplete() async {
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

  void _handleOutOfAttempts() async {
    await FeedbackService().heavyHapticFeedback();
    _showNoAttemptsDialog();
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
              // Muestra los puntos ganados solo si es la primera vez
              const SizedBox(height: 16),
              if (!wasCompleted)
                Text(
                  '¡Ganaste 5 puntos!',
                  style: const TextStyle(
                    color: Color(0xFF8B4513),
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
              // Botón para continuar
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Cierra el diálogo
                  Navigator.of(context).pop(); // Cierra la pantalla del nivel
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF8B4513), // Color específico A3
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

  //============================================================================
  // Constructor Principal de Contenido de Nivel (buildLevelContent)
  //============================================================================
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
  //================ END OF CONSTRUCTOR PRINCIPAL DE CONTENIDO =================
}
