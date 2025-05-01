import 'package:flutter/material.dart';

/// Define los posibles estados visuales y lógicos de un [SelectableItem].
enum SelectionState {
  /// El item no está seleccionado ni interactuado. Estado inicial.
  unselected,
  /// El item ha sido seleccionado por el usuario.
  selected,
  /// El item ha sido emparejado correctamente con otro.
  matched,
  /// El item fue seleccionado pero no formó un par correcto.
  error,
}

/// {@template selectable_item}
/// Un widget que representa un elemento interactivo (imagen o texto)
/// que puede ser seleccionado, emparejado o mostrar un estado de error.
///
/// Utilizado principalmente en la Actividad 3, Nivel 1, para el juego de emparejamiento.
/// Cambia su apariencia (fondo, borde, elevación) según su [state] actual
/// mediante una [AnimatedContainer].
/// {@endtemplate}
class SelectableItem extends StatelessWidget {
  /// Identificador único para este item, usado para la lógica de emparejamiento.
  final String id;
  /// El widget hijo que se mostrará dentro del item (ej. una Imagen o Texto).
  final Widget child;
  /// El estado actual del item, determina su apariencia.
  final SelectionState state;
  /// Indica si el [child] es una imagen. Afecta el padding y el color de fondo base.
  final bool isImage;
  /// La función callback que se ejecuta cuando el item es presionado.
  final VoidCallback onTap;
  /// Controla si el item puede ser presionado ([onTap] se ejecutará).
  /// Por defecto es `true`. Se deshabilita si el item ya está emparejado.
  final bool isEnabled;

  /// {@macro selectable_item}
  const SelectableItem({
    super.key,
    required this.id,
    required this.child,
    required this.state,
    required this.onTap,
    this.isImage = false,
    this.isEnabled = true,
  });

  /// Construye la interfaz visual del item seleccionable.
  ///
  /// Utiliza [AnimatedContainer] para transiciones suaves entre estados.
  /// El color de fondo, el color y grosor del borde, y la elevación
  /// cambian según el [state].
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
            isImage ? const Color(0xFF8B4513) : const Color(0xFF8B4513);
        borderColor = const Color(0xFF00FF00);
        borderWidth = 3.0;
        elevation = 4.0;
        break;
      // Si el estado es matched (coincide con otro item) se muestra con un borde verde fresco
      case SelectionState.matched:
        backgroundColor =
            isImage ? const Color(0xFF8B4513) : const Color(0xFF8B4513);
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
            onTap: isEnabled ? onTap : null, // Solo permite onTap si está habilitado
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
              // Padding diferente si es imagen o texto
              padding: EdgeInsets.all(isImage ? 12.0 : 16.0),
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  /// Devuelve una etiqueta textual descriptiva del estado para accesibilidad.
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
