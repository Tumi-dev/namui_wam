import 'package:flutter/material.dart';
import 'package:namui_wam/core/models/level_model.dart';
import 'package:namui_wam/core/templates/base_level_screen.dart';

class Activity2LevelScreen extends BaseLevelScreen {
  const Activity2LevelScreen({
    super.key,
    required LevelModel level,
  }) : super(level: level, activityNumber: 2);

  @override
  State<Activity2LevelScreen> createState() => _Activity2LevelScreenState();
}

class _Activity2LevelScreenState extends BaseLevelScreenState<Activity2LevelScreen> {
  @override
  Widget buildLevelContent() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [],
      ),
    );
  }
}