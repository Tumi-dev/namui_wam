import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:namuiwam/core/models/game_state.dart';

/// Una barra de información reutilizable que muestra los intentos restantes (opcional)
/// y los puntos globales del jugador.
///
/// Utiliza [Consumer<GameState>] para obtener los puntos globales actualizados.
/// El estilo y diseño están predefinidos con colores y sombras específicos.
class InfoBar extends StatelessWidget {
  /// El número de intentos restantes a mostrar. Si es nulo o [showAttempts] es falso,
  /// no se muestra la sección de intentos.
  final int? remainingAttempts;

  /// El margen exterior del contenedor de la barra de información.
  final EdgeInsetsGeometry margin;

  /// Controla si se debe mostrar la sección de intentos restantes.
  final bool showAttempts;

  /// Crea una instancia de [InfoBar].
  ///
  /// [remainingAttempts] es opcional.
  /// [margin] tiene un valor predeterminado.
  /// [showAttempts] es verdadero por defecto.
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
