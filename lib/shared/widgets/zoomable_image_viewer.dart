import 'package:flutter/material.dart';

/// {@template zoomable_image_viewer}
/// Un widget que muestra una imagen desde los assets y permite hacer zoom y paneo.
///
/// Este widget proporciona una experiencia de visualización interactiva para imágenes,
/// permitiendo a los usuarios:
/// - Hacer zoom para ver detalles específicos
/// - Hacer paneo para moverse por la imagen ampliada
/// - Ver la imagen en una pantalla completa con fondo optimizado para contraste
///
/// El componente presenta la imagen en un [Scaffold] con fondo negro para maximizar
/// la visibilidad y contraste, con una barra de navegación simple que facilita
/// regresar a la pantalla anterior.
///
/// Este visor es especialmente útil para:
/// - Mostrar imágenes detalladas como diagramas o mapas
/// - Permitir examinar textos o símbolos dentro de imágenes
/// - Presentar ilustraciones educativas donde los detalles son importantes
/// - Proporcionar una mejor visualización de pictogramas o elementos gráficos
///
/// El widget usa [InteractiveViewer] internamente para manejar los gestos de zoom
/// y paneo, configurado con límites para evitar un zoom excesivo o insuficiente.
///
/// Ejemplo de uso:
/// ```dart
/// // Botón que abre el visor al hacer clic
/// ElevatedButton(
///   onPressed: () {
///     Navigator.push(
///       context,
///       MaterialPageRoute(
///         builder: (context) => ZoomableImageViewer(
///           imagePath: 'assets/images/diagram.png',
///         ),
///       ),
///     );
///   },
///   child: Text('Ver imagen ampliable'),
/// )
/// ```
/// {@endtemplate}
class ZoomableImageViewer extends StatelessWidget {
  /// La ruta del asset de la imagen a mostrar.
  ///
  /// Debe ser una ruta válida a un recurso de imagen incluido en el 
  /// directorio de assets y correctamente declarado en pubspec.yaml.
  /// 
  /// Ejemplo: 'assets/images/namtrik_example.png'
  final String imagePath;

  /// {@macro zoomable_image_viewer}
  ///
  /// [imagePath] La ruta al asset de imagen que se mostrará.
  /// La ruta debe corresponder a un asset válido incluido en pubspec.yaml.
  const ZoomableImageViewer({required this.imagePath, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fondo oscuro para mejor contraste
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white), // Icono de cierre blanco
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true, // Habilitar paneo
          boundaryMargin: const EdgeInsets.all(20.0),
          minScale: 0.5, // Escala mínima
          maxScale: 4.0, // Escala máxima
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain, // Asegura que toda la imagen sea visible inicialmente
            errorBuilder: (context, error, stackTrace) {
              // Mostrar un mensaje de error si la imagen no carga
              return const Center(
                child: Text(
                  'No se pudo cargar la imagen.',
                  style: TextStyle(color: Colors.white),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
