import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:namuiwam/core/themes/app_theme.dart';
import 'package:namuiwam/core/models/activities_state.dart';
import 'package:namuiwam/core/models/level_model.dart';
import 'package:namuiwam/features/activity1/screens/activity1_level_screen.dart';

class Activity1Screen extends StatelessWidget {
  const Activity1Screen({super.key});

  void _navigateToHome(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _onLevelSelected(BuildContext context, LevelModel level) {
    if (level.isLocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este nivel está bloqueado')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Activity1LevelScreen(level: level),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ActivitiesState>(
      builder: (context, activitiesState, child) {
        final activity1 = activitiesState.getActivity(1);
        if (activity1 == null) return const SizedBox.shrink();

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            leading: IconButton(
              icon: AppTheme.homeIcon,
              onPressed: () => _navigateToHome(context),
            ),
            title: const Text(
              'Muntsik mɵik kɵtasha sɵl lau',
              style: AppTheme.activityTitleStyle,
            ),
            backgroundColor: Colors.transparent, // Color de fondo transparente para el app bar
            elevation: 0,
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: AppTheme.mainGradient,
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
                    final maxButtonWidth = isLandscape ? 450.0 : constraints.maxWidth;
                    
                    return ListView.builder(
                      itemCount: activity1.availableLevels.length,
                      itemBuilder: (context, index) {
                        final level = activity1.availableLevels[index];
                        return Center(
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: maxButtonWidth,
                            ),
                            width: double.infinity,
                            child: _buildLevelCard(context, level),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Construye un widget de tarjeta para un nivel de actividad
  Widget _buildLevelCard(BuildContext context, LevelModel level) {
    final bool isLocked = level.isLocked;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Card(
        elevation: 4,
        // Cambia el color de la tarjeta si el nivel está bloqueado o no
        color: isLocked ? Colors.grey[300] : Color(0xFF556B2F),
        child: InkWell(
          onTap: () => _onLevelSelected(context, level),
          child: Container(
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    // Cambia el color del círculo si el nivel está bloqueado o no
                    color: isLocked ? Colors.grey : Color(0xFF556B2F),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${level.id}',
                      style: AppTheme.levelNumberStyle,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    level.description,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      // Cambia el color del texto si el nivel está bloqueado o no
                      color: isLocked ? Colors.grey[600] : Colors.white,
                    ),
                  ),
                ),
                Icon(
                  isLocked ? Icons.lock : Icons.lock_open,
                  // Cambia el color del icono si el nivel está bloqueado o no
                  color: isLocked ? Colors.grey[600] : Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}