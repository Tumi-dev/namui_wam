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
  void _handleBackButton() {
    Navigator.of(context).pop();
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

  Widget buildLevelContent();
}