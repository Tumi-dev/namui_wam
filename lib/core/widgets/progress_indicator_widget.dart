import 'package:flutter/material.dart';

/// {@template progress_indicator_widget}
/// Un widget que muestra una barra de progreso con indicadores de pasos discretos.
///
/// Este indicador visual proporciona tanto una barra de progreso continua como
/// indicadores de pasos individuales, ofreciendo al usuario una clara representación
/// del avance en un proceso multi-etapa. Cada paso completado se marca con un
/// icono de verificación.
///
/// Características principales:
/// - Barra de progreso animada que muestra el avance general
/// - Indicadores circulares para cada paso del proceso
/// - Iconos de verificación en los pasos completados
/// - Colores personalizables para estados activos e inactivos
/// - Animación suave al cambiar el progreso
/// - Sombras para mejorar la apariencia visual
///
/// Ideal para:
/// - Seguimiento de progreso en tutoriales paso a paso
/// - Visualización de niveles completados en actividades educativas
/// - Indicación de avance en formularios o cuestionarios multi-página
/// - Cualquier interfaz que requiera mostrar progreso discreto
///
/// Ejemplo de uso básico:
/// ```dart
/// ProgressIndicatorWidget(
///   totalSteps: 5,
///   currentStep: 2, // El tercer paso (0-based index)
/// )
/// ```
///
/// Ejemplo con personalización:
/// ```dart
/// ProgressIndicatorWidget(
///   totalSteps: 4,
///   currentStep: 1,
///   height: 15.0,
///   activeColor: Colors.blue,
///   inactiveColor: Colors.grey.shade300,
/// )
/// ```
/// {@endtemplate}
class ProgressIndicatorWidget extends StatelessWidget {
  /// El número total de pasos o etapas en el progreso.
  ///
  /// Define cuántos indicadores circulares se mostrarán en la barra.
  /// Debe ser un valor positivo. Si es cero, la barra se mostrará vacía.
  final int totalSteps;

  /// El paso actual completado (basado en 0).
  ///
  /// Indica cuántos pasos se han completado, determinando:
  /// - El ancho de la parte activa de la barra de progreso
  /// - Qué indicadores circulares se marcan como completados
  ///
  /// Si es mayor que [totalSteps], se limitará automáticamente al valor máximo.
  /// Si es negativo, se ajustará a 0.
  final int currentStep;

  /// La altura de la barra de progreso y los indicadores de paso.
  ///
  /// Este valor define tanto la altura de la barra como el diámetro
  /// de los indicadores circulares. Un valor mayor hace que todos
  /// los elementos sean más grandes.
  final double height;

  /// El color utilizado para la parte activa de la barra y los pasos completados.
  ///
  /// Se aplica a:
  /// - La porción completada de la barra de progreso
  /// - Los círculos de los pasos completados
  /// - La sombra de la barra activa (con transparencia)
  final Color activeColor;

  /// El color utilizado para la parte inactiva de la barra y los pasos pendientes.
  ///
  /// Se aplica a:
  /// - El fondo completo de la barra de progreso (con transparencia)
  /// - Los círculos de los pasos pendientes (con transparencia)
  final Color inactiveColor;

  /// {@macro progress_indicator_widget}
  ///
  /// [totalSteps] El número total de pasos a mostrar.
  /// [currentStep] El índice (0-based) del paso actual completado.
  /// [height] La altura de la barra y diámetro de los indicadores (por defecto: 10.0).
  /// [activeColor] El color para elementos completados (por defecto: verde).
  /// [inactiveColor] El color para elementos pendientes (por defecto: gris).
  const ProgressIndicatorWidget({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    this.height = 10.0,
    this.activeColor = Colors.green,
    this.inactiveColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    // Asegura que currentStep no exceda totalSteps para el cálculo
    final safeCurrentStep = currentStep.clamp(0, totalSteps);

    return Container(
      height: height,
      decoration: BoxDecoration(
        // Fondo de la barra completa (inactivo)
        color: inactiveColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calcula la proporción del progreso
          final double progress = totalSteps > 0 ? safeCurrentStep / totalSteps : 0;
          return Stack(
            alignment: Alignment.centerLeft, // Alinea los elementos al inicio
            children: [
              // Barra de progreso animada (activa)
              AnimatedContainer(
                duration: const Duration(milliseconds: 500), // Duración de la animación
                width: constraints.maxWidth * progress, // Ancho basado en el progreso
                decoration: BoxDecoration(
                  color: activeColor,
                  borderRadius: BorderRadius.circular(height / 2),
                  boxShadow: [
                    BoxShadow(
                      color: activeColor.withOpacity(0.5),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              // Indicadores de pasos (círculos)
              if (totalSteps > 0)
                Padding(
                  // Añade padding para que los círculos no se peguen a los bordes
                  padding: EdgeInsets.symmetric(horizontal: height / 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      totalSteps,
                      (index) {
                        // Determina si el círculo está activo (antes o en el paso actual)
                        final isActive = index < safeCurrentStep;
                        return Container(
                          width: height, // Ancho del círculo igual a la altura
                          height: height, // Altura del círculo
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isActive
                                ? activeColor
                                : inactiveColor.withOpacity(0.5),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.5),
                              width: 1,
                            )
                          ),
                          // Muestra un check si el paso está completado
                          child: isActive
                              ? Icon(
                                  Icons.check,
                                  size: height * 0.6, // Tamaño del icono relativo a la altura
                                  color: Colors.white,
                                )
                              : null,
                        );
                      },
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
