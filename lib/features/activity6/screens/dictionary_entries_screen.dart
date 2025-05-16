import 'package:flutter/material.dart';
import 'package:namuiwam/core/di/service_locator.dart';
import 'package:namuiwam/core/services/audio_player_service.dart';
import 'package:namuiwam/core/services/feedback_service.dart';
import 'package:namuiwam/features/activity6/models/semantic_domain.dart';
import 'package:namuiwam/features/activity6/models/dictionary_entry.dart';
import 'package:namuiwam/features/activity6/services/activity6_service.dart';
import 'package:namuiwam/core/themes/app_theme.dart';
import 'package:namuiwam/shared/widgets/zoomable_image_viewer.dart'; // Importar el nuevo visor

/// {@template dictionary_entries_screen}
/// Pantalla que muestra la lista de entradas del diccionario para un [SemanticDomain] específico.
///
/// Recibe un [domain] y utiliza [Activity6Service] para obtener y mostrar
/// las [DictionaryEntry] correspondientes en una lista ([ListView]).
/// Cada entrada se representa mediante un widget de mosaico dedicado (construido internamente).
/// {@endtemplate}
class DictionaryEntriesScreen extends StatefulWidget {
  /// El dominio semántico cuyas entradas se mostrarán.
  final SemanticDomain domain;

  /// {@macro dictionary_entries_screen}
  const DictionaryEntriesScreen({required this.domain, super.key});

  @override
  State<DictionaryEntriesScreen> createState() =>
      _DictionaryEntriesScreenState();
}

/// Clase de estado para [DictionaryEntriesScreen].
///
/// Gestiona la carga de las entradas del diccionario para el dominio dado
/// y maneja la interacción con los elementos de la lista (reproducción de audio,
/// navegación al visor de imágenes).
class _DictionaryEntriesScreenState extends State<DictionaryEntriesScreen> {
  final Activity6Service _dictionaryService =
      getIt<Activity6Service>();
  final AudioPlayerService _audioPlayerService = getIt<AudioPlayerService>();
  /// Futuro que contiene la lista de entradas para el dominio actual.
  late Future<List<DictionaryEntry>> _entriesFuture;

  @override
  void initState() {
    super.initState();
    // Inicia la carga de las entradas para el dominio especificado.
    _entriesFuture = _dictionaryService.getEntriesForDomain(widget.domain.id);
  }

  @override
  void dispose() {
    // Detiene cualquier audio al salir de la pantalla.
    _audioPlayerService.stop();
    super.dispose();
  }

  /// Navega a la pantalla [ZoomableImageViewer] para mostrar una imagen ampliada.
  void _navigateToImageViewer(BuildContext context, String imagePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ZoomableImageViewer(imagePath: imagePath),
        fullscreenDialog: true, // Opcional: para una transición diferente
      ),
    );
  }

  /// Construye la interfaz de usuario de la pantalla de lista de entradas.
  ///
  /// Muestra un [AppBar] con el nombre del dominio.
  /// Utiliza un [FutureBuilder] para mostrar un indicador de carga, un error,
  /// o la lista de entradas ([ListView]) una vez que [_entriesFuture] se completa.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          widget.domain.name,
          style: AppTheme.activityTitleStyle,
        ),
        backgroundColor:
            Colors.transparent, // Color de fondo transparente de la AppBar
        elevation: 0,
        iconTheme: const IconThemeData(
            color: Colors.white), // Color de los iconos de la AppBar
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.mainGradient,
        ),
        child: FutureBuilder<List<DictionaryEntry>>(
          future: _entriesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(
                      color: Colors.white)); // Carga de indicador
            } else if (snapshot.hasError) {
              return Center(
                  child: Text('Error: ${snapshot.error}',
                      style: const TextStyle(
                          color: Colors.white))); // Mostrar error
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                  child: Text('No hay entradas en ${widget.domain.name}.',
                      style: const TextStyle(
                          color: Colors.white))); // Mensaje si no hay entradas
            } else {
              final entries = snapshot.data!;
              return SafeArea(
                child: ListView.builder(
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return _buildEntryTile(context, entry);
                  },
                ),
              );
            }
          },
        ),
      ),
    );
  }

  /// Construye un elemento de lista ([Card]) para una [DictionaryEntry] individual.
  ///
  /// Muestra la palabra en Namtrik, su traducción al español, variantes (si existen),
  /// composiciones (si existen), una imagen (si existe) y botones para reproducir
  /// el audio principal y el audio variante (si existen).
  ///
  /// Este método actúa como un despachador, seleccionando el método de construcción
  /// de la tarjeta apropiado ([_buildWamapEntryCard] o [_buildDefaultEntryCard])
  /// basado en el nombre del dominio de la entrada.
  ///
  /// Ver los DartDocs de los métodos helper para detalles específicos de cada layout.
  Widget _buildEntryTile(BuildContext context, DictionaryEntry entry) {
    final textTheme = Theme.of(context).textTheme;
    const double largeIconSize = 35.0;

    if (widget.domain.name == 'Wamap amɵñikun') {
      return _buildWamapEntryCard(context, entry, textTheme, largeIconSize);
    } else {
      return _buildDefaultEntryCard(context, entry, textTheme, largeIconSize);
    }
  }

  /// Construye la tarjeta para una entrada del dominio "Wamap amɵñikun".
  ///
  /// Presenta:
  /// - Sin imagen.
  /// - Textos de pregunta y respuesta (Namtrik y Español) con tamaño más grande.
  /// - Botones de audio (tamaño grande) para pregunta y respuesta, alineados a la derecha de los textos.
  Widget _buildWamapEntryCard(BuildContext context, DictionaryEntry entry, TextTheme textTheme, double largeIconSize) {
    final largerNamtrikStyle = textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold);
    final largerSpanishStyle = textTheme.titleMedium?.copyWith(color: Colors.white70);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      color: const Color(0xFFFF7F50),
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (entry.namtrik != null && entry.namtrik!.isNotEmpty)
                    Text(entry.namtrik!, style: largerNamtrikStyle),
                  if (entry.spanish != null && entry.spanish!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Text(entry.spanish!, style: largerSpanishStyle),
                    ),
                  if (entry.namtrikVariant != null && entry.namtrikVariant!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(entry.namtrikVariant!, style: largerNamtrikStyle),
                    ),
                  if (entry.spanishVariant != null && entry.spanishVariant!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Text(entry.spanishVariant!, style: largerSpanishStyle),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (entry.audioPath != null && entry.audioPath!.isNotEmpty)
                  IconButton(
                    icon: Icon(
                      _audioPlayerService.isPlaying && _audioPlayerService.currentPlayingPath == entry.audioPath
                          ? Icons.stop_circle_outlined
                          : Icons.play_circle_outline,
                      size: largeIconSize,
                      color: Colors.white,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () async {
                      await FeedbackService().lightHapticFeedback();
                      _audioPlayerService.play(entry.audioPath!);
                      if (mounted) setState(() {});
                    },
                    tooltip: 'Reproducir pregunta',
                  ),
                if (entry.audioVariantPath != null && entry.audioVariantPath!.isNotEmpty) ...[
                  SizedBox(height: (entry.audioPath != null && entry.audioPath!.isNotEmpty) ? 10.0 : 0.0),
                  IconButton(
                    icon: Icon(
                      _audioPlayerService.isPlaying && _audioPlayerService.currentPlayingPath == entry.audioVariantPath
                          ? Icons.stop_circle_outlined
                          : Icons.play_circle_outline,
                      size: largeIconSize,
                      color: Colors.white,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () async {
                      await FeedbackService().mediumHapticFeedback();
                      _audioPlayerService.play(entry.audioVariantPath!);
                      if (mounted) setState(() {});
                    },
                    tooltip: 'Reproducir respuesta',
                  ),
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Construye la tarjeta por defecto para entradas de otros dominios.
  ///
  /// Presenta:
  /// - Columna de texto a la izquierda (Namtrik, Español, variantes y composiciones) con tamaños de fuente por defecto.
  /// - Un botón de reproducción de audio (tamaño grande) a la izquierda de la imagen.
  /// - La imagen (si existe) a la derecha del botón de audio.
  /// - La imagen es interactiva y abre [ZoomableImageViewer] al tocarla.
  Widget _buildDefaultEntryCard(BuildContext context, DictionaryEntry entry, TextTheme textTheme, double largeIconSize) {
    final defaultNamtrikStyle = textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold);
    final defaultSpanishStyle = textTheme.titleSmall?.copyWith(color: Colors.white54);
    final defaultVariantStyle = textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic, color: Colors.white70);
    final defaultCompositionLabelStyle = textTheme.labelMedium?.copyWith(color: Colors.white);

    Widget buildCompositionRowsWidget(Map<String, String>? compositions) {
      if (compositions == null || compositions.isEmpty) {
        return const SizedBox.shrink();
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: compositions.entries.map((compEntry) {
          return Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Text('  ${compEntry.key}: ${compEntry.value}', style: defaultVariantStyle),
          );
        }).toList(),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      color: const Color(0xFFFF7F50),
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(entry.namtrik ?? '', style: defaultNamtrikStyle),
                  if (entry.namtrikVariant != null && entry.namtrikVariant!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 1.0),
                      child: Text('Variante: ${entry.namtrikVariant!}', style: defaultVariantStyle),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 1.0),
                    child: Text(entry.spanish ?? '', style: defaultSpanishStyle),
                  ),
                  if (entry.spanishVariant != null && entry.spanishVariant!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 1.0),
                      child: Text('Variante: ${entry.spanishVariant!}', style: defaultVariantStyle),
                    ),
                  if (entry.compositionsSpanish != null && entry.compositionsSpanish!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text('Composiciones:', style: defaultCompositionLabelStyle),
                    buildCompositionRowsWidget(entry.compositionsSpanish),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            if (entry.audioPath != null && entry.audioPath!.isNotEmpty)
              IconButton(
                icon: Icon(
                  _audioPlayerService.isPlaying && _audioPlayerService.currentPlayingPath == entry.audioPath
                      ? Icons.stop_circle_outlined
                      : Icons.play_circle_outline,
                  size: largeIconSize,
                  color: Colors.white,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () async {
                  await FeedbackService().lightHapticFeedback();
                  _audioPlayerService.play(entry.audioPath!);
                  if (mounted) setState(() {});
                },
                tooltip: 'Reproducir audio',
              )
            else
               SizedBox(width: largeIconSize),
            const SizedBox(width: 10),
            if (entry.imagePath != null)
              GestureDetector(
                onTap: () => _navigateToImageViewer(context, entry.imagePath!),
                child: Image.asset(
                  entry.imagePath!,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(width: 80, height: 80, color: Colors.grey[300], child: const Icon(Icons.broken_image, size: 40, color: Colors.grey));
                  },
                ),
              )
            else
              Container(
                width: 80, 
                height: 80, 
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Icon(
                  Icons.image_not_supported, 
                  size: 40,
                  color: Colors.grey[600],
                )
              ),
          ],
        ),
      ),
    );
  }
}
