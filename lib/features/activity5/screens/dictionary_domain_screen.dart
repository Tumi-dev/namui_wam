import 'package:flutter/material.dart';
import 'package:namui_wam/core/di/service_locator.dart';
import 'package:namui_wam/features/activity5/models/semantic_domain.dart';
import 'package:namui_wam/features/activity5/services/activity5_service.dart';
import 'package:namui_wam/core/services/logger_service.dart';
import 'dictionary_entries_screen.dart';

class DictionaryDomainScreen extends StatelessWidget {
  DictionaryDomainScreen({super.key}) {
    final _logger = getIt<LoggerService>();
    _logger.info('Entrando a DictionaryDomainScreen (constructor)');
  }
  // const DictionaryDomainScreen({super.key}); // Reemplazado por versión con log

  @override
  Widget build(BuildContext context) {
    final activity5Service = getIt<Activity5Service>();
    final Future<List<SemanticDomain>> domainsFuture = activity5Service.getAllDomains();

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
    return Card(
      elevation: 4.0,
      clipBehavior: Clip.antiAlias,
      color: const Color(0xFF4CAF50), // Naranja coral
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: InkWell(
        onTap: () {
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
