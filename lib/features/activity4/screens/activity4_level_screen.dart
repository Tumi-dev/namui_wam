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
/// de la Actividad 4: "Anwan ashipelɵ kɵkun" (Aprendamos a contar el dinero).
/// {@endtemplate}
class Activity4LevelScreen extends ScrollableLevelScreen {
  /// {@macro activity4_level_screen}
  const Activity4LevelScreen({
    Key? key,
    required LevelModel level,
  }) : super(level: level, activityNumber: 4);

  @override
  State<Activity4LevelScreen> createState() => _Activity4LevelScreenState();
}

class _Activity4LevelScreenState
    extends ScrollableLevelScreenState<Activity4LevelScreen> {
  //==============================================================================
  // Servicios y Estado General Compartido
  //==============================================================================
  late Activity4Service _activity4Service;
  final SoundService _soundService = GetIt.instance<SoundService>();
  bool _isLoading = true;

  /// Utilizado para el control de flujo y prevenir acciones adicionales
  /// después de que el usuario ha seleccionado correctamente la respuesta.
  /// Usado por Nivel 2 y Nivel 3 (y potencialmente Nivel 4 si se adapta).
  bool isCorrectAnswerSelected = false;

  /// Lista de modelos de dinero (billetes/monedas).
  /// Usado por Nivel 1 (para mostrar todas las denominaciones) y
  /// Nivel 3 (para mostrar un conjunto específico que debe ser nombrado).
  List<NamtrikMoneyModel> _moneyItems = [];

  //================ END OF SERVICIOS Y ESTADO GENERAL COMPARTIDO ================

  //==============================================================================
  // Nivel 1: Anwan ashipelө kөkun (Conozcamos el dinero)
  //==============================================================================
  
  // --- Variables Nivel 1 ---
  /// Índice del elemento actual en PageView (Nivel 1).
  int _currentIndex = 0;

  /// Controlador para el PageView del Nivel 1.
  final PageController _pageController = PageController();

  /// Mapa para rastrear qué imagen (primera o segunda) se muestra para cada item en Nivel 1.
  Map<int, bool> _showingSecondImage = {};

  /// Indica si se está reproduciendo un audio actualmente (Nivel 1).
  bool _isPlayingAudio = false;

  // --- Métodos Nivel 1 ---
  /// Alterna la imagen mostrada para un item de dinero en Nivel 1.
  void _toggleImage(int index) {
    if (_moneyItems[index].moneyImages.length < 2) return;
          setState(() {
      _showingSecondImage[index] = !(_showingSecondImage[index] ?? false);
    });
  }

  /// Obtiene la ruta de la imagen actual (primera o segunda) para un item en Nivel 1.
  String _getCurrentImage(int index) {
    if (_moneyItems[index].moneyImages.isEmpty) return '';
    if (_showingSecondImage[index] == true && _moneyItems[index].moneyImages.length > 1) {
      return _moneyItems[index].moneyImages[1];
      } else {
      return _moneyItems[index].moneyImages[0];
    }
  }

  /// Reproduce el audio correspondiente al valor Namtrik del item actual en Nivel 1.
  Future<void> _playMoneyAudio() async {
    if (_currentIndex >= _moneyItems.length) return;
    setState(() { _isPlayingAudio = true; });
    try {
      final audiosNamtrik = _moneyItems[_currentIndex].audiosNamtrik;
      await _activity4Service.playAudioForMoneyNamtrik(audiosNamtrik);
    } finally {
      if (mounted) {
        setState(() { _isPlayingAudio = false; });
      }
    }
  }

  /// Construye el widget que muestra la imagen del dinero para el Nivel 1 (en el PageView).
  Widget _buildMoneyImage(int index) {
    String imageName = _getCurrentImage(index);
    return GestureDetector(
      onTap: () => _toggleImage(index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        padding: const EdgeInsets.all(10),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(_activity4Service.getMoneyImagePath(imageName), fit: BoxFit.contain),
            Positioned(
              bottom: 5, right: 5,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.touch_app, color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widget Constructor UI Nivel 1 ---
  /// Construye el widget principal para el Nivel 1.
  Widget _buildLevel1UI() {
    if (_moneyItems.isEmpty && !_isLoading) { // Mostrar mensaje si no hay datos y no está cargando
      return const Center(child: Text('No se encontraron datos para el Nivel 1', style: TextStyle(color: Colors.white, fontSize: 18)));
    }
    if (_isLoading) { // Asegurarse de que _isLoading para el Nivel 1 también se maneje aquí
        return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;
    final double imageContainerHeight = isLandscape ? screenSize.height * 0.4 : screenSize.height * 0.35;

    return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
        InfoBar(remainingAttempts: remainingAttempts, margin: const EdgeInsets.only(bottom: 16)),
        Container(
          height: imageContainerHeight,
          constraints: BoxConstraints(maxHeight: isLandscape ? 200 : 250),
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) { setState(() { _currentIndex = index; }); },
            itemCount: _moneyItems.length,
            itemBuilder: (context, index) => _buildMoneyImage(index),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _moneyItems.asMap().entries.map((entry) {
            return Container(
              width: 10.0, height: 10.0, margin: const EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(shape: BoxShape.circle, color: _currentIndex == entry.key ? Colors.white : Colors.white.withOpacity(0.4)),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        if (_currentIndex < _moneyItems.length)
          Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFFCD5C5C), borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: const Color(0xFFCD5C5C), blurRadius: 8, offset: const Offset(0, 4))],
                ),
                child: Text(
                  _moneyItems[_currentIndex].moneyNamtrik,
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
                ElevatedButton(
                onPressed: _isPlayingAudio ? null : _playMoneyAudio,
                  style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFCD5C5C), foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  disabledBackgroundColor: const Color(0xFFCD5C5C).withOpacity(0.7),
                  disabledForegroundColor: Colors.white.withOpacity(0.7),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_isPlayingAudio ? Icons.volume_up : Icons.volume_down, size: 20),
                    const SizedBox(width: 8),
                    const Text('Escuchar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              SizedBox(height: isLandscape ? 20 : 40),
            ],
          ),
      ],
    );
  }

  //================ END OF NIVEL 1 SECTION ======================================

  //==============================================================================
  // Nivel 2: Mayaweik kөtash (¿Cuál es el precio del articulo?)
  //==============================================================================

  // --- Variables Nivel 2 ---
  /// El artículo actual a mostrar en el Nivel 2.
  NamtrikArticleModel? _currentArticle;

  /// Lista de opciones (cada opción es una lista de billetes/monedas) para el Nivel 2.
  List<List<NamtrikMoneyModel>> _moneyOptions = [];

  /// Índice de la opción correcta en [_moneyOptions] (Nivel 2).
  int _correctOptionIndex = -1;

  /// Índice de la opción seleccionada por el usuario (Nivel 2).
  int? _selectedOptionIndex;

  /// Indica si las opciones para el Nivel 2 ya se generaron.
  bool _optionsGenerated = false;

  /// Controla si se debe mostrar feedback (colores/iconos) en las opciones del Nivel 2.
  bool _showFeedback = false;

  // --- Métodos Nivel 2 ---
  /// Maneja la selección de una opción de conjunto de dinero en el Nivel 2.
  void _handleOptionSelection(int index) async {
    if (_showFeedback) return;
    setState(() {
      _selectedOptionIndex = index;
      _showFeedback = true;
      if (index != _correctOptionIndex) {
        decrementAttempts();
      } else {
        isCorrectAnswerSelected = true; // Usado por _handleLevelComplete
      }
    });

    if (index != _correctOptionIndex) {
      _soundService.playIncorrectSound();
      await FeedbackService().mediumHapticFeedback();
    } else {
      _soundService.playCorrectSound();
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

  /// Reinicia el estado del Nivel 2 para presentar un nuevo artículo y opciones.
  Future<void> _resetLevel2() async {
    setState(() {
      _isLoading = true; // Mostrar indicador de carga general
      _selectedOptionIndex = null;
      _optionsGenerated = false;
      isCorrectAnswerSelected = false;
      if (isCorrectAnswerSelected) { // Esta condición nunca será cierta aquí, pero se mantiene por si acaso
        resetAttempts();
      }
    });

    // Cargar nuevo artículo y opciones (esto podría tomar tiempo)
    _currentArticle = await _activity4Service.getRandomArticle();
    if (_currentArticle != null) {
      _moneyOptions = await _activity4Service.generateOptionsForLevel2(_currentArticle!);
      _correctOptionIndex = _activity4Service.findCorrectOptionIndex(_moneyOptions, _currentArticle!.numberMoneyImages);
      _optionsGenerated = true;
    }

      if (mounted) {
      setState(() { _isLoading = false; }); // Ocultar indicador de carga general
    }
  }

  /// Construye el widget para una opción de conjunto de dinero en el Nivel 2.
  Widget _buildMoneyOption(List<NamtrikMoneyModel> option, int optionIndex) {
    Color borderColor = const Color(0xFFCD5C5C);
    Color bgColor = Colors.transparent;
    IconData? feedbackIcon;

    if (_showFeedback && _selectedOptionIndex == optionIndex) {
      if (optionIndex == _correctOptionIndex) {
        borderColor = const Color(0xFF00FF00); bgColor = const Color(0xFF00FF00).withOpacity(0.2); feedbackIcon = Icons.check_circle;
      } else {
        borderColor = const Color(0xFFFF0000); bgColor = const Color(0xFFFF0000).withOpacity(0.2); feedbackIcon = Icons.cancel;
      }
    } else if (_selectedOptionIndex == optionIndex) {
      borderColor = Colors.white; bgColor = Colors.white.withOpacity(0.1);
    }

    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;
    final maxContainerWidth = isLandscape ? 450.0 : screenSize.width * 0.9;
    final int itemCount = option.length;
    final double imageSize = isLandscape ? (itemCount <= 2 ? 100.0 : itemCount <= 4 ? 90.0 : 80.0) : (itemCount <= 2 ? 110.0 : itemCount <= 4 ? 100.0 : 90.0);

    return Center(
      child: GestureDetector(
        onTap: () { if (_selectedOptionIndex == null || !_showFeedback) { _handleOptionSelection(optionIndex); }},
        child: Container(
          constraints: BoxConstraints(maxWidth: maxContainerWidth),
          width: double.infinity, margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(border: Border.all(color: borderColor, width: 2), borderRadius: BorderRadius.circular(12), color: bgColor),
          child: Column(children: [
              Wrap(
              alignment: WrapAlignment.center, spacing: 8, runSpacing: 8,
              children: option.map((item) => Container(
                width: imageSize, height: imageSize,
                child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset(_activity4Service.getMoneyImagePath(item.moneyImages[0]), fit: BoxFit.contain)),
              )).toList(),
            ),
            if (_showFeedback && _selectedOptionIndex == optionIndex && feedbackIcon != null)
              Padding(padding: const EdgeInsets.only(top: 16), child: Icon(feedbackIcon, color: optionIndex == _correctOptionIndex ? const Color(0xFF00FF00) : const Color(0xFFFF0000), size: 32)),
          ]),
        ),
      ),
    );
  }
  
  /// Muestra un diálogo con la imagen ampliada del artículo en el Nivel 2.
  void _showEnlargedImage(String imagePath) {
    showDialog(
      context: context, barrierColor: Colors.black.withOpacity(0.85),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black.withOpacity(0.7), insetPadding: const EdgeInsets.all(20),
          child: Stack(alignment: Alignment.center, children: [
            Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9, maxHeight: MediaQuery.of(context).size.height * 0.7),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.1), spreadRadius: 2, blurRadius: 5)]),
              child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.asset(_activity4Service.getArticleImagePath(imagePath), fit: BoxFit.contain)),
            ),
            Positioned(top: 0, right: 0, child: InkWell(
              onTap: () { Navigator.of(context).pop(); },
              child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), shape: BoxShape.circle), child: const Icon(Icons.close, color: Colors.white, size: 24)),
            )),
          ]),
        );
      },
    );
  }

  // --- Widget Constructor UI Nivel 2 ---
  /// Construye el widget principal para el Nivel 2.
  Widget _buildLevel2UI() {
    if (_currentArticle == null && !_isLoading) { // Similar al Nivel 1, mostrar mensaje si no hay datos y no está cargando
      return const Center(child: Text('No se encontró ningún artículo para el Nivel 2', style: TextStyle(color: Colors.white, fontSize: 18)));
    }
     if (_isLoading) {
        return const Center(child: CircularProgressIndicator(color: Colors.white));
    }


    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;
    final maxContainerWidth = isLandscape ? 450.0 : screenSize.width * 0.9;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InfoBar(remainingAttempts: remainingAttempts, margin: const EdgeInsets.only(bottom: 16)),
          Center(child: Container(
            constraints: BoxConstraints(maxWidth: maxContainerWidth, maxHeight: isLandscape ? screenSize.height * 0.4 : screenSize.height * 0.35),
            width: double.infinity, padding: const EdgeInsets.all(1),
            child: Stack(alignment: Alignment.center, children: [
              Image.asset(_activity4Service.getArticleImagePath(_currentArticle!.imageArticle), fit: BoxFit.contain),
              Positioned(bottom: 10, right: 10, child: InkWell(
                onTap: () => _showEnlargedImage(_currentArticle!.imageArticle),
                child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), shape: BoxShape.circle), child: const Icon(Icons.zoom_in, color: Colors.white, size: 28)),
              )),
            ]),
          )),
          const SizedBox(height: 16),
          Center(child: Container(
            constraints: BoxConstraints(maxWidth: maxContainerWidth), width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            decoration: BoxDecoration(color: const Color(0xFFCD5C5C), borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: const Color(0xFFCD5C5C), blurRadius: 8, offset: const Offset(0, 4))]),
            child: Text(_currentArticle!.namePriceNamtrik, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          )),
          const SizedBox(height: 20),
          if (_moneyOptions.isNotEmpty)
            ..._moneyOptions.asMap().entries.map((entry) => _buildMoneyOption(entry.value, entry.key)).toList(),
        ],
      ),
    );
  }

  //================ END OF NIVEL 2 SECTION ======================================

  //==============================================================================
  // Nivel 3: An mayankөtash (¿Cuánto dinero hay?)
  //==============================================================================

  // --- Variables Nivel 3 ---
  // _moneyItems es compartido con Nivel 1, se declara arriba.

  /// El nombre Namtrik correcto para el conjunto de dinero actual (Nivel 3).
  String _correctNamtrikName = '';

  /// Lista de nombres Namtrik incorrectos para generar opciones (Nivel 3).
  List<String> _incorrectNamtrikNames = [];

  /// Lista de nombres Namtrik (correcto + incorrectos) desordenados para mostrar como opciones (Nivel 3).
  List<String> _shuffledNamtrikNames = [];

  /// Índice del nombre correcto en [_shuffledNamtrikNames] (Nivel 3).
  int _correctNameIndex = -1;

  /// Índice del nombre seleccionado por el usuario (Nivel 3).
  int? _selectedNameIndex;

  /// Controla si se debe mostrar feedback (colores/iconos) en las opciones de nombres (Nivel 3).
  bool _showNameFeedback = false;

  // --- Métodos Nivel 3 ---
  /// Maneja la selección de una opción de nombre Namtrik en el Nivel 3.
  void _handleNameSelection(int index) async {
    if (_showNameFeedback) return;
    setState(() {
      _selectedNameIndex = index; _showNameFeedback = true;
      if (index != _correctNameIndex) { decrementAttempts(); } else { isCorrectAnswerSelected = true; } // Usado por _handleLevelComplete
    });

    if (index != _correctNameIndex) {
      _soundService.playIncorrectSound(); await FeedbackService().mediumHapticFeedback();
                } else {
      _soundService.playCorrectSound(); await FeedbackService().lightHapticFeedback();
    }

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showNameFeedback = false;
          if (index == _correctNameIndex) {
            _handleLevelComplete();
          } else {
            if (remainingAttempts <= 0) { _handleOutOfAttempts(); } else { _resetLevel3(); }
          }
        });
      }
    });
  }

  /// Reinicia el estado del Nivel 3 para presentar un nuevo conjunto de dinero y opciones de nombres.
  Future<void> _resetLevel3() async {
    setState(() { _isLoading = true; _selectedNameIndex = null; isCorrectAnswerSelected = false; });
    // Cargar nuevos datos para Nivel 3
    final syncData = await _activity4Service.getSynchronizedLevel3Data();
    _moneyItems = List<NamtrikMoneyModel>.from(syncData['moneyItems']);
    _correctNamtrikName = syncData['correctName'];
    _incorrectNamtrikNames = List<String>.from(syncData['incorrectNames']);
    _shuffledNamtrikNames = [_correctNamtrikName, ..._incorrectNamtrikNames];
    _shuffledNamtrikNames.shuffle();
    _correctNameIndex = _shuffledNamtrikNames.indexOf(_correctNamtrikName);
    if (mounted) { setState(() { _isLoading = false; });}
  }
  
  /// Construye los 4 recuadros interactivos para las opciones de nombres en Nivel 3.
  List<Widget> _buildEmptyBoxes(bool isLandscape) {
    List<Widget> boxes = [];
    final screenWidth = MediaQuery.of(context).size.width;
    final boxWidth = isLandscape ? 450.0 : screenWidth - 32;

    for (int i = 0; i < 4; i++) {
      Color borderColor = Colors.transparent; Color bgColor = const Color(0xFFCD5C5C); IconData? feedbackIcon;
      if (_showNameFeedback && _selectedNameIndex == i) {
        if (i == _correctNameIndex) {
          borderColor = const Color(0xFF00FF00); bgColor = const Color(0xFF00FF00).withOpacity(0.2); feedbackIcon = Icons.check_circle;
        } else {
          borderColor = const Color(0xFFFF0000); bgColor = const Color(0xFFFF0000).withOpacity(0.2); feedbackIcon = Icons.cancel;
        }
      } else if (_selectedNameIndex == i) {
        borderColor = Colors.white; bgColor = Colors.white.withOpacity(0.1);
      }
      boxes.add(Center(child: GestureDetector(
        onTap: () { if (_selectedNameIndex == null || !_showNameFeedback) { _handleNameSelection(i); }},
        child: Container(
          width: boxWidth, margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor, width: 1.5)),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(child: Text(
              _shuffledNamtrikNames.isNotEmpty && i < _shuffledNamtrikNames.length ? _shuffledNamtrikNames[i] : '',
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500), textAlign: TextAlign.center,
            )),
            if (_showNameFeedback && _selectedNameIndex == i && feedbackIcon != null)
              Icon(feedbackIcon, color: i == _correctNameIndex ? Colors.green : Colors.red, size: 24),
          ]),
        ),
      )));
    }
    return boxes;
  }

  // --- Widget Constructor UI Nivel 3 ---
  /// Construye el widget principal para el Nivel 3.
  Widget _buildLevel3UI() {
    if (_moneyItems.isEmpty && !_isLoading) {
      return const Center(child: Text('No se encontraron datos para el Nivel 3', style: TextStyle(color: Colors.white, fontSize: 18)));
    }
     if (_isLoading) {
        return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
      children: [
          InfoBar(remainingAttempts: remainingAttempts, margin: const EdgeInsets.only(bottom: 16)),
        Container(
            width: double.infinity, padding: const EdgeInsets.all(16), margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFCD5C5C), width: 1)),
            child: LayoutBuilder(builder: (context, constraints) {
              final double containerWidth = constraints.maxWidth;
              final int crossAxisCount = isLandscape && _moneyItems.isNotEmpty ? _moneyItems.length : 2; // Evitar división por cero si _moneyItems está vacío
              const double spacing = 12;
              double itemWidth = crossAxisCount > 0 ? (isLandscape ? (containerWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount : (containerWidth - spacing) / 2) : containerWidth;
              if(itemWidth <=0) itemWidth = containerWidth / 2; // Fallback por si acaso
              final double itemHeight = itemWidth * 0.6;
              return Wrap(
                spacing: spacing, runSpacing: spacing, alignment: WrapAlignment.center,
                children: _moneyItems.map((item) => Container(
                  width: itemWidth, height: itemHeight,
                  child: GestureDetector(child: Stack(alignment: Alignment.center, children: [
                    Image.asset(_activity4Service.getMoneyImagePath(item.moneyImages[0]), fit: BoxFit.contain),
                  ])),
                )).toList(),
              );
            }),
          ),
          const SizedBox(height: 24),
          ..._buildEmptyBoxes(isLandscape),
        ],
      ),
    );
  }
  
  //================ END OF NIVEL 3 SECTION ======================================

  //==============================================================================
  // Nivel 4: An mayan kөtasha pөnsrө (Coloca la cantidad correcta de dinero)
  //==============================================================================
  
  // --- Variables Nivel 4 ---
  bool _level4DataLoaded = false;
  List<String> _level4NamtrikNames = [];
  String _currentLevel4NamtrikName = '';
  bool _moneyImagesLoaded = false; // Específico para las imágenes de la cuadrícula del Nivel 4
  List<String> _level4MoneyImagePaths = [];
  int _currentTotalValue = 0;
  int _targetTotalValue = 0;
  /// Lista que contiene todas las combinaciones de billetes/monedas válidas para el objetivo actual.
  List<List<int>> _validCombinations = [];
  /// Mapa que asocia el índice de un billete/moneda en [_level4MoneyImagePaths] con su valor numérico (Nivel 4).
  Map<int, int> _numberIndexToValue = {};
  
  // --- Variables para el nuevo sistema de validación manual ---
  bool _showLevel4Feedback = false;
  bool _isCorrectLevel4Answer = false;
  bool _hasEarnedPointsLevel4 = false;
  /// Lista de valores seleccionados para mostrar en el nuevo recuadro
  List<Map<String, dynamic>> _selectedMoneyValues = [];
  /// Último índice seleccionado para la lógica de selección única
  int? _lastSelectedIndex;

  // --- Métodos Nivel 4 ---
  /// Formatea un número con separadores de miles y símbolo de peso
  String _formatMoneyValue(int value) {
    if (value == 0) return '';
    final formatted = value.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match match) => '${match[1]}.'
    );
    return '\$$formatted';
  }

  /// Maneja el tap en una imagen de dinero para el Nivel 4.
  void _handleMoneyImageTap(int index) {
    if (_showLevel4Feedback) return;
    
    final moneyNumber = index + 1;
    final valueToAdd = _numberIndexToValue[moneyNumber] ?? 0;
    
    setState(() {
      // Limpiar selección anterior y agregar la nueva
      _lastSelectedIndex = index;
      
      // Agregar el valor a la lista de seleccionados
      _selectedMoneyValues.add({
        'index': index,
        'moneyNumber': moneyNumber,
        'value': valueToAdd,
        'imagePath': _level4MoneyImagePaths[index],
      });
      
      // Actualizar el total
      _currentTotalValue += valueToAdd;
    });
  }

  /// Elimina un valor de la lista de seleccionados
  void _removeSelectedValue(int index) {
    if (_showLevel4Feedback) return;
    
    setState(() {
      final removedValue = _selectedMoneyValues[index];
      _currentTotalValue -= removedValue['value'] as int;
      _selectedMoneyValues.removeAt(index);
      
      // Si se eliminó el último valor seleccionado, limpiar la selección en la cuadrícula
      if (_selectedMoneyValues.isEmpty) {
        _lastSelectedIndex = null;
      } else {
        // Seleccionar el último valor restante
        final lastValue = _selectedMoneyValues.last;
        _lastSelectedIndex = lastValue['index'] as int;
      }
    });
  }

  /// Valida la respuesta del usuario
  void _validateAnswer() {
    if (_showLevel4Feedback || _selectedMoneyValues.isEmpty) return;
    
    setState(() {
      if (_currentTotalValue > _targetTotalValue) {
        _showLevel4Feedback = true;
        _isCorrectLevel4Answer = false;
        _soundService.playIncorrectSound();
        _activity4Service.playAlertAudio('valor_excedido');
        decrementAttempts();
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _showLevel4Feedback = false;
              if (remainingAttempts <= 0) {
                _handleOutOfAttempts();
              } else {
                _resetLevel4Selection();
              }
            });
          }
        });
      } else if (_currentTotalValue == _targetTotalValue) {
        // Verificar si la combinación es correcta
        bool hasCorrectCombination = _checkCorrectCombination();
        
        _showLevel4Feedback = true;
        _isCorrectLevel4Answer = hasCorrectCombination;
        
        if (hasCorrectCombination) {
          _soundService.playCorrectSound();
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              _handleLevel4Completion(true);
            }
          });
        } else {
          _soundService.playIncorrectSound();
          _activity4Service.playAlertAudio('combinacion_incorrecta');
          decrementAttempts();
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                _showLevel4Feedback = false;
                if (remainingAttempts <= 0) {
                  _handleOutOfAttempts();
                } else {
                  _resetLevel4Selection();
                }
              });
            }
          });
        }
      } else {
        // Valor menor al objetivo
        _showLevel4Feedback = true;
        _isCorrectLevel4Answer = false;
        _soundService.playIncorrectSound();
        _activity4Service.playAlertAudio('valor_insuficiente');
        decrementAttempts();
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _showLevel4Feedback = false;
              if (remainingAttempts <= 0) {
                _handleOutOfAttempts();
              } else {
                _resetLevel4Selection();
              }
            });
          }
        });
      }
    });
  }

  /// Verifica si la combinación seleccionada es correcta
  bool _checkCorrectCombination() {
    // 1. Obtener la frecuencia de la selección del usuario.
    Map<int, int> userSelectionFrequency = {};
    for (var selectedValue in _selectedMoneyValues) {
      final moneyNumber = selectedValue['moneyNumber'] as int;
      userSelectionFrequency[moneyNumber] = (userSelectionFrequency[moneyNumber] ?? 0) + 1;
    }

    // 2. Iterar a través de cada combinación válida.
    for (var validCombination in _validCombinations) {
      Map<int, int> targetFrequency = {};
      // 2a. Calcular la frecuencia de la combinación válida actual.
      for (int number in validCombination) {
        targetFrequency[number] = (targetFrequency[number] ?? 0) + 1;
      }

      // 2b. Comparar las frecuencias (tamaño y contenido).
      if (userSelectionFrequency.length == targetFrequency.length) {
        bool isMatch = true;
        for (var key in userSelectionFrequency.keys) {
          if (userSelectionFrequency[key] != targetFrequency[key]) {
            isMatch = false;
            break; // No coincide, pasar a la siguiente combinación válida.
          }
        }
        if (isMatch) {
          return true; // Encontramos una coincidencia.
        }
      }
    }

    // 3. Si no se encontró ninguna coincidencia después de verificar todas las combinaciones.
    return false;
  }

  /// Resetea la selección del nivel 4
  void _resetLevel4Selection() {
    _selectedMoneyValues = [];
    _currentTotalValue = 0;
    _lastSelectedIndex = null;
  }

  /// Selecciona aleatoriamente un nombre Namtrik para el Nivel 4 y carga sus datos.
  void _selectRandomLevel4Name() {
    if (_level4NamtrikNames.isNotEmpty) {
      setState(() {
        _resetLevel4Selection();
        _showLevel4Feedback = false;
        _isCorrectLevel4Answer = false;
        _hasEarnedPointsLevel4 = false;
        final randomIndex = Random().nextInt(_level4NamtrikNames.length);
        _currentLevel4NamtrikName = _level4NamtrikNames[randomIndex];
        _loadTargetMoneyValues();
      });
    }
  }

  /// Carga los valores monetarios objetivo para el nombre Namtrik seleccionado en Nivel 4.
  Future<void> _loadTargetMoneyValues() async {
    try {
      final targetData = await _activity4Service.getLevel4MoneyValuesForName(_currentLevel4NamtrikName);
      if (targetData != null) {
        setState(() {
          _targetTotalValue = targetData['total_money'];
          // El servicio ahora devuelve una lista de listas
          _validCombinations = List<List<int>>.from(targetData['valid_combinations'].map((e) => List<int>.from(e)));
        });
      }
      await _loadMoneyValueMapping(); // Asegura que el mapeo esté listo
    } catch (e) { debugPrint('Error cargando valores objetivo N4: $e'); }
  }

  /// Carga el mapeo de índices de las imágenes de dinero a sus valores numéricos (Nivel 4).
  Future<void> _loadMoneyValueMapping() async {
    try {
      final allMoneyItems = await _activity4Service.getAllMoneyItems(); // Asume que esto devuelve todos los tipos de dinero con su valor
      if (allMoneyItems.isNotEmpty) {
        setState(() {
          _numberIndexToValue = {};
          for (var item in allMoneyItems) {
            _numberIndexToValue[item.number] = item.valueMoney;
          }
        });
      }
    } catch (e) { debugPrint('Error cargando mapeo de valores N4: $e'); }
  }
  
  /// Manejador específico para la finalización del Nivel 4, muestra diálogos.
  void _handleLevel4Completion(bool justCompleted) async {
    final activitiesState = ActivitiesState.of(context);
    final gameState = GameState.of(context);
    final wasCompletedBeforeThisAttempt = gameState.isLevelCompleted(4, widget.level.id - 1);

    bool showPointsDialog = false;

    if (!wasCompletedBeforeThisAttempt && !_hasEarnedPointsLevel4) {
        final pointsAdded = await gameState.addPoints(4, widget.level.id - 1, 5);
        if (pointsAdded) {
            activitiesState.completeLevel(4, widget.level.id - 1);
            if (mounted) {
                setState(() {
                    totalScore = gameState.globalPoints;
                    _hasEarnedPointsLevel4 = true; // Marcar que ya se ganaron puntos en esta instancia del nivel
                });
            }
            showPointsDialog = true; // Ganó puntos por primera vez
        }
    }
    
    if (!mounted) return;

    showDialog(
      context: context, barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(showPointsDialog ? '¡Felicitaciones!' : '¡Buen trabajo!', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text(showPointsDialog ? '¡Ganaste 5 puntos!' : 'Ya habías completado este nivel anteriormente.', style: showPointsDialog ? const TextStyle(color: Color(0xFFCD5C5C), fontWeight: FontWeight.bold, fontSize: 16) : const TextStyle(), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cierra el diálogo
              // Para Nivel 4, siempre reiniciar con un nuevo valor después de aceptar el diálogo.
              setState(() { 
                _showLevel4Feedback = false; 
                _selectRandomLevel4Name(); 
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFCD5C5C), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12)),
            child: Text(showPointsDialog ? 'Continuar' : 'Aceptar'),
          ),
        ])),
      ),
    );
  }


  // --- Widget Constructor UI Nivel 4 ---
  /// Construye el widget principal para el Nivel 4.
  Widget _buildLevel4UI() {
    if (!_level4DataLoaded && !_isLoading) {
      return const Center(child: Text('Cargando datos del Nivel 4...', style: TextStyle(color: Colors.white)));
    }
    if (_isLoading && !_level4DataLoaded) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;
    final double containerWidth = isLandscape ? 450.0 : screenSize.width - 32;

    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InfoBar(remainingAttempts: remainingAttempts, margin: const EdgeInsets.only(bottom: 16)),
            
            // Recuadro 1: Texto en namtrik
            Container(
              width: containerWidth,
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFCD5C5C),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: const Color(0xFFCD5C5C), blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: Center(
                child: Text(
                  _currentLevel4NamtrikName,
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            
            // Recuadro 2: Valor total formateado
            Container(
              width: containerWidth,
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: _showLevel4Feedback
                    ? (_isCorrectLevel4Answer
                        ? const Color(0xFF00FF00).withOpacity(0.2)
                        : const Color(0xFFFF0000).withOpacity(0.2))
                    : const Color(0xFFCD5C5C),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _showLevel4Feedback
                      ? (_isCorrectLevel4Answer
                          ? const Color(0xFF00FF00)
                          : const Color(0xFFFF0000))
                      : Colors.transparent,
                ),
              ),
              child: SizedBox(
                height: 50,
                child: Center(
                  child: Text(
                    _formatMoneyValue(_currentTotalValue),
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            
            // Recuadro 3: Valores seleccionados
            if (_selectedMoneyValues.isNotEmpty)
              Container(
                width: containerWidth,
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFCD5C5C), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Valores seleccionados:',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selectedMoneyValues.asMap().entries.map((entry) {
                        final index = entry.key;
                        final value = entry.value;
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFCD5C5C),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                _activity4Service.getMoneyImagePath(value['imagePath']),
                                width: 24,
                                height: 24,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _formatMoneyValue(value['value'] as int),
                                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => _removeSelectedValue(index),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            
            // Botón de validación
            if (_selectedMoneyValues.isNotEmpty && !_showLevel4Feedback)
              Container(
                width: containerWidth,
                margin: const EdgeInsets.only(bottom: 16),
                child: ElevatedButton(
                  onPressed: _validateAnswer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCD5C5C),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, size: 20),
                      SizedBox(width: 8),
                      Text('Validar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            
            // Cuadrícula de valores de dinero
            if (_moneyImagesLoaded)
              Container(
                width: containerWidth,
                margin: const EdgeInsets.only(bottom: 24, top: 16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _level4MoneyImagePaths.length,
                  itemBuilder: (context, index) {
                    final isSelected = _lastSelectedIndex == index;
                    return GestureDetector(
                      onTap: () {
                        if (!_showLevel4Feedback) {
                          _handleMoneyImageTap(index);
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFCD5C5C).withOpacity(0.3)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFCD5C5C),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        padding: const EdgeInsets.all(1),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Image.asset(
                                _activity4Service.getMoneyImagePath(_level4MoneyImagePaths[index]),
                                fit: BoxFit.contain,
                              ),
                            ),
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
                                  child: const Icon(Icons.check, color: Colors.white, size: 12),
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

  //==============================================================================
  // Métodos Comunes del Juego / Ciclo de Vida del State
  //==============================================================================
  @override
  void initState() {
    super.initState();
    _activity4Service = GetIt.instance<Activity4Service>();
    _loadLevelData();
  }

  @override
  void dispose() {
    _pageController.dispose(); // Para el PageView del Nivel 1
    // Si otros niveles tuvieran PageControllers u otros elementos que necesiten dispose, se agregarían aquí.
    super.dispose();
  }

  /// Carga los datos necesarios según el ID del nivel actual.
  Future<void> _loadLevelData() async {
    if (!mounted) return;
    setState(() { _isLoading = true; });

    try {
      if (widget.level.id == 1) {
        _moneyItems = await _activity4Service.getLevelData(widget.level);
        if (mounted) {
          setState(() {
            for (var i = 0; i < _moneyItems.length; i++) { _showingSecondImage[i] = false; }
            _isLoading = false;
          });
        }
      } else if (widget.level.id == 2) {
        _currentArticle = await _activity4Service.getRandomArticle();
        if (_currentArticle != null && !_optionsGenerated) {
          _moneyOptions = await _activity4Service.generateOptionsForLevel2(_currentArticle!);
          _correctOptionIndex = _activity4Service.findCorrectOptionIndex(_moneyOptions, _currentArticle!.numberMoneyImages);
          _optionsGenerated = true;
        }
        if (mounted) { setState(() { _isLoading = false; });}
      } else if (widget.level.id == 3) {
        final syncData = await _activity4Service.getSynchronizedLevel3Data();
        _moneyItems = List<NamtrikMoneyModel>.from(syncData['moneyItems']);
        _correctNamtrikName = syncData['correctName'];
        _incorrectNamtrikNames = List<String>.from(syncData['incorrectNames']);
        _shuffledNamtrikNames = [_correctNamtrikName, ..._incorrectNamtrikNames];
        _shuffledNamtrikNames.shuffle();
        _correctNameIndex = _shuffledNamtrikNames.indexOf(_correctNamtrikName);
        if (mounted) { setState(() { _isLoading = false; });}
      } else if (widget.level.id == 4) {
        _level4NamtrikNames = await _activity4Service.getLevel4NamtrikNames();
        await _loadMoneyValueMapping(); // Cargar mapeo primero
        _level4MoneyImagePaths = await _activity4Service.getAllMoneyImages(); // Luego las imágenes
        _selectRandomLevel4Name(); // Esto usará los nombres y el mapeo, y setea _targetTotalValue etc.
        if (mounted) { setState(() { _level4DataLoaded = true; _moneyImagesLoaded = true; _isLoading = false; });}
        } else {
         if (mounted) { setState(() { _isLoading = false; });} // Nivel desconocido
      }
    } catch (e) {
      if (mounted) { setState(() { _isLoading = false; }); }
      debugPrint('Error cargando datos del nivel: $e');
    }
  }

  /// Muestra un diálogo indicando que se agotaron los intentos.
  void _handleOutOfAttempts() async {
    await FeedbackService().heavyHapticFeedback();
    if (!mounted) return;
    showDialog(
      context: context, barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('¡Sin intentos!'),
        content: const Text('Has agotado tus intentos. Volviendo al menú de actividad.'),
        actions: [
          TextButton(
            onPressed: () { Navigator.of(context).pop(); Navigator.of(context).pop(); },
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFCD5C5C)),
            child: const Text('Aceptar'),
                    ),
                ],
              ),
    );
  }

  /// Maneja la lógica de finalización exitosa de un nivel (común para Nivel 2 y 3).
  /// Nivel 4 tiene su propio _handleLevel4Completion.
  void _handleLevelComplete() async {
    await FeedbackService().lightHapticFeedback();
    if (!mounted) return;
    final activitiesState = ActivitiesState.of(context);
    final gameState = GameState.of(context);
    final wasCompleted = gameState.isLevelCompleted(4, widget.level.id - 1);

    bool showPointsDialog = false;
    if (!wasCompleted) {
      final pointsAdded = await gameState.addPoints(4, widget.level.id - 1, 5);
      if (pointsAdded) {
        activitiesState.completeLevel(4, widget.level.id - 1);
        if (mounted) { setState(() { totalScore = gameState.globalPoints; });}
        showPointsDialog = true;
      }
    }
    
    if (!mounted) return;
    showDialog(
      context: context, barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(showPointsDialog ? '¡Felicitaciones!' : '¡Buen trabajo!', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text(showPointsDialog ? '¡Ganaste 5 puntos!' : 'Ya habías completado este nivel anteriormente.', style: showPointsDialog ? const TextStyle(color: Color(0xFFCD5C5C), fontWeight: FontWeight.bold, fontSize: 16) : const TextStyle(), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () { Navigator.of(context).pop(); Navigator.of(context).pop(); }, // Volver al menú de niveles
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFCD5C5C), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12)),
            child: const Text('Continuar'),
          ),
        ])),
      ),
    );
  }

  /// Disminuye el contador de intentos restantes.
  void decrementAttempts() {
    if (remainingAttempts > 0) { setState(() { remainingAttempts--; });}
  }

  /// Restablece el contador de intentos a su valor inicial (3).
  void resetAttempts() { setState(() { remainingAttempts = 3; });}
  //==============================================================================
  // Constructor Principal de Contenido de Nivel (buildLevelContent)
  //==============================================================================
  @override
  Widget buildLevelContent() {
    // Obtener el tamaño de la pantalla para diseño responsivo
    final screenSize = MediaQuery.of(context).size;

    return Container(
      // Asegurar que el contenido ocupe al menos toda la altura disponible en portrait
      constraints: BoxConstraints(
        minHeight: screenSize.height - 220, // Restar altura aproximada de la descripción y appbar
      ),
      child: _isLoading
          ? const SizedBox(
              height: 300,
              child: Center(child: CircularProgressIndicator(color: Colors.white)),
            )
          : _buildLevelUIByID(),
    );
  }

  /// Método auxiliar para construir la UI según el ID del nivel
  Widget _buildLevelUIByID() {
    switch (widget.level.id) {
      case 1:
        return _buildLevel1UI();
      case 2:
        return _buildLevel2UI();
      case 3:
        return _buildLevel3UI();
      case 4:
        return _buildLevel4UI();
      default:
        return Center(child: Text('Nivel ${widget.level.id} no encontrado.', style: const TextStyle(color: Colors.white)));
    }
  }
}
