import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:namuiwam/core/models/game_state.dart';

/// {@template info_bar}
/// Una barra de información reutilizable que muestra los intentos restantes (opcional)
/// y los puntos globales del jugador.
///
/// Este widget proporciona una interfaz visual consistente para mostrar información
/// crucial durante las actividades educativas, como:
/// - El número de intentos restantes para completar un nivel
/// - Los puntos globales acumulados por el jugador
///
/// Características visuales:
/// - Barra de color verde con sombra amarilla
/// - Bordes redondeados para mejor apariencia
/// - Iconos intuitivos (estrella para puntos, refrescar para intentos)
/// - Texto en blanco para mejor contraste
///
/// Se actualiza automáticamente cuando cambia el estado global del juego
/// mediante [Consumer<GameState>], asegurando que siempre muestre los 
/// puntos actualizados.
///
/// Ejemplo de uso básico:
/// ```dart
/// InfoBar(
///   remainingAttempts: 3,
/// )
/// ```
///
/// Ejemplo sin mostrar intentos (solo puntos):
/// ```dart
/// InfoBar(
///   showAttempts: false,
/// )
/// ```
///
/// Ejemplo con margen personalizado:
/// ```dart
/// InfoBar(
///   remainingAttempts: 5,
///   margin: EdgeInsets.only(bottom: 16, top: 8),
/// )
/// ```
///
/// Este widget se utiliza típicamente en:
/// - La parte superior de pantallas de actividades
/// - Antes de comenzar un nivel para mostrar información relevante
/// - Durante juegos para seguimiento del progreso
/// {@endtemplate}
class InfoBar extends StatelessWidget {
  /// El número de intentos restantes a mostrar. 
  ///
  /// Si es nulo o [showAttempts] es falso, no se muestra la sección de intentos.
  /// Este valor no se actualiza automáticamente - el widget que lo contiene debe
  /// reconstruir el InfoBar con el nuevo valor cuando sea necesario.
  final int? remainingAttempts;

  /// El margen exterior del contenedor de la barra de información.
  ///
  /// Define el espacio entre este widget y los elementos circundantes.
  /// Por defecto tiene un margen inferior de 24 píxeles.
  final EdgeInsetsGeometry margin;

  /// Controla si se debe mostrar la sección de intentos restantes.
  ///
  /// Si es `false`, la sección de intentos no se muestra incluso si
  /// [remainingAttempts] tiene un valor. Útil para escenarios donde solo
  /// se quiere mostrar la puntuación global.
  final bool showAttempts;

  /// {@macro info_bar}
  ///
  /// [remainingAttempts] El número de intentos disponibles para mostrar.
  /// Puede ser nulo si no hay un límite de intentos.
  ///
  /// [margin] El margen exterior del widget. Por defecto es un margen
  /// inferior de 24 píxeles.
  ///
  /// [showAttempts] Determina si se debe mostrar la sección de intentos.
  /// Por defecto es `true`.
  const InfoBar({
    super.key,
    this.remainingAttempts,
    this.margin = const EdgeInsets.only(bottom: 24),
    this.showAttempts = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: margin,
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50), // Color de fondo verde
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFC107), // Sombra amarilla
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Muestra los intentos restantes si están disponibles y showAttempts es true
          if (showAttempts && remainingAttempts != null) ...[
            Row(
              children: [
                const Icon(Icons.refresh, color: Color(0xFFFFC107)), // Icono amarillo
                const SizedBox(width: 8),
                Text(
                  'Intentos: $remainingAttempts',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
          // Muestra los puntos globales usando Consumer para reaccionar a cambios en GameState
          Consumer<GameState>(
            builder: (context, gameState, _) => Row(
              children: [
                const Icon(Icons.star, color: Color(0xFFFFC107)), // Icono amarillo
                const SizedBox(width: 8),
                Text(
                  'Puntos: ${gameState.globalPoints}', // Obtiene puntos de GameState
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
