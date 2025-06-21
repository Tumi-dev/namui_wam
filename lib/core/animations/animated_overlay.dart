import 'package:flutter/material.dart';
import 'package:namuiwam/core/animations/app_animations.dart';

/// {@template animated_overlay}
/// Widget reutilizable para crear overlays animados de forma consistente.
///
/// Este widget proporciona una base sólida para cualquier tipo de overlay
/// (help banners, modals, dialogs, etc.) con animaciones fluidas y
/// configuración centralizada.
///
/// Características:
/// - Animaciones de entrada y salida suaves
/// - Fondo semi-transparente configurable
/// - Cierre por tap externo configurable
/// - Configuración de animación personalizable
/// - Responsive design
///
/// Ejemplo de uso:
/// ```dart
/// AnimatedOverlay(
///   isVisible: isModalVisible,
///   onClose: () => setState(() => isModalVisible = false),
///   child: MyCustomModalContent(),
/// )
/// ```
/// {@endtemplate}
class AnimatedOverlay extends StatefulWidget {
  /// {@macro animated_overlay}
  const AnimatedOverlay({
    super.key,
    required this.isVisible,
    required this.onClose,
    required this.child,
    this.config = AppAnimations.overlay,
    this.closeOnTapOutside = true,
    this.alignment = Alignment.center,
  });

  /// Indica si el overlay debe ser visible
  final bool isVisible;

  /// Callback que se ejecuta cuando el usuario cierra el overlay
  final VoidCallback onClose;

  /// Widget hijo que se mostrará dentro del overlay
  final Widget child;

  /// Configuración de animación para el overlay
  final OverlayAnimationConfig config;

  /// Si se debe cerrar al tocar fuera del contenido
  final bool closeOnTapOutside;

  /// Alineación del contenido dentro del overlay
  final Alignment alignment;

  @override
  State<AnimatedOverlay> createState() => _AnimatedOverlayState();
}

class _AnimatedOverlayState extends State<AnimatedOverlay>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Controlador para la animación de fade del fondo
    _fadeController = AnimationController(
      duration: widget.config.fadeInDuration,
      reverseDuration: widget.config.fadeOutDuration,
      vsync: this,
    );

    // Controlador para la animación de escala del contenido
    _scaleController = AnimationController(
      duration: widget.config.fadeInDuration,
      reverseDuration: widget.config.fadeOutDuration,
      vsync: this,
    );

    // Animación de fade para el fondo
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: widget.config.backgroundOpacity,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: widget.config.curve,
    ));

    // Animación de escala para el contenido
    _scaleAnimation = Tween<double>(
      begin: widget.config.contentScaleBegin,
      end: widget.config.contentScaleEnd,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: widget.config.curve,
    ));
  }

  @override
  void didUpdateWidget(AnimatedOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _showOverlay();
      } else {
        _hideOverlay();
      }
    }
  }

  void _showOverlay() {
    _fadeController.forward();
    _scaleController.forward();
  }

  void _hideOverlay() {
    _fadeController.reverse();
    _scaleController.reverse();
  }

  void _handleTapOutside() {
    if (widget.closeOnTapOutside && widget.isVisible) {
      widget.onClose();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible &&
        _fadeController.status == AnimationStatus.dismissed) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: AnimatedBuilder(
        animation: Listenable.merge([_fadeController, _scaleController]),
        builder: (context, child) {
          return Container(
            color: Colors.black.withOpacity(_fadeAnimation.value),
            child: GestureDetector(
              onTap: _handleTapOutside,
              child: Align(
                alignment: widget.alignment,
                child: GestureDetector(
                  onTap:
                      () {}, // Previene que el tap en el contenido cierre el overlay
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: widget.child,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
