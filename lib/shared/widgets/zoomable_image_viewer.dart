
import 'package:flutter/material.dart';

class ZoomableImageViewer extends StatelessWidget {
  final String imagePath;

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
