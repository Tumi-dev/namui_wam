import 'package:flutter/material.dart';
import 'package:namui_wam/core/models/level_model.dart';
import 'package:namui_wam/core/themes/app_theme.dart';
import 'package:namui_wam/core/constants/activity_descriptions.dart';
import 'package:namui_wam/core/widgets/game_description_widget.dart';

abstract class BaseLevelScreen extends StatefulWidget {
  final LevelModel level;
  final int activityNumber;

  const BaseLevelScreen({
    super.key,
    required this.level,
    required this.activityNumber,
  });
}

abstract class BaseLevelScreenState<T extends BaseLevelScreen> extends State<T> {
  int remainingAttempts = 2;
  int totalScore = 0;

  void _handleBackButton() {
    Navigator.of(context).pop();
  }

  Widget buildLevelContent();

  Widget buildScoreAndAttempts() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.green[700]?.withOpacity(0.9),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.refresh,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Intentos: $remainingAttempts',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Puntos: $totalScore',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _handleBackButton();
        return false;
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          leading: IconButton(
            icon: AppTheme.backArrowIcon,
            onPressed: _handleBackButton,
          ),
          title: Text(
            widget.level.description,
            style: AppTheme.levelTitleStyle,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.mainGradient,
          ),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                GameDescriptionWidget(
                  description: ActivityGameDescriptions.getDescriptionForActivity(widget.activityNumber),
                ),
                buildScoreAndAttempts(),
                Expanded(
                  child: buildLevelContent(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}