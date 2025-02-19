import 'package:flutter/material.dart';
import 'package:namui_wam/core/models/level_model.dart';
import 'package:namui_wam/core/templates/base_level_screen.dart';
import 'package:namui_wam/features/activity1/data/numbers_data.dart';

class Activity1LevelScreen extends BaseLevelScreen {
  const Activity1LevelScreen({
    super.key,
    required LevelModel level,
  }) : super(level: level, activityNumber: 1);

  @override
  State<Activity1LevelScreen> createState() => _Activity1LevelScreenState();
}

class _Activity1LevelScreenState extends BaseLevelScreenState<Activity1LevelScreen> with SingleTickerProviderStateMixin {
  late NumberWord currentNumber;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    currentNumber = NumbersData.getRandomNumber();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.elasticOut,
      ),
    );
    _scaleController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget buildLevelContent() {
    if (widget.level.id != 1) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [],
        ),
      );
    }

    return Center(
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.green[700]?.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Text(
            currentNumber.word,
            style: const TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  offset: Offset(2, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}