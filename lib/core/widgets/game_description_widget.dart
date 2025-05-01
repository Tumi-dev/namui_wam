import 'package:flutter/material.dart';
import 'package:namuiwam/core/themes/app_theme.dart';

/// Un widget reutilizable para mostrar la descripción de un juego o actividad.
///
/// Presenta el texto de descripción dentro de un contenedor estilizado
/// utilizando las decoraciones y estilos definidos en [AppTheme].
class GameDescriptionWidget extends StatelessWidget {
  /// El texto de la descripción a mostrar.
  final String description;

  /// Crea una instancia de [GameDescriptionWidget].
  ///
  /// Requiere el texto de la [description].
  const GameDescriptionWidget({
    super.key,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: AppTheme.gameDescriptionDecoration, // Estilo del contenedor
        child: Text(
          description,
          style: AppTheme.gameDescriptionStyle, // Estilo del texto
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}