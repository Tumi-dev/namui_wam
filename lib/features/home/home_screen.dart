import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/themes/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<String> activityDescriptions = [
    'Muntsik møik køtasha søl lau',
    'Muntsikelan pөram kusrekun',
    'Muntsielan namtrikmai yunømarøpik',
    'Nøsik utøwan asam kusrekun',
    'Anwan ashipelø køkun',
    'Wammeran tulisha manchípik kui asamik pørik',
  ];

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final logoSize = screenSize.width * 0.3; // 30% del ancho de la pantalla

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
                  'Tsatsø Musik',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              // Logo adaptable
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Image.asset(
                  'assets/images/1.logo-colibri.png',
                  height: logoSize,
                  width: logoSize,
                  fit: BoxFit.contain,
                ),
              ),
              // Lista de botones
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

  Widget _buildActivityButton(BuildContext context, int activityNumber) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        height: 80,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            padding: EdgeInsets.zero,
          ),
          onPressed: () {
            // TODO: Implementar navegación a cada actividad
          },
          child: Row(
            children: [
              Container(
                width: 80,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.green[700],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                  ),
                ),
                child: Center(
                  child: Text(
                    '$activityNumber',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Actividad $activityNumber',
                        style: TextStyle(
                          fontSize: 18,
                          // color: Colors.blue[700],
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        activityDescriptions[activityNumber - 1],
                        style: TextStyle(
                          fontSize: 14,
                          // color: Colors.blue[700]?.withOpacity(0.7),
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                // color: Colors.blue[700],
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 16),
            ],
          ),
        ),
      ),
    );
  }
}
