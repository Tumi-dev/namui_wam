import 'package:flutter/material.dart';
import 'package:namuiwam/core/di/service_locator.dart';
import 'package:namuiwam/features/activity6/models/semantic_domain.dart';
import 'package:namuiwam/features/activity6/services/activity6_service.dart';
import 'package:namuiwam/core/services/logger_service.dart';
import 'package:namuiwam/core/services/audio_player_service.dart'; // Importar AudioPlayerService
import 'package:namuiwam/core/services/feedback_service.dart'; // Importar FeedbackService
import 'dictionary_entries_screen.dart';

class DictionaryDomainScreen extends StatelessWidget {
  DictionaryDomainScreen({super.key}) {
    final _logger = getIt<LoggerService>();
    _logger.info('Entrando a DictionaryDomainScreen (constructor)');
  }
  // const DictionaryDomainScreen({super.key}); // Reemplazado por versión con log

  // Mapa de overrides para nombres de carpeta/archivo de audio (similar a Activity6Service)
  final Map<String, String> _domainPathOverrides = {
    'Wamap amɵñikun': 'wamapamɵnikun',
    'Namui kewa amɵneiklɵ': 'kewaamɵneiklɵ',
    // Añadir otros overrides si son necesarios
  };

  // Función para calcular el nombre base del archivo/carpeta (similar a Activity6Service)
  String _calculateDomainAudioName(String domainName) {
    // Check for override first
    if (_domainPathOverrides.containsKey(domainName)) {
      return _domainPathOverrides[domainName]!;
    }
    // Default calculation: lowercase, replace spaces with underscores
    // REMOVED: .replaceAll('ɵ', 'o')
    return domainName.toLowerCase().replaceAll(' ', '_');
  }

  @override
  Widget build(BuildContext context) {
    final activity6Service = getIt<Activity6Service>();
    final Future<List<SemanticDomain>> domainsFuture = activity6Service.getAllDomains();

    return FutureBuilder<List<SemanticDomain>>(
      future: domainsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.white)); // Mostrar un indicador de carga
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white))); // Mostrar error
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No se encontraron dominios.', style: TextStyle(color: Colors.white))); // Mostrar mensaje si no hay dominios
        } else {
          final domains = snapshot.data!;
          return SafeArea(
            child: GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, 
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 3 / 2, 
              ),
              itemCount: domains.length,
              itemBuilder: (context, index) {
                final domain = domains[index];
                return _buildDomainCard(context, domain);
              },
            ),
          );
        }
      },
    );
  }

  Widget _buildDomainCard(BuildContext context, SemanticDomain domain) {
    final audioPlayerService = getIt<AudioPlayerService>(); // Obtener instancia del servicio de audio
    final feedbackService = getIt<FeedbackService>(); // Obtener instancia del servicio de feedback

    // Construir la ruta del audio para este dominio using the updated function
    final String audioBaseName = _calculateDomainAudioName(domain.name);
    // Ensure the path uses the calculated name correctly
    final String domainAudioPath = 'assets/audio/dictionary/$audioBaseName.mp3';
    final logger = getIt<LoggerService>(); // Obtener logger
    logger.debug('Audio path for domain "${domain.name}": $domainAudioPath'); // Log updated path

    return Card(
      elevation: 4.0,
      clipBehavior: Clip.antiAlias,
      color: const Color(0xFFFF7F50), // Coral cálido
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: InkWell(
        onTap: () async { // Convertir a async para await
          logger.info('Tapped on domain: ${domain.name}. Playing audio: $domainAudioPath');
          await feedbackService.lightHapticFeedback(); // Añadir feedback háptico
          try {
            // Stop any currently playing audio before starting new playback
            await audioPlayerService.stop(); 
            await audioPlayerService.play(domainAudioPath); // Reproducir audio del dominio
          } catch (e, stackTrace) {
            logger.error(
              'Error playing domain audio: $domainAudioPath', 
              e, 
              stackTrace
            );
            // Opcional: Mostrar un mensaje al usuario si falla la reproducción
            // ScaffoldMessenger.of(context).showSnackBar(
            //   SnackBar(content: Text('Error al reproducir audio: ${domain.name}')),
            // );
          }
          
          // Navegar después de intentar reproducir el audio
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DictionaryEntriesScreen(domain: domain),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Calculamos un tamaño adaptable basado en el espacio disponible
                    double size = constraints.maxWidth * 0.5; // 50% del ancho disponible
                    // Limitamos el tamaño mínimo y máximo para mantener la calidad
                    size = size.clamp(40.0, 80.0);
                    
                    return SizedBox(
                      width: size,
                      height: size,
                      child: Image.asset(
                        domain.imagePath,
                        fit: BoxFit.contain, // Mantiene la proporción y calidad
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.broken_image, size: size * 0.7);
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                domain.name,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Color de texto de la tarjeta
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
