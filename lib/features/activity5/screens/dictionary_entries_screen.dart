import 'package:flutter/material.dart';
import 'package:namui_wam/core/di/service_locator.dart';
import 'package:namui_wam/core/services/audio_player_service.dart';
import 'package:namui_wam/core/services/feedback_service.dart';
import 'package:namui_wam/features/activity5/models/semantic_domain.dart';
import 'package:namui_wam/features/activity5/models/dictionary_entry.dart';
import 'package:namui_wam/features/activity5/services/activity5_service.dart';
import 'package:namui_wam/core/themes/app_theme.dart';

class DictionaryEntriesScreen extends StatefulWidget {
  final SemanticDomain domain;

  const DictionaryEntriesScreen({required this.domain, super.key});

  @override
  State<DictionaryEntriesScreen> createState() =>
      _DictionaryEntriesScreenState();
}

class _DictionaryEntriesScreenState extends State<DictionaryEntriesScreen> {
  final Activity5Service _dictionaryService =
      getIt<Activity5Service>();
  final AudioPlayerService _audioPlayerService = getIt<AudioPlayerService>();
  late Future<List<DictionaryEntry>> _entriesFuture;

  @override
  void initState() {
    super.initState();
    _entriesFuture = _dictionaryService.getEntriesForDomain(widget.domain.id);
  }

  @override
  void dispose() {
    _audioPlayerService.stop();
    super.dispose();
  }

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

  Widget _buildEntryTile(BuildContext context, DictionaryEntry entry) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    // --- Layout especial para el dominio 'Saludos' ---
    if (widget.domain.name == 'Saludos') {
      // Validar que existan los datos requeridos
      if (entry.greetings_ask_namtrik == null ||
          entry.greetings_ask_spanish == null ||
          entry.greetings_answer_namtrik == null ||
          entry.greetings_answer_spanish == null) {
        return const SizedBox.shrink();
      }

      return Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        color: const Color(0xFF4CAF50),
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Text Column (Question and Answer)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pregunta:',
                        style: textTheme.labelMedium?.copyWith(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    Text(entry.greetings_ask_namtrik!,
                        style: textTheme.titleMedium?.copyWith(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    Text(entry.greetings_ask_spanish!,
                        style: textTheme.titleSmall
                            ?.copyWith(color: Colors.white70)),
                    const SizedBox(height: 8),
                    Text('Respuesta:',
                        style: textTheme.labelMedium?.copyWith(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    Text(entry.greetings_answer_namtrik!,
                        style: textTheme.titleMedium?.copyWith(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    Text(entry.greetings_answer_spanish!,
                        style: textTheme.titleSmall
                            ?.copyWith(color: Colors.white70)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Optional Image for Greetings
              if (entry.images_greetings != null)
                Image.asset(
                  entry.images_greetings!,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image,
                          size: 40, color: Colors.grey),
                    );
                  },
                )
              else
                // Placeholder if no image for greetings
                Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported)),
              const SizedBox(width: 10),
              // Audio Buttons Column (Ask and Answer)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (entry.audio_greetings_ask != null)
                    IconButton(
                      icon: Icon(
                        _audioPlayerService.isPlaying &&
                                _audioPlayerService.currentPlayingPath ==
                                    entry.audio_greetings_ask
                            ? Icons.stop_circle_outlined
                            : Icons.play_circle_outline,
                        size: 30,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        await FeedbackService().lightHapticFeedback();
                        _audioPlayerService.play(entry.audio_greetings_ask!);
                        setState(() {});
                      },
                      tooltip: 'Reproducir pregunta',
                    ),
                  if (entry.audio_greetings_answer != null)
                    IconButton(
                      icon: Icon(
                        _audioPlayerService.isPlaying &&
                                _audioPlayerService.currentPlayingPath ==
                                    entry.audio_greetings_answer
                            ? Icons.stop_circle_outlined
                            : Icons.play_circle_outline,
                        size: 30,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        await FeedbackService().mediumHapticFeedback();
                        _audioPlayerService.play(entry.audio_greetings_answer!);
                        setState(() {});
                      },
                      tooltip: 'Reproducir respuesta',
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    // --- Default Layout for Other Domains ---
    else {
      // Helper function to build composition rows (remains the same)
      Widget _buildCompositionRows(Map<String, String>? compositions) {
        if (compositions == null || compositions.isEmpty) {
          return const SizedBox.shrink(); // Return empty if no compositions
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: compositions.entries.map((compEntry) {
            return Text('  ${compEntry.key}: ${compEntry.value}',
                style: const TextStyle(color: Colors.white));
          }).toList(),
        );
      }

      return Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        color: const Color(
            0xFF4CAF50), // Naranja coral - mismo color que los botones de dominio
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text Column (Namtrik/Spanish/Variants/Compositions)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(entry.namtrik ?? '', // Provide default value
                            style: textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        if (entry.namtrikVariant != null)
                          Text('Variant: ${entry.namtrikVariant}',
                              style: textTheme.bodySmall?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.white70)),
                        Text(entry.spanish ?? '', // Provide default value
                            style: textTheme.titleSmall
                                ?.copyWith(color: Colors.white54)),
                        if (entry.spanishVariant != null)
                          Text('Variant: ${entry.spanishVariant}',
                              style: textTheme.bodySmall?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.white70)),
                        // Display Compositions if they exist
                        if (entry.compositionsSpanish != null) ...[
                          const SizedBox(height: 4),
                          Text('Composiciones (Español):',
                              style: textTheme.labelMedium
                                  ?.copyWith(color: Colors.white)),
                          _buildCompositionRows(entry.compositionsSpanish),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Image display (if available)
                  if (entry.imagePath != null)
                    Image.asset(
                      entry.imagePath!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[
                              300], // Color de fondo gris claro de la imagen
                          child: const Icon(Icons.broken_image,
                              size: 40,
                              color: Colors.grey), // Icono de imagen rota
                        );
                      },
                    )
                  else
                    Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[200],
                        child: const Icon(Icons
                            .image_not_supported)), // Icono de imagen no soportada
                  const SizedBox(width: 10),
                  // Audio buttons (if available)
                  Column(
                    children: [
                      if (entry.audioPath != null)
                        IconButton(
                          icon: Icon(
                            _audioPlayerService.isPlaying &&
                                    _audioPlayerService.currentPlayingPath ==
                                        entry.audioPath
                                ? Icons.stop_circle_outlined
                                : Icons.play_circle_outline,
                            size: 30,
                            color: Colors
                                .white, // Cambiado a blanco para mejor contraste
                          ),
                          onPressed: () async {
                            await FeedbackService().lightHapticFeedback();
                            _audioPlayerService.play(entry.audioPath!);
                            setState(() {});
                          },
                          tooltip: 'Reproducir audio',
                        ),
                      if (entry.audioVariantPath != null) ...[
                        const SizedBox(height: 5),
                        IconButton(
                          icon: Icon(
                            _audioPlayerService.isPlaying &&
                                    _audioPlayerService.currentPlayingPath ==
                                        entry.audioVariantPath
                                ? Icons.stop_circle_outlined
                                : Icons.play_circle_outline,
                            size: 30,
                            color: Colors
                                .white, // Cambiado a blanco para mejor contraste
                          ),
                          onPressed: () async {
                            await FeedbackService().mediumHapticFeedback();
                            _audioPlayerService.play(entry.audioVariantPath!);
                            setState(() {});
                          },
                          tooltip: 'Reproducir audio variante',
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }
}
