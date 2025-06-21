import 'package:flutter/material.dart';

/// {@template help_banner_mixin}
/// Mixin que proporciona funcionalidad común para gestionar banners de ayuda.
///
/// Este mixin simplifica la gestión del estado del banner de ayuda proporcionando:
/// - Variable de estado booleana para controlar la visibilidad
/// - Métodos estándar para mostrar y ocultar el banner
/// - Lógica reutilizable que puede ser incorporada en cualquier StatefulWidget
///
/// Para usar este mixin:
/// ```dart
/// class _MyActivityScreenState extends State<MyActivityScreen>
///     with HelpBannerMixin {
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       appBar: AppBar(
///         actions: [
///           IconButton(
///             icon: AppTheme.questionIcon,
///             onPressed: showHelpBanner,
///           ),
///         ],
///       ),
///       body: Stack(
///         children: [
///           // Contenido principal...
///           HelpBannerWidget(
///             isVisible: isHelpBannerVisible,
///             onClose: hideHelpBanner,
///             headerColor: myActivityColor,
///             content: myInstructions,
///           ),
///         ],
///       ),
///     );
///   }
/// }
/// ```
/// {@endtemplate}
mixin HelpBannerMixin<T extends StatefulWidget> on State<T> {
  /// Estado de visibilidad del banner de ayuda
  bool _isHelpBannerVisible = false;

  /// Getter para acceder al estado de visibilidad del banner
  bool get isHelpBannerVisible => _isHelpBannerVisible;

  /// Muestra el banner de ayuda con las instrucciones de la actividad
  void showHelpBanner() {
    setState(() {
      _isHelpBannerVisible = true;
    });
  }

  /// Oculta el banner de ayuda
  void hideHelpBanner() {
    setState(() {
      _isHelpBannerVisible = false;
    });
  }

  /// Alterna la visibilidad del banner de ayuda
  void toggleHelpBanner() {
    setState(() {
      _isHelpBannerVisible = !_isHelpBannerVisible;
    });
  }
}
