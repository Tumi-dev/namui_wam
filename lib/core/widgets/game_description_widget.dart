import 'package:flutter/material.dart';
import 'package:namuiwam/core/themes/app_theme.dart';

class GameDescriptionWidget extends StatelessWidget {
  final String description;

  const GameDescriptionWidget({
    super.key,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: AppTheme.gameDescriptionDecoration,
        child: Text(
          description,
          style: AppTheme.gameDescriptionStyle,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}