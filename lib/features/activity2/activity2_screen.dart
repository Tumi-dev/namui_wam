import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:namui_wam/core/themes/app_theme.dart';
import 'package:namui_wam/core/models/activity_levels.dart';
import 'package:namui_wam/core/models/level_model.dart';
import 'package:namui_wam/features/activity2/screens/activity2_level_screen.dart';

class Activity2Screen extends StatelessWidget {
  const Activity2Screen({super.key});

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
        builder: (context) => Activity2LevelScreen(level: level),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: AppTheme.homeIcon,
          onPressed: () => _navigateToHome(context),
        ),
        title: const Text(
          'Muntsikelan pөram kusrekun',
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
            child: Consumer<ActivityLevels>(
              builder: (context, activityLevels, child) {
                return ListView.builder(
                  itemCount: activityLevels.availableLevels.length,
                  itemBuilder: (context, index) {
                    final level = activityLevels.availableLevels[index];
                    return _buildLevelCard(context, level);
                  },
                );
              },
            ),
          ),
        ),
      ),
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
                    style: isLocked 
                      ? const TextStyle(color: Colors.grey, fontSize: 16)
                      : AppTheme.levelDescriptionStyle,
                  ),
                ),
                if (isLocked)
                  const Icon(
                    Icons.lock,
                    color: Colors.grey,
                  )
                else
                  AppTheme.levelArrowIcon,
              ],
            ),
          ),
        ),
      ),
    );
  }
}