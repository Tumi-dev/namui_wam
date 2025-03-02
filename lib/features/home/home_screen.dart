import 'package:flutter/material.dart';
import 'package:namui_wam/core/themes/app_theme.dart';
import 'package:namui_wam/features/activity1/activity1_screen.dart';
import 'package:namui_wam/features/activity2/activity2_screen.dart';
import 'package:namui_wam/features/activity3/activity3_screen.dart';
import 'package:namui_wam/features/activity4/activity4_screen.dart';
import 'package:namui_wam/features/activity5/activity5_screen.dart';
import 'package:namui_wam/features/activity6/activity6_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<String> activityDescriptions = [
    'Muntsik mɵik kɵtasha sɵl lau',
    'Muntsikelan pөram kusrekun',
    'Muntsielan namtrikmai yunɵmarɵpik',
    'Nɵsik utɵwan asam kusrekun',
    'Anwan ashipelɵ kɵkun',
    'Wammeran tulisha manchípik kui asamik pɵrik',
  ];

  void _navigateToActivity(BuildContext context, int activityNumber) {
    final Map<int, Widget> activities = {
      1: const Activity1Screen(),
      2: const Activity2Screen(),
      3: const Activity3Screen(),
      4: const Activity4Screen(),
      5: const Activity5Screen(),
      6: const Activity6Screen(),
    };

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => activities[activityNumber]!),
    );
  }

  // Es el override de la clase StatelessWidget para build
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final logoSize = screenSize.width * 0.2; // 20% del ancho de la pantalla de home

    // Es el cuerpo de la pantalla home
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.mainGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'Tsatsɵ Musik',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              // Logo adaptable a la pantalla home
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20), // 20% de la altura de la pantalla de home
                child: Image.asset(
                  'assets/images/1.logo-colibri.png',
                  height: logoSize,
                  width: logoSize,
                  fit: BoxFit.contain,
                ),
              ),
              // Lista de botones de actividades
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: 6,
                  itemBuilder: (context, index) {
                    return _buildActivityButton(context, index + 1);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Es un widget personalizado que representa un botón de actividad con un número y una descripción
  Widget _buildActivityButton(BuildContext context, int activityNumber) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        height: 70, // Altura reducida para un diseño más minimalista
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green, // Color de fondo verde oscuro con opacidad 0.1 (10%)
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          onPressed: () => _navigateToActivity(context, activityNumber),
          child: Row(
            children: [
              // Número estilizado con un fondo verde oscuro con opacidad 0.1 (10%)
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.green[700], // Fondo verde oscuro con opacidad 0.1 (10%) para resaltar el número de actividad
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$activityNumber',
                    style: AppTheme.levelNumberStyle,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Descripción de la actividad con un estilo y un número de actividad
              Expanded(
                child: Text(
                  activityDescriptions[activityNumber - 1],
                  style: AppTheme.buttonTextStyle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Espacio entre el número y la descripción
              const SizedBox(width: 8),
              // Flecha indicativa para indicar que es un botón de actividad
              AppTheme.levelArrowIcon,
            ],
          ),
        ),
      ),
    );
  }
}
