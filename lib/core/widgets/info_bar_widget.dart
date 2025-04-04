import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:namui_wam/core/models/game_state.dart';

class InfoBar extends StatelessWidget {
  final int? remainingAttempts;
  final EdgeInsetsGeometry margin;
  final bool showAttempts;

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
        color: const Color(0xFF4CAF50),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFC107),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          if (showAttempts && remainingAttempts != null) ...[
            Row(
              children: [
                const Icon(Icons.refresh, color: Color(0xFFFFC107)),
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
          Consumer<GameState>(
            builder: (context, gameState, _) => Row(
              children: [
                const Icon(Icons.star, color: Color(0xFFFFC107)),
                const SizedBox(width: 8),
                Text(
                  'Puntos: ${gameState.globalPoints}',
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
