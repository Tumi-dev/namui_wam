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
/// Un widget personalizado que representa un elemento seleccionable e interactivo para 
/// los juegos de emparejamiento y selección de la Actividad 3.
///
/// Diseñado específicamente para visualizar:
/// - Imágenes de relojes y sus representaciones textuales en Namtrik
/// - Estados visuales distintos según la interacción del usuario
/// - Transiciones animadas entre estados
///
/// Características principales:
/// - Cambia dinámicamente de apariencia según su [state] (sin seleccionar, seleccionado, emparejado, error)
/// - Utiliza [AnimatedContainer] para transiciones suaves entre estados
/// - Proporciona feedback visual con colores y bordes distintos
/// - Incluye soporte para accesibilidad con etiquetas semánticas
/// - Se puede desactivar cuando forma parte de un emparejamiento completado
///
/// Ejemplo de uso:
/// ```dart
/// // Imagen de reloj seleccionable
/// SelectableItem(
///   id: '1:30',
///   state: SelectionState.unselected,
///   isImage: true,
///   onTap: () => _handleClockSelected('1:30'),
///   child: Image.asset('assets/images/clocks/clock_01_30.png'),
/// )
///
/// // Texto en Namtrik seleccionable
/// SelectableItem(
///   id: '1:30',
///   state: _getItemState('1:30'),
///   onTap: () => _handleTextSelected('1:30'),
///   child: Text(
///     'pik unan oraisku tsik yam',
///     style: TextStyle(color: Colors.white, fontSize: 16),
///   ),
/// )
/// ```
/// {@endtemplate}
class SelectableItem extends StatelessWidget {
  /// Identificador único para este item, usado para la lógica de emparejamiento.
  ///
  /// Este ID se utiliza para:
  /// - Identificar el elemento dentro de un conjunto de opciones
  /// - Verificar si dos elementos seleccionados (por ejemplo, un reloj y un texto)
  ///   deben emparejarse correctamente
  /// - Rastrear qué elementos ya han sido emparejados
  final String id;

  /// El widget hijo que se mostrará dentro del item (ej. una Imagen o Texto).
  ///
  /// Puede ser una imagen ([Image]) en el caso de relojes, o un texto ([Text]) 
  /// para las descripciones en Namtrik. El contenido visual depende
  /// enteramente de este widget hijo.
  final Widget child;

  /// El estado actual del item, determina su apariencia.
  ///
  /// Los estados posibles son:
  /// - [SelectionState.unselected]: Estado inicial, sin interacción
  /// - [SelectionState.selected]: El usuario ha seleccionado este elemento
  /// - [SelectionState.matched]: El elemento forma parte de un par correcto
  /// - [SelectionState.error]: El elemento formó un par incorrecto (transitorio)
  final SelectionState state;

  /// Indica si el [child] es una imagen.
  ///
  /// Este flag afecta:
  /// - El padding (mayor para texto, menor para imágenes)
  /// - Los colores de fondo base (transparente para imágenes, opaco para texto)
  /// - Las etiquetas de accesibilidad
  final bool isImage;

  /// La función callback que se ejecuta cuando el item es presionado.
  ///
  /// Típicamente se utiliza para:
  /// - Notificar a la pantalla que este elemento ha sido seleccionado
  /// - Cambiar el estado del elemento (seleccionado o no)
  /// - Verificar si forma un par correcto con otro elemento seleccionado previamente
  final VoidCallback onTap;

  /// Controla si el item puede ser presionado ([onTap] se ejecutará).
  ///
  /// Por defecto es `true`. Se establece en `false` cuando:
  /// - El elemento ya ha sido emparejado correctamente y debe quedar bloqueado
  /// - La interfaz está esperando la finalización de una animación
  /// - El juego ha llegado a su fin
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
  /// Este método:
  /// 1. Determina los colores, bordes y elevación según el [state] actual
  /// 2. Construye un [Semantics] para mejorar la accesibilidad
  /// 3. Utiliza [AnimatedContainer] para transiciones suaves entre estados
  /// 4. Aplica [InkWell] para la respuesta táctil, con [onTap] solo si está habilitado
  ///
  /// Las transiciones animadas tienen una duración de 300ms para proporcionar
  /// una experiencia fluida pero responsive.
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

  /// Convierte un [SelectionState] en una descripción textual accesible.
  ///
  /// Este método interno proporciona traducciones comprensibles
  /// de los estados para las etiquetas de accesibilidad, facilitando
  /// el uso de lectores de pantalla.
  ///
  /// [state] El estado a convertir en texto descriptivo.
  /// Retorna una cadena de texto que describe el estado de manera accesible.
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
