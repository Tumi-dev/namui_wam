import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:namui_wam/core/themes/app_theme.dart';
import 'package:namui_wam/core/models/activities_state.dart';
import 'package:namui_wam/core/models/level_model.dart';
import 'package:namui_wam/features/activity1/screens/activity1_level_screen.dart';

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
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: AppTheme.mainGradient,
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: ListView.builder(
                  itemCount: activity1.availableLevels.length,
                  itemBuilder: (context, index) {
                    final level = activity1.availableLevels[index];
                    return _buildLevelCard(context, level);
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLevelCard(BuildContext context, LevelModel level) {
    final bool isLocked = level.isLocked;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Card(
        elevation: 4,
        color: isLocked ? Colors.grey[300] : Colors.green,
        child: InkWell(
          onTap: () => _onLevelSelected(context, level),
          child: Container(
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isLocked ? Colors.grey : Colors.green[700],
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
                      color: isLocked ? Colors.grey[600] : Colors.white,
                    ),
                  ),
                ),
                Icon(
                  isLocked ? Icons.lock : Icons.lock_open,
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