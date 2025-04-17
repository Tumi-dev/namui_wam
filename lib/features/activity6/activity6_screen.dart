import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:namui_wam/core/constants/activity_descriptions.dart';
import 'package:namui_wam/core/di/service_locator.dart';
import 'package:namui_wam/core/themes/app_theme.dart';
import 'package:namui_wam/core/widgets/game_description_widget.dart';
import 'package:namui_wam/features/activity6/services/activity6_service.dart';

class Activity6Screen extends StatefulWidget {
  const Activity6Screen({super.key});

  @override
  State<Activity6Screen> createState() => _Activity6ScreenState();
}

class _Activity6ScreenState extends State<Activity6Screen>
    with WidgetsBindingObserver {
  final TextEditingController _numberController = TextEditingController();
  final Activity6Service _activity6Service = getIt<Activity6Service>();
  final ScrollController _scrollController = ScrollController();
  String _namtrikResult = '';
  bool _isLoading = false;
  bool _hasInvalidInput = false;
  bool _isAudioAvailable = false;
  bool _isPlayingAudio = false;
  int? _currentNumber;
  bool _isKeyboardVisible = false;
  Color? _inputBorderColor;

  // Define el color de fondo amarillo dorado del contenedor de texto
  final Color _boxColor = const Color(0xFFFF7043);

  @override
  void initState() {
    super.initState();
    _numberController.addListener(_onNumberChanged);
    // Register for lifecycle events
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _numberController.removeListener(_onNumberChanged);
    _numberController.dispose();
    _scrollController.dispose();
    // Stop any playing audio when leaving the screen
    _stopAudioIfPlaying();
    // Unregister from lifecycle events
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Stop audio if app goes to background or is inactive
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _stopAudioIfPlaying();
    }
  }

  // Helper method to stop audio if it's playing
  void _stopAudioIfPlaying() {
    if (_isPlayingAudio) {
      _activity6Service.stopAudio();
      if (mounted) {
        setState(() {
          _isPlayingAudio = false;
        });
      }
    }
  }

  void _navigateToHome(BuildContext context) {
    // Stop any playing audio before navigating away
    _stopAudioIfPlaying();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

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
    if (_hasInvalidInput && _activity6Service.isValidNumber(number)) {
      setState(() {
        _hasInvalidInput = false;
        _inputBorderColor = null;
      });
    }

    if (_activity6Service.isValidNumber(number)) {
      setState(() {
        _isLoading = true;
        _isAudioAvailable = false;
        _currentNumber = number;
        _inputBorderColor = null;
      });

      try {
        final namtrikValue =
            await _activity6Service.getNamtrikForNumber(number!);

        // Check if audio is available for this number
        final audioFiles =
            await _activity6Service.getAudioFilesForNumber(number);
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

  // Function to handle the listen button press
  Future<void> _handleListenPressed() async {
    if (!_isAudioAvailable || _isPlayingAudio || _currentNumber == null) {
      return;
    }

    setState(() {
      _isPlayingAudio = true;
    });

    try {
      await _activity6Service.playAudioForNumber(_currentNumber!);
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

  // Function to handle the copy button press
  void _handleCopyPressed() {
    if (_namtrikResult.isNotEmpty &&
        _namtrikResult != 'Resultado del número' &&
        !_namtrikResult.startsWith('El número debe') &&
        !_namtrikResult.startsWith('Error')) {
      Clipboard.setData(ClipboardData(text: _namtrikResult));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Texto copiado al portapapeles'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay texto válido para copiar'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Function to handle the share button press
  void _handleSharePressed() {
    if (_namtrikResult.isNotEmpty &&
        _namtrikResult != 'Resultado del número' &&
        !_namtrikResult.startsWith('El número debe') &&
        !_namtrikResult.startsWith('Error')) {
      // This would typically use a share plugin, but for now we'll just show a message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Compartiendo: $_namtrikResult'),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay texto válido para compartir'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

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
          elevation: 0,
        ),
        // Use resizeToAvoidBottomInset to prevent keyboard from pushing content
        resizeToAvoidBottomInset: false,
        body: Container(
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
                                    .getDescriptionForActivity(3),
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
                                color: Colors.grey[700],
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
                                      const Color(0xFFFFA500),
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
                                              700] // Color gris texto del contenedor resultado vacío del número
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
                                  : 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build action buttons with consistent styling
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
            0xFFFF7043) // Color para botones activos en la pantalla de inicio
        : const Color(0xFFFF7043)
            .withValues(alpha: 128, red: 255, green: 193, blue: 7); // 50% alpha

    final Color iconColor = isActive
        ? Colors
            .white // Color blanco para botones activos en la pantalla de inicio
        : Colors.white.withValues(
            alpha: 128, red: 255, green: 255, blue: 255); // 50% alpha

    // Especial color de los botones de reproducción (playing)
    final Color playingColor = isPlaying
        ? const Color(
            0xFFFFA500) // Color verde fresco para botones de reproducción
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
