import 'package:flutter/material.dart';

enum SelectionState {
  unselected,
  selected,
  matched,
  error,
}

class SelectableItem extends StatelessWidget {
  final String id;
  final Widget child;
  final SelectionState state;
  final bool isImage;
  final VoidCallback onTap;
  final bool isEnabled;

  const SelectableItem({
    super.key,
    required this.id,
    required this.child,
    required this.state,
    required this.onTap,
    this.isImage = false,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    // Definir colores y bordes según el estado
    Color backgroundColor;
    Color borderColor;
    double borderWidth;
    double elevation;

    switch (state) {
      case SelectionState.unselected:
        backgroundColor = isImage ? Colors.transparent : Colors.green.shade700;
        borderColor = Colors.transparent;
        borderWidth = 2.0;
        elevation = 2.0;
        break;
      case SelectionState.selected:
        backgroundColor = isImage ? Colors.transparent : Colors.green.shade700;
        borderColor = Colors.blue;
        borderWidth = 3.0;
        elevation = 4.0;
        break;
      case SelectionState.matched:
        backgroundColor = isImage ? Colors.transparent : Colors.green.shade700;
        borderColor = Colors.amber;
        borderWidth = 3.0;
        elevation = 4.0;
        break;
      case SelectionState.error:
        backgroundColor = isImage ? Colors.transparent : Colors.green.shade700;
        borderColor = Colors.red;
        borderWidth = 3.0;
        elevation = 4.0;
        break;
    }

    return AnimatedContainer(
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
    );
  }
}
