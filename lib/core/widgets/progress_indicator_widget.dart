import 'package:flutter/material.dart';

/// Un widget que muestra una barra de progreso con indicadores de pasos discretos.
///
/// Ideal para visualizar el progreso en actividades o tutoriales con un número
/// definido de etapas.
class ProgressIndicatorWidget extends StatelessWidget {
  /// El número total de pasos o etapas en el progreso.
  final int totalSteps;

  /// El paso actual completado (basado en 0, pero la lógica interna lo ajusta).
  final int currentStep;

  /// La altura de la barra de progreso y los indicadores de paso.
  final double height;

  /// El color utilizado para la parte activa de la barra y los pasos completados.
  final Color activeColor;

  /// El color utilizado para la parte inactiva de la barra y los pasos pendientes.
  final Color inactiveColor;

  /// Crea una instancia de [ProgressIndicatorWidget].
  ///
  /// Requiere [totalSteps] y [currentStep].
  /// Los demás parámetros tienen valores predeterminados.
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
