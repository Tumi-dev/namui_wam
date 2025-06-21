import 'package:flutter/material.dart';

/// {@template app_animations}
/// Sistema centralizado de animaciones para la aplicación.
///
/// Proporciona constantes y configuraciones de animación reutilizables
/// para mantener consistencia visual en toda la aplicación.
/// {@endtemplate}
class AppAnimations {
  AppAnimations._(); // Constructor privado para evitar instanciación

  // ============================================================================
  // DURACIONES ESTÁNDAR
  // ============================================================================

  /// Duración rápida para micro-interacciones (botones, hover, etc.)
  static const Duration fast = Duration(milliseconds: 150);

  /// Duración normal para transiciones comunes (modals, drawers, etc.)
  static const Duration normal = Duration(milliseconds: 300);

  /// Duración lenta para transiciones complejas o de navegación
  static const Duration slow = Duration(milliseconds: 500);

  // ============================================================================
  // CURVAS ESTÁNDAR
  // ============================================================================

  /// Curva para entrada suave con rebote al final
  static const Curve easeOutBack = Curves.easeOutBack;

  /// Curva para transiciones suaves y naturales
  static const Curve easeInOut = Curves.easeInOut;

  /// Curva para transiciones cúbicas elegantes
  static const Curve easeInOutCubic = Curves.easeInOutCubic;

  /// Curva para apariciones rápidas
  static const Curve easeOut = Curves.easeOut;

  // ============================================================================
  // CONFIGURACIONES ESPECÍFICAS PARA HELP BANNERS
  // ============================================================================

  /// Configuración de animación para help banners
  static const BannerAnimationConfig helpBanner = BannerAnimationConfig(
    duration: normal,
    opacityDuration: normal,
    scaleDuration: normal,
    opacityCurve: easeInOut,
    scaleCurve: easeOutBack,
    scaleBegin: 0.8,
    scaleEnd: 1.0,
    opacityBegin: 0.0,
    opacityEnd: 1.0,
  );

  // ============================================================================
  // CONFIGURACIONES PARA OVERLAYS
  // ============================================================================

  /// Configuración de animación para overlays generales
  static const OverlayAnimationConfig overlay = OverlayAnimationConfig(
    backgroundOpacity: 0.5,
    fadeInDuration: normal,
    fadeOutDuration: fast,
    contentScaleBegin: 0.9,
    contentScaleEnd: 1.0,
    curve: easeInOut,
  );
}

/// {@template banner_animation_config}
/// Configuración específica para animaciones de banners.
/// {@endtemplate}
class BannerAnimationConfig {
  const BannerAnimationConfig({
    required this.duration,
    required this.opacityDuration,
    required this.scaleDuration,
    required this.opacityCurve,
    required this.scaleCurve,
    required this.scaleBegin,
    required this.scaleEnd,
    required this.opacityBegin,
    required this.opacityEnd,
  });

  /// Duración total de la animación
  final Duration duration;

  /// Duración específica para la animación de opacidad
  final Duration opacityDuration;

  /// Duración específica para la animación de escala
  final Duration scaleDuration;

  /// Curva para la animación de opacidad
  final Curve opacityCurve;

  /// Curva para la animación de escala
  final Curve scaleCurve;

  /// Valor inicial de escala
  final double scaleBegin;

  /// Valor final de escala
  final double scaleEnd;

  /// Valor inicial de opacidad
  final double opacityBegin;

  /// Valor final de opacidad
  final double opacityEnd;
}

/// {@template overlay_animation_config}
/// Configuración específica para animaciones de overlays.
/// {@endtemplate}
class OverlayAnimationConfig {
  const OverlayAnimationConfig({
    required this.backgroundOpacity,
    required this.fadeInDuration,
    required this.fadeOutDuration,
    required this.contentScaleBegin,
    required this.contentScaleEnd,
    required this.curve,
  });

  /// Opacidad del fondo semi-transparente
  final double backgroundOpacity;

  /// Duración de la animación de entrada
  final Duration fadeInDuration;

  /// Duración de la animación de salida
  final Duration fadeOutDuration;

  /// Escala inicial del contenido
  final double contentScaleBegin;

  /// Escala final del contenido
  final double contentScaleEnd;

  /// Curva de animación
  final Curve curve;
}
