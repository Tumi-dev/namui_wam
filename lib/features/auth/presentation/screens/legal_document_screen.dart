import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

/// Una pantalla genérica para mostrar documentos legales desde un archivo Markdown.
///
/// Carga el contenido de un archivo .md desde la ruta de assets proporcionada
/// y lo renderiza en un widget de Markdown desplazable.
class LegalDocumentScreen extends StatelessWidget {
  /// El título que se mostrará en la AppBar de la pantalla.
  final String title;

  /// La ruta completa del archivo .md dentro del directorio `assets`.
  /// Ejemplo: 'assets/legal/terms_of_use.md'
  final String mdFilePath;

  const LegalDocumentScreen({
    super.key,
    required this.title,
    required this.mdFilePath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder(
        future: rootBundle.loadString(mdFilePath),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            return Markdown(
              data: snapshot.data!,
              padding: const EdgeInsets.all(16.0),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
