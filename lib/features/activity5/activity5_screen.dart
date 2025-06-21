import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:namuiwam/core/constants/activity_descriptions.dart';
import 'package:namuiwam/core/di/service_locator.dart';
import 'package:namuiwam/core/themes/app_theme.dart';
import 'package:namuiwam/core/services/feedback_service.dart';
import 'package:namuiwam/core/widgets/game_description_widget.dart';
import 'package:namuiwam/features/activity5/services/activity5_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:namuiwam/core/constants/activity_instructions.dart';
import 'package:namuiwam/core/widgets/help/help.dart';

/// {@template activity5_screen}
/// Pantalla para la Actividad 5: "Muntsielan namtrikmai yunɵmarɵpik (Convertir números en letras)".
///
/// Implementa una herramienta interactiva que permite a los usuarios:
/// - Ingresar un número arábigo en el rango de 1 a 9,999,999
/// - Visualizar instantáneamente su representación escrita en Namtrik
/// - Escuchar la pronunciación correcta a través de archivos de audio
/// - Copiar el texto resultante al portapapeles
/// - Compartir el resultado con otras aplicaciones
///
/// A diferencia de las actividades 1-4 basadas en niveles de juego, esta actividad
/// funciona como una utilidad práctica para el aprendizaje y uso cotidiano del sistema
/// numérico Namtrik, proporcionando un recurso valioso para estudiantes, docentes
/// y hablantes de la lengua.
///
/// Características principales:
/// - Validación en tiempo real de la entrada numérica
/// - Feedback visual para entradas inválidas (borde rojo)
/// - Adaptación automática cuando aparece/desaparece el teclado
/// - Retroalimentación háptica en las interacciones principales
/// - Detección y manejo del ciclo de vida para parar audio en segundo plano
///
/// Ejemplo de navegación a esta pantalla:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => const Activity5Screen(),
///   ),
/// );
/// ```
/// {@endtemplate}
class Activity5Screen extends StatefulWidget {
  /// {@macro activity5_screen}
  const Activity5Screen({super.key});

  @override
  State<Activity5Screen> createState() => _Activity5ScreenState();
}

/// Clase de estado para [Activity5Screen].
///
/// Gestiona el ciclo completo de la herramienta de conversión de números:
/// - Entrada y validación del número arábigo
/// - Consulta al [Activity5Service] para obtener representaciones en Namtrik
/// - Actualización de la interfaz según el estado (carga, error, éxito)
/// - Control de la reproducción de audio
/// - Funcionalidades de copia y compartición
/// - Adaptación a cambios en el ciclo de vida de la aplicación
///
/// Implementa [WidgetsBindingObserver] para detectar cuando la app pasa a segundo
/// plano y detener el audio en reproducción, mejorando la experiencia del usuario.
class _Activity5ScreenState extends State<Activity5Screen>
    with WidgetsBindingObserver, HelpBannerMixin {
  /// Color específico de la Actividad 5 - Verde oliva apagado
  static const Color _activity5Color = Color(0xFF7E7745);

  /// Controlador para el campo de texto donde el usuario ingresa el número.
  ///
  /// Gestiona:
  /// - El texto actual ingresado por el usuario
  /// - La posición del cursor
  /// - La selección de texto
  /// - Notificaciones de cambios a través de listeners
  final TextEditingController _numberController = TextEditingController();

  /// Instancia del servicio para la lógica de la Actividad 5.
  ///
  /// Proporciona métodos para:
  /// - Validar números en el rango soportado
  /// - Obtener la representación Namtrik del número
  /// - Gestionar la reproducción de audio
  /// - Manejar errores durante la conversión
  final Activity5Service _activity5Service = getIt<Activity5Service>();

  /// Controlador para el scroll principal, usado para ajustar la vista con el teclado.
  ///
  /// Permite:
  /// - Desplazar automáticamente el contenido cuando aparece el teclado
  /// - Asegurar que el campo de texto permanezca visible durante la edición
  /// - Controlar el comportamiento del scroll en la pantalla
  final ScrollController _scrollController = ScrollController();

  /// Almacena la representación Namtrik del número ingresado.
  ///
  /// Contiene:
  /// - Cadena vacía cuando no hay entrada
  /// - El texto en Namtrik cuando la conversión es exitosa
  /// - Mensaje de error cuando la entrada es inválida o falla la conversión
  String _namtrikResult = '';

  /// Indica si se está esperando una respuesta del servicio.
  ///
  /// Controla la visualización del indicador de carga (CircularProgressIndicator)
  /// mientras se consulta al servicio para obtener la representación Namtrik.
  bool _isLoading = false;

  /// Indica si la entrada actual es inválida (ej. fuera de rango).
  ///
  /// Se utiliza para:
  /// - Mostrar mensajes de error apropiados
  /// - Cambiar el color del borde del campo de entrada
  /// - Evitar consultas innecesarias al servicio
  bool _hasInvalidInput = false;

  /// Indica si hay audio disponible para el número actual.
  ///
  /// Determina si se debe habilitar o deshabilitar el botón de reproducción
  /// según la disponibilidad de archivos de audio para el número actual.
  bool _isAudioAvailable = false;

  /// Indica si se está reproduciendo audio actualmente.
  ///
  /// Controla:
  /// - El cambio de iconos en el botón de reproducción
  /// - La deshabilitación del botón mientras se reproduce
  /// - La prevención de reproducciones superpuestas
  bool _isPlayingAudio = false;

  /// Almacena el número válido actual ingresado por el usuario.
  ///
  /// Se utiliza para:
  /// - Evitar repetir consultas innecesarias al servicio
  /// - Proporcionar el valor a los métodos que requieren el número
  /// - Validar si ha cambiado la entrada del usuario
  int? _currentNumber;

  /// Indica si el teclado está visible en pantalla.
  ///
  /// Se utiliza para ajustar el diseño y comportamiento de la UI
  /// cuando el teclado aparece o desaparece.
  bool _isKeyboardVisible = false;

  /// Controla el color del borde del campo de entrada para feedback de error.
  ///
  /// Valores:
  /// - `null`: Borde normal (cuando la entrada es válida)
  /// - `Colors.red`: Borde rojo (cuando la entrada es inválida)
  Color? _inputBorderColor;
  /// Define el color de fondo (verde oliva apagado) para los contenedores de texto.
  ///
  /// Color temático específico de la Actividad 5, que se aplica a:
  /// - El contenedor del resultado Namtrik
  /// - Los botones de acción
  /// - Otros elementos visuales de la actividad
  final Color _boxColor = _activity5Color;

  @override
  void initState() {
    super.initState();
    // Registra un listener para detectar cambios en el campo de texto
    _numberController.addListener(_onNumberChanged);
    // Se registra para observar cambios en el ciclo de vida de la app
    // para poder detener el audio cuando la app pasa a segundo plano
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Limpieza para evitar memory leaks
    _numberController.removeListener(_onNumberChanged);
    _numberController.dispose();
    _scrollController.dispose();
    // Detiene cualquier audio en reproducción al salir de la pantalla
    _stopAudioIfPlaying();
    // Deja de observar cambios en el ciclo de vida
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Se llama cuando cambia el estado del ciclo de vida de la aplicación.
  ///
  /// Detecta cuando la app pasa a segundo plano o se inactiva, para
  /// detener automáticamente cualquier audio en reproducción y mejorar
  /// así la experiencia del usuario.
  ///
  /// Casos manejados:
  /// - AppLifecycleState.paused: App en segundo plano
  /// - AppLifecycleState.inactive: App visible pero no interactiva
  /// - AppLifecycleState.detached: App en proceso de terminación
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Stop audio if app goes to background or is inactive
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _stopAudioIfPlaying();
    }
  }

  /// Método auxiliar para detener el audio si se está reproduciendo.
  ///
  /// Verifica primero si hay audio en reproducción para evitar llamadas
  /// innecesarias al servicio. Luego:
  /// 1. Llama al servicio para detener la reproducción
  /// 2. Actualiza el estado de la UI para reflejar que el audio se detuvo
  ///
  /// Este método se utiliza en múltiples puntos:
  /// - Al salir de la pantalla (dispose)
  /// - Cuando la app pasa a segundo plano (didChangeAppLifecycleState)
  /// - Al navegar a otra pantalla (navigateToHome)
  void _stopAudioIfPlaying() {
    if (_isPlayingAudio) {
      _activity5Service.stopAudio();
      if (mounted) {
        setState(() {
          _isPlayingAudio = false;
        });
      }
    }
  }

  /// Navega hacia la pantalla de inicio de la aplicación.
  ///
  /// Implementa una navegación limpia asegurando que:
  /// 1. Se detenga cualquier audio en reproducción
  /// 2. Se retorne a la pantalla inicial (primera ruta)
  ///
  /// Este método se invoca cuando el usuario presiona el botón
  /// de "Inicio" (Home) en la barra de navegación superior.
  ///
  /// [context] El contexto de construcción para la navegación
  void _navigateToHome(BuildContext context) {
    // Stop any playing audio before navigating away
    _stopAudioIfPlaying();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  /// Se llama cada vez que cambia el texto en [_numberController].
  ///
  /// Implementa la lógica central de validación y conversión:
  /// 1. Valida si la entrada está vacía, es 0, o está fuera de rango
  /// 2. Actualiza el estado visual (borde rojo para entrada inválida)
  /// 3. Para entradas válidas, consulta al servicio para obtener:
  ///    - La representación Namtrik del número
  ///    - La disponibilidad de archivos de audio
  /// 4. Actualiza el estado de la UI para reflejar el resultado
  ///
  /// Maneja casos especiales como:
  /// - Entrada vacía: Limpia el resultado
  /// - Entrada "0": Muestra mensaje de error y previene más dígitos
  /// - Número inválido: Muestra mensaje de error con borde rojo
  /// - Errores del servicio: Muestra mensaje de error
  Future<void> _onNumberChanged() async {
    // If the text is empty, reset everything
    if (_numberController.text.isEmpty) {
      setState(() {
        _namtrikResult = '';
        _hasInvalidInput = false;
        _isAudioAvailable = false;
        _currentNumber = null;
        _inputBorderColor = null;
      });
      return;
    }

    final String text = _numberController.text;
    final int? number = int.tryParse(text);

    // Check if the input is "0"
    if (number == 0) {
      setState(() {
        _namtrikResult = 'El número debe estar entre 1 y 9999999';
        _hasInvalidInput = true;
        _isAudioAvailable = false;
        _currentNumber = null;
        _inputBorderColor = Colors.red;
      });

      // If user tries to enter more after "0", revert back to just "0"
      if (text.length > 1) {
        _numberController.text = "0";
        _numberController.selection = TextSelection.fromPosition(
          TextPosition(offset: _numberController.text.length),
        );
      }
      return;
    }

    // If previous input was invalid but now it's valid, reset the flag
    if (_hasInvalidInput && _activity5Service.isValidNumber(number)) {
      setState(() {
        _hasInvalidInput = false;
        _inputBorderColor = null;
      });
    }

    if (_activity5Service.isValidNumber(number)) {
      setState(() {
        _isLoading = true;
        _isAudioAvailable = false;
        _currentNumber = number;
        _inputBorderColor = null;
      });

      try {
        final namtrikValue =
            await _activity5Service.getNamtrikForNumber(number!);

        // Check if audio is available for this number
        final audioFiles =
            await _activity5Service.getAudioFilesForNumber(number);
        final hasAudio = audioFiles.isNotEmpty;

        if (!mounted) return;
        setState(() {
          _namtrikResult = namtrikValue;
          _isLoading = false;
          _isAudioAvailable = hasAudio;
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _namtrikResult = 'Error: $e';
          _isLoading = false;
          _isAudioAvailable = false;
          _currentNumber = null;
        });
      }
    } else if (number != null) {
      setState(() {
        _namtrikResult = 'El número debe estar entre 1 y 9999999';
        _hasInvalidInput = true;
        _isAudioAvailable = false;
        _currentNumber = null;
        _inputBorderColor = Colors.red;
      });
    }
  }

  /// Maneja la acción del botón "Escuchar".
  ///
  /// Reproduce la secuencia de audio para [_currentNumber] usando [_activity5Service].
  /// Actualiza el estado [_isPlayingAudio] durante la reproducción.
  /// Proporciona feedback háptico.
  Future<void> _handleListenPressed() async {
    if (!_isAudioAvailable || _isPlayingAudio || _currentNumber == null) {
      return;
    }

    await FeedbackService().lightHapticFeedback();
    setState(() {
      _isPlayingAudio = true;
    });

    try {
      await _activity5Service.playAudioForNumber(_currentNumber!);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error reproduciendo audio: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPlayingAudio = false;
        });
      }
    }
  }

  /// Maneja la acción del botón "Copiar".
  ///
  /// Copia el número ingresado y su representación Namtrik ([_namtrikResult])
  /// al portapapeles si ambos son válidos. Muestra un [SnackBar] con el resultado.
  /// Proporciona feedback háptico.
  void _handleCopyPressed() async {
    if (_namtrikResult.isNotEmpty &&
        _namtrikResult != 'Resultado del número' &&
        !_namtrikResult.startsWith('El número debe') &&
        !_namtrikResult.startsWith('Error') &&
        _currentNumber != null) {
      await FeedbackService().mediumHapticFeedback();

      // Construct the text to copy
      final String textToCopy =
          'Número: $_currentNumber\nTexto Namtrik: $_namtrikResult';

      Clipboard.setData(ClipboardData(text: textToCopy));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Texto copiado al portapapeles'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      await FeedbackService().heavyHapticFeedback();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay texto válido para copiar'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// Maneja la acción del botón "Compartir".
  ///
  /// Utiliza el plugin `share_plus` para compartir el número ingresado
  /// y su representación Namtrik ([_namtrikResult]) si ambos son válidos.
  /// Proporciona feedback háptico.
  void _handleSharePressed() async {
    if (_namtrikResult.isNotEmpty &&
        _namtrikResult != 'Resultado del número' &&
        !_namtrikResult.startsWith('El número debe') &&
        !_namtrikResult.startsWith('Error') &&
        _currentNumber != null) {
      await FeedbackService().mediumHapticFeedback();

      // Construct the text to share
      final String textToShare =
          'Número: $_currentNumber\nTexto Namtrik: $_namtrikResult';

      // Use share_plus to share the content
      await Share.share(textToShare);
    } else {
      await FeedbackService().heavyHapticFeedback();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay texto válido para compartir'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// Construye la interfaz de usuario de la pantalla de la herramienta de conversión Namtrik.
  ///
  /// Incluye el [AppBar], la descripción, el campo de entrada de número,
  /// el campo de resultado Namtrik, y los botones de acción (Escuchar, Copiar, Compartir).
  /// Ajusta el diseño según si el teclado está visible y el tamaño de la pantalla.
  @override
  Widget build(BuildContext context) {
    // Check if keyboard is visible
    _isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    // Get screen dimensions
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.height < 600;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        // Stop audio when back button is pressed
        _stopAudioIfPlaying();
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          leading: IconButton(
            icon: AppTheme.homeIcon,
            onPressed: () => _navigateToHome(context),
          ),
          title: const Text(
            'Muntsielan namtrikmai yunɵmarɵpik',
            style: AppTheme.activityTitleStyle,
          ),
          backgroundColor: Colors
              .transparent, // Transparente para mostrar el gradiente de fondo
          elevation: 0,          actions: [
            IconButton(
              icon: AppTheme.questionIcon, // Icono de ayuda/información
              onPressed: showHelpBanner,
            ),
          ],
        ),
        // Use resizeToAvoidBottomInset to prevent keyboard from pushing content
        resizeToAvoidBottomInset: false,        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: AppTheme.mainGradient,
              ),
          child: SafeArea(
            // Use bottom: false to allow content to extend behind the keyboard
            bottom: false,
            child: Column(
              children: [
                // Scrollable content area
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          // Hide game description when keyboard is visible on small screens
                          if (!(_isKeyboardVisible && isSmallScreen))
                            Center(
                              child: GameDescriptionWidget(
                                description: ActivityGameDescriptions
                                    .getDescriptionForActivity(5),
                              ),
                            ),
                          SizedBox(
                              height: _isKeyboardVisible && isSmallScreen
                                  ? 10
                                  : 40),
                          const Text(
                            'Muntsik wan yu pɵr',
                            style: TextStyle(
                              color: Colors
                                  .white, // Color blanco para el texto de la pantalla de inicio
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _numberController,
                            style: const TextStyle(
                                color: Colors
                                    .white), // Color blanco para el texto del campo de texto
                            keyboardType: TextInputType.number,
                            cursorColor: Colors.white,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(7),
                              // Custom input formatter to handle "0" input
                              TextInputFormatter.withFunction(
                                  (oldValue, newValue) {
                                // If we have an invalid input (like "0") and user is trying to add more digits
                                if (_hasInvalidInput &&
                                    newValue.text.length >
                                        oldValue.text.length) {
                                  return oldValue; // Prevent the change
                                }
                                return newValue; // Allow the change
                              }),
                            ],
                            onTap: () {
                              // When the text field is tapped, scroll to ensure it's visible
                              Future.delayed(const Duration(milliseconds: 300),
                                  () {
                                if (_scrollController.hasClients) {
                                  _scrollController.animateTo(
                                    _scrollController.position.maxScrollExtent,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOut,
                                  );
                                }
                              });
                            },
                            onChanged: (_) {
                              if (_inputBorderColor != null) {
                                setState(() {
                                  _inputBorderColor = null;
                                });
                              }
                            },
                            decoration: InputDecoration(
                              hintText: 'Digita el número',
                              hintStyle: TextStyle(
                                // Color gris texto de sugerencia en el campo de digitar número
                                color: Colors.grey[500],
                                fontSize: 16,
                              ),
                              filled: true,
                              fillColor: _boxColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: _inputBorderColor ??
                                      const Color(0xFF7E7745),
                                  width: 4,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color:
                                      _inputBorderColor ?? Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),
                          // Texto Namtrikmai del contenedor de texto del número
                          const SizedBox(height: 20),
                          const Text(
                            'Namtrikmai',
                            style: TextStyle(
                              color: Colors
                                  .white, // Color blanco para el texto Namtrikmai del contenedor de texto del número
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            // Ajuste de altura del contenedor de texto del número
                            constraints: BoxConstraints(
                              minHeight: _isKeyboardVisible && isSmallScreen
                                  ? 80
                                  : 100,
                            ),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _boxColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: _isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors
                                          .white, // Color blanco para el indicador de carga en la pantalla de inicio de la actividad
                                    ),
                                  )
                                : Text(
                                    _namtrikResult.isEmpty
                                        ? 'Resultado del número'
                                        : _namtrikResult,
                                    style: TextStyle(
                                      color: _namtrikResult.isEmpty
                                          ? Colors.grey[
                                              500] // Color gris texto del contenedor resultado vacío del número
                                          : Colors
                                              .white, // Color blanco texto del contenedor resultado del número
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                          // Ajuste de espaciado del contenedor de texto del número
                          SizedBox(
                              height: _isKeyboardVisible && isSmallScreen
                                  ? 16
                                  : 24),
                          // Fila de botones de acción
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Listen button
                              _buildActionButton(
                                icon: Icons.volume_up,
                                label: 'Escuchar',
                                onPressed: _isAudioAvailable
                                    ? _handleListenPressed
                                    : null,
                                isActive: _isAudioAvailable,
                                isPlaying: _isPlayingAudio,
                                isSmallScreen:
                                    _isKeyboardVisible && isSmallScreen,
                              ),
                              // Copy button
                              _buildActionButton(
                                icon: Icons.content_copy,
                                label: 'Copiar',
                                onPressed: _handleCopyPressed,
                                isActive: true,
                                isSmallScreen:
                                    _isKeyboardVisible && isSmallScreen,
                              ),
                              // Share button
                              _buildActionButton(
                                icon: Icons.share,
                                label: 'Compartir',
                                onPressed: _handleSharePressed,
                                isActive: true,
                                isSmallScreen:
                                    _isKeyboardVisible && isSmallScreen,
                              ),
                            ],
                          ),
                          // Add extra space at the bottom when keyboard is visible
                          SizedBox(
                              height: _isKeyboardVisible
                                  ? MediaQuery.of(context).viewInsets.bottom
                                  : 20),                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
            // Banner de ayuda usando el widget reutilizable
            HelpBannerWidget(
              isVisible: isHelpBannerVisible,
              onClose: hideHelpBanner,
              headerColor: _activity5Color,
              content: ActivityInstructions.getInstructionForActivity(5),
            ),
          ],
        ),
      ),
    );
  }

  /// Método auxiliar para construir los botones de acción (Escuchar, Copiar, Compartir)
  /// con un estilo consistente.
  ///
  /// Ajusta el tamaño y estilo según [isSmallScreen] (cuando el teclado está visible).
  /// Cambia la apariencia del botón "Escuchar" si [isPlaying] es true.
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    bool isActive = true,
    bool isPlaying = false,
    bool isSmallScreen = false,
  }) {
    // Colores para los botones activos e inactivos
    final Color backgroundColor = isActive
        ? const Color(
            0xFF7E7745) // Color para botones activos en la pantalla de inicio
        : const Color(0xFF7E7745)
            .withValues(alpha: 128, red: 255, green: 193, blue: 7); // 50% alpha

    final Color iconColor = isActive
        ? Colors
            .white // Color blanco para botones activos en la pantalla de inicio
        : Colors.white.withValues(
            alpha: 128, red: 255, green: 255, blue: 255); // 50% alpha

    // Especial color de los botones de reproducción (playing)
    final Color playingColor = isPlaying
        ? const Color(
            0xFFDAA520) // Color orion - verde oliva apagado para botones de reproducción
        : iconColor;

    // Ajustes de tamaño y estilo según el tamaño de la pantalla
    final double buttonSize = isSmallScreen ? 40.0 : 56.0;
    final double iconSize = isSmallScreen ? 18.0 : 24.0;
    final double fontSize = isSmallScreen ? 10.0 : 12.0;

    return Semantics(
      button: true,
      enabled: isActive,
      label: label + (isPlaying ? ' (reproduciendo)' : ''),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: EdgeInsets.all(isSmallScreen ? 10 : 16),
              backgroundColor: backgroundColor,
              minimumSize: Size(buttonSize, buttonSize),
            ),
            child: Icon(
              icon,
              size: iconSize,
              color: isPlaying
                  ? playingColor
                  : iconColor, // Use playing color if playing
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white, // Color blanco para el texto de los botones
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}
