import 'package:flutter/material.dart';
import 'package:namuiwam/core/di/service_locator.dart';
import 'package:namuiwam/features/activity6/models/semantic_domain.dart';
import 'package:namuiwam/features/activity6/services/activity6_service.dart';
import 'package:namuiwam/core/services/logger_service.dart';
import 'package:namuiwam/core/services/audio_player_service.dart'; // Importar AudioPlayerService
import 'package:namuiwam/core/services/feedback_service.dart'; // Importar FeedbackService
import 'dictionary_entries_screen.dart';

/// {@template dictionary_domain_screen}
/// Pantalla principal de la Actividad 6 (Diccionario).
///
/// Implementa la interfaz inicial del diccionario Namtrik-Español que muestra
/// una cuadrícula interactiva con todos los dominios semánticos disponibles
/// (categorías como animales, colores, partes del cuerpo, etc.).
///
/// Características principales:
/// - Carga asíncrona de dominios desde [Activity6Service]
/// - Visualización en cuadrícula ([GridView]) adaptable y responsiva, con tarjetas más juntas
/// - Tarjetas ([_buildDomainCard]) interactivas para cada dominio con:
///   * Imagen representativa del dominio (dispuesta arriba).
///   * Nombre en Namtrik (dispuesto abajo, mostrando el texto completo).
///   * Retroalimentación háptica al tocar
///   * Reproducción automática del audio del nombre al seleccionar
/// - Navegación a [DictionaryEntriesScreen] al seleccionar un dominio
///
/// Esta pantalla sirve como punto de entrada al diccionario y utiliza 
/// un color coral (0xFFFF7F50) como elemento temático distintivo de esta actividad.
/// Maneja diferentes estados de carga (espera, error, vacío) y proporciona feedback
/// multisensorial (visual, auditivo, háptico) durante la interacción.
/// {@endtemplate}
class DictionaryDomainScreen extends StatelessWidget {
  /// {@macro dictionary_domain_screen}
  DictionaryDomainScreen({super.key}) {
    final _logger = getIt<LoggerService>();
    _logger.info('Entrando a DictionaryDomainScreen (constructor)');
  }
  // const DictionaryDomainScreen({super.key}); // Reemplazado por versión con log

  /// Mapa de excepciones para la normalización de nombres de dominios.
  ///
  /// Proporciona una correspondencia directa entre los nombres de dominios
  /// que contienen caracteres especiales o estructuras particulares y sus
  /// versiones normalizadas para uso en rutas de archivos.
  ///
  /// Esto es crucial para manejar dominios como "Wamap amɵñikun" donde 
  /// una simple normalización automática podría no ser suficiente.
  final Map<String, String> _domainPathOverrides = {
    'Wamap amɵñikun': 'wamapamɵnikun',
    'Namui kewa amɵneiklɵ': 'kewaamɵneiklɵ',
    // Añadir otros overrides si son necesarios
  };

  /// Calcula el nombre normalizado de un dominio para uso en rutas de archivos.
  ///
  /// Este método aplica reglas de normalización consistentes:
  /// 1. Verifica primero si existe un override específico en [_domainPathOverrides]
  /// 2. Si no existe, convierte el nombre a minúsculas
  /// 3. Reemplaza espacios por guiones bajos
  ///
  /// La normalización es necesaria porque los sistemas de archivos y las rutas
  /// de assets tienen restricciones sobre los caracteres permitidos.
  ///
  /// [domainName] El nombre original del dominio en Namtrik
  /// Retorna una cadena normalizada adecuada para rutas de archivos
  String _calculateDomainAudioName(String domainName) {
    // Check for override first
    if (_domainPathOverrides.containsKey(domainName)) {
      return _domainPathOverrides[domainName]!;
    }
    // Default calculation: lowercase, replace spaces with underscores
    // REMOVED: .replaceAll('ɵ', 'o')
    return domainName.toLowerCase().replaceAll(' ', '_');
  }

  /// Construye la interfaz de usuario de la pantalla de selección de dominios.
  ///
  /// Implementa un patrón de carga asíncrona con [FutureBuilder] que:
  /// 1. Obtiene la lista de [SemanticDomain] desde [Activity6Service.getAllDomains]
  /// 2. Muestra un indicador circular mientras carga
  /// 3. Maneja estados de error y resultados vacíos con mensajes apropiados
  /// 4. Construye una cuadrícula de dominios cuando los datos están disponibles
  ///
  /// La cuadrícula utiliza [GridView.builder] con un layout adaptativo que 
  /// muestra 2 columnas con relación de aspecto 3:2 para cada elemento.
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
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200.0, // Max width for each item
                crossAxisSpacing: 3.0, // Reduced spacing for closer cards
                mainAxisSpacing: 3.0, // Reduced spacing for closer cards
                childAspectRatio: 3 / 2.5, 
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

  /// Construye una tarjeta interactiva para un dominio semántico específico.
  ///
  /// Crea un [Card] con [InkWell] que presenta:
  /// - Una imagen representativa del dominio en la parte superior, ocupando una porción mayor del espacio.
  /// - El nombre del dominio en Namtrik debajo de la imagen, centrado y con posibilidad de mostrarse completo.
  /// - Interactividad con retroalimentación visual y háptica.
  /// - Uso optimizado del espacio interno del card para acercar contenido a los bordes.
  ///
  /// Al tocar la tarjeta:
  /// 1. Proporciona feedback háptico ligero mediante [FeedbackService]
  /// 2. Detiene cualquier audio en reproducción
  /// 3. Intenta reproducir el audio con el nombre del dominio en Namtrik
  /// 4. Navega a [DictionaryEntriesScreen] con el dominio seleccionado
  ///
  /// Las imágenes se redimensionan automáticamente según el espacio disponible,
  /// manteniendo la proporción y asegurando una visualización de calidad.
  ///
  /// [context] El contexto de construcción para la navegación y el tema
  /// [domain] El dominio semántico para el cual construir la tarjeta
  /// Retorna un [Widget] que representa la tarjeta interactiva del dominio
  Widget _buildDomainCard(BuildContext context, SemanticDomain domain) {
    final audioPlayerService = getIt<AudioPlayerService>();
    final feedbackService = getIt<FeedbackService>();
    final logger = getIt<LoggerService>();

    final String audioBaseName = _calculateDomainAudioName(domain.name);
    final String domainAudioPath = 'assets/audio/dictionary/$audioBaseName.mp3';
    logger.debug('Audio path for domain "${domain.name}": $domainAudioPath');

    return Card(
      elevation: 4.0,
      clipBehavior: Clip.antiAlias,
      color: const Color(0xFFFF7F50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10.0),
        onTap: () async {
          logger.info('Tapped on domain: ${domain.name}. Playing audio: $domainAudioPath');
          await feedbackService.lightHapticFeedback();
          try {
            await audioPlayerService.stop();
            await audioPlayerService.play(domainAudioPath);
          } catch (e, stackTrace) {
            logger.error('Error playing domain audio: $domainAudioPath', e, stackTrace);
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DictionaryEntriesScreen(domain: domain),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, 
          mainAxisAlignment: MainAxisAlignment.start, 
          children: [
            // Imagen en la parte superior, utilizando el espacio eficientemente
            Expanded(
              flex: 3, 
              child: Padding(
                padding: const EdgeInsets.only(top: 4.0, left: 4.0, right: 4.0), // Padding reducido para maximizar espacio
                child: Center( 
                  child: Image.asset(
                    domain.imagePath,
                    fit: BoxFit.contain, 
                    errorBuilder: (context, error, stackTrace) {
                      // Display a placeholder icon if the image fails to load
                      return Icon(
                        Icons.broken_image,
                        size: 50.0, // A reasonable fixed size for the error icon
                        color: Colors.white.withOpacity(0.7),
                      );
                    },
                  ),
                ),
              ),
            ),
            // Texto debajo de la imagen, centrado y con padding reducido
            Padding(
              padding: const EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 8.0), 
              child: Text(
                domain.name,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                // Removed maxLines and overflow to allow text to wrap and show completely
                // Consider adding a minHeight to the Card or adjusting childAspectRatio if text wrapping varies a lot
              ),
            ),
          ],
        ),
      ),
    );
  }
}
