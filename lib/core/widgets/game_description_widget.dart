import 'package:flutter/material.dart';
import 'package:namuiwam/core/themes/app_theme.dart';

/// {@template game_description_widget}
/// Un widget reutilizable para mostrar la descripción de un juego o actividad.
///
/// Este widget encapsula una caja decorativa para presentar textos descriptivos
/// de manera visualmente atractiva y consistente a lo largo de la aplicación.
/// Es especialmente útil para mostrar introducciones, instrucciones o detalles
/// sobre actividades educativas.
///
/// Características:
/// - Estilo visual consistente definido en [AppTheme]
/// - Padding interno y externo predefinido
/// - Alineación de texto centrada
/// - Decoración con colores y bordes redondeados
///
/// Ejemplo de uso:
/// ```dart
/// GameDescriptionWidget(
///   description: 'Selecciona el número correcto que corresponde '
///     'a la palabra en Namtrik mostrada en pantalla.',
/// )
/// ```
///
/// Este widget se utiliza comúnmente en:
/// - Pantallas de introducción de niveles
/// - Secciones de instrucciones en actividades
/// - Pantallas de ayuda o información adicional
/// {@endtemplate}
class GameDescriptionWidget extends StatelessWidget {
  /// El texto de la descripción a mostrar.
  ///
  /// Este texto se presenta dentro del contenedor decorativo
  /// y debe proporcionar contexto o instrucciones claras para el usuario.
  /// Se recomienda mantener el texto conciso para mejor legibilidad.
  final String description;

  /// {@macro game_description_widget}
  ///
  /// [description] El texto descriptivo que se mostrará dentro del contenedor.
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