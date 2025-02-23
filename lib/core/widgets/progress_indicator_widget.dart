import 'package:flutter/material.dart';

class ProgressIndicatorWidget extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  final double height;
  final Color activeColor;
  final Color inactiveColor;

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
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: inactiveColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double progress = currentStep / totalSteps;
          return Stack(
            children: [
              // Barra de progreso
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: constraints.maxWidth * progress,
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
              // Indicadores de pasos
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  totalSteps,
                  (index) => Container(
                    width: height,
                    height: height,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index < currentStep
                          ? activeColor
                          : inactiveColor.withOpacity(0.5),
                    ),
                    child: index < currentStep
                        ? const Icon(
                            Icons.check,
                            size: 8,
                            color: Colors.white,
                          )
                        : null,
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
