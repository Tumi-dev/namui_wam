import 'package:flutter/material.dart';

/// {@template help_banner_widget}
/// Widget reutilizable para mostrar banners de ayuda modernos y animados.
///
/// Este widget proporciona una interfaz consistente para mostrar instrucciones
/// y ayuda en diferentes pantallas de actividades. Características principales:
/// - Animaciones suaves de entrada y salida
/// - Diseño moderno con sombras y bordes redondeados
/// - Header personalizable con color específico por actividad
/// - Overlay semi-transparente que se puede cerrar tocando fuera del banner
/// - Respuesta inmediata a toques en botón X y fuera del banner
///
/// Ejemplo de uso:
/// ```dart
/// HelpBannerWidget(
///   isVisible: _isHelpVisible,
///   onClose: () => setState(() => _isHelpVisible = false),
///   headerColor: const Color(0xFF556B2F),
///   content: 'Instrucciones de la actividad...',
/// )
/// ```
/// {@endtemplate}
class HelpBannerWidget extends StatelessWidget {
  /// {@macro help_banner_widget}
  const HelpBannerWidget({
    super.key,
    required this.isVisible,
    required this.onClose,
    required this.headerColor,
    required this.content,
    this.title = 'Ayuda e Instrucciones',
  });

  /// Indica si el banner debe ser visible
  final bool isVisible;

  /// Callback que se ejecuta cuando el usuario cierra el banner
  final VoidCallback onClose;

  /// Color del header del banner (específico para cada actividad)
  final Color headerColor;

  /// Contenido de texto a mostrar en el banner
  final String content;

  /// Título del header del banner
  final String title;

  @override
  Widget build(BuildContext context) {
    if (!isVisible) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: AnimatedOpacity(
        opacity: isVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          color: Colors.black.withOpacity(0.5),
          child: GestureDetector(
            onTap: onClose, // Cierre directo al tocar fuera
            behavior: HitTestBehavior.opaque,
            child: Center(
              child: AnimatedScale(
                scale: isVisible ? 1.0 : 0.8,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutBack,
                child: GestureDetector(
                  onTap: () {}, // Previene cierre al tocar el contenido
                  child: _buildBannerContent(context),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  /// Construye el contenido principal del banner
  Widget _buildBannerContent(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.9,
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          _buildContent(),
        ],
      ),
    );
  }

  /// Construye el header del banner con el color específico de la actividad
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: headerColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.help_outline,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          GestureDetector(
            onTap: onClose, // Cierre directo
            child: Container(
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.close, 
                color: Colors.white, 
                size: 24
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye el contenido de texto del banner
  Widget _buildContent() {
    return Flexible(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Text(
          content,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}
