import 'package:flutter/material.dart';

// Estados de selección de un item en la actividad
enum SelectionState {
  unselected,
  selected,
  matched,
  error,
}

// Widget que representa un item seleccionable
class SelectableItem extends StatelessWidget {
  final String id;
  final Widget child;
  final SelectionState state;
  final bool isImage;
  final VoidCallback onTap;
  final bool isEnabled;

  // Constructor del widget SelectableItem
  const SelectableItem({
    super.key,
    required this.id,
    required this.child,
    required this.state,
    required this.onTap,
    this.isImage = false,
    this.isEnabled = true,
  });

  // Método para construir el widget SelectableItem
  @override
  Widget build(BuildContext context) {
    // Definir colores y bordes según el estado
    Color backgroundColor;
    Color borderColor;
    double borderWidth;
    double elevation;

    // Definir colores y bordes según el estado del item
    switch (state) {
      // Si el estado es unselected (no seleccionado) se muestra con un borde transparente
      case SelectionState.unselected:
        backgroundColor = isImage ? Colors.transparent : Colors.transparent;
        borderColor = Colors.transparent;
        borderWidth = 2.0;
        elevation = 2.0;
        break;
      // Si el estado es selected (seleccionado) se muestra con un borde amarillo
      case SelectionState.selected:
        backgroundColor =
            isImage ? const Color(0xFFFF00FF) : const Color(0xFFFF00FF);
        borderColor = const Color(0xFFFFFF00);
        borderWidth = 3.0;
        elevation = 4.0;
        break;
      // Si el estado es matched (coincide con otro item) se muestra con un borde verde fresco
      case SelectionState.matched:
        backgroundColor =
            isImage ? const Color(0xFF9C27B0) : const Color(0xFF9C27B0);
        borderColor = const Color(0xFF4CAF50);
        borderWidth = 3.0;
        elevation = 4.0;
        break;
      // Si el estado es error (no coincide con otro item) se muestra con un borde aqua
      case SelectionState.error:
        backgroundColor =
            isImage ? const Color(0xFFFF0000) : const Color(0xFFFF0000);
        borderColor = const Color(0xFF00FFFF);
        borderWidth = 3.0;
        elevation = 4.0;
        break;
    }

    // Retornar el widget con la animación de la selección
    return Semantics(
      button: true,
      enabled: isEnabled,
      label: isImage
          ? 'Imagen de reloj, estado: ${_stateLabel(state)}'
          : 'Texto namtrik, estado: ${_stateLabel(state)}',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.all(8.0),
        child: Material(
          elevation: elevation,
          borderRadius: BorderRadius.circular(12),
          color: backgroundColor,
          child: InkWell(
            onTap: isEnabled ? onTap : null,
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: borderColor,
                  width: borderWidth,
                ),
              ),
              padding: EdgeInsets.all(isImage ? 12.0 : 16.0),
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  String _stateLabel(SelectionState state) {
    switch (state) {
      case SelectionState.unselected:
        return 'no seleccionado';
      case SelectionState.selected:
        return 'seleccionado';
      case SelectionState.matched:
        return 'emparejado';
      case SelectionState.error:
        return 'error';
    }
  }
}
